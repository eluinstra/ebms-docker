#!/usr/bin/env bash
#===============================================================================
# smoke-test.sh — two-adapter EbMS smoke test for the ebms-docker images
#
# Builds the docker images from images/ for the host architecture and then
# verifies them with the examples/demo two-adapter stack (digipoort + overheid,
# both running the locally built eluinstra/ebms-adapter-test image):
#
#  Adapter 1 ("digipoort", container)
#    image    : eluinstra/ebms-adapter-test:${EBMS_VERSION} (built locally)
#    REST API : http://localhost:8080/service/rest/v19
#    EbMS     : https://digipoort:8888/ebms (compose network)
#
#  Adapter 2 ("overheid", container)
#    image    : eluinstra/ebms-adapter-test:${EBMS_VERSION} (built locally)
#    REST API : http://localhost:8088/service/rest/v19
#    EbMS     : https://overheid:8888/ebms (compose network)
#
#  Test steps
#    1. build the images (images/build.sh; skip with --skip-build)
#    2. docker compose up (examples/demo)
#    3. health checks (container health) + init containers finished
#    4. load the local examples/cpa.xml on both adapters; getCPAIds
#    5. ping adapter 1 -> adapter 2 and adapter 2 -> adapter 1
#    6. sendMessage (REST + attachment) adapter 1 -> adapter 2
#    7. sendMessage (REST + attachment) adapter 2 -> adapter 1
#    8. sendMessageMTOM (multipart) adapter 1 -> adapter 2
#    9. each sent message is picked up on the other adapter via
#       /ebms/messages/unprocessed, fetched (processed) via
#       /ebms/messages/{id} and the payload is verified
#
#  Usage
#    ./smoke-test.sh [--skip-build] [--keep] [--help]
#      --skip-build  do not rebuild the images (use what is already local)
#      --keep        leave the demo stack running after the test
#
#  Environment
#    SMOKE_LOG_DIR  optional directory; when the test fails, the adapter
#                   container logs are copied there
#
#  Requirements: Docker (daemon + compose + buildx), curl, jq
#===============================================================================

set -u

#--- configuration -------------------------------------------------------------
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE_DIR="$REPO_ROOT/examples/demo"
COMPOSE_FILE="$COMPOSE_DIR/docker-compose.yml"
COMPOSE_PROJECT="ebms-docker-smoke"
CPA_FILE="$REPO_ROOT/examples/cpa.xml"
# the version the images are built with (images/env.sh)
. "$REPO_ROOT/images/env.sh"

REST1="http://localhost:8080/service/rest/v19"   # adapter 1 (digipoort)
REST2="http://localhost:8088/service/rest/v19"   # adapter 2 (overheid)

CPA_ID="cpaStubEBF.rm.https.signed"
DIGIPOORT_PARTY='urn:osb:oin:00000000000000000000'
DIGIPOORT_ROLE="DIGIPOORT"
OVERHEID_PARTY='urn:osb:oin:00000000000000000001'
OVERHEID_ROLE="OVERHEID"
AFLEVEREN_SERVICE='urn:osb:services:osb:afleveren:1.1$1.0'
AANLEVEREN_SERVICE='urn:osb:services:osb:aanleveren:1.1$1.0'
TEST_PAYLOAD_B64="U2FtcGxlIG1lc3NhZ2Uu"            # base64("Sample message.")

# ports that must be free before starting
NEEDED_PORTS="8080 8088"
HOST_ARCH="$(dpkg --print-architecture)"
# build.sh tags the local images per-arch (e.g. 2.20.9-amd64); the un-suffixed
# tag only exists in Docker Hub after manifest.sh has published the manifest
LOCAL_IMAGE_TAG="${EBMS_VERSION}-${HOST_ARCH}"

SKIP_BUILD=0
KEEP=0
for arg in "$@"; do
  case "$arg" in
    --skip-build) SKIP_BUILD=1 ;;
    --keep)       KEEP=1 ;;
    --help|-h)    grep '^#' "$0" | sed 's/^#//;s/^ //' ; exit 0 ;;
    *) echo "Unknown option: $arg (use --help)" >&2; exit 2 ;;
  esac
done

PASS=0
FAIL=0
DC=()

