#!/usr/bin/env bash
# -- Compile nextpnr-ecp5 script

set -e -x

nextpnr_dir=nextpnr-ecp5-bba
nextpnr_uri=https://github.com/YosysHQ/nextpnr.git
nextpnr_commit=master
nextpnr_commit=$(git ls-remote ${nextpnr_uri} ${nextpnr_commit} | cut -f 1)

prjtrellis_dir=prjtrellis-bba
prjtrellis_uri=https://github.com/YosysHQ/prjtrellis.git
# Every time you update this, regenerate the chipdb files!
prjtrellis_commit=master
prjtrellis_commit=$(git ls-remote ${prjtrellis_uri} ${prjtrellis_commit} | cut -f 1)

git_clone $nextpnr_dir $nextpnr_uri $nextpnr_commit 1 # enable submodule update
git_clone $prjtrellis_dir $prjtrellis_uri $prjtrellis_commit 1 # enable submodule update

cd $BUILD_DIR/

if [ -e $nextpnr_dir/CMakeCache.txt -o -e $prjtrellis_dir/CMakeCache.txt ]
then
    echo "CMakeCache.txt exists!"
fi
rm -f $nextpnr_dir/CMakeCache.txt $prjtrellis_dir/CMakeCache.txt

# -- Compile it
cd $BUILD_DIR/$prjtrellis_dir/libtrellis

# build libtrellis with the python module enabled
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

# use libtrellis + the python module to generate BBA files
cd $BUILD_DIR/$nextpnr_dir
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
make -j$J CXX="$CXX" chipdb-ecp5-bbas

mkdir -p $PACKAGE_DIR/$NAME/bba
cp $BUILD_DIR/$nextpnr_dir/ecp5/chipdb/*.bba $PACKAGE_DIR/$NAME/bba

clean_build $nextpnr_dir
clean_build $prjtrellis_dir
