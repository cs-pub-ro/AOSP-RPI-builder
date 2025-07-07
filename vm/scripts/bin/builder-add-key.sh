#!/bin/bash
set -e

NAME="$1"
KEY="$2"

if [[ $# != 2 || -z "$NAME" || -z "$KEY" ]]; then
	echo "Syntax: builder-add-key.sh USERNAME PUBLIC_KEY" >&2
	echo "(don't forget to quote the key argument!)"
	exit 1
fi

su "$NAME" -c 'mkdir -p ~/.ssh; touch ~/.ssh/authorized_keys'
echo "$KEY" >> "/home/$NAME/.ssh/authorized_keys"
chmod 700 "/home/$NAME/.ssh" -R

