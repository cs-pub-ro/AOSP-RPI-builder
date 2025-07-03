## Top-level makefile for build VM

FRAMEWORK_DIR ?= framework/
USER_CONFIG_DIR = .

# Include framework + all libraries / layers
include $(FRAMEWORK_DIR)/framework.mk
include $(FRAMEWORK_DIR)/lib/inc_all.mk

# set default goals
DEFAULT_GOAL = main
INIT_GOAL = main

# user-definable base (used for testing)
BASE ?= ubuntu
$(call vm_new_base_$(BASE),base)

# VM versioning & unified prefix scheme
vm-ver = 2025
vm-prefix = arm_builder_$(vm-ver)

# Local VM rule
# [re]build with `make main_clean main`
$(call vm_new_layer_generic,main)
main-name = $(vm-prefix)_main
# always update scripts from framework (prevent re-building base on changes)
# same as above, include scripts from framework, full layer + our own overrides
main-copy-scripts = $(abspath $(FRAMEWORK_DIR)/scripts)/
main-copy-scripts += $(VM_FULL_FEATURED_SCRIPTS_DIR)
# builder VM scripts + overrides
main-copy-scripts += $(abspath ./vm/scripts)/

# Cloud image based on main
# [re]build with `make full_cloud_clean full_cloud`
$(call vm_new_layer_cloud,cloud)
cloud-name = $(vm-prefix)_cloud
cloud-src-from = main
cloud-copy-scripts = $(abspath $(FRAMEWORK_DIR)/scripts)/
cloud-copy-scripts += $(VM_CLOUD_SCRIPTS_DIR)
cloud-copy-scripts += $(abspath ./cloud/script-overrides)/
# Set cloud VM password from config
cloud-extra-envs += "CLOUD_ADMIN_PASSWORD=$(CLOUD_ADMIN_PASSWORD)",
# use `make full_cloud_compact` to run zerofree on its image
cloud-extra-rules += $(vm_zerofree_rule)

# List of targets to generate rules for (note: must manually order them
# topologically, i.e. build dependencies before their targets)
build-vms = base main cloud

$(call vm_eval_all_rules)

