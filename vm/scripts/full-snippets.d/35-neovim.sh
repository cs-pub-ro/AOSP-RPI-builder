#!/bin/bash
[[ -n "$__INSIDE_VM_RUNNER" ]] || { echo "Only call within VM runner!" >&2; return 1; }

# unfortunately, nvim plugins require nodejs + npm :| 
pkg_install nodejs npm

# install ripgrep, fd-find and other goodies
pkg_install ripgrep fd-find jq

# Install latest Neovim release
wget -qO- https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz | \
	tar -xz -C /usr/local --strip-components=1

