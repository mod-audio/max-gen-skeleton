#!/usr/bin/make -f
# Makefile for max-gen-skeleton #
# ----------------------------- #
# Created by falkTX
#

AR  ?= ar
CC  ?= gcc
CXX ?= g++

# ---------------------------------------------------------------------------------------------------------------------
# Set OS

ifneq ($(HAIKU),true)
ifneq ($(MACOS),true)
ifneq ($(WIN32),true)
ifeq (,$(wildcard /System/Library))
LINUX=true
else
MACOS=true
endif
endif
endif
endif

# ---------------------------------------------------------------------------------------------------------------------
# Set build and link flags

BASE_FLAGS = -Wall -Wextra -pipe
BASE_OPTS  = -O3 -ffast-math -mtune=generic -msse -msse2 -fdata-sections -ffunction-sections

ifneq ($(MACOS),true)
# MacOS doesn't support this
BASE_OPTS += -mfpmath=sse
endif

ifeq ($(MACOS),true)
# MacOS linker flags
LINK_OPTS  = -fdata-sections -ffunction-sections -Wl,-dead_strip -Wl,-dead_strip_dylibs
else
# Common linker flags
LINK_OPTS  = -fdata-sections -ffunction-sections -Wl,--gc-sections -Wl,-O1 -Wl,--as-needed -Wl,--strip-all
endif

ifeq ($(NOOPT),true)
# No optimization flags
BASE_OPTS  = -O3 -ffast-math -fdata-sections -ffunction-sections
endif

ifneq ($(WIN32),true)
# not needed for Windows
BASE_FLAGS += -fPIC -DPIC
endif

ifeq ($(DEBUG),true)
BASE_FLAGS += -DDEBUG -O0 -g
LINK_OPTS   =
else
BASE_FLAGS += -DNDEBUG $(BASE_OPTS) -fvisibility=hidden
CXXFLAGS   += -fvisibility-inlines-hidden
endif

BUILD_C_FLAGS   = $(BASE_FLAGS) -std=c99 -std=gnu99 $(CFLAGS)
BUILD_CXX_FLAGS = $(BASE_FLAGS) -std=c++0x -std=gnu++0x $(CXXFLAGS) $(CPPFLAGS)
LINK_FLAGS      = $(LINK_OPTS) -Wl,--no-undefined $(LDFLAGS)

ifeq ($(MACOS),true)
# No C++11 support
BUILD_CXX_FLAGS = $(BASE_FLAGS) $(CXXFLAGS) $(CPPFLAGS)
LINK_FLAGS      = $(LINK_OPTS) $(LDFLAGS)
endif

# ---------------------------------------------------------------------------------------------------------------------
# Check for optional libs

ifeq ($(LINUX),true)
HAVE_JACK = $(shell pkg-config --exists jack && echo true)
endif

# ---------------------------------------------------------------------------------------------------------------------
# Set app extension

ifeq ($(WIN32),true)
APP_EXT = .exe
endif

# ---------------------------------------------------------------------------------------------------------------------
# Set shared lib extension

LIB_EXT = .so

ifeq ($(MACOS),true)
LIB_EXT = .dylib
endif

ifeq ($(WIN32),true)
LIB_EXT = .dll
endif

# ---------------------------------------------------------------------------------------------------------------------
# Set shared library CLI arg

SHARED = -shared

ifeq ($(MACOS),true)
SHARED = -dynamiclib
endif

# ---------------------------------------------------------------------------------------------------------------------
# Import plugin information

include .plugin-info

# ---------------------------------------------------------------------------------------------------------------------
# Basic setup

TARGET_DIR = ../bin

BUILD_C_FLAGS   += -I.
BUILD_CXX_FLAGS += -I. -Idpf/distrho -Igen_dsp -I../plugin -Wno-unused-parameter
BUILD_CXX_FLAGS += -DGENLIB_USE_FASTMATH -DGENLIB_USE_FLOAT32 -DGENLIB_USE_JSON=0

ifeq ($(HAVE_JACK),true)
BASE_FLAGS += -DHAVE_JACK
JACK_FLAGS  = $(shell pkg-config --cflags --libs jack)
endif

# ---------------------------------------------------------------------------------------------------------------------
# Set plugin binary file targets

jack   = $(TARGET_DIR)/$(NAME)$(APP_EXT)
ladspa = $(TARGET_DIR)/$(NAME)-ladspa$(LIB_EXT)
lv2    = $(TARGET_DIR)/$(NAME).lv2/$(NAME)_dsp$(LIB_EXT)
vst    = $(TARGET_DIR)/$(NAME)-vst$(LIB_EXT)

# ---------------------------------------------------------------------------------------------------------------------
# Set files to build

OBJS = DistrhoPluginMaxGen.cpp.o
DISTRHO_PLUGIN_FILES = dpf/distrho/DistrhoPluginMain.cpp

# ---------------------------------------------------------------------------------------------------------------------
# all needs to be first

all:

# ---------------------------------------------------------------------------------------------------------------------
# Common

%.c.o: %.c
	$(CC) $< $(BUILD_C_FLAGS) -MD -MP -c -o $@

%.cpp.o: %.cpp
	$(CXX) $< $(BUILD_CXX_FLAGS) -MD -MP -c -o $@

clean:
	rm -f *.d *.o
	rm -rf $(TARGET_DIR)/$(NAME) $(TARGET_DIR)/$(NAME)-* $(TARGET_DIR)/$(NAME).lv2/

# ---------------------------------------------------------------------------------------------------------------------
# JACK

jack: $(jack)

$(jack): $(OBJS) $(DISTRHO_PLUGIN_FILES)
	mkdir -p $(shell dirname $@)
	$(CXX) $^ $(BUILD_CXX_FLAGS) $(LINK_FLAGS) $(JACK_FLAGS) -DDISTRHO_PLUGIN_TARGET_JACK -o $@

# ---------------------------------------------------------------------------------------------------------------------
# LADSPA

ladspa: $(ladspa)

$(ladspa): $(OBJS) $(DISTRHO_PLUGIN_FILES)
	mkdir -p $(shell dirname $@)
	$(CXX) $^ $(BUILD_CXX_FLAGS) $(LINK_FLAGS) $(SHARED) -DDISTRHO_PLUGIN_TARGET_LADSPA -o $@

# ---------------------------------------------------------------------------------------------------------------------
# LV2

lv2: $(lv2)

$(lv2): $(OBJS) $(DISTRHO_PLUGIN_FILES)
	mkdir -p $(shell dirname $@)
	$(CXX) $^ $(BUILD_CXX_FLAGS) $(LINK_FLAGS) $(SHARED) -DDISTRHO_PLUGIN_TARGET_LV2 -o $@

# ---------------------------------------------------------------------------------------------------------------------
# VST

vst: $(vst)

$(vst): $(OBJS) $(DISTRHO_PLUGIN_FILES)
	mkdir -p $(shell dirname $@)
	$(CXX) $^ $(BUILD_CXX_FLAGS) $(LINK_FLAGS) $(SHARED) -DDISTRHO_PLUGIN_TARGET_VST -o $@

# ---------------------------------------------------------------------------------------------------------------------
# Enable all possible plugin types

ifeq ($(HAVE_JACK),true)
TARGETS += jack
endif

ifeq ($(LINUX),true)
TARGETS += ladspa
endif

TARGETS += lv2
TARGETS += vst

all: $(TARGETS)

# ---------------------------------------------------------------------------------------------------------------------
# Include dependencies

-include $(OBJS:%.o=%.d)

# ---------------------------------------------------------------------------------------------------------------------
