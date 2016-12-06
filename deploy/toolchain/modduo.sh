#!/bin/bash

set -e

#######################################################################################################################
# Colored print functions

function download {
  if (which curl 1>/dev/null); then
    curl $1 -o $2
  else
    wget $1 -O $2
   fi
}

#######################################################################################################################

CT_NG_LINK=http://crosstool-ng.org/download/crosstool-ng/
CT_NG_VERSION=crosstool-ng-1.22.0
CT_NG_FILE=${CT_NG_VERSION}.tar.bz2

#######################################################################################################################
# setup directories

SOURCE_DIR=$(cd "$(dirname "$0")"; pwd)
BUILD_DIR=${SOURCE_DIR}/build
DOWNLOAD_DIR=${SOURCE_DIR}/download
TOOLCHAIN_DIR=${SOURCE_DIR}/toolchain

mkdir -p ${BUILD_DIR}
mkdir -p ${DOWNLOAD_DIR}
mkdir -p ${TOOLCHAIN_DIR}

#######################################################################################################################
# download and extract crosstool-ng

if [ ! -f ${BUILD_DIR}/${CT_NG_VERSION}/configure ]; then
  if [ ! -f ${DOWNLOAD_DIR}/${CT_NG_FILE} ]; then
    download ${CT_NG_LINK}/${CT_NG_FILE} ${DOWNLOAD_DIR}/${CT_NG_FILE}
  fi

  mkdir -p ${BUILD_DIR}/${CT_NG_VERSION}
  tar xf ${DOWNLOAD_DIR}/${CT_NG_FILE} -C ${BUILD_DIR}/${CT_NG_VERSION} --strip-components=1
fi

#######################################################################################################################
# build crosstool-ng

cd ${BUILD_DIR}/${CT_NG_VERSION}

if [ ! -f .config ]; then
  cp ${SOURCE_DIR}/modduo.config .config
  sed -i -e "s|CT_LOCAL_TARBALLS_DIR=.*|CT_LOCAL_TARBALLS_DIR=\"${DOWNLOAD_DIR}\"|" .config
  sed -i -e "s|CT_PREFIX_DIR=.*|CT_PREFIX_DIR=\"${TOOLCHAIN_DIR}\"|" .config
fi

if [ ! -f .stamp_configured ]; then
  ./configure --enable-local
  touch .stamp_configured
fi

if [ ! -f .stamp_built1 ]; then
  make
  touch .stamp_built1
fi

if [ ! -f .stamp_built2 ]; then
  ./ct-ng build
  touch .stamp_built2
fi

#######################################################################################################################