#--- helpers -------------------------------------------------------------------
info()  { echo -e "\033[1;34m==> $*\033[0m"; }
ok()    { echo -e "  \033[1;32m[PASS]\033[0m $1"; PASS=$((PASS+1)); }
bad()   { echo -e "  \033[1;31m[FAIL]\033[0m $1"; FAIL=$((FAIL+1)); }

die() {
  echo -e "\033[1;31mERROR: $*\033[0m" >&2
  exit 1
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "required command '$1' not found"
}

port_in_use() {
  # no bare "exec" redirects here: they persist in the main shell and would
  # silently move its stderr to /dev/null for the rest of the script
  local rc=1
  (exec 3<>/dev/tcp/127.0.0.1/"$1") 2>/dev/null && rc=0
  return $rc
}

# container_id <service> -> id of the compose container (also when exited)
container_id() {
  "${DC[@]}" ps -q "$1" 2>/dev/null | head -1
}

# wait_for <description> <timeout-seconds> <command...>
wait_for() {
  local desc="$1" timeout="$2"; shift 2
  local deadline=$(( $(date +%s) + timeout ))
  while true; do
    if "$@" >/dev/null 2>&1; then
      return 0
    fi
    if (( $(date +%s) >= deadline )); then
      echo "  (timed out after ${timeout}s waiting: $desc)" >&2
      return 1
    fi
    sleep 2
  done
}

# http <method> <url> [extra curl args...] -> sets HTTP_CODE and HTTP_BODY
http() {
  local method="$1" url="$2"; shift 2
  local body_file; body_file=$(mktemp)
  HTTP_CODE=$(curl -sS -o "$body_file" -w '%{http_code}' -X "$method" "$@" "$url" 2>&1) || HTTP_CODE=000
  HTTP_BODY=$(cat "$body_file")
  rm -f "$body_file"
}

# expect_http <description> <method> <url> [curl args...]  (asserts 2xx)
expect_http() {
  local desc="$1" method="$2" url="$3"; shift 3
  http "$method" "$url" "$@"
  case "$HTTP_CODE" in
    2*) ok "$desc (HTTP $HTTP_CODE)" ;;
    *)  bad "$desc (HTTP $HTTP_CODE) body: ${HTTP_BODY:0:300}";;
  esac
}

# container_healthy <service>
container_healthy() {
  local id
  id=$(container_id "$1")
  [[ -n "$id" ]] && [[ "$(docker inspect --format '{{.State.Health.Status}}' "$id" 2>/dev/null)" == "healthy" ]]
}

# init_done <service> (one-shot containers must have exited 0)
init_done() {
  local id
  id=$(container_id "$1")
  [[ -n "$id" ]] && [[ "$(docker inspect --format '{{.State.ExitCode}}' "$id" 2>/dev/null)" == "0" ]]
}

# send_message <adapter:1|2> <json-properties-file> -> sets SENT_MESSAGE_ID
send_message() {
  local adapter="$1" props_file="$2" rest
  if [[ "$adapter" == "1" ]]; then rest="$REST1"; else rest="$REST2"; fi
  http POST "$rest/ebms/messages" \
    -H 'Content-Type: application/json' --data-binary "@$props_file"
  case "$HTTP_CODE" in
    2*) SENT_MESSAGE_ID=$(echo "$HTTP_BODY" | tr -d '[:space:]');;
    *)  SENT_MESSAGE_ID="";;
  esac
}

# wait_received <adapter:1|2> <message-id> -> asserts unprocessed on that adapter
wait_received() {
  local adapter="$1" msg_id="$2" rest
  [[ -z "$msg_id" ]] && return 1
  if [[ "$adapter" == "1" ]]; then rest="$REST1"; else rest="$REST2"; fi
  wait_for "message $msg_id to arrive on adapter $adapter" 120 sh -c \
    "curl -fsS '$rest/ebms/messages/unprocessed?messageId=$msg_id' | grep -q '$msg_id'" \
    || return 1
}

