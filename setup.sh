#!/bin/bash

cd $(dirname $0)

if [ ! -f plugin/gen_exported.cpp ] || [ ! -f plugin/gen_exported.h ]; then
  echo "Missing gen_exported.cpp/h files, please copy them to the plugin folder"
  exit 1
fi

set -e

echo "Please type your plugin name, then press enter to confirm"
read NAME

if [ "${NAME}"x == ""x ]; then
  echo "Empty plugin name, cannot continue"
  exit 1
fi

SYMBOL=$(echo ${NAME} | sed -e "s/[^A-Za-z0-9._-]/_/g")

URI="urn:maxgen:${SYMBOL}"
ID1=$(echo ${SYMBOL} | cut -c 1)
ID2=$(echo ${SYMBOL} | rev | cut -c 1)
NUMINS=$(cat plugin/gen_exported.cpp | awk 'sub("gen_kernel_numins = ","")' | rev | cut -c 2)
NUMOUTS=$(cat plugin/gen_exported.cpp | awk 'sub("gen_kernel_numouts = ","")' | rev | cut -c 2)

cp source/DistrhoPluginInfo.h.in source/DistrhoPluginInfo.h
echo "NAME = ${NAME}" > source/.plugin-info

sed -i "s|@NAME@|${NAME}|" source/DistrhoPluginInfo.h
sed -i "s|@URI@|${URI}|" source/DistrhoPluginInfo.h
sed -i "s|@ID1@|${ID1}|" source/DistrhoPluginInfo.h
sed -i "s|@ID2@|${ID2}|" source/DistrhoPluginInfo.h
sed -i "s|@NUMINS@|${NUMINS}|" source/DistrhoPluginInfo.h
sed -i "s|@NUMOUTS@|${NUMOUTS}|" source/DistrhoPluginInfo.h
