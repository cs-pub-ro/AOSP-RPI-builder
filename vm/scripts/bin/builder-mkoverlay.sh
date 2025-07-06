#!/bin/bash
# Mounts a build filesystem overlay.
set -e

NAME="${SUDO_USER}"
AS_OVERLAY=1
UMOUNT=
while [[ $# -gt 0 ]]; do
	case "$1" in
		--root)
			if [[ -z "$SUDO_USER" || "$SUDO_USER" == "admin" ]]; then
				AS_OVERLAY=
			fi ;;
		-u|--umount)
			UMOUNT=1 ;;
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
BUILDERS=builders

BASE_DIR="$BDIR/base"
UPPER_DIR="$BDIR/up/$NAME"
WORK_DIR="$BDIR/work/$NAME"
MOUNT_DIR=/build
MNS="$BDIR/ns/$NAME"

if [[ "$UMOUNT" == "1" ]]; then
	nsenter --mount="$MNS" umount "$MOUNT_DIR"
	echo "Build dir was un-mounted for $MNS"
	exit 0
fi

# create upper dir
mkdir -p "$UPPER_DIR" "$WORK_DIR"
chown "$NAME:$BUILDERS" "$UPPER_DIR" "$WORK_DIR"

OVOPTS="lowerdir=$BASE_DIR,upperdir=$UPPER_DIR,workdir=$WORK_DIR"
OVOPTS+=",redirect_dir=on,metacopy=on"
MOUNT_OVER=(mount -t overlay -o"$OVOPTS" overlay "$MOUNT_DIR")
CHOWN=(chown "$NAME:$BUILDERS" "$MOUNT_DIR" -R)

if [[ "$AS_OVERLAY" == "1" ]]; then
	echo "Mounting overlay at $MOUNT_DIR [NS=$MNS]"
	[[ -f "$MNS" ]] || {
		echo "ERROR: mount namespace '$MNS' not found!" >&2; exit 1; }
	nsenter --mount="$MNS" "${MOUNT_OVER[@]}"
	echo "Preparing permissions..."
	nsenter --mount="$MNS" "${CHOWN[@]}"
else
	# directly mount base dir (for admin/root to do initial build)
	echo "Mounting base dir at $MOUNT_DIR [NS=$MNS]"
	nsenter --mount="$MNS" mount --bind "$BASE_DIR" "$MOUNT_DIR"
fi
echo "Build dir successfully mounted for $MNS"

