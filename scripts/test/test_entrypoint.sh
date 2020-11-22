#!/usr/bin/env bash

set -e

export ARCH=$1

if [ ${ARCH} == "linux_armv7l" ] || [ ${ARCH} == "linux_aarch64" ]
then
    if [ ${ARCH} == "linux_armv7l" ]; then
        QUS_ARCH="arm"
        DOCKER_IMAGE="arm32v7/ubuntu:16.04"
    else
        QUS_ARCH="aarch64"
        DOCKER_IMAGE="aarch64/ubuntu:16.04"
    fi

    # QUS allows us to easily run an arm container (uses QEMU behind the scenes)
    # sudo docker run --rm --privileged aptman/qus -s -- -p $QUS_ARCH
    docker run --env VERSION $(awk 'BEGIN{for(v in ENVIRON) if (v ~ /TEST_/) { print "--env "v }}') \
        -v `pwd`:/fpga-toolchain -w /fpga-toolchain \
        $DOCKER_IMAGE /fpga-toolchain/scripts/test/run_tests.sh $ARCH
else
    ./scripts/test/run_tests.sh $ARCH
fi
