#!/bin/sh

set -eu

export BASE_DIR=`dirname $(realpath $0)`
. $BASE_DIR/env.sh

ARCH="$(dpkg --print-architecture)"
ARCH_OPTION="${1:-$ARCH}"

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

for IMAGE in $IMAGE_NAMES; do
	docker image rm -f "${IMAGE}:${EBMS_VERSION}" 2>/dev/null || true

	for TARGET_ARCH in $ARCH_LIST; do
		docker image rm -f "${REPO}${IMAGE}:${EBMS_VERSION}-${TARGET_ARCH}" 2>/dev/null || true
		# floating tags may or may not exist for this version (pre-release
		# never publishes them); rm -f || true covers both
		# shellcheck disable=SC2086
		for TAG in ${EBMS_FLOATING_TAGS} latest; do
			docker image rm -f "${REPO}${IMAGE}:${TAG}-${TARGET_ARCH}" 2>/dev/null || true
		done
	done
done