# fetch_and_verify <adapter:1|2> <message-id> <expected-to-party-id> [mtom]
fetch_and_verify() {
  local adapter="$1" msg_id="$2" expected_to="$3" mtom="${4:-}" rest
  if [[ "$adapter" == "1" ]]; then rest="$REST1"; else rest="$REST2"; fi
  local path="messages/$msg_id?process=true"
  [[ -n "$mtom" ]] && path="messages/mtom/$msg_id?process=true"
  http GET "$rest/ebms/$path"
  case "$HTTP_CODE" in
    2*) : ;;
    *)  bad "getMessage adapter $adapter for $msg_id (HTTP $HTTP_CODE) body: ${HTTP_BODY:0:300}"; return 1;;
  esac
  if [[ -n "$mtom" ]]; then
    if echo "$HTTP_BODY" | grep -q "$TEST_PAYLOAD_B64"; then
      ok "received MTOM message $msg_id on adapter $adapter (payload verified)"
    else
      bad "received MTOM message $msg_id on adapter $adapter but payload missing (body: ${HTTP_BODY:0:300})"
    fi
    return 0
  fi
  local content to_party
  content=$(echo "$HTTP_BODY" | jq -r '.dataSources[0].content' 2>/dev/null)
  to_party=$(echo "$HTTP_BODY" | jq -r '.properties.toParty.partyId' 2>/dev/null)
  [[ "$content" == "$TEST_PAYLOAD_B64" ]] \
    && ok "received message $msg_id on adapter $adapter (payload verified)" \
    || bad "message $msg_id payload mismatch (content: ${content:0:60})"
  [[ "$to_party" == "$expected_to" ]] \
    && ok "message $msg_id addressed to $to_party" \
    || bad "message $msg_id unexpected toParty (got: $to_party, want: $expected_to)"
}

save_logs() {
  local svc id
  for svc in digipoort overheid; do
    id=$(container_id "$svc")
    if [[ -n "$id" ]]; then
      echo "  docker logs: ${svc} (last 20 lines)"
      docker logs --tail 20 "$id" 2>&1 | sed 's/^/    /'
    fi
  done
  if [[ -n "${SMOKE_LOG_DIR:-}" ]]; then
    mkdir -p "$SMOKE_LOG_DIR" 2>/dev/null || true
    for svc in digipoort overheid; do
      id=$(container_id "$svc")
      [[ -n "$id" ]] && docker logs "$id" > "$SMOKE_LOG_DIR/${svc}-docker.log" 2>&1 || true
    done
    echo "smoke test logs saved to $SMOKE_LOG_DIR"
  fi
}

cleanup() {
  if [[ -n "${DC[@]:-}" ]]; then
    "${DC[@]}" down --remove-orphans >/dev/null 2>&1 || true
  fi
}
trap 'rc=$?; if (( rc != 0 )); then
  echo; echo "--- adapter logs (on failure) ---"; save_logs
fi; if [[ $KEEP -eq 0 ]]; then cleanup; fi' EXIT

#--- pre-flight -----------------------------------------------------------------
info "Pre-flight checks"
for c in docker curl jq; do require_cmd "$c"; done
docker info >/dev/null 2>&1 || die "docker daemon is not reachable"
if docker compose version >/dev/null 2>&1; then
  DC=(docker compose -p "$COMPOSE_PROJECT" -f "$COMPOSE_FILE")
else
  die "docker compose (v2) is required"
fi
for p in $NEEDED_PORTS; do
  port_in_use "$p" && die "port $p is already in use; stop the other process and retry"
done
[[ -f "$COMPOSE_FILE" ]] || die "compose file not found: $COMPOSE_FILE"
[[ -f "$CPA_FILE" ]] || die "CPA file not found: $CPA_FILE"
[[ -x "$REPO_ROOT/images/build.sh" ]] || die "images/build.sh not found or not executable"
info "Testing image eluinstra/ebms-adapter-test:${LOCAL_IMAGE_TAG} (images/env.sh, host arch ${HOST_ARCH})"

#--- build the images -------------------------------------------------------------
if [[ $SKIP_BUILD -eq 0 ]]; then
  info "Building docker images for the host architecture (images/build.sh)..."
  "$REPO_ROOT/images/build.sh" || die "image build failed"
else
  info "Skipping image build (--skip-build)"
fi
docker image inspect "eluinstra/ebms-adapter-test:${LOCAL_IMAGE_TAG}" >/dev/null 2>&1 \
  || die "image eluinstra/ebms-adapter-test:${LOCAL_IMAGE_TAG} not found locally (re-run without --skip-build)"
ok "image eluinstra/ebms-adapter-test:${LOCAL_IMAGE_TAG} is available locally"

