#!/usr/bin/env bash

set -e

dir_name=avy
commit=cav19
git_url=https://bitbucket.org/arieg/extavy.git

git_clone $dir_name $git_url $commit 1 # enable submodule update

# cd $UPSTREAM_DIR
# cd avy/avy
# git pull origin new_quip
# cd ..
# rsync -a avy $BUILD_DIR --exclude .git

cd $BUILD_DIR/$dir_name
mkdir -p build
cd build

if [ $ARCH = "darwin" ]
then
    cmake -DCMAKE_BUILD_TYPE=Release ../
    $MAKE -j$J
elif [ ${ARCH:0:7} = "windows" ]
then
    cmake -G "MinGW Makefiles"  -DCMAKE_BUILD_TYPE=Release -DAVY_STATIC_EXE=ON ../
    $MAKE -j$J
else
    cmake -DCMAKE_BUILD_TYPE=Release -DAVY_STATIC_EXE=ON ../
    $MAKE -j$J
fi

test_bin avy/src/avy$EXE
cp avy/src/avy$EXE $PACKAGE_DIR/$NAME/bin
strip_binaries bin/avy$EXE

clean_build $dir_name
