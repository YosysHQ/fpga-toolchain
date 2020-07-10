#!/usr/bin/env bash

set -e

dir_name=z3
commit=master
git_url=https://github.com/Z3Prover/z3.git

git_clone $dir_name $git_url $commit

cd $BUILD_DIR/$dir_name
mkdir build
cd build

if [ $ARCH = "darwin" ]
then
    cmake ../
    $MAKE
elif [ ${ARCH:0:7} = "windows" ]
    cmake -G "MinGW Makefiles" ../
    $MAKE
then
    cmake ../
    $MAKE
else
fi

test_bin z3$EXE
cp z3$EXE $PACKAGE_DIR/$NAME/bin