#--- start the demo stack ------------------------------------------------------------
# the compose files use eluinstra/ebms-adapter-*:${EBMS_VERSION}; the shell env
# overrides examples/demo/.env, so the stack runs the locally built per-arch image
info "Starting the demo stack (docker compose: $COMPOSE_FILE)"
EBMS_VERSION="$LOCAL_IMAGE_TAG" "${DC[@]}" up -d || die "docker compose up failed"

info "Waiting for both adapters to become healthy..."
wait_for "digipoort healthy" 240 container_healthy digipoort \
  || die "digipoort did not become healthy (see 'docker compose logs digipoort')"
wait_for "overheid healthy" 240 container_healthy overheid \
  || die "overheid did not become healthy (see 'docker compose logs overheid')"
ok "adapter 1 (digipoort) is up on http://localhost:8080 + https://digipoort:8888/ebms"
ok "adapter 2 (overheid) is up on http://localhost:8088 + https://overheid:8888/ebms"

info "Waiting for the init containers (CPA load) to finish..."
wait_for "digipoort_init exited 0" 180 init_done digipoort_init \
  || die "digipoort_init did not finish successfully (see 'docker compose logs digipoort_init')"
wait_for "overheid_init exited 0" 180 init_done overheid_init \
  || die "overheid_init did not finish successfully (see 'docker compose logs overheid_init')"
ok "init containers finished"

#--- CPA setup (deterministic: use the local cpa.xml, not the remote copy) -----------
info "Loading the local CPA (examples/cpa.xml) into both adapters"
expect_http "insertCPA adapter 1" POST "$REST1/cpas?overwrite=true" \
  -H 'Content-Type: text/plain' --data-binary "@$CPA_FILE"
expect_http "insertCPA adapter 2" POST "$REST2/cpas?overwrite=true" \
  -H 'Content-Type: text/plain' --data-binary "@$CPA_FILE"

http GET "$REST1/cpas"
echo "$HTTP_BODY" | jq -e --arg id "$CPA_ID" 'index($id)' >/dev/null \
  && ok "getCPAIds adapter 1 contains $CPA_ID" \
  || bad "getCPAIds adapter 1 missing $CPA_ID (body: $HTTP_BODY)"

http GET "$REST2/cpas"
echo "$HTTP_BODY" | jq -e --arg id "$CPA_ID" 'index($id)' >/dev/null \
  && ok "getCPAIds adapter 2 contains $CPA_ID" \
  || bad "getCPAIds adapter 2 missing $CPA_ID (body: $HTTP_BODY)"

#--- ping (both directions) ------------------------------------------------------------
info "Ping tests"
expect_http "ping adapter 1 -> adapter 2" POST \
  "$REST1/ebms/ping/$CPA_ID/from/$DIGIPOORT_PARTY/to/$OVERHEID_PARTY"
expect_http "ping adapter 2 -> adapter 1" POST \
  "$REST2/ebms/ping/$CPA_ID/from/$OVERHEID_PARTY/to/$DIGIPOORT_PARTY"

#--- sendMessage adapter 1 -> adapter 2 (REST) ------------------------------------------
info "sendMessage adapter 1 -> adapter 2 (afleveren, REST + attachment)"
WORK_DIR=$(mktemp -d "${TMPDIR:-/tmp}/ebms-docker-smoke.XXXXXX")
cat > "$WORK_DIR/props12.json" <<'EOF'
{
  "properties": {
    "cpaId": "cpaStubEBF.rm.https.signed",
    "fromPartyId": "urn:osb:oin:00000000000000000000",
    "fromRole": "DIGIPOORT",
    "toPartyId": "urn:osb:oin:00000000000000000001",
    "toRole": "OVERHEID",
    "service": "urn:osb:services:osb:afleveren:1.1$1.0",
    "action": "afleveren"
  },
  "dataSources": [{
    "name": "test.txt",
    "contentType": "text/plain",
    "content": "U2FtcGxlIG1lc3NhZ2Uu"
  }]
}
EOF
send_message 1 "$WORK_DIR/props12.json"
if [[ -n "$SENT_MESSAGE_ID" ]]; then
  ok "sendMessage accepted (messageId: $SENT_MESSAGE_ID)"
  if wait_received 2 "$SENT_MESSAGE_ID"; then
    ok "message $SENT_MESSAGE_ID picked up by adapter 2 (unprocessed)"
    fetch_and_verify 2 "$SENT_MESSAGE_ID" "$OVERHEID_PARTY"
  else
    bad "message $SENT_MESSAGE_ID never arrived on adapter 2"
  fi
