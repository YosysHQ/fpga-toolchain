#!/bin/bash -x
# -- Compile nextpnr-ecp5 script

set -e

nextpnr_dir=nextpnr-ecp5
nextpnr_uri=https://github.com/YosysHQ/nextpnr.git
nextpnr_commit=master
nextpnr_commit=$(git ls-remote ${nextpnr_uri} ${nextpnr_commit} | cut -f 1)

prjtrellis_dir=prjtrellis
prjtrellis_uri=https://github.com/YosysHQ/prjtrellis.git
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

cd $BUILD_DIR/

if [ -e $nextpnr_dir/CMakeCache.txt -o -e $prjtrellis_dir/CMakeCache.txt ]
then
    echo "CMakeCache.txt exists!"
fi
rm -f $nextpnr_dir/CMakeCache.txt $prjtrellis_dir/CMakeCache.txt

# -- Compile it
cd $BUILD_DIR/$prjtrellis_dir/libtrellis

# The first run of the build produces the Python shared library
# (Disabled since we now use PREGENERATED_BBA_PATH)
mkdir -p $BUILD_DIR/$prjtrellis_dir/tmp_prjtrellis_install
cmake \
    -DBUILD_SHARED=ON \
    -DCMAKE_INSTALL_PREFIX=$BUILD_DIR/$prjtrellis_dir/tmp_prjtrellis_install \
    -DSTATIC_BUILD=OFF \
    -DBoost_USE_STATIC_LIBS=OFF \
    -DBUILD_PYTHON=ON \
    -DCURRENT_GIT_VERSION=$prjtrellis_commit \
    .
make -j$J CXX="$CXX"
make install
rm -rf CMakeCache.txt

cd $BUILD_DIR/$nextpnr_dir
        # -DPREGENERATED_BBA_PATH=$BUILD_DIR/chipdb
cmake \
    -DARCH=ecp5 \
    -DTRELLIS_INSTALL_PREFIX=$BUILD_DIR/$prjtrellis_dir/tmp_prjtrellis_install \
    -DBUILD_HEAP=ON \
    -DBUILD_GUI=OFF \
    -DBUILD_PYTHON=ON \
    -DSTATIC_BUILD=OFF \
    -DBoost_USE_STATIC_LIBS=OFF \
    .

# skip most of the nextpnr build and generate the *.bba chipdb files
# (also needlessly runs bbasm to generate *.cc files and compiles them but for now we'll let it)
make -j$J CXX="$CXX" chipdb-ecp5-bbas

mkdir -p $PACKAGE_DIR/$NAME/bba
cp $BUILD_DIR/$nextpnr_dir/ecp5/chipdb/*.bba $PACKAGE_DIR/$NAME/bba
