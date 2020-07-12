#!/usr/bin/env bash

set -e

dir_name=boolector
commit=master
git_url=https://github.com/boolector/boolector.git

git_clone $dir_name $git_url $commit

cd $BUILD_DIR/$dir_name

if [ $ARCH = "darwin" ]
then
    ./contrib/setup-btor2tools.sh
    ./contrib/setup-lingeling.sh
    ./configure.sh

    $MAKE -C build -j$J
elif [ ${ARCH:0:7} = "windows" ]
then
    $SED -i 's/MINGW32/MINGW/;' ./contrib/setup-utils.sh # fix windows detection on MINGW64
    $SED -i 's|\./configure.sh -fPIC|\./configure.sh -fPIC -static|;' ./contrib/setup-btor2tools.sh
    # this is easier than working out how to escape an arg with a space in CMAKE_OPTS
    $SED -i 's/cmake .. $cmake_opts/cmake -DIS_WINDOWS_BUILD=1 -G "MinGW Makefiles" .. $cmake_opts/;' ./configure.sh

    ./contrib/setup-btor2tools.sh
    ./contrib/setup-lingeling.sh
    ./configure.sh

    $MAKE -C build -j$J
else
    $SED -i 's|\./configure.sh -fPIC|\./configure.sh -fPIC -static|;' ./contrib/setup-btor2tools.sh

    ./contrib/setup-btor2tools.sh
    ./contrib/setup-lingeling.sh
    ./configure.sh

    $MAKE -C build -j$J
fi

for i in build/bin/{boolector*,btor*} deps/btor2tools/bin/btorsim*
do
    test_bin $i
    cp $i $PACKAGE_DIR/$NAME/bin
done