else
  bad "sendMessage rejected (HTTP $HTTP_CODE) body: ${HTTP_BODY:0:300}"
fi

#--- sendMessage adapter 2 -> adapter 1 (REST) ------------------------------------------
info "sendMessage adapter 2 -> adapter 1 (aanleveren, REST + attachment)"
cat > "$WORK_DIR/props21.json" <<'EOF'
{
  "properties": {
    "cpaId": "cpaStubEBF.rm.https.signed",
    "fromPartyId": "urn:osb:oin:00000000000000000001",
    "fromRole": "OVERHEID",
    "toPartyId": "urn:osb:oin:00000000000000000000",
    "toRole": "DIGIPOORT",
    "service": "urn:osb:services:osb:aanleveren:1.1$1.0",
    "action": "aanleveren"
  },
  "dataSources": [{
    "name": "test.txt",
    "contentType": "text/plain",
    "content": "U2FtcGxlIG1lc3NhZ2Uu"
  }]
}
EOF
send_message 2 "$WORK_DIR/props21.json"
if [[ -n "$SENT_MESSAGE_ID" ]]; then
  ok "sendMessage accepted (messageId: $SENT_MESSAGE_ID)"
  if wait_received 1 "$SENT_MESSAGE_ID"; then
    ok "message $SENT_MESSAGE_ID picked up by adapter 1 (unprocessed)"
    fetch_and_verify 1 "$SENT_MESSAGE_ID" "$DIGIPOORT_PARTY"
  else
    bad "message $SENT_MESSAGE_ID never arrived on adapter 1"
  fi
else
  bad "sendMessage rejected (HTTP $HTTP_CODE) body: ${HTTP_BODY:0:300}"
fi

#--- sendMessageMTOM adapter 1 -> adapter 2 -----------------------------------------------
info "sendMessageMTOM adapter 1 -> adapter 2"
cat > "$WORK_DIR/props12-mtom.json" <<'EOF'
{
  "cpaId": "cpaStubEBF.rm.https.signed",
  "fromPartyId": "urn:osb:oin:00000000000000000000",
  "fromRole": "DIGIPOORT",
  "toPartyId": "urn:osb:oin:00000000000000000001",
  "toRole": "OVERHEID",
  "service": "urn:osb:services:osb:afleveren:1.1$1.0",
  "action": "afleveren"
}
EOF
printf '%s' "$TEST_PAYLOAD_B64" > "$WORK_DIR/attachment.b64"
http POST "$REST1/ebms/messages/mtom" \
  -F "requestProperties=@$WORK_DIR/props12-mtom.json;type=application/json" \
  -F "attachment=@$WORK_DIR/attachment.b64;filename=test.txt;type=text/plain;content-transfer-encoding=base64"
case "$HTTP_CODE" in
  2*) SENT_MESSAGE_ID=$(echo "$HTTP_BODY" | tr -d '[:space:]')
      ok "sendMessageMTOM accepted (messageId: $SENT_MESSAGE_ID)" ;;
  *)  SENT_MESSAGE_ID=""; bad "sendMessageMTOM rejected (HTTP $HTTP_CODE) body: ${HTTP_BODY:0:300}" ;;
esac
if [[ -n "$SENT_MESSAGE_ID" ]] && wait_received 2 "$SENT_MESSAGE_ID"; then
  ok "MTOM message $SENT_MESSAGE_ID picked up by adapter 2 (unprocessed)"
  fetch_and_verify 2 "$SENT_MESSAGE_ID" "$OVERHEID_PARTY" mtom
else
  bad "MTOM message $SENT_MESSAGE_ID never arrived on adapter 2"
fi

#--- summary ---------------------------------------------------------------------------
rm -rf "$WORK_DIR"
echo
echo "============================================================"
echo " Smoke test finished: $PASS passed, $FAIL failed"
echo "============================================================"
if [[ $KEEP -eq 1 ]]; then
  echo " --keep: leaving the demo stack running"
  echo "   adapter 1 REST: $REST1"
  echo "   adapter 2 REST: $REST2"
  echo "   stop with:     docker compose -p $COMPOSE_PROJECT -f $COMPOSE_FILE down --remove-orphans"
else
  info "Tearing down the demo stack"
fi
exit $(( FAIL > 0 ? 1 : 0 ))
