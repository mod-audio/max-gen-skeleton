#!/bin/bash

BASENAME=arm-mod-linux-gnueabihf
OPTS_BASE="-O3 -mcpu=cortex-a7 -mtune=cortex-a7 -mfpu=neon-vfpv4 -mfloat-abi=hard -mvectorize-with-neon-quad"
OPTS_AGGRESSIVE="$OPTS_BASE -ffast-math -fno-finite-math-only -fprefetch-loop-arrays -funroll-loops -funsafe-loop-optimizations"

export PATH=$(dirname $0)/toolchain/toolchain:$PATH

export AR=$BASENAME-gcc-ar
export CC=$BASENAME-gcc
export CPP=$BASENAME-cpp
export CXX=$BASENAME-g++
export LD=$BASENAME-ld
export STRIP=$BASENAME-strip

export CFLAGS=$OPTS_AGGRESSIVE
export CXXFLAGS=$OPTS_AGGRESSIVE
export LDFLAGS="-Wl,-O1 -Wl,--as-needed -Wl,--strip-all -Wl,--no-undefined"

unset CPPFLAGS
unset BASENAME
unset OPTS_BASE
unset OPTS_AGGRESSIVE
