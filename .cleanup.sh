#!/bin/bash

cd $(dirname $0)

touch source/.plugin-info
make clean

rm -f source/DistrhoPluginInfo.h
rm -f source/.plugin-info
