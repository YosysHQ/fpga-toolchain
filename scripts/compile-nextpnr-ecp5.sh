#!/bin/bash -x
# -- Compile nextpnr-ecp5 script

set -e

nextpnr_dir=nextpnr-ecp5
nextpnr_uri=https://github.com/YosysHQ/nextpnr.git
nextpnr_commit=master
nextpnr_commit=$(git ls-remote ${nextpnr_uri} ${nextpnr_commit} | cut -f 1)

prjtrellis_dir=prjtrellis
prjtrellis_uri=https://github.com/SymbiFlow/prjtrellis.git
# Every time you update this, regenerate the chipdb files!
prjtrellis_commit=master
prjtrellis_commit=$(git ls-remote ${prjtrellis_uri} ${prjtrellis_commit} | cut -f 1)

# -- Setup
. $WORK_DIR/scripts/build_setup.sh

cd $UPSTREAM_DIR

# -- Clone the sources from github
test -e $nextpnr_dir || git clone $nextpnr_uri $nextpnr_dir
git -C $nextpnr_dir fetch
git -C $nextpnr_dir checkout $nextpnr_commit
git -C $nextpnr_dir log -1

test -e $prjtrellis_dir || git clone $prjtrellis_uri $prjtrellis_dir
git -C $prjtrellis_dir fetch
git -C $prjtrellis_dir checkout $prjtrellis_commit
git -C $prjtrellis_dir submodule init
git -C $prjtrellis_dir submodule update
git -C $prjtrellis_dir log -1

# -- Copy the upstream sources into the build directory
mkdir -p $BUILD_DIR/$nextpnr_dir
mkdir -p $BUILD_DIR/$prjtrellis_dir
rsync -a $nextpnr_dir $BUILD_DIR --exclude .git
rsync -a $prjtrellis_dir $BUILD_DIR --exclude .git

# NOTE: We build libtrellis with python DISABLED.
# We do this to speed up build time and to enable static builds.
# We have a precompiled chipdb in this repository, so there is no
# need to have Python functioning.
# Additionally, libtrellis doesn't build correctly when making
# static binaries and having Python enabled.

cd $BUILD_DIR/

if [ -e $nextpnr_dir/CMakeCache.txt -o -e $prjtrellis_dir/CMakeCache.txt ]
then
    echo "CMakeCache.txt exists!"
fi
rm -f $nextpnr_dir/CMakeCache.txt $prjtrellis_dir/CMakeCache.txt

cd $BUILD_DIR
mkdir -p chipdb
cd chipdb
tar -xvf $WORK_DIR/chipdb.tar.gz

# -- Compile it
if [ $ARCH = "darwin" ]
then
    cd $BUILD_DIR/$prjtrellis_dir/libtrellis
    cmake \
        -DBUILD_SHARED=OFF \
        -DSTATIC_BUILD=ON \
        -DBUILD_PYTHON=OFF \
        -DCMAKE_INSTALL_PREFIX=$PACKAGE_DIR/$NAME \
        -DCURRENT_GIT_VERSION=$prjtrellis_commit \
        -DBoost_USE_STATIC_LIBS=ON \
        .
    make -j$J CXX="$CXX" LIBS="-lm -fno-lto -ldl -lutil"
    make install

    cd $BUILD_DIR/$nextpnr_dir
    cmake -DARCH=ecp5 \
        -DTRELLIS_ROOT=$BUILD_DIR/$prjtrellis_dir \
        -DPYTRELLIS_LIBDIR=$BUILD_DIR/$prjtrellis_dir/libtrellis \
        -DPREGENERATED_BBA_PATH=$BUILD_DIR/chipdb/ecp5-bba/bba \
        -DBoost_USE_STATIC_LIBS=ON \
        -DPYTHON_EXECUTABLE=$CONDA_ROOT/bin/python \
        -DPYTHON_LIBRARY=$CONDA_ROOT/lib/libpython$EMBEDDED_PY_VER.a \
        -DBUILD_GUI=OFF \
        -DBUILD_PYTHON=ON \
        -DBUILD_HEAP=ON \
        -DCMAKE_EXE_LINKER_FLAGS='-fno-lto -ldl -lutil' \
        -DSTATIC_BUILD=ON \
        .
    make -j$J CXX="$CXX" LIBS="-lm -fno-lto -ldl -lutil" VERBOSE=1
    cd ..
