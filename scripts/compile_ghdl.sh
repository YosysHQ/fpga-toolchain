#!/usr/bin/env bash

set -e

dir_name=ghdl
commit=master
git_url=https://github.com/ghdl/ghdl.git

git_clone $dir_name $git_url $commit

cd $BUILD_DIR/$dir_name

# remove unwanted -lz linker flag on Darwin (because it causes a dynamic link)
$SED -i 's/^[ \t]*pragma Linker_Options ("-lz");//;' ./src/grt/grt-zlib.ads
# customise the version string for ghdl
patch -p1 < $WORK_DIR/patches/ghdl/ghdl_version.patch
patch -p1 < $WORK_DIR/patches/ghdl/ghdl_largs.patch

export GHDL_DESC="$(git -C $UPSTREAM_DIR/$dir_name describe --dirty 2> /dev/null)"
sed -i -e "s/@BUILDER@/open-tool-forge.$VERSION/" src/version.in

# -- Compile it
if [ $ARCH == "darwin" ]; then
    OLD_PATH=$PATH
    export PATH="$GNAT_ROOT/bin:$PATH"

    ./configure --prefix=/opt/fpga-toolchain
    $MAKE -j$J GNAT_LARGS="-static-libgcc $ZLIB_ROOT/lib/libz.a"
    $MAKE DESTDIR=$PACKAGE_DIR/$NAME-prefix install
    cp -r $PACKAGE_DIR/$NAME-prefix/opt/fpga-toolchain/* $PACKAGE_DIR/$NAME

    export PATH="$OLD_PATH"
else
    ./configure --prefix=/opt/fpga-toolchain
    $MAKE -j$J GNAT_BARGS="-bargs -E -static" GNAT_LARGS="-static -lz"
    $MAKE DESTDIR=$PACKAGE_DIR/$NAME-prefix install
    cp -r $PACKAGE_DIR/$NAME-prefix/opt/fpga-toolchain/* $PACKAGE_DIR/$NAME
fi

test_bin $PACKAGE_DIR/$NAME/bin/ghdl$exe

strip_binaries bin/ghdl$EXE

clean_build $dir_name
