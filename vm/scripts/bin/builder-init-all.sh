#!/bin/bash

if [[ "$SUDO_USER" != "admin" ]]; then
	echo "This should only be ran by admin (with sudo)!" >&2; exit 2
fi

builder-mkmountns.sh
builder-mkoverlay.sh --root

builder-enter.sh builder-init-build-aosp.sh

builder-mkoverlay.sh --umount
builder-mkmountns.sh --rm

