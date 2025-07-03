#!/bin/bash
[[ -n "$__INSIDE_VM_RUNNER" ]] || { echo "Only call within VM runner!" >&2; return 1; }
# User account (student) tweaks

SRC="$(realpath "$(sh_get_script_path)/..")"

# copy default files to /etc/skel
rsync -a --chown=root:root --chmod=755 "$SRC/etc/skel/" "/etc/skel/"

# this will be ran as the `student` & `root` users
function _install_home_config() {
	set -e

	# copy skel over (since user was created previous to installing files)
	rsync -a --chmod=750 "/etc/skel/" "$HOME/"

	# run zsh to install plugins
	zsh -i -c 'source ~/.zshrc; exit 0'
}

_exported_script="$(declare -p SRC); $(declare -f _install_home_config)"
echo "$_exported_script; _install_home_config" | su -c bash student
echo "$_exported_script; _install_home_config" | su -c bash root

chsh -s /usr/bin/zsh "root"
chsh -s /usr/bin/zsh "student"

