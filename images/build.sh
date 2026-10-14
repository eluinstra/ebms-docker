#!/bin/sh

set -eu

export BASE_DIR=`dirname $(realpath $0)`
. $BASE_DIR/env.sh

ARCH="$(dpkg --print-architecture)"
ARCH_OPTION="${1:-$ARCH}"

if ! docker buildx version >/dev/null 2>&1; then
  echo "docker buildx is required"
  exit 1
fi

case "$ARCH" in
  amd64|arm64)
    ;;
  *)
    echo "Unsupported host architecture '$ARCH'"
    exit 1
    ;;
esac

case "$ARCH_OPTION" in
  amd64|arm64)
    ARCH_LIST="$ARCH_OPTION"
    ;;
  all)
    ARCH_LIST="amd64 arm64"
    ;;
  *)
    echo "Unsupported option '$ARCH_OPTION'"
    echo "Usage: $0 [amd64|arm64|all]"
    exit 1
    ;;
esac

# The version tag is always published; the floating tags (latest,
# <major>.<minor>) only for a stable release (EBMS_FLOATING_TAGS in env.sh).
# The unquoted substitutions below are word-split deliberately: image tags
# never contain whitespace, and an empty EBMS_FLOATING_TAGS must expand to
# nothing, so a pre-release publishes just its own version tag.
build_tags() {
  image=$1
  set -- -t "${REPO}${image}:${EBMS_VERSION}-${TARGET_ARCH}"
  for TAG in ${EBMS_FLOATING_TAGS}; do
    set -- "$@" -t "${REPO}${image}:${TAG}-${TARGET_ARCH}"
  done
  printf '%s\n' "$@"
}

for TARGET_ARCH in $ARCH_LIST; do
  PLATFORM="linux/${TARGET_ARCH}"

  echo "Building ebms-adapter-bin for ${TARGET_ARCH}"
  cd "$BASE_DIR/ebms-adapter-bin/"
  # shellcheck disable=SC2086
  docker buildx build \
    --platform "$PLATFORM" \
    --build-arg EBMS_VERSION="${EBMS_VERSION}" \
    $(build_tags ebms-adapter-bin) \
    --load .
  if [ "$TARGET_ARCH" = "$ARCH" ]; then
    docker tag "${REPO}ebms-adapter-bin:${EBMS_VERSION}-${TARGET_ARCH}" "ebms-adapter-bin:${EBMS_VERSION}"
  fi

  echo "Building ebms-adapter-pg for ${TARGET_ARCH}"
  cd "$BASE_DIR/ebms-adapter-pg/"
  # shellcheck disable=SC2086
  docker buildx build \
    --platform "$PLATFORM" \
    --build-arg EBMS_VERSION="${EBMS_VERSION}" \
    --build-context "eluinstra/ebms-adapter-bin:${EBMS_VERSION}=docker-image://${REPO}ebms-adapter-bin:${EBMS_VERSION}-${TARGET_ARCH}" \
    $(build_tags ebms-adapter-pg) \
    --load .
  if [ "$TARGET_ARCH" = "$ARCH" ]; then
    docker tag "${REPO}ebms-adapter-pg:${EBMS_VERSION}-${TARGET_ARCH}" "ebms-adapter-pg:${EBMS_VERSION}"
  fi

  echo "Building ebms-adapter-test for ${TARGET_ARCH}"
  cd "$BASE_DIR/ebms-adapter-test/"
  # shellcheck disable=SC2086
  docker buildx build \
    --platform "$PLATFORM" \
    --build-arg EBMS_VERSION="${EBMS_VERSION}" \
    --build-context "eluinstra/ebms-adapter-bin:${EBMS_VERSION}=docker-image://${REPO}ebms-adapter-bin:${EBMS_VERSION}-${TARGET_ARCH}" \
    $(build_tags ebms-adapter-test) \
    --load .
  if [ "$TARGET_ARCH" = "$ARCH" ]; then
    docker tag "${REPO}ebms-adapter-test:${EBMS_VERSION}-${TARGET_ARCH}" "ebms-adapter-test:${EBMS_VERSION}"
  fi
done
