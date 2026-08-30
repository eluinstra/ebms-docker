#!/bin/sh
#===============================================================================
# bump.sh — bump the EbMS version in the docker files
#
# Updates all version-pinned files in this repo to a new release version:
#   images/env.sh               EBMS_MAJOR_VERSION + EBMS_VERSION
#   examples/demo/.env          EBMS_VERSION
#   examples/demo-pg/.env       EBMS_VERSION
#   examples/demo-hs/.env       EBMS_VERSION
#
# The Dockerfiles download the release JARs from the eluinstra/ebms-admin
# GitHub release at build time, so by default the script checks that the
# release exists before writing anything.
#
# Usage
#   ./bump.sh               bump to the latest eluinstra/ebms-admin release
#   ./bump.sh 2.20.9        bump to an explicit version
#   ./bump.sh 2.20.9 --check
#                           report drift only, write nothing
#                           (exit 1 when drift is found, 0 when in sync)
#   ./bump.sh 2.20.9 --commit
#                           also commit in this repo (no push)
#   --force                 skip the GitHub release preflight check
#
# After pushing this repo, the parent repo must re-pin the submodule
# (ignore=all in the parent's .gitmodules requires -f):
#   git add -f ebms-docker && git commit -m "chore: bump ebms-docker pin" \
#     && git push origin HEAD
#
# Requirements: curl, sed, git; jq only when resolving the latest release
#===============================================================================

set -eu

BASE_DIR="$(cd "$(dirname "$0")" && pwd)"

VERSION=""
CHECK=0
COMMIT=0
FORCE=0
for arg in "$@"; do
  case "$arg" in
    --check)   CHECK=1 ;;
    --commit)  COMMIT=1 ;;
    --force)   FORCE=1 ;;
    --help|-h) grep '^#' "$0" | sed 's/^#//;s/^ //' ; exit 0 ;;
    -*) echo "Unknown option: $arg (use --help)" >&2; exit 2 ;;
    *)
      [ -z "$VERSION" ] || { echo "Unexpected argument: $arg (use --help)" >&2; exit 2; }
      VERSION="$arg"
      ;;
  esac
done

die() { echo "ERROR: $*" >&2; exit 1; }

# "file:key" pairs of every version-pinned file in this repo
VERSION_FILES="
images/env.sh:EBMS_MAJOR_VERSION
images/env.sh:EBMS_VERSION
examples/demo/.env:EBMS_VERSION
examples/demo-pg/.env:EBMS_VERSION
examples/demo-hs/.env:EBMS_VERSION
"

# get_rhs <file> <key> -> right-hand side of the first "<key>=" line
# (with optional "export " prefix); empty when the key is absent
get_rhs() {
  sed -n "s/^\(export \)\?$2=//p" "$1" | head -n 1
}

# effective <file> <key> -> current effective value of the key
# (expands the derived form ${EBMS_MAJOR_VERSION}.<patch> in env.sh)
effective() {
  file="$BASE_DIR/$1"; key="$2"
  rhs=$(get_rhs "$file" "$key")
  [ -n "$rhs" ] || return 1
  case "$key" in
    EBMS_VERSION)
      # derived form: ${EBMS_MAJOR_VERSION}.<patch> -> expand with the file's major
      case "$rhs" in
        '${EBMS_MAJOR_VERSION}.'*)
          major=$(get_rhs "$file" "EBMS_MAJOR_VERSION")
          rhs="${major}.${rhs#'${EBMS_MAJOR_VERSION}.'}"
          ;;
      esac
      ;;
  esac
  printf '%s\n' "$rhs"
}

#--- resolve the target version --------------------------------------------------
if [ -z "$VERSION" ]; then
  tag=$(curl -sf "https://api.github.com/repos/eluinstra/ebms-admin/releases/latest" \
    | jq -r .tag_name) || die "could not fetch the latest eluinstra/ebms-admin release"
  VERSION="${tag#ebms-admin-}"
  echo "latest eluinstra/ebms-admin release: ${VERSION}"
