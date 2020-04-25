#!/bin/bash
#
# Install dependencies script

set -e

base_packages="build-essential bison flex libreadline-dev \
               gawk tcl-dev libffi-dev git rsync \
               pkg-config python3 python3 python3.6-dev libpython3.6-dev cmake"

cross_x64="libboost-dev libboost-filesystem-dev libboost-thread-dev \
           libboost-program-options-dev libboost-python-dev libboost-iostreams-dev \
           libboost-system-dev libboost-chrono-dev libboost-date-time-dev \
           libboost-atomic-dev libboost-regex-dev libpython3.6-dev libeigen3-dev"
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
    # TODO(edbordin): do we need gcc-7 specifically still?
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y $base_packages $cross_armhf \
                            gcc-arm-linux-gnueabihf \
                            g++-arm-linux-gnueabihf \
                            binfmt-support \
                            gcc-7-arm-linux-gnueabihf \
                            g++-7-arm-linux-gnueabihf \
                            qemu-user-static
    arm-linux-gnueabihf-gcc --version
    arm-linux-gnueabihf-g++ --version
fi

if [ $ARCH == "linux_aarch64" ]; then
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y $base_packages $cross_arm64 \
                            gcc-aarch64-linux-gnu \
                            g++-aarch64-linux-gnu  \
                            binfmt-support qemu-user-static

    aarch64-linux-gnu-gcc --version
    aarch64-linux-gnu-g++ --version
fi

if [ $ARCH == "windows_x86" ]; then
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y $base_packages \
                            mingw-w64 mingw-w64-tools mingw-w64-i686-dev \
                            zip

#   this was used to cross-compile nextpnr-ecp5 for Windows but we can't build native python libs
#   for Windows with MinGW (CPython on Windows is built with MSVC) and the built python libs are run as part
#   of the build process
# 
#   sudo apt-get install -y build-essential bison flex libreadline-dev \
#                           gawk tcl-dev libffi-dev git mercurial graphviz \
#                           xdot pkg-config python3.5-dev qt5-default libqt5opengl5-dev $BOOST \
#                           gcc-5-mingw-w64 gc++-5-mingw-w64 wine libeigen3-dev qtbase5-dev libpython3.5-dev zip
#                           #mingw-w64 mingw-w64-tools
#   sudo apt-get autoremove -y
#   ln -s /usr/include/x86_64-linux-gnu/zconf.h /usr/include
#   sudo update-alternatives \
#     --install /usr/bin/i686-w64-mingw32-gcc i686-w64-mingw32-gcc /usr/bin/i686-w64-mingw32-gcc-5 60 \
#     --slave /usr/bin/i686-w64-mingw32-g++ i686-w64-mingw32-g++ /usr/bin/i686-w64-mingw32-g++-5

    i686-w64-mingw32-gcc --version
    i686-w64-mingw32-g++ --version
fi

if [ $ARCH == "windows_amd64" ]; then
    sudo DEBIAN_FRONTEND=noninteractiveapt-get install -y $base_packages \
                            mingw-w64 mingw-w64-tools mingw-w64-x86-64-dev \
                            zip

#   this was used to cross-compile nextpnr-ecp5 for Windows but we can't build native python libs
#   for Windows with MinGW (CPython on Windows is built with MSVC) and the built python libs are run as part
#   of the build process
#   sudo apt-get install -y build-essential bison flex libreadline-dev \
#                           gawk tcl-dev libffi-dev git mercurial graphviz \
#                           xdot pkg-config python3.5-dev qt5-default libqt5opengl5-dev $BOOST \
#                           gcc-5-mingw-w64 gc++-5-mingw-w64 wine libeigen3-dev qtbase5-dev libpython3.5-dev zip
#                           #mingw-w64 mingw-w64-tools
#   sudo apt-get autoremove -y
#   ln -s /usr/include/x86_64-linux-gnu/zconf.h /usr/include
#   sudo update-alternatives \
#     --install /usr/bin/x86_64-w64-mingw32-gcc x86_64-w64-mingw32-gcc /usr/bin/x86_64-w64-mingw32-gcc-5 60 \
#     --slave /usr/bin/x86_64-w64-mingw32-g++ x86_64-w64-mingw32-g++ /usr/bin/x86_64-w64-mingw32-g++-5

    x86_64-w64-mingw32-gcc --version
    x86_64-w64-mingw32-g++ --version
fi

if [ $ARCH == "darwin" ]; then
    export PATH=/tmp/conda/bin:$PATH
    for dep in $(ls -1 $WORK_DIR/build-data/darwin/*.bz2)
    do
        mkdir -p /tmp/conda
        pushd /tmp/conda
        echo "Extracting $dep..."
        tar xjf $dep
        if [ -e info/has_prefix ]
        then
            python3 $WORK_DIR/build-data/darwin/convert.py /tmp/conda
            rm -f info/has_prefix
        fi
        popd
    done
    echo copying libftdi1 to libftdi
    cp /tmp/conda/lib/libftdi1.a /tmp/conda/lib/libftdi.a
    cp /tmp/conda/lib/libftdi1.dylib /tmp/conda/lib/libftdi.dylib
else
    cp $WORK_DIR/build-data/lib/$ARCH/libftdi1.a $WORK_DIR/build-data/lib/$ARCH/libftdi.a
fi
