#!/bin/bash

cd $(dirname $0)

if [ ! -f plugin/gen_exported.cpp ] || [ ! -f plugin/gen_exported.h ]; then
  echo "Missing gen_exported.cpp/h files, please copy them to the plugin folder"
  exit 1
fi

set -e

if [ -n "${MAX_GEN_AUTOMATED}" ]; then
    NAME="${MAX_GEN_NAME}"
    BRAND="${MAX_GEN_BRAND}"
    SYMBOL="${MAX_GEN_SYMBOL}"
    DESCRIPTION="${MAX_GEN_DESCRIPTION}"
    LV2_CATEGORY="${MAX_GEN_LV2_CATEGORY}"
else
    echo "Please type your plugin name, then press enter to confirm"
    read NAME

    if [ "${NAME}"x == ""x ]; then
      echo "Empty plugin name, cannot continue"
      exit 1
    fi

    BRAND="MAX gen~"
    SYMBOL=$(echo ${NAME} | sed -e "s/[^A-Za-z0-9._-]/_/g")
    DESCRIPTION="MAX gen~ based plugin, automatically generated via max-gen-skeleton"
    LV2_CATEGORY="lv2:Plugin"
fi

URI="urn:maxgen:${SYMBOL}"
ID1=$(echo ${SYMBOL} | cut -c 1)
ID2=$(echo ${SYMBOL} | rev | cut -c 1)
NUMINS=$(cat plugin/gen_exported.cpp | awk 'sub("gen_kernel_numins = ","")' | rev | cut -c 2)
NUMOUTS=$(cat plugin/gen_exported.cpp | awk 'sub("gen_kernel_numouts = ","")' | rev | cut -c 2)

cp source/DistrhoPluginInfo.h.in source/DistrhoPluginInfo.h
echo "NAME = ${SYMBOL}" > source/.plugin-info

sed -i -e "s|@NAME@|${NAME}|" source/DistrhoPluginInfo.h
sed -i -e "s|@BRAND@|${BRAND}|" source/DistrhoPluginInfo.h
sed -i -e "s|@URI@|${URI}|" source/DistrhoPluginInfo.h
sed -i -e "s|@ID1@|${ID1}|" source/DistrhoPluginInfo.h
sed -i -e "s|@ID2@|${ID2}|" source/DistrhoPluginInfo.h
sed -i -e "s|@NUMINS@|${NUMINS}|" source/DistrhoPluginInfo.h
sed -i -e "s|@NUMOUTS@|${NUMOUTS}|" source/DistrhoPluginInfo.h
sed -i -e "s|@DESCRIPTION@|${DESCRIPTION}|" source/DistrhoPluginInfo.h
sed -i -e "s|@LV2_CATEGORY@|${LV2_CATEGORY}|" source/DistrhoPluginInfo.h
