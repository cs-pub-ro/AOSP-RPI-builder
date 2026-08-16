# Sample VM build script config
# Copy it as `config.local.mk` & modify to take effect.
# (also check out framework/config.default.mk for all variables)

# ISO images location
BASE_ISO_DIR = $(HOME)/Downloads/iso

# optional: change APT mirror 
#BASE_UBUNTU_APT_MIRROR = http://mirrors.hosterion.ro/ubuntu/

# E.g., move build output (VM destination) directory to an external drive
#BUILD_DIR ?= /media/myssd/tmp/packer

# Preload VM with SSH keys (must be absolute)
#VM_AUTHORIZED_KEYS = $(abspath dist/authorized_keys)

# Password for cloud VM's console (this is certainly NOT it!)
#CLOUD_ADMIN_PASSWORD=hunter2

