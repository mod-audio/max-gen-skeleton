#!/usr/bin/make -f
# Makefile for max-gen-skeleton #
# ----------------------------- #
# Created by falkTX
#

# ---------------------------------------------------------------------------------------------------------------------
# Import plugin information

include .plugin-info

FILES_DSP = DistrhoPluginMaxGen.cpp

# ---------------------------------------------------------------------------------------------------------------------
# Build setup

DPF_TARGET_DIR=../bin
include dpf/Makefile.plugins.mk

BUILD_CXX_FLAGS += -Igen_dsp -I../plugin -Wno-unused-parameter
BUILD_CXX_FLAGS += -DGENLIB_USE_FASTMATH -DGENLIB_USE_FLOAT32 -DGENLIB_USE_JSON=0

all: jack ladspa lv2 vst2 vst3

# ---------------------------------------------------------------------------------------------------------------------
