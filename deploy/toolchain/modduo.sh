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
export PKG_CONFIG_PATH=${SYSPREFIX_DIR}/lib/pkgconfig

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
  OPTS=$4

  if [ ! -d ${DOWNLOAD_DIR}/${NAME}.${EXT} ]; then
    if [ ! -f ${DOWNLOAD_DIR}/${NAME}.${EXT} ]; then
      download ${URL}/${NAME}.${EXT} ${DOWNLOAD_DIR}/${NAME}.${EXT}
    fi
    mkdir -p ${BUILD_DIR}/${NAME}
    tar xf ${DOWNLOAD_DIR}/${NAME}.${EXT} -C ${BUILD_DIR}/${NAME} --strip-components=1
  fi

  cd ${BUILD_DIR}/${NAME}

  if [ ! -f .stamp_configured ]; then
    ./configure --prefix=${SYSPREFIX_DIR} $OPTS
    touch .stamp_configured
  fi

  make
}

#######################################################################################################################
# Special Mac OS setup

if [ -d /System/Library ]; then
  if [ ! -f ${SYSPREFIX_DIR}/bin/sed ]; then
    build_for_osx http://ftp.gnu.org/gnu/sed sed-4.2.2 tar.bz2
    make install
  fi
  if [ ! -f ${SYSPREFIX_DIR}/bin/whoami ]; then
    build_for_osx http://ftp.gnu.org/gnu/coreutils coreutils-8.26 tar.xz
    make install
  fi
  if [ ! -f ${SYSPREFIX_DIR}/bin/libtool ]; then
    build_for_osx http://ftp.gnu.org/gnu/libtool libtool-2.2.10 tar.gz
    make install
  fi
  if [ ! -f ${SYSPREFIX_DIR}/bin/gawk ]; then
    build_for_osx http://ftp.gnu.org/gnu/gawk gawk-3.1.8 tar.bz2
    make install
  fi
  if [ ! -f ${SYSPREFIX_DIR}/bin/objdump ]; then
    build_for_osx http://ftp.gnu.org/gnu/binutils binutils-2.26.1 tar.bz2
    cp binutils/obj{dump,copy} binutils/readelf ${SYSPREFIX_DIR}/bin/
  fi
#   if [ ! -f ${SYSPREFIX_DIR}/include/gmp.h ]; then
#     build_for_osx http://ftp.gnu.org/gnu/gmp gmp-6.1.1 tar.xz
#     make install
#   fi
#   if [ ! -f ${SYSPREFIX_DIR}/bin/nettle-hash ]; then
#     build_for_osx http://ftp.gnu.org/gnu/nettle nettle-3.3 tar.gz
#     make install
#   fi
#   if [ ! -f ${SYSPREFIX_DIR}/bin/TODO ]; then
#     build_for_osx http://ftp.gnu.org/gnu/gnutls gnutls-2.12.21 tar.bz2
#     make install
#   fi
  if [ ! -f ${SYSPREFIX_DIR}/bin/wget ]; then
    build_for_osx http://ftp.gnu.org/gnu/wget wget-1.18 tar.xz --with-ssl=openssl
    make install
  fi
  if [ ! -f ${SYSPREFIX_DIR}/bin/help2man ]; then
    build_for_osx http://ftp.gnu.org/gnu/help2man help2man-1.47.4 tar.xz
    make install
  fi
fi

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
