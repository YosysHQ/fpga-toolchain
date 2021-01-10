#!/usr/bin/env bash

set -e

dir_name=ghdl
commit=master
git_url=https://github.com/ghdl/ghdl.git

git_clone $dir_name $git_url $commit

cd $BUILD_DIR/$dir_name

# remove unwanted -lz linker flag on Darwin (because it causes a dynamic link)
$SED -i 's/pragma Linker_Options ("-lz");//;' ./src/grt/grt-zlib.ads
patch -p1 < $WORK_DIR/scripts/ghdl_version.diff

export GHDL_DESC="$(git -C $UPSTREAM_DIR/$dir_name describe --dirty 2> /dev/null)"
sed -i -e "s/@BUILDER@/open-tool-forge.$VERSION/" src/version.in

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

clean_build $dir_name
