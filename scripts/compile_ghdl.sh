#!/bin/bash

set -e

ghdl=ghdl
commit=master
git_ghdl=https://github.com/ghdl/ghdl.git

cd $UPSTREAM_DIR

# -- Clone the sources from github
test -e $ghdl || git clone $git_ghdl $ghdl
git -C $ghdl pull
git -C $ghdl checkout $commit
git -C $ghdl log -1

# -- Copy the upstream sources into the build directory
rsync -a $ghdl $BUILD_DIR --exclude .git

cd $BUILD_DIR/$ghdl

patch < $WORK_DIR/scripts/libghdl_static.diff

# -- Compile it
if [ $ARCH == "darwin" ]; then
    OLD_PATH=$PATH
    export PATH="$GNAT_ROOT/bin:$PATH"

    ./configure --prefix=$PACKAGE_DIR/$NAME

    $MAKE -j$J LDFLAGS="-static-libgcc $ZLIB_ROOT/lib/libz.a"
    $MAKE install

    export PATH="$OLD_PATH"
else
    ./configure --prefix=$PACKAGE_DIR/$NAME
    $MAKE -j$J LDFLAGS="-static -lz"
    $MAKE install
fi
