#!/bin/bash
[[ -n "$__INSIDE_VM_RUNNER" ]] || { echo "Only call within VM runner!" >&2; return 1; }
# ARM Builder VM full-snippets configuration + vars

VM_SRC=$(sh_get_script_path)/..

# Enable [almost] all features from the full_featured layer
VM_LEGACY_IFNAMES=1
VM_SYSTEM_TWEAKS=1
VM_INSTALL_TERM_TOOLS=1
VM_INSTALL_NET_TOOLS=1
VM_INSTALL_DEV_TOOLS=1
VM_INSTALL_HACKING_TOOLS=1
VM_INSTALL_DOCKER=0  # disabled, we're using raw namespaces
VM_USER_TWEAKS=0     # manual dotfiles installation to users

