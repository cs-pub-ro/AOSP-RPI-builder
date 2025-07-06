#!/bin/bash
# Creates a persistent mount namespace (to be used by the multi-user build
# system).
set -e

NAME="${SUDO_USER}"
while [[ $# -gt 0 ]]; do
	case "$1" in
		--rm)
			DELETE=1 ;;
		-*) echo "Invalid argument: $1" >&2; exit 1 ;;
		*) 
			if [[ -z "$SUDO_USER" || "$SUDO_USER" == "admin" ]]; then
				NAME="$1"
			else
				echo "Invalid argument: $1" >&2; exit 1
			fi ;;
	esac; shift
done
if [[ $EUID -ne 0 ]]; then
	echo "this script must be run as root!" >&2; exit 2
fi

# shared build directory
BDIR="/home/_aosp_build"
NSDIR="$BDIR/ns"
MNS="$NSDIR/$NAME"

if [[ "$DELETE" == "1" ]]; then
	if mountpoint -q "$MNS"; then
		umount "$MNS"
	fi
	rm -f "$MNS"
	exit 0
fi

# mount a private tmpfs
if ! mountpoint -q "$NSDIR"; then
	mount --make-private -t tmpfs "$NSDIR"
fi

: > "$MNS"
unshare --propagation private --mount="$MNS" sleep 1

echo "Mount namespace successfully created for $NAME:"
ls -l "$MNS"