elif [ ${ARCH:0:7} = "windows" ]
then
    cd $BUILD_DIR/$prjtrellis_dir/libtrellis
    cmake \
        -G "MinGW Makefiles" \
        -DBUILD_SHARED=OFF \
        -DSTATIC_BUILD=ON \
        -DBUILD_PYTHON=OFF \
        -DCMAKE_INSTALL_PREFIX=$PACKAGE_DIR/$NAME \
        -DCURRENT_GIT_VERSION=$prjtrellis_commit \
        -DBoost_USE_STATIC_LIBS=ON \
        .
    mingw32-make -j$J CXX="$CXX" LIBS="-lm"
    mingw32-make install

    cd $BUILD_DIR/$nextpnr_dir
    cp $WORK_DIR/scripts/nextpnr-CMakeLists.txt CMakeLists.txt

    cmake \
        -G "MinGW Makefiles" \
        -DARCH=ecp5 \
        -DTRELLIS_ROOT=$BUILD_DIR/$prjtrellis_dir \
        -DPYTRELLIS_LIBDIR=$BUILD_DIR/$prjtrellis_dir/libtrellis \
        -DPREGENERATED_BBA_PATH=$BUILD_DIR/chipdb/ecp5-bba/bba \
        -DBoost_USE_STATIC_LIBS=ON \
        -DBUILD_GUI=OFF \
        -DBUILD_PYTHON=ON \
        -DBUILD_HEAP=ON \
        -DSTATIC_BUILD=ON \
        .

    mingw32-make -j$J CXX="$CXX" VERBOSE=1
    cd ..
else
    cd $BUILD_DIR/$prjtrellis_dir/libtrellis

    # The second run builds the static libraries we'll use in the final release
    cmake \
        -DBUILD_SHARED=OFF \
        -DSTATIC_BUILD=ON \
        -DBUILD_PYTHON=OFF \
        -DBoost_USE_STATIC_LIBS=ON \
        -DCMAKE_INSTALL_PREFIX=$PACKAGE_DIR/$NAME \
        -DCURRENT_GIT_VERSION=$prjtrellis_commit \
        -DCMAKE_FIND_LIBRARY_SUFFIXES=".a" \
        .
    make -j$J CXX="$CXX"
    make install

    cd $BUILD_DIR/$nextpnr_dir
    cmake \
        -DARCH=ecp5 \
        -DTRELLIS_ROOT=$BUILD_DIR/$prjtrellis_dir \
        -DPYTRELLIS_LIBDIR=$BUILD_DIR/$prjtrellis_dir/libtrellis \
        -DPREGENERATED_BBA_PATH=$BUILD_DIR/chipdb/ecp5-bba/bba \
        -DBUILD_HEAP=ON \
        -DBUILD_GUI=OFF \
        -DBUILD_PYTHON=ON \
        -DSTATIC_BUILD=ON \
        -DBoost_USE_STATIC_LIBS=ON \
        .
    make -j$J CXX="$CXX"

    # Install a copy of Python, since Python libraries are not compatible
    # across minor versions.
    mkdir libpython3
    cd libpython3
    for pkg in $(ls -1 ${WORK_DIR}/build-data/linux/*.deb)
    do
        echo "Extracting $pkg..."
        ar p $pkg data.tar.xz | tar xvJ
    done
    mkdir -p $PACKAGE_DIR/$NAME
    mv usr/* $PACKAGE_DIR/$NAME
    cd ..
fi || exit 1

# -- Copy the executables to the bin dir
mkdir -p $PACKAGE_DIR/$NAME/bin
# $WORK_DIR/scripts/test_bin.sh $BUILD_DIR/$nextpnr_dir/nextpnr-ecp5$EXE
cp $BUILD_DIR/$nextpnr_dir/nextpnr-ecp5$EXE $PACKAGE_DIR/$NAME/bin/nextpnr-ecp5$EXE
for i in ecpmulti ecppack ecppll ecpunpack ecpbram
do
    # $WORK_DIR/scripts/test_bin.sh $BUILD_DIR/$prjtrellis_dir/libtrellis/$i$EXE
    cp $BUILD_DIR/$prjtrellis_dir/libtrellis/$i$EXE $PACKAGE_DIR/$NAME/bin/$i$EXE
done

# Do a test run of the new binary
$PACKAGE_DIR/$NAME/bin/nextpnr-ecp5$EXE --help
echo 'print("hello from python!")' > hello.py
$PACKAGE_DIR/$NAME/bin/nextpnr-ecp5$EXE --run hello.py
