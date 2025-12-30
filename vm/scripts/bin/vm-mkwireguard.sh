#!/bin/bash
# Script to install a wireguard tunnel for reverse proxy (frontend)
set -e

# TODO: hardcoded, make it configurable!
SERVER_ENDPOINT=isc2024.root.sx:51820
VM_IDX="$1"

# Wireguard options
WG_NAME="wg-vm"
WG_VM_IP_ADDR="10.13.14.$VM_IDX/24"

# Wireguard config / data storage
WG_DIR="/etc/wireguard"
# Server public key (preloaded by Packer on VMs)
SERVER_PUBLIC_KEY=$(cat "/etc/wireguard/vm_server.pub")
# Configuration file
VM_CONFIG_FILE="${WG_DIR}/${WG_NAME}.conf"

# generate wireguard private and public key
VM_PRIVATE_KEY=$(wg genkey)
VM_PUBLIC_KEY=$(echo "$VM_PRIVATE_KEY" | wg pubkey)

echo "Client Public Key: $VM_PUBLIC_KEY"

cat << EOF > "$VM_CONFIG_FILE"
# Client configuration for ${WG_NAME} #$VM_IDX
[Interface]
PrivateKey = ${VM_PRIVATE_KEY}
Address = ${WG_VM_IP_ADDR}
MTU = 1300

[Peer]
PublicKey = ${SERVER_PUBLIC_KEY}
Endpoint = ${SERVER_ENDPOINT}
AllowedIPs = 10.13.14.0/24
PersistentKeepalive = 25
EOF
chmod 600 "$VM_CONFIG_FILE"

systemctl enable "wg-quick@$WG_NAME"
systemctl restart "wg-quick@$WG_NAME"

echo "Done!"
echo

cat << EOF
# Add this [Peer] block to your server's WireGuard configuration file:
[Peer]
#VM_IDX=${VM_IDX}/${WG_VM_IP_ADDR}
PublicKey = ${VM_PUBLIC_KEY}
AllowedIPs = ${WG_VM_IP_ADDR%/24}/32
PersistentKeepalive = 25
EOF

