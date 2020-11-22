#!/usr/bin/env bash

set -e

export ARCH=$1

if [ ${ARCH} == "linux_armv7l" ] || [ ${ARCH} == "linux_aarch64" ]
then
    if [ ${ARCH} == "linux_armv7l" ]; then
        DOCKER_ARCH="arm"
    else
        DOCKER_ARCH="aarch64"
    fi

    # QUS allows us to easily run an arm container (uses QEMU behind the scenes)
    sudo docker run --rm --privileged aptman/qus -s -- -p $DOCKER_ARCH
    docker run --env VERSION -v `pwd`:/fpga-toolchain $DOCKER_ARCH/ubuntu:16.04 /fpga-toolchain/scripts/test/run_tests.sh $ARCH
else
    ./scripts/test/run_tests.sh $ARCH
fi
