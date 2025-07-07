#!/bin/bash
# Enters a user's build directory namespace
set -e

NAME="${SUDO_USER}"
CMD=("$@")

if [[ $EUID -ne 0 ]]; then
	echo "this script must be run as root!" >&2; exit 2
fi

# shared build directory
BDIR="/home/_aosp_build"
NSDIR="$BDIR/ns"
MNS="$NSDIR/$NAME"

SU_ARGS=()
if [[ "${#CMD[@]}" -gt 0 ]]; then
	SU_ARGS+=('-c' "$(printf "%q " "${CMD[@]}")")
fi

nsenter --mount="$MNS" su --login "$NAME" "${SU_ARGS[@]}"

