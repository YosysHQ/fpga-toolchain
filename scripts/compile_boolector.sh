#!/usr/bin/env bash

set -e

dir_name=boolector
commit=master
git_url=https://github.com/boolector/boolector.git

git_clone $dir_name $git_url $commit

cd $BUILD_DIR/$dir_name

$SED -i 's|\./configure.sh -fPIC|\./configure.sh -fPIC -static|;' ./contrib/setup-btor2tools.sh
./contrib/setup-btor2tools.sh
./contrib/setup-lingeling.sh
./configure.sh

if [ $ARCH = "darwin" ]
then
    $MAKE -C build -j$J
elif [ ${ARCH:0:7} = "windows" ]
then
    $MAKE -C build -j$J
else
    $MAKE -C build -j$J
fi

for i in build/bin/{boolector*,btor*} deps/btor2tools/bin/btorsim*
do
    test_bin $i
    cp $i $PACKAGE_DIR/$NAME/bin
done
