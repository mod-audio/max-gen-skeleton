#!/bin/bash

cd $(dirname $0)

if [ ! -f plugin/gen_exported.cpp ] || [ ! -f plugin/gen_exported.h ]; then
  echo "Missing gen_exported.cpp/h files, please copy them to the plugin folder"
  exit 1
fi

set -e

NAME="testname1"
URI="urn:maxgen:testplugin1"
ID1="x"
ID2="y"
NUMINS="0"
NUMOUTS="0"

cp source/DistrhoPluginInfo.h.in source/DistrhoPluginInfo.h
echo "NAME = ${NAME}" > source/.plugin-info

sed -i "s|@NAME@|${NAME}|" source/DistrhoPluginInfo.h
sed -i "s|@URI@|${URI}|" source/DistrhoPluginInfo.h
sed -i "s|@ID1@|${ID1}|" source/DistrhoPluginInfo.h
sed -i "s|@ID2@|${ID2}|" source/DistrhoPluginInfo.h
sed -i "s|@NUMINS@|${NUMINS}|" source/DistrhoPluginInfo.h
sed -i "s|@NUMOUTS@|${NUMOUTS}|" source/DistrhoPluginInfo.h
