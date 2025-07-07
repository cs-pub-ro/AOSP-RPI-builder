#!/bin/bash
set -e

NAME="$1"
BUILDERS=builders

if [[ -z "$NAME" ]]; then
	echo "No user name given!" >&2
	exit 1
fi

useradd -m -s "/usr/bin/zsh" -G "$BUILDERS" "$NAME"

BUILDENV_SV="build-env-for@$NAME.service"
systemctl enable "$BUILDENV_SV"
systemctl restart "$BUILDENV_SV"

echo "User $NAME successfully configured!"

