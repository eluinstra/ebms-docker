#!/bin/sh

set -eu

export BASE_DIR=`dirname $(realpath $0)`
. $BASE_DIR/env.sh

for IMAGE in $IMAGE_NAMES; do
  # a pre-release publishes only its own version tag: EBMS_FLOATING_TAGS is
  # empty then, keeping <major>.<minor> and latest on the last stable release
  # (env.sh). Unquoted on purpose: empty must expand to nothing.
  # shellcheck disable=SC2086
  for TAG in "$EBMS_VERSION" ${EBMS_FLOATING_TAGS}; do
    TARGET="${REPO}${IMAGE}:${TAG}"

    docker manifest rm "$TARGET" >/dev/null 2>&1 || true

    docker manifest create "$TARGET" \
      --amend "${REPO}${IMAGE}:${TAG}-amd64" \
      --amend "${REPO}${IMAGE}:${TAG}-arm64"

    docker manifest annotate "$TARGET" "${REPO}${IMAGE}:${TAG}-amd64" --arch amd64
    docker manifest annotate "$TARGET" "${REPO}${IMAGE}:${TAG}-arm64" --arch arm64

    docker manifest push --purge "$TARGET"
  done
done
