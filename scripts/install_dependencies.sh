#!/usr/bin/env bash
#
# Install dependencies script

set -e

base_packages="build-essential bison flex libreadline-dev \
               gawk tcl-dev libffi-dev git rsync wget curl \
               pkg-config python3 cmake autotools-dev automake gperf gnat"

cross_x64="libboost-dev libboost-filesystem-dev libboost-thread-dev \
           libboost-program-options-dev libboost-python-dev libboost-iostreams-dev \
           libboost-system-dev libboost-chrono-dev libboost-date-time-dev \
           libboost-atomic-dev libboost-regex-dev libpython3-dev libeigen3-dev \
           libgmp-dev"
for b in $cross_x64; do
    cross_arm64="$cross_arm64 $b:arm64"
    cross_armhf="$cross_armhf $b:armhf"
    cross_i386="$cross_i386 $b:i386"
done

if [ $ARCH == "linux_x86_64" ]; then
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y $base_packages $cross_x64
    gcc --version
    g++ --version
fi

if [ $ARCH == "linux_i686" ]; then
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y $base_packages $cross_i386 \
                            gcc-multilib g++-multilib
    sudo ln -s /usr/include/asm-generic /usr/include/asm
    gcc --version
    g++ --version
fi

if [ $ARCH == "linux_armv7l" ]; then
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y $base_packages \
                            qemu-user-static
    wget_retry --progress=dot https://github.com/open-tool-forge/buildroot-arm/releases/download/0.0.1/buildroot_${ARCH}.tar.gz
    tar xvf buildroot_${ARCH}.tar.gz -C /tmp
    /tmp/arm-buildroot-linux-gnueabihf_sdk-buildroot/relocate-sdk.sh

    /tmp/arm-buildroot-linux-gnueabihf_sdk-buildroot/bin/arm-buildroot-linux-gnueabihf-gcc --version
    /tmp/arm-buildroot-linux-gnueabihf_sdk-buildroot/bin/arm-buildroot-linux-gnueabihf-g++ --version
fi

if [ $ARCH == "linux_aarch64" ]; then
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y $base_packages \
                            qemu-user-static
    wget_retry --progress=dot https://github.com/open-tool-forge/buildroot-arm/releases/download/0.0.1/buildroot_${ARCH}.tar.gz
    tar xvf buildroot_${ARCH}.tar.gz -C /tmp
    /tmp/aarch64-buildroot-linux-gnu_sdk-buildroot_sdk-buildroot/relocate-sdk.sh

    /tmp/aarch64-buildroot-linux-gnu_sdk-buildroot_sdk-buildroot/bin/aarch64-buildroot-linux-gnu_sdk-buildroot-gcc --version
    /tmp/aarch64-buildroot-linux-gnu_sdk-buildroot_sdk-buildroot/bin/aarch64-buildroot-linux-gnu_sdk-buildroot-g++ --version
fi

if [ $ARCH == "windows_amd64" ]; then
    pacman --noconfirm --needed -S git base-devel mingw-w64-x86_64-toolchain mingw-w64-x86_64-cmake \
    mingw-w64-x86_64-boost mingw-w64-x86_64-eigen3 rsync unzip zip mingw-w64-x86_64-libftdi bison flex \
    mingw-w64-x86_64-gcc-ada p7zip mingw-w64-x86_64-jsoncpp

    x86_64-w64-mingw32-gcc --version
    x86_64-w64-mingw32-g++ --version
fi

if [ $ARCH == "darwin" ]; then
    sudo xcode-select -s /Applications/Xcode_11.4.1.app/Contents/Developer
    # yosys detects some of these tools if a homebrew version is installed
    # so we may not need to add all of them to PATH
    brew install automake pkg-config bison flex gawk libffi git graphviz xdot bash cmake boost boost-python3 eigen \
        libftdi libusb zlib libedit ncurses bzip2 gnu-sed

    wget_retry --progress=dot https://repo.anaconda.com/miniconda/Miniconda3-4.7.12.1-MacOSX-x86_64.sh -O miniconda.sh
    bash miniconda.sh -b -p /tmp/conda
    source /tmp/conda/bin/activate base
    conda env update -n base -f $WORK_DIR/build-data/darwin/environment.yml
    conda deactivate

    GNAT_VERSION=9.1.0
    GNAT_ARCHIVE=gcc-$GNAT_VERSION-x86_64-apple-darwin15-bin
    mkdir -p /tmp/gnat
    wget_retry https://sourceforge.net/projects/gnuada/files/GNAT_GCC%20Mac%20OS%20X/$GNAT_VERSION/native/$GNAT_ARCHIVE.tar.bz2
    tar jxvf $GNAT_ARCHIVE.tar.bz2 -C /tmp/gnat
    export GNAT_ROOT=/tmp/gnat/$GNAT_ARCHIVE
else
    cp $WORK_DIR/build-data/lib/$ARCH/libftdi1.a $WORK_DIR/build-data/lib/$ARCH/libftdi.a
fi
