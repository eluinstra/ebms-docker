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
		echo "Unsupported architecture '$ARCH'"
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
	for IMAGE in $IMAGE_NAMES; do
		docker image push "${REPO}${IMAGE}:${EBMS_VERSION}-${TARGET_ARCH}"
		# the floating tags (<major>.<minor>, latest) only for a stable
		# release: EBMS_FLOATING_TAGS is empty for a pre-release (env.sh).
		# Unquoted on purpose: empty must expand to nothing.
		# shellcheck disable=SC2086
		for TAG in ${EBMS_FLOATING_TAGS}; do
			docker image push "${REPO}${IMAGE}:${TAG}-${TARGET_ARCH}"
		done
	done
done
