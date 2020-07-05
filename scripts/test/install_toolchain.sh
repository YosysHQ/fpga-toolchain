#!/usr/bin/env bash

# this script assumes the toolchain artifact has been copied into
# the root of the repo

cd $WORK_DIR
if [ ${ARCH:0:7} = "windows" ]
then
    unzip fpga-toolchain-$ARCH-$VERSION.zip
else
    tar -xvf fpga-toolchain-$ARCH-$VERSION.tar.gz
fi

export PATH="$WORK_DIR/fpga-toolchain/bin:$PATH"
