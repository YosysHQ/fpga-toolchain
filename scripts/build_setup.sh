#!/usr/bin/env bash
# Build setup script

set -e

export MAKE="make"

if [ $ARCH == "darwin" ]; then
    export J=`sysctl -n hw.ncpu`
else
    export J=`nproc`
fi
echo nproc=$J

export SED=sed
export TARGET_PREFIX=""

if [ $ARCH == "linux_x86_64" ]; then
    export CC="gcc"
    export CXX="g++"
    export ABC_ARCHFLAGS="-DLIN64 -DSIZEOF_VOID_P=8 -DSIZEOF_LONG=8 -DSIZEOF_INT=4"
    export EMBEDDED_PY_VER=$(python3 -c 'import sys; print(str(sys.version_info[0])+"."+str(sys.version_info[1]))')
fi

if [ $ARCH == "linux_i686" ]; then
    export CC="gcc -m32"
    export CXX="g++ -m32"
    export ABC_ARCHFLAGS="-DLIN -DSIZEOF_VOID_P=4 -DSIZEOF_LONG=4 -DSIZEOF_INT=4"
    sudo ln -s /usr/include/asm-generic /usr/include/asm
fi

if [ $ARCH == "linux_armv7l" ]; then
    export TARGET_PREFIX="arm-buildroot-linux-gnueabihf-"
    export CC="${TARGET_PREFIX}gcc"
    export CXX="${TARGET_PREFIX}g++"
    export GNATMAKE="${TARGET_PREFIX}gnatmake"
    export HOST_FLAGS="--host=arm-buildroot-linux-gnueabihf"
    export ABC_ARCHFLAGS="-DLIN -DSIZEOF_VOID_P=4 -DSIZEOF_LONG=4 -DSIZEOF_INT=4"

    export BUILDROOT_SDK_PATH="/tmp/arm-buildroot-linux-gnueabihf_sdk-buildroot"
    export PATH="$BUILDROOT_SDK_PATH/bin:$PATH"
    export BUILDROOT_SYSROOT="$BUILDROOT_SDK_PATH/arm-buildroot-linux-gnueabihf/sysroot"
fi

if [ $ARCH == "linux_aarch64" ]; then
    export TARGET_PREFIX="aarch64-buildroot-linux-gnu-"
    export CC="aarch64-buildroot-linux-gnu-gcc"
    export CXX="aarch64-buildroot-linux-gnu-g++"
    export GNATMAKE="${TARGET_PREFIX}gnatmake"
    export HOST_FLAGS="--host=aarch64-buildroot-linux-gnu"
    export ABC_ARCHFLAGS="-DLIN64 -DSIZEOF_VOID_P=8 -DSIZEOF_LONG=8 -DSIZEOF_INT=4"
    export BUILDROOT_SDK_PATH="/tmp/aarch64-buildroot-linux-gnu_sdk-buildroot"
    export BUILDROOT_SYSROOT="$BUILDROOT_SDK_PATH/aarch64-buildroot-linux-gnu/sysroot"
    export PATH="$BUILDROOT_SDK_PATH/bin:$PATH"
fi

if [ $ARCH == "windows_x86" ]; then
    export PY=".py"
    export EXE=".exe"
    export CC="i686-w64-mingw32-gcc"
    export CXX="i686-w64-mingw32-g++"
    export HOST_FLAGS="--host=i686-w64-mingw32"
    export ABC_ARCHFLAGS="-DSIZEOF_VOID_P=4 -DSIZEOF_LONG=4 -DSIZEOF_INT=4 -DWIN32_NO_DLL -DHAVE_STRUCT_TIMESPEC -D_POSIX_SOURCE -fpermissive -w"
fi

if [ $ARCH == "windows_amd64" ]; then
    export PY=".py"
    export EXE=".exe"
    export CC="x86_64-w64-mingw32-gcc"
    export CXX="x86_64-w64-mingw32-g++"
    export HOST_FLAGS="--host=x86_64-w64-mingw32"
    export ABC_ARCHFLAGS="-DSIZEOF_VOID_P=8 -DSIZEOF_LONG=4 -DSIZEOF_INT=4 -DWIN32_NO_DLL -DHAVE_STRUCT_TIMESPEC -D_POSIX_SOURCE -fpermissive -w"
    export MAKE="mingw32-make"

    export EMBEDDED_PY_VER=$(python.exe -c 'import sys; print(str(sys.version_info[0])+"."+str(sys.version_info[1]))')

    export J=$(($J*2))
fi

if [ $ARCH == "darwin" ]; then
    export CC="clang"
    export CXX="clang++"
    export ABC_ARCHFLAGS="-DLIN64 -DSIZEOF_VOID_P=8 -DSIZEOF_LONG=8 -DSIZEOF_INT=4"
    export J=`sysctl -n hw.ncpu`
    export MACOSX_DEPLOYMENT_TARGET="10.10"

    export LIBFTDI_VERSION=$(brew list --versions libftdi | tr ' ' '\n' | tail -1)
    export LIBFTDI_ROOT=$(brew --cellar libftdi)/$LIBFTDI_VERSION
    export LIBUSB_VERSION=$(brew list --versions libusb | tr ' ' '\n' | tail -1)
    export LIBUSB_ROOT=$(brew --cellar libusb)/$LIBUSB_VERSION
    export ZLIB_ROOT=$(brew --cellar zlib)/$(brew list --versions zlib | tr ' ' '\n' | tail -1)
    export CONDA_ROOT=/tmp/conda
    export EMBEDDED_PY_VER=$($CONDA_ROOT/bin/python -c 'import sys; print(str(sys.version_info[0])+"."+str(sys.version_info[1]))')

    GNAT_VERSION=9.1.0
    GNAT_ARCHIVE=gcc-$GNAT_VERSION-x86_64-apple-darwin15-bin
    export GNAT_ROOT=/tmp/gnat/$GNAT_ARCHIVE
    export SED=gsed
fi

echo Running with J=$J
