#!/bin/bash
[[ -n "$__INSIDE_VM_RUNNER" ]] || { echo "Only call within VM runner!" >&2; return 1; }
# User account (student) tweaks

VM_SRC="$(realpath "$(sh_get_script_path)/..")"

# install dotfiles to /etc/skel/
# emulate installation using XDG paths
env HOME=/etc/skel/ XDG_CONFIG_HOME="/etc/skel/.config" \
	XDG_DATA_HOME="/etc/skel/.local/share" \
	XDG_CACHE_HOME="/tmp/dotfiles-cache" \
	XDG_STATE_HOME="/tmp/dotfiles-state" \
	"$VM_SRC/labvm-dotfiles/install.sh"
chmod 755 "/etc/skel" -R

# cleanup MOTD + add fastfetch
for f in /etc/update-motd.d/*; do 
	n=${f##*/}; [[ ${n%%-*} =~ ^[0-9]+$ ]] && (( ${n%%-*} < 96 )) && rm -v -- "$f"
done
rsync -a --chown=root:root --chmod=755 "$VM_SRC/etc/update-motd.d/" "/etc/update-motd.d/"

# this will be ran with individual user privileges
function _install_home_config() {
	set -e
	# copy skel over (since user was created previous to installing files)
	rsync -a --chmod=750 "/etc/skel/" "$HOME/"

	# set git identities
	git config --global user.email "$USER@armbuilder.local"
	git config --global user.name "${USER}_builder"
}

_exported_script="$(declare -p VM_SRC); $(declare -f _install_home_config)"

for u in student admin root; do
	echo "$_exported_script; _install_home_config" | su -c bash "$u"
	chsh -s /usr/bin/zsh "$u"
done

