#!/bin/bash
[[ -n "$__INSIDE_VM_RUNNER" ]] || { echo "Only call within VM runner!" >&2; return 1; }
# Neovim latest

curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
rm -rf /opt/nvim*
tar -C /opt -xzf nvim-linux-x86_64.tar.gz

echo 'export PATH=/opt/nvim-linux-x86_64/bin:$PATH' > /etc/profile.d/30-nvim.sh

export PATH="$PATH:/opt/nvim-linux-x86_64/bin"

# unfortunately, nvim plugins require nodejs + npm :| 
apt-get install -y nodejs npm

