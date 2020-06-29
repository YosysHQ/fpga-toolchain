#!/bin/bash -x
# -- Compile Yosys script

set -e

REL=0 # 1: load from release tag. 0: load from source code

VER=master
YOSYS=yosys
GIT_YOSYS=https://github.com/YosysHQ/yosys.git

cd $UPSTREAM_DIR

# -- Clone the sources from github
test -e $YOSYS || git clone $GIT_YOSYS $YOSYS
git -C $YOSYS pull
git -C $YOSYS checkout $VER
git -C $YOSYS log -1
pushd $YOSYS && $MAKE bumpversion && popd

ghdl_yosys_plugin=ghdl_yosys_plugin
commit_gyp=master
git_ghdl_yosys_plugin=https://github.com/ghdl/ghdl-yosys-plugin

# -- Clone the sources from github
test -e $ghdl_yosys_plugin || git clone $git_ghdl_yosys_plugin $ghdl_yosys_plugin
git -C $ghdl_yosys_plugin pull
git -C $ghdl_yosys_plugin checkout $commit_gyp
git -C $ghdl_yosys_plugin log -1

# -- Copy the upstream sources into the build directory
rsync -a $ghdl_yosys_plugin $BUILD_DIR --exclude .git

# -- Copy the upstream sources into the build directory
rsync -a $YOSYS $BUILD_DIR --exclude .git

cd $BUILD_DIR/$YOSYS
# TODO contribute updated patch upstream as it has gone stale
patch < $WORK_DIR/scripts/yosys-ghdl.diff

mkdir -p frontends/ghdl
cp -R ../$ghdl_yosys_plugin/src/* frontends/ghdl
MAKEFILE_CONF_GHDL=$'ENABLE_GHDL := 1\n'
MAKEFILE_CONF_GHDL+="GHDL_DIR := $PACKAGE_DIR/$NAME"

# -- Compile it
if [ $ARCH == "darwin" ]; then
    OLDPATH=$PATH
    export PATH="/usr/local/opt/bison/bin:/usr/local/opt/flex/bin:$PATH"

    $MAKE config-clang
    echo "$MAKEFILE_CONF_GHDL" >> Makefile.conf
    sed -i "" "s/-Wall -Wextra -ggdb/-w/;" Makefile
    sed -i "" 's/(\d+\.\d+\+\d+)/\1 \(open-tool-forge build\)/;'
    CXXFLAGS="-std=c++11 $CXXFLAGS" make \
            -j$J PRETTY=0 \
            LDLIBS="-lm $PACKAGE_DIR/$NAME/lib/libghdl.a $(tr -s '\n' ' ' < $PACKAGE_DIR/$NAME/lib/libghdl.link)" \
            ENABLE_TCL=0 ENABLE_PLUGINS=0 ENABLE_READLINE=0 ENABLE_COVER=0 ENABLE_ZLIB=0 ENABLE_ABC=1 \
            ABCMKARGS="CC=\"$CC\" CXX=\"$CXX\" OPTFLAGS=\"-O\" \
                       ARCHFLAGS=\"$ABC_ARCHFLAGS\" ABC_USE_NO_READLINE=1"

    export PATH=$OLDPATH
elif [ ${ARCH:0:7} == "windows" ]; then
    $MAKE config-msys2-64
    echo "$MAKEFILE_CONF_GHDL" >> Makefile.conf
    sed -i 's/(\d+\.\d+\+\d+)/\1 \(open-tool-forge build\)/;'
    $MAKE -j$J PRETTY=0 \
              LDLIBS="-static -lstdc++ -lm $(cygpath -m -a $PACKAGE_DIR/$NAME/lib/libghdl.a) $((tr -s '\n' ' ' | tr -s '\\' '/') < $PACKAGE_DIR/$NAME/lib/libghdl.link)" \
              ABCMKARGS="CC=\"$CC\" CXX=\"$CXX\" LIBS=\"-static -lm\" OPTFLAGS=\"-O\" \
                         ARCHFLAGS=\"$ABC_ARCHFLAGS\" \
                         ABC_USE_NO_READLINE=1 \
                         ABC_USE_NO_PTHREADS=1 \
                         ABC_USE_LIBSTDCXX=1" \
              ENABLE_TCL=0 ENABLE_PLUGINS=0 ENABLE_READLINE=0 ENABLE_COVER=0 ENABLE_ZLIB=0 ENABLE_ABC=1

    test_bin yosys-smtbmc$EXE
else
    $MAKE config-gcc
    echo "$MAKEFILE_CONF_GHDL" >> Makefile.conf
    sed -i "s/-Wall -Wextra -ggdb/-w/;" Makefile
    sed -i 's/(\d+\.\d+\+\d+)/\1 \(open-tool-forge build\)/;'
    # sed -i "s/LD = gcc$/LD = $CC/;" Makefile
    # sed -i "s/CXX = gcc$/CXX = $CC/;" Makefile
    # sed -i "s/LDFLAGS += -rdynamic/LDFLAGS +=/;" Makefile
    $MAKE -j$J PRETTY=0 \
                LDLIBS="-static -lstdc++ -lm $PACKAGE_DIR/$NAME/lib/libghdl.a $(tr -s '\n' ' ' < $PACKAGE_DIR/$NAME/lib/libghdl.link) -ldl" \
                ENABLE_TCL=0 ENABLE_PLUGINS=0 ENABLE_READLINE=0 ENABLE_COVER=0 ENABLE_ZLIB=0 ENABLE_ABC=1 \
                ABCMKARGS="CC=\"$CC\" CXX=\"$CXX\" LIBS=\"-static -lm -ldl -pthread\" \
                           OPTFLAGS=\"-O\" \
                           ARCHFLAGS=\"$ABC_ARCHFLAGS -Wno-unused-but-set-variable\" \
                           ABC_USE_NO_READLINE=1"
fi

# -- Test the generated executables
test_bin yosys$EXE
test_bin yosys-abc$EXE
test_bin yosys-filterlib$EXE

# -- Copy the executable files
cp yosys$EXE $PACKAGE_DIR/$NAME/bin/yosys$EXE
cp yosys-abc$EXE $PACKAGE_DIR/$NAME/bin/yosys-abc$EXE

# this is a custom version of yosys-config (https://github.com/open-tool-forge/fpga-toolchain/issues/26)
cp $WORK_DIR/build-data/yosys-config $PACKAGE_DIR/$NAME/bin/yosys-config

cp yosys-filterlib$EXE $PACKAGE_DIR/$NAME/bin/yosys-filterlib$EXE
cp yosys-smtbmc$EXE $PACKAGE_DIR/$NAME/bin/yosys-smtbmc$EXE

# -- Copy the share folder to the package folder
mkdir -p $PACKAGE_DIR/$NAME/share/yosys
cp -r share/* $PACKAGE_DIR/$NAME/share/yosys
