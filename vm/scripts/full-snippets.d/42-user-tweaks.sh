#!/bin/bash
[[ -n "$__INSIDE_VM_RUNNER" ]] || { echo "Only call within VM runner!" >&2; return 1; }
# User account (student) tweaks

SRC="$(realpath "$(sh_get_script_path)/..")"

# copy default files to /etc/skel
rsync -a --chown=root:root --chmod=755 "$SRC/etc/skel/" "/etc/skel/"
# clone fzf
if [[ ! -d /etc/skel/.fzf/.git ]]; then
	git clone --depth 1 https://github.com/junegunn/fzf.git /etc/skel/.fzf/
fi

# this will be ran with individual user privileges
function _install_home_config() {
	set -e

	# copy skel over (since user was created previous to installing files)
	rsync -a --chmod=750 "/etc/skel/" "$HOME/"
	# install fzf
	yes | "$HOME/.fzf/install"

	# run zsh to install plugins
	zsh -i -c 'source ~/.zshrc; exit 0'

	# set git identities
	git config --global user.email "$USER@armbuilder.local"
	git config --global user.name "${USER}_builder"
}

_exported_script="$(declare -p SRC); $(declare -f _install_home_config)"

for u in student admin root; do
	echo "$_exported_script; _install_home_config" | su -c bash "$u"
	chsh -s /usr/bin/zsh "$u"
done

