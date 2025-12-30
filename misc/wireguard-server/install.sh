#!/bin/bash
# Sets up wireguard on server
set -eo pipefail

WG_NAME=wg-vm-fwd
SERVER_PRIV_KEY=/etc/wireguard/$WG_NAME.priv
SERVER_PUB_KEY=/etc/wireguard/$WG_NAME.pub

SERVER_CONFIG_FILE=/etc/wireguard/$WG_NAME.conf
WG_POST_UP_SCRIPT="/usr/local/bin/wg-vm-fwd-iptables.sh"

umask 0077
if [[ ! -f "$SERVER_PRIV_KEY" ]]; then
	wg genkey > "$SERVER_PRIV_KEY"
fi
_WG_PRIV_KEY=$(tail -1 "$SERVER_PRIV_KEY")
if [[ ! -f "$SERVER_PUB_KEY" ]]; then
	wg pubkey < "$SERVER_PRIV_KEY" > "$SERVER_PUB_KEY"
fi

if [[ ! -f "$SERVER_CONFIG_FILE" ]]; then
	cat << EOF > "$SERVER_CONFIG_FILE"
# Server configuration for ${WG_NAME}
[Interface]
PrivateKey = ${_WG_PRIV_KEY}
Address = 10.13.14.254/24
ListenPort = 51820
MTU = 1300
PostUp = $WG_POST_UP_SCRIPT
PostDown = $WG_POST_UP_SCRIPT --rm

# TODO: add [Peer] blocks below!
EOF
fi

chmod 700 /etc/wireguard -R

install -m0755 "wg-vm-fwd-iptables.sh" "$WG_POST_UP_SCRIPT"
systemctl enable "wg-quick@$WG_NAME"
systemctl restart "wg-quick@$WG_NAME"

echo "Done!"

echo "Wireguard server's public key:"
cat "$SERVER_PUB_KEY"

