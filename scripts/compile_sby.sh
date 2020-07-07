#!/usr/bin/env bash

set -e

dir_name=symbiyosys
commit=master
git_url=https://github.com/YosysHQ/SymbiYosys.git

git_clone $dir_name $git_url $commit

cd $BUILD_DIR/$dir_name

patch -p1 < $WORK_DIR/scripts/sby_launcher.diff

# -- Compile it
if [ ${ARCH:0:7} = "windows" ]
then
    $MAKE install PYTHON="./bin/python3-private.exe" # override the shebang telling the exe launcher where to find python
    
else
    $MAKE install
fi
