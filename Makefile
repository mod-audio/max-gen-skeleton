#!/usr/bin/make -f
# Makefile for max-gen-skeleton #
# ----------------------------- #
# Created by falkTX
#

include source/dpf/Makefile.base.mk

# ---------------------------------------------------------------------------------------------------------------------

ifeq (,$(wildcard plugin/gen_exported.cpp))
$(error "Please copy gen_exported.cpp and gen_exported.h to the plugin folder")
endif

ifeq (,$(wildcard source/.plugin-info))
$(error "Please run setup.sh before trying to build this repository")
endif

# ---------------------------------------------------------------------------------------------------------------------

all: plugin gen

# ---------------------------------------------------------------------------------------------------------------------

plugin:
	$(MAKE) all -C source

gen: plugin source/dpf/utils/lv2_ttl_generator
	@$(CURDIR)/source/dpf/utils/generate-ttl.sh

source/dpf/utils/lv2_ttl_generator:
	$(MAKE) -C source/dpf/utils/lv2-ttl-generator

# ---------------------------------------------------------------------------------------------------------------------

clean:
	$(MAKE) clean -C source
	$(MAKE) clean -C source/dpf/utils/lv2-ttl-generator

# ---------------------------------------------------------------------------------------------------------------------

.PHONY: plugin
