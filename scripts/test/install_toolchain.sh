#!/usr/bin/env bash

set -e

# this script assumes the toolchain artifact has been copied into
# the root of the repo

cd $WORK_DIR
if [ ${ARCH:0:7} = "windows" ]
then
    unzip fpga-toolchain-$ARCH-$VERSION.zip
    export PIP=pip
    export PYTHON=python
elif [ $ARCH = "darwin" ]
then
    tar -xvf fpga-toolchain-$ARCH-$VERSION.tar.gz
    brew install python@3.8
    export PIP=pip3
    export PYTHON=python3
else
    tar -xvf fpga-toolchain-$ARCH-$VERSION.tar.gz
    # sudo apt-get update && sudo apt-get install python3-setuptools
    pip3 install setuptools wheel
    export PIP=pip3
    export PYTHON=python3
fi

export PATH="$WORK_DIR/fpga-toolchain/bin:$PATH"

$PIP install git+https://github.com/nmigen/nmigen.git#egg=nmigen
$PIP install git+https://github.com/nmigen/nmigen-boards.git
