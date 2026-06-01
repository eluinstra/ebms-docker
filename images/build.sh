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

for TARGET_ARCH in $ARCH_LIST; do
  PLATFORM="linux/${TARGET_ARCH}"

  echo "Building ebms-adapter-bin for ${TARGET_ARCH}"
  cd "$BASE_DIR/ebms-adapter-bin/"
  docker buildx build \
    --platform "$PLATFORM" \
    --build-arg EBMS_VERSION="${EBMS_VERSION}" \
    -t "${REPO}ebms-adapter-bin:${EBMS_MAJOR_VERSION}-${TARGET_ARCH}" \
    -t "${REPO}ebms-adapter-bin:${EBMS_VERSION}-${TARGET_ARCH}" \
    -t "${REPO}ebms-adapter-bin:latest-${TARGET_ARCH}" \
    --load .
  if [ "$TARGET_ARCH" = "$ARCH" ]; then
    docker tag "${REPO}ebms-adapter-bin:${EBMS_VERSION}-${TARGET_ARCH}" "ebms-adapter-bin:${EBMS_VERSION}"
  fi

  echo "Building ebms-adapter-pg for ${TARGET_ARCH}"
  cd "$BASE_DIR/ebms-adapter-pg/"
  docker buildx build \
    --platform "$PLATFORM" \
    --build-arg EBMS_VERSION="${EBMS_VERSION}-${TARGET_ARCH}" \
    -t "${REPO}ebms-adapter-pg:${EBMS_MAJOR_VERSION}-${TARGET_ARCH}" \
    -t "${REPO}ebms-adapter-pg:${EBMS_VERSION}-${TARGET_ARCH}" \
    -t "${REPO}ebms-adapter-pg:latest-${TARGET_ARCH}" \
    --load .
  if [ "$TARGET_ARCH" = "$ARCH" ]; then
    docker tag "${REPO}ebms-adapter-pg:${EBMS_VERSION}-${TARGET_ARCH}" "ebms-adapter-pg:${EBMS_VERSION}"
  fi
done
