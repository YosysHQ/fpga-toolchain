#!/usr/bin/env bash

set -e

YICES2_VERSION=2.6.2
YICES2_URL_WIN=https://yices.csl.sri.com/releases/$YICES2_VERSION/yices-$YICES2_VERSION-x86_64-pc-mingw32-static-gmp.zip
YICES2_URL_DARWIN=https://yices.csl.sri.com/releases/$YICES2_VERSION/yices-$YICES2_VERSION-x86_64-apple-darwin18.7.0-static-gmp.tar.gz
YICES2_URL_LINUX=https://yices.csl.sri.com/releases/$YICES2_VERSION/yices-$YICES2_VERSION-x86_64-pc-linux-gnu-static-gmp.tar.gz

mkdir -p $BUILD_DIR/yices2
cd $BUILD_DIR/yices2

if [ $ARCH == "darwin" ]
then
    wget $YICES2_URL_DARWIN -O yices2.tar.gz
    tar xvf yices2.tar.gz
    cp -R yices-*/bin/* $PACKAGE_DIR/$NAME/bin/
elif [ ${ARCH:0:7} = "windows" ]
then
    wget $YICES2_URL_WIN -O yices2.zip
    unzip yices2.zip
    cp -R yices-*/bin/* $PACKAGE_DIR/$NAME/bin/
else
    wget $YICES2_URL_LINUX -O yices2.tar.gz
    tar xvf yices2.tar.gz
    cp -R yices-*/bin/* $PACKAGE_DIR/$NAME/bin/
fi

strip_binaries bin/{yices,yices-sat,yices-smt,yices-smt2}$EXE
