#!/usr/bin/env bash

set -e

dir_name=yices2
commit=master
git_url=https://github.com/SRI-CSL/yices2.git

git_clone $dir_name $git_url $commit
cd $BUILD_DIR/$dir_name
./autoconf
./configure
$make -j$J static-bin

if [ $ARCH == "darwin" ]
then
    YICES2_BINDIR=./build/x86_64-apple-darwin*-release/static_bin
elif [ ${ARCH:0:7} = "windows" ]
then
    YICES2_BINDIR=./build/x86_64-pc-mingw32-release/static_bin
else
    YICES2_BINDIR=./build/x86_64-pc-linux-gnu-release/static_bin
fi

cp $YICES2_BINDIR/yices$EXE $PACKAGE_DIR/$NAME/bin/yices$EXE
cp $YICES2_BINDIR/yices_sat$EXE $PACKAGE_DIR/$NAME/bin/yices-sat$EXE
cp $YICES2_BINDIR/yices_smt$EXE $PACKAGE_DIR/$NAME/bin/yices-smt$EXE
cp $YICES2_BINDIR/yices_smt2$EXE $PACKAGE_DIR/$NAME/bin/yices-smt2$EXE

strip_binaries bin/{yices,yices-sat,yices-smt,yices-smt2}$EXE

clean_build $dir_name
