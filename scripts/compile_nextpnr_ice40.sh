#!/usr/bin/env bash
# -- Compile nextpnr-ice40 script

set -e

dir_name=nextpnr-ice40
commit=master
git_url=https://github.com/YosysHQ/nextpnr.git

git_clone $dir_name $git_url $commit

cd $BUILD_DIR/$dir_name

if [ -e CMakeCache.txt ]
then
  echo "CMakeCache.txt exists!"
fi
rm -f CMakeCache.txt

# -- Compile it
if [ $ARCH == "darwin" ]; then
  cmake -DARCH=ice40 \
    -DBoost_USE_STATIC_LIBS=ON \
    -DPYTHON_EXECUTABLE=$CONDA_ROOT/bin/python \
    -DPYTHON_LIBRARY=$CONDA_ROOT/lib/libpython$EMBEDDED_PY_VER.a \
    -DBUILD_GUI=OFF \
    -DBUILD_HEAP=ON \
    -DCMAKE_EXE_LINKER_FLAGS='-fno-lto -ldl -lutil' \
    -DICESTORM_INSTALL_PREFIX=$PACKAGE_DIR/$NAME/share/icebox \
    -DSTATIC_BUILD=ON \
    .
    make -j$J CXX="$CXX" LIBS="-lm -fno-lto -ldl -lutil"
elif [ ${ARCH:0:7} == "windows" ]; then
    cmake \
      -G "MinGW Makefiles" \
      -DARCH=ice40 \
      -DBUILD_HEAP=ON \
      -DBUILD_GUI=OFF \
      -DBUILD_PYTHON=ON \
      -DSTATIC_BUILD=ON \
      -DICESTORM_INSTALL_PREFIX=$PACKAGE_DIR/$NAME/share/icebox \
      -DBoost_USE_STATIC_LIBS=ON \
      .

    $MAKE -j$J CXX="$CXX" VERBOSE=1

elif [ ${ARCH} == "linux_armv7l" ] || [ ${ARCH} == "linux_aarch64" ]; then
    pushd bba
    CC=gcc CXX=g++ cmake .
    CC=gcc CXX=g++ make
    popd

      cmake \
        -DCMAKE_TOOLCHAIN_FILE=$WORK_DIR/scripts/toolchain_${ARCH}.cmake \
        -DARCH=ice40 \
        -DBBA_IMPORT=$BUILD_DIR/$dir_name/bba/bba-export.cmake \
        -DBUILD_HEAP=ON \
        -DBUILD_GUI=OFF \
        -DBUILD_PYTHON=ON \
        -DPYTHON_LIBRARY=$BUILDROOT_SYSROOT/usr/lib/python3.8/config-3.8-arm-linux-gnueabihf/libpython$EMBEDDED_PY_VER.a \
        -DSTATIC_BUILD=ON \
        -DICESTORM_INSTALL_PREFIX=$PACKAGE_DIR/$NAME/share/icebox \
        -DBoost_USE_STATIC_LIBS=ON \
        .
    make -j$J CXX="$CXX"
else
    cmake \
        -DARCH=ice40 \
        -DBUILD_HEAP=ON \
        -DBUILD_GUI=OFF \
        -DSTATIC_BUILD=ON \
        -DICESTORM_INSTALL_PREFIX=$PACKAGE_DIR/$NAME/share/icebox \
        -DBoost_USE_STATIC_LIBS=ON \
        .
    make -j$J CXX="$CXX"
fi || exit 1

# -- Copy the executable to the bin dir
mkdir -p $PACKAGE_DIR/$NAME/bin
cp nextpnr-ice40$EXE $PACKAGE_DIR/$NAME/bin/nextpnr-ice40$EXE

strip_binaries bin/nextpnr-ice40$EXE

clean_build $dir_name
