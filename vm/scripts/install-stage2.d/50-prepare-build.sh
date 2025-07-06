#!/bin/bash
[[ -n "$__INSIDE_VM_RUNNER" ]] || { echo "Only call within VM runner!" >&2; return 1; }

BUILDERS=builders
id -g "$BUILDERS" >/dev/null 2>&1 || groupadd -g "2999" "$BUILDERS"

BDIR="/home/_aosp_build"
BUILD_MOUNT=/build

mkdir -p "$BDIR/base"
mkdir -p "$BDIR/up"
mkdir -p "$BDIR/ns"
mkdir "$BUILD_MOUNT"

chown "admin:$BUILDERS" "$BDIR" -R
chmod 755 "$BDIR" -R
# set it group-writable with sticky bit
chmod 1775 "$BDIR/ns"

