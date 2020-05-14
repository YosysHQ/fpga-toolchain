#!/bin/bash
# -- Compile nextpnr-ice40 script

set -e

nextpnr_dir=nextpnr-ice40
nextpnr_commit=master
nextpnr_uri=https://github.com/YosysHQ/nextpnr.git

# -- Setup
. $WORK_DIR/scripts/build_setup.sh

cd $UPSTREAM_DIR

# -- Clone the sources from github
test -e $nextpnr_dir || git clone $nextpnr_uri $nextpnr_dir
git -C $nextpnr_dir fetch
git -C $nextpnr_dir checkout $nextpnr_commit
git -C $nextpnr_dir log -1

# -- Copy the upstream sources into the build directory
rsync -a $nextpnr_dir $BUILD_DIR --exclude .git

cd $BUILD_DIR/$nextpnr_dir

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
    cp $WORK_DIR/scripts/nextpnr-CMakeLists.txt CMakeLists.txt

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

    # Install a copy of Python, since Python libraries are not compatible
    # across minor versions.
    mkdir libpython3
    cd libpython3
    for pkg in $(ls -1 ${WORK_DIR}/build-data/$ARCH/*.deb)
    do
        echo "Extracting $pkg..."
        ar p $pkg data.tar.xz | tar xJ
    done
    mkdir -p $PACKAGE_DIR/$NAME
    mv usr/* $PACKAGE_DIR/$NAME
    cd ..
fi || exit 1

# -- Copy the executable to the bin dir
mkdir -p $PACKAGE_DIR/$NAME/bin
cp nextpnr-ice40$EXE $PACKAGE_DIR/$NAME/bin/nextpnr-ice40$EXE

# Do a test run of the new binary
$PACKAGE_DIR/$NAME/bin/nextpnr-ice40$EXE --up5k --package sg48 --pcf $WORK_DIR/build-data/test/top.pcf --json $WORK_DIR/build-data/test/top.json --asc /tmp/nextpnr/top.txt --pre-pack $WORK_DIR/build-data/test/top_pre_pack.py --seed 0 --placer heap
