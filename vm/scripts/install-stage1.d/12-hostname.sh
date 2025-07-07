#!/bin/bash
[[ -n "$__INSIDE_VM_RUNNER" ]] || { echo "Only call within VM runner!" >&2; return 1; }
# VM network configuration

NEW_HOSTNAME=armbuilder

# Change hostname
if [[ "$(hostname)" != "$NEW_HOSTNAME" ]]; then
	hostnamectl set-hostname $NEW_HOSTNAME
	sed -i "s/^127.0.1.1\s.*/127.0.1.1       $NEW_HOSTNAME/g"  /etc/hosts
fi


