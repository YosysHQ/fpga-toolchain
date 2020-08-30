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
    # use make rather than mingw32-make here because the sed tool expects unix paths
    # PYTHON overrides the shebang telling the sby.exe launcher where to find python
    make install PREFIX=$PACKAGE_DIR/$NAME PYTHON="./bin/python3-private.exe"
    test_bin $PACKAGE_DIR/$NAME/bin/sby.exe
elif [ $ARCH == "darwin" ]; then
    # put GNU sed in path temporarily
    OLDPATH=$PATH
    export PATH="/usr/local/opt/gnu-sed/libexec/gnubin:$PATH"
    $MAKE install PREFIX=$PACKAGE_DIR/$NAME
    export PATH=$OLDPATH
else
    $MAKE install PREFIX=$PACKAGE_DIR/$NAME
fi

clean_build $dir_name
