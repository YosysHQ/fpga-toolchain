#!/usr/bin/env bash

set -e -x

if [ $ARCH == "linux_x86_64" ]; then
    # Install a copy of Python, since Python libraries are not compatible
    # across minor versions.
    mkdir -p $BUILD_DIR/libpython3
    cd $BUILD_DIR/libpython3
    for pkg in $(ls -1 ${WORK_DIR}/build-data/$ARCH/*.deb)
    do
        echo "Extracting $pkg..."
        ar p $pkg data.tar.xz | tar xJ
    done
    mkdir -p $PACKAGE_DIR/$NAME/lib/python$EMBEDDED_PY_VER
    mv usr/lib/python$EMBEDDED_PY_VER/* $PACKAGE_DIR/$NAME/lib/python$EMBEDDED_PY_VER
    cd ..

    clean_build libpython3
elif [ $ARCH == "windows_amd64" ]; then
    mkdir -p $PACKAGE_DIR/$NAME/lib/python$EMBEDDED_PY_VER
        cp -L -R /mingw64/lib/python$EMBEDDED_PY_VER $PACKAGE_DIR/$NAME/lib
        # this isn't necessary and takes up ~half the size
        rm -rf $PACKAGE_DIR/$NAME/lib/python$EMBEDDED_PY_VER/test
        cp /mingw64/bin/{libgcc_s_seh-1.dll,libstdc++-6.dll,libwinpthread-1.dll,libpython$EMBEDDED_PY_VER.dll} $PACKAGE_DIR/$NAME/bin
        cp /mingw64/bin/python$EMBEDDED_PY_VER.exe $PACKAGE_DIR/$NAME/bin/python3-private.exe
elif [ ${ARCH} == "linux_armv7l" ] || [ ${ARCH} == "linux_aarch64" ]; then
    mkdir -p $PACKAGE_DIR/$NAME/lib/python$EMBEDDED_PY_VER
    cp -L -R $BUILDROOT_SYSROOT/usr/lib/python$EMBEDDED_PY_VER $PACKAGE_DIR/$NAME/lib
elif [ $ARCH == "darwin" ]; then
    mkdir -p $PACKAGE_DIR/$NAME/lib/python$EMBEDDED_PY_VER
    cp -L -R $CONDA_ROOT/lib/python$EMBEDDED_PY_VER $PACKAGE_DIR/$NAME/lib
fi
