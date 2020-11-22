#!/usr/bin/env bash
# -- Compile Yosys script

set -e -x

dir_name=yosys
commit=master
git_url=https://github.com/YosysHQ/yosys.git

dir_name_gyp=ghdl_yosys_plugin
commit_gyp=master
git_url_gyp=https://github.com/ghdl/ghdl-yosys-plugin

git_clone $dir_name $git_url $commit
GIT_REV=$(git -C $UPSTREAM_DIR/$dir_name rev-parse --short HEAD 2> /dev/null || echo UNKNOWN)

if [ $COMPILE_GHDL == "1" ]
then
    git_clone $dir_name_gyp $git_url_gyp $commit_gyp
fi

cd $BUILD_DIR/$dir_name

MAKEFILE_CONF_GHDL=
GHDL_LDLIBS=
if [ $COMPILE_GHDL == "1" ]
then
    patch < $WORK_DIR/scripts/yosys_ghdl.diff

    mkdir -p frontends/ghdl
    cp -R ../$dir_name_gyp/src/* frontends/ghdl
    MAKEFILE_CONF_GHDL=$'ENABLE_GHDL := 1\n'
    MAKEFILE_CONF_GHDL+="GHDL_DIR := $PACKAGE_DIR/$NAME"

    if [ $ARCH == "darwin" ]; then
        GHDL_LDLIBS="$PACKAGE_DIR/$NAME/lib/libghdl.a $(tr -s '\n' ' ' < $PACKAGE_DIR/$NAME/lib/libghdl.link)"
    elif [ ${ARCH:0:7} == "windows" ]; then
        GHDL_LDLIBS="$(cygpath -m -a $PACKAGE_DIR/$NAME/lib/libghdl.a) $(cat $PACKAGE_DIR/$NAME/lib/libghdl.link | tr -s '\n' ' ' | tr -s '\\' '/' )"
    else
        GHDL_LDLIBS="$PACKAGE_DIR/$NAME/lib/libghdl.a $(tr -s '\n' ' ' < $PACKAGE_DIR/$NAME/lib/libghdl.link)"
    fi
fi

# -- Compile it
if [ $ARCH == "darwin" ]; then
    OLDPATH=$PATH
    export PATH="/usr/local/opt/bison/bin:/usr/local/opt/flex/bin:$PATH"
    $MAKE config-clang
    echo "$MAKEFILE_CONF_GHDL" >> Makefile.conf
    gsed -r -i 's/^(YOSYS_VER := [0-9]+\.[0-9]+\+[0-9]+).*$/\1 \(open-tool-forge build\)/;' Makefile
    sed -i "" "s/-Wall -Wextra -ggdb/-w/;" Makefile
    CXXFLAGS="-std=c++11 $CXXFLAGS" make \
            -j$J GIT_REV="${GIT_REV}" PRETTY=0 \
            LDLIBS="-lm $GHDL_LDLIBS" \
            ENABLE_TCL=0 ENABLE_PLUGINS=0 ENABLE_READLINE=0 ENABLE_COVER=0 ENABLE_ZLIB=0 ENABLE_ABC=1 \
            ABCMKARGS="CC=\"$CC\" CXX=\"$CXX\" OPTFLAGS=\"-O\" \
                       ARCHFLAGS=\"$ABC_ARCHFLAGS\" ABC_USE_NO_READLINE=1"

    export PATH=$OLDPATH
elif [ ${ARCH:0:7} == "windows" ]; then
    $MAKE config-msys2-64
    echo "$MAKEFILE_CONF_GHDL" >> Makefile.conf
    sed -r -i 's/^(YOSYS_VER := [0-9]+\.[0-9]+\+[0-9]+).*$/\1 \(open-tool-forge build\)/;' Makefile
    $MAKE -j$J GIT_REV="${GIT_REV}" PRETTY=0 \
              LDLIBS="-static -lstdc++ -lm $GHDL_LDLIBS" \
              ABCMKARGS="CC=\"$CC\" CXX=\"$CXX\" LIBS=\"-static -lm\" OPTFLAGS=\"-O\" \
                         ARCHFLAGS=\"$ABC_ARCHFLAGS\" \
                         ABC_USE_NO_READLINE=1 \
                         ABC_USE_NO_PTHREADS=1 \
                         ABC_USE_LIBSTDCXX=1" \
              ENABLE_TCL=0 ENABLE_PLUGINS=0 ENABLE_READLINE=0 ENABLE_COVER=0 ENABLE_ZLIB=0 ENABLE_ABC=1 \
              PYTHON="./bin/python3-private.exe" # override the shebang telling the exe launcher where to find python

    test_bin yosys-smtbmc$EXE
else
    if [ ${ARCH} == "linux_armv7l" ] || [ ${ARCH} == "linux_aarch64" ]; then
        # yosys uses this to derive a header include path
        # (defaults to /usr/local which is very wrong for a cross build)
        YOSYS_PREFIX="PREFIX=$BUILDROOT_SYSROOT"
    else
        YOSYS_PREFIX=""
    fi
    $MAKE config-gcc
    echo "$MAKEFILE_CONF_GHDL" >> Makefile.conf
    sed -i "s/-Wall -Wextra -ggdb/-w/;" Makefile
    sed -r -i 's/^(YOSYS_VER := [0-9]+\.[0-9]+\+[0-9]+).*$/\1 \(open-tool-forge build\)/;' Makefile
    sed -i "s/LD = gcc/LD = $CC/g" Makefile
    sed -i "s/CC = gcc/CC = $CC/g" Makefile
    sed -i "s/CXX = gcc/CXX = $CC/g" Makefile
    sed -i "s/LDFLAGS += -rdynamic/LDFLAGS +=/;" Makefile
    $MAKE -j$J GIT_REV="${GIT_REV}" PRETTY=0 \
                LDLIBS="-static -lstdc++ -lm $GHDL_LDLIBS -ldl" \
                ENABLE_TCL=0 ENABLE_PLUGINS=0 ENABLE_READLINE=0 ENABLE_COVER=0 ENABLE_ZLIB=0 ENABLE_ABC=1 \
                $YOSYS_PREFIX \
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
[[ ! -z "$EXE" ]] && cp yosys-smtbmc-script.py $PACKAGE_DIR/$NAME/bin/yosys-smtbmc-script.py

# -- Copy the share folder to the package folder
mkdir -p $PACKAGE_DIR/$NAME/share/yosys
cp -r share/* $PACKAGE_DIR/$NAME/share/yosys

strip_binaries bin/{yosys,yosys-abc,yosys-filterlib}$EXE

clean_build $dir_name
clean_build $dir_name_gyp
