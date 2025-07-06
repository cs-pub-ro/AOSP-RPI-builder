#!/bin/bash
# Enters a user's build directory namespace
set -e

NAME="${SUDO_USER:-$1}"

# shared build directory
BDIR="/home/_aosp_build"
NSDIR="$BDIR/ns"
MNS="$NSDIR/$NAME"

nsenter --mount="$MNS" su --login "$NAME"

