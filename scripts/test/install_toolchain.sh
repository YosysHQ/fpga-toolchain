#!/usr/bin/env bash

set -e

# this script assumes the toolchain artifact has been copied into
# the root of the repo

cd $WORK_DIR

SUDO="sudo"
if [ ${ARCH} == "linux_armv7l" ] || [ ${ARCH} == "linux_aarch64" ]; then
    # already root in these containers and sudo is not installed
    SUDO=""
fi

if [ ${ARCH:0:7} = "windows" ]
then
    unzip fpga-toolchain-$ARCH-$VERSION.zip
    export PIP=pip
    export PYTHON=python
    export SED=sed
elif [ $ARCH = "darwin" ]
then
    tar -xvf fpga-toolchain-$ARCH-$VERSION.tar.gz
    brew install python@3.8 gnu-sed
    export PIP=pip3
    export PYTHON=python3
    export SED=gsed
else
    tar -xvf fpga-toolchain-$ARCH-$VERSION.tar.gz

    # install python 3.6 on ubuntu 16.04 for nmigen
    # TODO: test on non-debian distros
    $SUDO apt-get update
    $SUDO apt-get install -y --no-install-recommends software-properties-common
    $SUDO add-apt-repository -y -u ppa:deadsnakes/ppa
    $SUDO apt-get install -y --no-install-recommends python3.6 python3-pip

    export PIP="python3.6 -m pip"
    export PYTHON=python3.6
    export SED=sed
    $PIP install --upgrade pip
    $PIP install setuptools wheel
fi

export PATH="$WORK_DIR/fpga-toolchain/bin:$PATH"
export GHDL_PREFIX="$WORK_DIR/fpga-toolchain/lib/ghdl"

$PIP install git+https://github.com/nmigen/nmigen.git#egg=nmigen
$PIP install git+https://github.com/nmigen/nmigen-boards.git
