#!/bin/bash

set -e

#######################################################################################################################
# crosstool-ng variables

CT_NG_LINK=http://crosstool-ng.org/download/crosstool-ng/
CT_NG_VERSION=crosstool-ng-1.22.0
CT_NG_FILE=${CT_NG_VERSION}.tar.bz2

#######################################################################################################################
# setup directories

SOURCE_DIR=$(cd "$(dirname "$0")"; pwd)
BUILD_DIR=${SOURCE_DIR}/build
DOWNLOAD_DIR=${SOURCE_DIR}/download
SYSPREFIX_DIR=${SOURCE_DIR}/sysprefix
TOOLCHAIN_DIR=${SOURCE_DIR}/toolchain

mkdir -p ${BUILD_DIR}
mkdir -p ${DOWNLOAD_DIR}
mkdir -p ${SYSPREFIX_DIR}/bin
mkdir -p ${TOOLCHAIN_DIR}

export PATH=${SYSPREFIX_DIR}/bin:$PATH

#######################################################################################################################
# Misc functions

function download {
  if (which curl 1>/dev/null); then
    curl $1 -o $2
  else
    wget $1 -O $2
   fi
}

function build_for_osx {
  URL=$1
  NAME=$2
  EXT=$3

  download ${URL}/${NAME}.${EXT} ${DOWNLOAD_DIR}/${NAME}.${EXT}

  mkdir -p ${BUILD_DIR}/${NAME}
  tar xf ${DOWNLOAD_DIR}/${NAME}.${EXT} -C ${BUILD_DIR}/${NAME} --strip-components=1

  cd ${BUILD_DIR}/${NAME}
  ./configure --prefix=${SYSPREFIX_DIR}
  make
}

#######################################################################################################################
# Special Mac OS setup

if [ -d /System/Library ]; then
  if [ ! -f ${SYSPREFIX_DIR}/bin/sed ]; then
    build_for_osx http://ftp.gnu.org/gnu/sed sed-4.2.1 tar.bz2
    make install
  fi
  if [ ! -f ${SYSPREFIX_DIR}/bin/objdump ]; then
    build_for_osx http://ftp.gnu.org/gnu/binutils binutils-2.19.1 tar.bz2
    cp binutils/obj{dump,copy} /usr/local/bin
  fi
fi

#     58     curl -O http://ftp.gnu.org/gnu/coreutils/coreutils-7.4.tar.gz
#     59     tar -xf coreutils-7.4.tar.gz
#     60     cd coreutils-7.4
#     61     ./configure --prefix=/usr/local
#     62     make -j 2
#     63     sudo make install
#
#     67     curl -O http://ftp.gnu.org/gnu/libtool/libtool-2.2.6a.tar.gz
#     68     tar -xf libtool-2.2.6a.tar.gz
#     69     cd libtool-2.2.6
#     70     ./configure --prefix=/usr/local
#     71     make -j 2
#     72     sudo make install
#
#     76     curl -O http://ftp.gnu.org/gnu/gawk/gawk-3.1.7.tar.bz2
#     77     tar -xf gawk-3.1.7.tar.bz2
#     78     cd gawk-3.1.7
#     79     ./configure --prefix=/usr/local
#     80     make -j 2
#     81     sudo make install
#     82

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
