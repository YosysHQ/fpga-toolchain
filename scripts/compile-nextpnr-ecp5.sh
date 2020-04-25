#!/bin/bash -x
# -- Compile nextpnr-ecp5 script

set -e

nextpnr_dir=nextpnr
nextpnr_uri=https://github.com/YosysHQ/nextpnr.git
nextpnr_commit=371d33146fcfda9a1c568f46fd1f5775cd4fb1be

prjtrellis_dir=prjtrellis
prjtrellis_uri=https://github.com/SymbiFlow/prjtrellis.git
# Every time you update this, regenerate the chipdb files!
prjtrellis_commit=88e28f5ebba8a31c0aea74c2b7fddd43846f9a56

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

# -- Compile it
if [ $ARCH = "darwin" ]
then
    cd $BUILD_DIR
    mkdir chipdb
    cd chipdb
    for i in $(ls $WORK_DIR/chipdb/*.gz)
    do
        cp $i .
        gunzip -f $(basename $i)
    done

    cd $BUILD_DIR/$prjtrellis_dir/libtrellis
    cmake \
        -DBUILD_SHARED=OFF \
        -DSTATIC_BUILD=ON \
        -DBUILD_PYTHON=OFF \
        -DBOOST_ROOT=/tmp/nextpnr \
        -DCMAKE_INSTALL_PREFIX=$PACKAGE_DIR/$NAME \
        -DPYTHON_EXECUTABLE=/tmp/nextpnr/bin/python3 \
        -DBoost_USE_STATIC_LIBS=ON \
        .
    make -j$J CXX="$CXX" LIBS="-lm -fno-lto -ldl -lutil"
    make install

    cd $BUILD_DIR/$nextpnr_dir
    cmake -DARCH=ecp5 \
        -DTRELLIS_ROOT=$BUILD_DIR/$prjtrellis_dir \
        -DPYTRELLIS_LIBDIR=$BUILD_DIR/$prjtrellis_dir/libtrellis \
        -DPREGENERATED_BBA_PATH=$BUILD_DIR/chipdb \
        -DBOOST_ROOT=/tmp/nextpnr \
        -DBoost_USE_STATIC_LIBS=ON \
        -DBOOST_ROOT=/tmp/nextpnr \
        -DPYTHON_EXECUTABLE=/tmp/nextpnr/bin/python3 \
        -DPYTHON_LIBRARY=/tmp/nextpnr/lib/libpython3.6m.a \
        -DEigen3_DIR=/tmp/nextpnr/share/eigen3/cmake \
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
    echo "Build not functioning on Windows"
    exit 1
else
    cd $BUILD_DIR
    mkdir chipdb
    cd chipdb
    for i in $(ls $WORK_DIR/chipdb/*.gz)
    do
        cp $i .
        gunzip -f $(basename $i)
    done

    cd $BUILD_DIR/$prjtrellis_dir/libtrellis

    # The first run of the build produces the Python shared library
    # (Disabled since we now use PREGENERATED_BBA_PATH)
    # cmake \
    #     -DBUILD_SHARED=ON \
    #     -DSTATIC_BUILD=OFF \
    #     -DBUILD_PYTHON=ON \
    #     .
    # make -j$J CXX="$CXX"
    # rm -rf CMakeCache.txt

    # The second run builds the static libraries we'll use in the final release
    cmake \
        -DBUILD_SHARED=OFF \
        -DSTATIC_BUILD=ON \
        -DBUILD_PYTHON=OFF \
        -DBoost_USE_STATIC_LIBS=ON \
        -DCMAKE_INSTALL_PREFIX=$PACKAGE_DIR/$NAME \
        -DCMAKE_FIND_LIBRARY_SUFFIXES=".a" \
        .
    make -j$J CXX="$CXX"
    make install

    cd $BUILD_DIR/$nextpnr_dir
    cmake \
        -DARCH=ecp5 \
        -DTRELLIS_ROOT=$BUILD_DIR/$prjtrellis_dir \
        -DPYTRELLIS_LIBDIR=$BUILD_DIR/$prjtrellis_dir/libtrellis \
        -DPREGENERATED_BBA_PATH=$BUILD_DIR/chipdb \
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
$WORK_DIR/scripts/test_bin.sh $BUILD_DIR/$nextpnr_dir/nextpnr-ecp5$EXE
cp $BUILD_DIR/$nextpnr_dir/nextpnr-ecp5$EXE $PACKAGE_DIR/$NAME/bin/nextpnr-ecp5$EXE
for i in ecpmulti ecppack ecppll ecpunpack ecpbram
do
    $WORK_DIR/scripts/test_bin.sh $BUILD_DIR/$prjtrellis_dir/libtrellis/$i$EXE
    cp $BUILD_DIR/$prjtrellis_dir/libtrellis/$i$EXE $PACKAGE_DIR/$NAME/bin/$i$EXE
done

# Do a test run of the new binary
$PACKAGE_DIR/$NAME/bin/nextpnr-ecp5$EXE --help
