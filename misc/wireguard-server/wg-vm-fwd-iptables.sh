#!/usr/bin/bash
# Iptables configuration script for wireguard reverse port forwarding

set -eo pipefail

WG_CONF=/etc/wireguard/wg-vm-fwd.conf
WG_NET="10.13.14.0/24"
DELETE_ONLY=
[[ "$1" != "--rm" ]] || DELETE_ONLY=1

iptables -D FORWARD -p tcp --dport 22 -d "$WG_NET" -j ACCEPT &>/dev/null || true
iptables -D FORWARD -p tcp --sport 22 -s "$WG_NET" -j ACCEPT &>/dev/null || true
iptables -t nat -D POSTROUTING -d "$WG_NET" -j MASQUERADE &>/dev/null || true

iptables -I FORWARD -p tcp --dport 22 -d "$WG_NET" -j ACCEPT
iptables -I FORWARD -p tcp --sport 22 -s "$WG_NET" -j ACCEPT
iptables -t nat -I POSTROUTING -d "$WG_NET" -j MASQUERADE

# we also need to so SNAT...
iptables -t nat -D POSTROUTING 1 -d 10.13.14.0/24 -j MASQUERADE
iptables -t nat -I POSTROUTING 1 -d 10.13.14.0/24 -j MASQUERADE

# parse configuration file and return all peers' VM_IDX
while IFS="" read -r peer || [ -n "$peer" ]; do
	mapfile -td/ pf < <(echo -n "$peer")
	dport=$(( 2200 + pf[0] ))
	RULE=(-p tcp --dport "$dport" -j DNAT --to-destination "${pf[1]}:22")
	echo iptables -t nat -A PREROUTING "${RULE[@]}"
	iptables -t nat -D PREROUTING "${RULE[@]}" &>/dev/null || true
	[[ "$DELETE_ONLY" == "1" ]] || \
		iptables -t nat -A PREROUTING "${RULE[@]}"

done < <(sed -n -e 's/^\s*#VM_IDX=//p' "$WG_CONF")
