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
    -DICEBOX_ROOT=$PACKAGE_DIR/$NAME/share/icebox \
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
      -DICEBOX_ROOT=$PACKAGE_DIR/$NAME/share/icebox \
      -DBoost_USE_STATIC_LIBS=ON \
      .

    $MAKE -j$J CXX="$CXX" VERBOSE=1
else
    cmake \
        -DARCH=ice40 \
        -DBUILD_HEAP=ON \
        -DBUILD_GUI=OFF \
        -DSTATIC_BUILD=ON \
        -DICEBOX_ROOT=$PACKAGE_DIR/$NAME/share/icebox \
        -DBoost_USE_STATIC_LIBS=ON \
        .
    make -j$J CXX="$CXX"
fi || exit 1

# -- Copy the executable to the bin dir
mkdir -p $PACKAGE_DIR/$NAME/bin
cp nextpnr-ice40$EXE $PACKAGE_DIR/$NAME/bin/nextpnr-ice40$EXE

# Do a test run of the new binary
$PACKAGE_DIR/$NAME/bin/nextpnr-ice40$EXE --up5k --package sg48 --pcf $WORK_DIR/build-data/test/top.pcf --json $WORK_DIR/build-data/test/top.json --asc /tmp/nextpnr/top.txt --pre-pack $WORK_DIR/build-data/test/top_pre_pack.py --seed 0 --placer heap
