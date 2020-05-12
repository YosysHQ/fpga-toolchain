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

    export EMBEDDED_PY_VER=$(python.exe -c 'import sys; print(str(sys.version_info[0])+"."+str(sys.version_info[1]))')
    mkdir -p $PACKAGE_DIR/$NAME/lib/python$EMBEDDED_PY_VER
    cp -L -R /c/msys64/mingw64/lib/python$EMBEDDED_PY_VER $PACKAGE_DIR/$NAME/lib
    # this isn't necessary and takes up ~half the size
    rm -rf $PACKAGE_DIR/$NAME/lib/python$EMBEDDED_PY_VER/test
    cp /c/msys64/mingw64/bin/{libgcc_s_seh-1.dll,libstdc++-6.dll,libwinpthread-1.dll,libpython$EMBEDDED_PY_VER.dll} $PACKAGE_DIR/$NAME/bin
fi

if [ $ARCH == "darwin" ]; then
    export CC="clang"
    export CXX="clang++"
    export ABC_ARCHFLAGS="-DLIN64 -DSIZEOF_VOID_P=8 -DSIZEOF_LONG=8 -DSIZEOF_INT=4"
    export J=`sysctl -n hw.ncpu`
    export MACOSX_DEPLOYMENT_TARGET="10.10"

    export LIBFTDI_ROOT=$(brew --cellar libftdi)/$(brew list --versions libftdi | tr ' ' '\n' | tail -1)
    export LIBUSB_ROOT=$(brew --cellar libusb)/$(brew list --versions libusb | tr ' ' '\n' | tail -1)
    export CONDA_ROOT=/tmp/conda
    export EMBEDDED_PY_VER=$($CONDA_ROOT/bin/python -c 'import sys; print(str(sys.version_info[0])+"."+str(sys.version_info[1]))')

    mkdir -p $PACKAGE_DIR/$NAME/lib/python$EMBEDDED_PY_VER
    cp -L -R $CONDA_ROOT/lib/python$EMBEDDED_PY_VER $PACKAGE_DIR/$NAME/lib
else
    export J=`nproc`
fi

# Support for 1cpu machines
if [ $J -gt 1 ]; then
    J=$(($J-1))
fi
