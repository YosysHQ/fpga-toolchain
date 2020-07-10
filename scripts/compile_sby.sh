#!/usr/bin/env bash

set -e

dir_name=symbiyosys
commit=master
git_url=https://github.com/YosysHQ/SymbiYosys.git

git_clone $dir_name $git_url $commit

cd $BUILD_DIR/$dir_name

# -- Compile it
if [ ${ARCH:0:7} = "windows" ]
then
    # override the shebang telling the exe launcher where to find python
    $MAKE install PREFIX=$PACKAGE_DIR/$NAME PYTHON="./bin/python3-private.exe"
else
    $MAKE install PREFIX=$PACKAGE_DIR/$NAME
fi
