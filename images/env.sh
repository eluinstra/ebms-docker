#!/bin/sh

# The version keys below are rewritten by ../bump.sh (literal KEY=value
# lines); EBMS_MAJOR_VERSION is re-derived from EBMS_VERSION further down.
export EBMS_MAJOR_VERSION=2.21
export EBMS_VERSION=2.21.0
export REPO=eluinstra/
export IMAGE_NAMES="ebms-adapter-bin ebms-adapter-pg ebms-adapter-test"

# Pre-release support: a version with a qualifier (2.22.0-M1, 2.22.0-RC1,
# 2.22.0-beta.1) is a pre-release of its base version. Its own version tag is
# always published; the floating tags (`latest` and <major>.<minor>) are only
# moved by a stable release, so they keep pointing at the last stable version
# and nobody accidentally pulls a milestone with
# `docker pull eluinstra/ebms-adapter-pg:latest`.
case "${EBMS_VERSION}" in
  *-*) EBMS_PRERELEASE=true  EBMS_BASE_VERSION="${EBMS_VERSION%%-*}" ;;
  *)   EBMS_PRERELEASE=false EBMS_BASE_VERSION="${EBMS_VERSION}" ;;
esac
# the <major>.<minor> tag follows the base version, not the qualifier
# (a 2.22.0-M1 build belongs to the 2.22 line; it must not produce a
# "2.22.0-M" tag)
EBMS_MAJOR_VERSION="${EBMS_BASE_VERSION%.*}"
if [ "${EBMS_PRERELEASE}" = true ]; then
  EBMS_FLOATING_TAGS=""
else
  EBMS_FLOATING_TAGS="${EBMS_MAJOR_VERSION} latest"
fi
export EBMS_PRERELEASE EBMS_BASE_VERSION EBMS_MAJOR_VERSION EBMS_FLOATING_TAGS
