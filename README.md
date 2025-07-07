# AOSP RPi Builder VM (Embedded Android Summer School)

This repository contains the builder VM scripts for a Android AOSP builder VM, 
mainly based on [LabVM Framework](https://github.com/cs-pub-ro/labvm-framework)
(automated using `qemu` and Packer).

The VM container a series of scripts and workarounds for facilitating
a multi-user AOSP build environment optimized for disk usage:

 * AOSP code is only downloaded once and shared among all users (using overlay fs);
 * Script to create/enter specific mount namespaces for each user inside
   an unchanged `/build` mountpoint to prevent AOSP build cache invalidation;
 * Automated build scripts for the [raspberry-vanilla](https://github.com/raspberry-vanilla/android_local_manifest) project;
 * TMUX / ZSH / NVim customizations for a friendly terminal experience;
 * Script to establish Wireguard tunnel to a frontend;

Requirements:
 - a modern Linux system;
 - basic build tools (make);
 - [Hashicorp's Packer](https://packer.io/);
 - [qemu+kvm](https://qemu.org/);
 - hosting with >= 16 CPUs, 64GB RAM, 300GB disk space (yep, this is the
   mininum requirement for [building AOSP]()!

## Preparation

Download and save a [Ubuntu 22.04 Live Server
install](http://cdimage.ubuntu.com/releases/22.04.1/release/) iso image.

Optionally, create `config.local.mk`, copy the variables from
[`config.sample.mk`](https://github.com/cs-pub-ro/AOSP-RPI-builder/blob/master/config.sample.mk) and/or [`framework/config.default.mk`](https://github.com/cs-pub-ro/labvm-framework/blob/master/config.default.mk)
and edit them to your liking.

You might also want to ensure that packer and qemu are properly installed and
configured.

## Building the VM

The following Makefile goals are available (the build process is usually in this
order):

- `base`: builds a base Ubuntu 22.04 install (required for the VM image);
- `main`: builds the maine VM with all required scripts and config;
- `cloud`: builds (from `main` VM) the cloud VM, cleaned up and ready
  for cloud usage (e.g., AWS, OpenStack).
- `main_edit`: easily edit an already build Lab VM (uses the previous
  image as backing snapshot);
- `main_commit`: commits the edited VM back to its backing base;
- `[*]_clean`: removes the generated image(s);
- `ssh`: SSH-es into a running Packer VM;

If packer complains about the output file existing, you must either manually
delete the generated VM from inside `TMP_DIR`, or set the `DELETE=1` makefile
variable (but be careful):
```sh
make DELETE=1 main
```

If you want to keep the install scripts at the end of the provisioning phase,
set the `DEBUG` variable. Also check out `PAUSE` (it pauses packer,
letting you inspect the VM inside qemu):
```sh
make PAUSE=1 DEBUG=1 main
```

Read [https://github.com/cs-pub-ro/labvm-framework|LabVM Framework's]
documentation for more lower-level targets and options.

## VM: OverlayFS Usage

Once booted up, the VM has a clean environment.

If you wish, mount a large (_>= 300GB_) volume at `/home/_aosp_build` and do
your first build! During the AOSP development process, the overlay filesystem
will be mounted on `/build` (using a separate mount namespace for each user so
they do not conflict with eachother).

### Base Layer (as `admin`)

First, we must create a mount namespace for `admin` and mount the base layer 
at `/build`:

```sh
whoami
# admin, right ???
sudo builder-mkmountns.sh
# work with the base layer, NOT an upper overlay:
sudo builder-mkoverlay.sh --root
# enter the new mount namespace:
sudo builder-enter.sh
```

Next, navigate to the `/build` directory and follow the AOSP build instructions
for your preferred distribution
(you might wish to do these steps inside a `tmux` session...):

```sh
cd /build
repo init -u https://android.googlesource.com/platform/manifest -b android-16.0.0_r1 --depth=1
curl -o .repo/local_manifests/manifest_brcm_rpi.xml -L https://raw.githubusercontent.com/raspberry-vanilla/android_local_manifest/android-16.0/manifest_brcm_rpi.xml --create-dirs
curl -o .repo/local_manifests/remove_projects.xml -L https://raw.githubusercontent.com/raspberry-vanilla/android_local_manifest/android-16.0/remove_projects.xml
# minimize the downloaded size
repo sync -c --no-clone-bundle
# now, each time you wish to work with AOSP you must load its environment:
. build/envsetup.sh
# if starting with a pre-defined configuration:
lunch aosp_rpi5-bp2a-userdebug
# finally, start the build (but keep some cores for other services)
make bootimage systemimage vendorimage -j$(nproc --ignore=2)
```

### Overlay for each `student` user

After the base build is over, here's how to make an user-specific overlay
(e.g. for `student`):

The easy way, autostarted with VM (replace with actual username):
```sh
STUDENT_USER=student
systemctl enable build-env-for@$STUDENT_USER
systemctl restart build-env-for@$STUDENT_USER
# this should do the required setup
```

Or the manual way:
```sh
sudo builder-mkmountns.sh $STUDENT_USER
# work with the base layer, NOT an upper overlay:
sudo builder-mkoverlay.sh $STUDENT_USER
```

As student, enter the new mount namespace and build AOSP:
```sh
# first, must enter the namespace (with tmux, recommended)
sudo builder-enter.sh tmux
# android should be already built from previous step!
ls -l /build
# e.g., further change the build
. build/envsetup.sh
lunch aosp_rpi5-bp2a-userdebug
# change something
vim device/brcm/rpi5/BoardConfig.mk
# rebuild
make bootimage systemimage vendorimage -j$(nproc --ignore=2)
```

