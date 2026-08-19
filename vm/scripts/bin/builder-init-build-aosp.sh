#!/bin/bash
set -eo pipefail

# default configuration vars
AOSP_MANIFEST_URL=https://android.googlesource.com/platform/manifest
AOSP_MANIFEST_BRANCH=TODO
RPIV_MANIFEST_PREFIX="https://raw.githubusercontent.com/raspberry-vanilla/android_local_manifest"
RPIV_MANIFEST_BRANCH=TODO
AOSP_VARIANT_BASE="aosp_rpi5_car"
AOSP_VARIANT_CAR="aosp_rpi5"
AOSP_RELEASE="TODO"

if [[ -f "/etc/aospi/.env" ]]; then
	source /etc/aospi/.env
fi

if [[ "$USER" != "admin" ]]; then
	echo "This should only be ran by admin (without sudo)!" >&2; exit 2
fi
if ! mountpoint -q /build; then
	echo "This should only be ran inside a build mount namespace!" >&2; exit 2
fi

cd /build

# download raspberry-vanilla manifests
repo init -u "$AOSP_MANIFEST_URL" -b "$AOSP_MANIFEST_BRANCH" --depth=1
curl -o .repo/local_manifests/manifest_brcm_rpi.xml -L \
	"$RPIV_MANIFEST_PREFIX/$RPIV_MANIFEST_BRANCH/manifest_brcm_rpi.xml" \
	--create-dirs
curl -o .repo/local_manifests/remove_projects.xml -L \
	"$RPIV_MANIFEST_PREFIX/$RPIV_MANIFEST_BRANCH/remove_projects.xml"

# minimize the downloaded size
repo sync -c --no-clone-bundle

# now, each time you wish to work with AOSP you must load its environment:
source build/envsetup.sh

# build Android Car first
if [[ -n "$AOSP_VARIANT_CAR" ]]; then
	lunch "$AOSP_VARIANT_CAR-$AOSP_RELEASE"
	make bootimage systemimage vendorimage -j$(nproc --ignore=2)
fi

# afterwards, re-build & switch to Android Main
lunch "$AOSP_VARIANT_BASE-$AOSP_RELEASE"
make bootimage systemimage vendorimage -j$(nproc --ignore=2)

