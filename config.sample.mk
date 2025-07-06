# Sample VM build script config
# Copy it as `config.local.mk` & modify to take effect.
# (also check out framework/config.default.mk for all variables)


# Ubuntu .iso image
UBUNTU_22_ISO = $(HOME)/Downloads/ubuntu-22.04.5-live-server-amd64.iso

# E.g., move build output (VM destination) directory to an external drive
#BUILD_DIR ?= /media/myssd/tmp/packer

# Preload VM with SSH keys (must be absolute)
#VM_AUTHORIZED_KEYS = $(abspath dist/authorized_keys)

# Password for cloud VM's console (this is certainly NOT it!)
#CLOUD_ADMIN_PASSWORD=hunter2

