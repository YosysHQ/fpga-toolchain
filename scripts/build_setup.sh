#!/bin/bash
# Build setup script

set -e

if [ $ARCH == "linux_x86_64" ]; then
    export CC="gcc"
    export CXX="g++"
    export ABC_ARCHFLAGS="-DLIN64 -DSIZEOF_VOID_P=8 -DSIZEOF_LONG=8 -DSIZEOF_INT=4"
fi

if [ $ARCH == "linux_i686" ]; then
    export CC="gcc -m32"
    export CXX="g++ -m32"
    export ABC_ARCHFLAGS="-DLIN -DSIZEOF_VOID_P=4 -DSIZEOF_LONG=4 -DSIZEOF_INT=4"
    sudo ln -s /usr/include/asm-generic /usr/include/asm
fi

if [ $ARCH == "linux_armv7l" ]; then
    export CC="arm-linux-gnueabihf-gcc"
    export CXX="arm-linux-gnueabihf-g++"
    export HOST_FLAGS="--host=arm-linux-gnueabihf"
    export ABC_ARCHFLAGS="-DLIN -DSIZEOF_VOID_P=4 -DSIZEOF_LONG=4 -DSIZEOF_INT=4"
fi

if [ $ARCH == "linux_aarch64" ]; then
    export CC="aarch64-linux-gnu-gcc"
    export CXX="aarch64-linux-gnu-g++"
    export HOST_FLAGS="--host=aarch64-linux-gnu"
    export ABC_ARCHFLAGS="-DLIN64 -DSIZEOF_VOID_P=8 -DSIZEOF_LONG=8 -DSIZEOF_INT=4"
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
fi

if [ $ARCH == "darwin" ]; then
    export CC="clang"
    export CXX="clang++"
    export ABC_ARCHFLAGS="-DLIN64 -DSIZEOF_VOID_P=8 -DSIZEOF_LONG=8 -DSIZEOF_INT=4"
    export J=`sysctl -n hw.ncpu`
    export MACOSX_DEPLOYMENT_TARGET="10.10"
else
    export J=`nproc`
fi

# Support for 1cpu machines
if [ $J -gt 1 ]; then
    J=$(($J-1))
fi
