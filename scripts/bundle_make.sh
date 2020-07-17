#!/usr/bin/env bash

set -e

MAKE_VERSION=4.3
MAKE_URL_WIN=https://sourceforge.net/projects/ezwinports/files/make-$MAKE_VERSION-without-guile-w32-bin.zip/download

mkdir -p $BUILD_DIR/gnu_make
cd $BUILD_DIR/gnu_make

if [ ${ARCH:0:7} = "windows" ]
then
    wget $MAKE_URL_WIN -O gnumake.zip
    unzip gnumake.zip
    cp bin/make.exe $PACKAGE_DIR/$NAME/bin/
else
    print "Skipping bundling make (this platform should provide its own version of this tool)"
fi

clean_build gnu_make