fi

printf '%s' "$VERSION" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+$' \
  || die "version must be MAJOR.MINOR.PATCH, got: '$VERSION'"
MAJOR="${VERSION%.*}"

current_major=$(effective images/env.sh EBMS_MAJOR_VERSION || true)
if [ -n "$current_major" ] && [ "$current_major" != "$MAJOR" ]; then
  echo "WARNING: major version changes from ${current_major} to ${MAJOR} (new tag scheme)"
fi

#--- preflight: the release must exist (the Dockerfiles pull the JARs from it) ---
if [ "$FORCE" -eq 0 ]; then
  url="https://github.com/eluinstra/ebms-admin/releases/download/ebms-admin-${VERSION}/ebms-admin-${VERSION}.jar"
  code=$(curl -sL -r 0-0 -o /dev/null -w '%{http_code}' "$url" 2>/dev/null) || code=000
  if [ "$code" != "200" ] && [ "$code" != "206" ]; then
    die "GitHub release ebms-admin-${VERSION} not found (HTTP ${code}). Run the Release workflow first, or use --force to skip this check"
  fi
fi

#--- drift detection ----------------------------------------------------------------
changed=0
for line in $VERSION_FILES; do
  file="${line%%:*}"
  key="${line#*:}"
  case "$key" in
    EBMS_MAJOR_VERSION) target="$MAJOR" ;;
    *)                  target="$VERSION" ;;
  esac
  cur=$(effective "$file" "$key" || true)
  if [ "$cur" != "$target" ]; then
    printf '  %-24s %-18s %s -> %s\n' "$file" "$key" "${cur:-<missing>}" "$target"
    changed=1
  fi
done

if [ "$CHECK" -eq 1 ]; then
  if [ "$changed" -eq 1 ]; then
    echo "drift found (run ./bump.sh ${VERSION} to fix)"
    exit 1
  fi
  echo "all version files are at ${VERSION}"
  exit 0
fi

if [ "$changed" -eq 0 ]; then
  echo "all version files are already at ${VERSION}; nothing to do"
  exit 0
fi

#--- apply ---------------------------------------------------------------------------
for line in $VERSION_FILES; do
  file="${line%%:*}"
  key="${line#*:}"
  case "$key" in
    EBMS_MAJOR_VERSION) target="$MAJOR" ;;
    *)                  target="$VERSION" ;;
  esac
  [ -n "$(get_rhs "$BASE_DIR/$file" "$key")" ] || die "key ${key} not found in ${file}"
  case "$file" in
    images/env.sh)
      sed -i "s|^export ${key}=.*|export ${key}=${target}|" "$BASE_DIR/$file" ;;
    *)
      sed -i "s|^${key}=.*|${key}=${target}|" "$BASE_DIR/$file" ;;
  esac
done
echo "bumped to ${VERSION}:"
printf '  %s\n' images/env.sh examples/demo/.env examples/demo-pg/.env examples/demo-hs/.env

#--- optional commit ---------------------------------------------------------------------
if [ "$COMMIT" -eq 1 ]; then
  git -C "$BASE_DIR" add images/env.sh examples/demo/.env examples/demo-pg/.env examples/demo-hs/.env
  if git -C "$BASE_DIR" diff --cached --quiet; then
    echo "no changes to commit"
  else
    git -C "$BASE_DIR" commit -m "bump version to ${VERSION}"
  fi
  branch=$(git -C "$BASE_DIR" branch --show-current || true)
  cat <<EOF

to publish:
  git -C ${BASE_DIR} push https://x-access-token:<TOKEN>@github.com/eluinstra/ebms-docker.git ${branch:-<branch>}
  # then in the parent repo (ignore=all requires -f):
  git add -f ebms-docker \\
    && git commit -m "chore: bump ebms-docker pin to ${VERSION}" \\
    && git push origin HEAD
EOF
fi
