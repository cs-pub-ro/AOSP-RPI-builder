#!/bin/bash
set -e

NAME="$1"
BUILDERS=builders

if [[ -z "$NAME" ]]; then
	echo "No user name given!" >&2
	exit 1
fi

useradd -m -s "/usr/bin/zsh" -G "$BUILDERS" "$NAME"

BUILDENV_SV="build-env-for@$NAME.service"
systemctl enable "$BUILDENV_SV"
systemctl restart "$BUILDENV_SV"

# this will be ran as the `$NAME` user
function _install_home_config() {
	set -e
	# install fzf
	yes | "$HOME/.fzf/install"
	# run zsh to install plugins
	zsh -i -c 'source ~/.zshrc; exit 0'

	# set git identities
	git config --global user.email "$USER@armbuilder.local"
	git config --global user.name "${USER}_builder"
}

_exported_script="$(declare -f _install_home_config)"
echo "$_exported_script; _install_home_config" | su -c bash "$NAME"

echo "User $NAME successfully configured!"

