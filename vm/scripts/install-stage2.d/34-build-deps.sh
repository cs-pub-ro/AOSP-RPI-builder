#!/bin/bash
[[ -n "$__INSIDE_VM_RUNNER" ]] || { echo "Only call within VM runner!" >&2; return 1; }
# VM install initialization

# terminal tools
apt-get install -y tmux lzma xz-utils moreutils expect lsof jq vim less \
	rsync zsh

# build dependencies
apt-get install -y \
    sudo nano vim wget curl ca-certificates repo bash bash-completion \
	git gnupg flex bison build-essential zip curl zlib1g-dev libc6-dev-i386 \
	x11proto-core-dev libx11-dev lib32z1-dev libgl1-mesa-dev \
	libxml2-utils xsltproc unzip fontconfig \
    libssl-dev liblz4-tool libmpc-dev \
	coreutils dosfstools e2fsprogs fdisk kpartx mtools ninja-build \
	pkg-config python3-pip rsync fakeroot libgmp-dev \
    cmake device-tree-compiler \
    ncurses-dev libgucharmap-2-90-dev bzip2 expat gpgv2 \
    bc time file bsdmainutils

apt-get clean

if [[ -n "$VM_FULL_UPGRADE" ]]; then
	pkg_upgrade_all
fi

