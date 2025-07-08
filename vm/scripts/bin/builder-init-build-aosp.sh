#!/bin/bash
set -eo pipefail

if [[ "$USER" != "admin" ]]; then
	echo "This should only be ran by admin (without sudo)!" >&2; exit 2
fi
if ! mountpoint -q /build; then
	echo "This should only be ran inside a build mount namespace!" >&2; exit 2
fi

cd /build

# download raspberry-vanilla manifests
repo init -u https://android.googlesource.com/platform/manifest -b android-16.0.0_r1 --depth=1
curl -o .repo/local_manifests/manifest_brcm_rpi.xml \
	-L https://raw.githubusercontent.com/raspberry-vanilla/android_local_manifest/android-16.0/manifest_brcm_rpi.xml --create-dirs
curl -o .repo/local_manifests/remove_projects.xml \
	-L https://raw.githubusercontent.com/raspberry-vanilla/android_local_manifest/android-16.0/remove_projects.xml

# minimize the downloaded size
repo sync -c --no-clone-bundle

# now, each time you wish to work with AOSP you must load its environment:
source build/envsetup.sh

# build Android Car first
lunch aosp_rpi4_car-bp2a-userdebug
make bootimage systemimage vendorimage -j$(nproc --ignore=2)

# afterwards, re-build & switch to Android Main
lunch aosp_rpi5-bp2a-userdebug
make bootimage systemimage vendorimage -j$(nproc --ignore=2)

