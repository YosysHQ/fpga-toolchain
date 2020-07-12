#!/usr/bin/env bash

set -e

dir_name=ghdl
commit=master
git_url=https://github.com/ghdl/ghdl.git

git_clone $dir_name $git_url $commit

cd $BUILD_DIR/$dir_name

# remove unwanted -lz linker flag on Darwin (because it causes a dynamic link)
patch -p1 < $WORK_DIR/scripts/libghdl_static.diff

# -- Compile it
if [ $ARCH == "darwin" ]; then
    OLD_PATH=$PATH
    export PATH="$GNAT_ROOT/bin:$PATH"

    ./configure --prefix=$PACKAGE_DIR/$NAME

    $MAKE -j$J GNAT_LARGS="-static-libgcc $ZLIB_ROOT/lib/libz.a"
    $MAKE install

    export PATH="$OLD_PATH"
else
    ./configure --prefix=$PACKAGE_DIR/$NAME
    $MAKE -j$J GNAT_BARGS="-bargs -E -static" GNAT_LARGS="-static -lz"
    $MAKE install
fi

test_bin $PACKAGE_DIR/$NAME/bin/ghdl$exe

strip_binaries bin/ghdl$EXE
