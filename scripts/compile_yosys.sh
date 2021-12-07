#!/usr/bin/env bash
# -- Compile Yosys script

set -e -x

dir_name=yosys
commit=master
# commit=5eff0b73ae82ee490be3e732241eb22cb4bff952
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

GHDL_LDLIBS=
if [ $COMPILE_GHDL == "1" ]
then
    patch < $WORK_DIR/patches/yosys/yosys_ghdl.patch

    #if [ ${ARCH:0:7} == "windows" ]; then
    #    sed -i -e 's@.*\(/mingw.*\)@\1@' $PACKAGE_DIR/$NAME/lib/libghdl.link
    #fi

    GHDL_LDLIBS="$PACKAGE_DIR/$NAME/lib/libghdl.a $(cat $PACKAGE_DIR/$NAME/lib/libghdl.link)"
fi

_ghdl_conf() {
    if [ $COMPILE_GHDL == "1" ]
    then
        mkdir -p frontends/ghdl
        cp -R ../$dir_name_gyp/src/* frontends/ghdl

        echo 'ENABLE_GHDL := 1' >> Makefile.conf
        echo "GHDL_PREFIX := $PACKAGE_DIR/$NAME" >> Makefile.conf
    fi
}

# -- Compile it
if [ $ARCH == "darwin" ]; then
    OLDPATH=$PATH
    export PATH="/usr/local/opt/bison/bin:/usr/local/opt/flex/bin:$PATH"
    $MAKE config-clang
    _ghdl_conf
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
    _ghdl_conf
    sed -r -i 's/^(YOSYS_VER := [0-9]+\.[0-9]+\+[0-9]+).*$/\1 \(open-tool-forge build\)/;' Makefile
    $MAKE -j$J GIT_REV="${GIT_REV}" PRETTY=0 \
              LDLIBS="-static -lstdc++ -lm $GHDL_LDLIBS" \
              ABCMKARGS="CC=\"$CC\" CXX=\"$CXX\" LIBS=\"-static -lm\" OPTFLAGS=\"-O\" \
                         ARCHFLAGS=\"$ABC_ARCHFLAGS\" \
                         ABC_USE_NO_READLINE=1 \
                         ABC_USE_NO_PTHREADS=1 \
                         ABC_USE_LIBSTDCXX=1 \
                         OPTFLAGS=\"-ggdb -O0\" \
                         ABC_MAKE_VERBOSE=1" \
              ENABLE_TCL=0 ENABLE_PLUGINS=0 ENABLE_READLINE=0 ENABLE_COVER=0 ENABLE_ZLIB=0 ENABLE_ABC=1 \
              PYTHON="./bin/python3-private.exe" # override the shebang telling the exe launcher where to find python

    test_bin yosys-smtbmc$EXE
else
    $MAKE config-gcc
    _ghdl_conf
    sed -i "s/-Wall -Wextra -ggdb/-w/;" Makefile
    sed -r -i 's/^(YOSYS_VER := [0-9]+\.[0-9]+\+[0-9]+).*$/\1 \(open-tool-forge build\)/;' Makefile
    # sed -i "s/LD = gcc$/LD = $CC/;" Makefile
    # sed -i "s/CXX = gcc$/CXX = $CC/;" Makefile
    # sed -i "s/LDFLAGS += -rdynamic/LDFLAGS +=/;" Makefile
    $MAKE -j$J GIT_REV="${GIT_REV}" PRETTY=0 \
                LDLIBS="-static -lstdc++ -lm $GHDL_LDLIBS -ldl" \
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
[[ ! -z "$EXE" ]] && cp yosys-smtbmc-script.py $PACKAGE_DIR/$NAME/bin/yosys-smtbmc-script.py

# -- Copy the share folder to the package folder
mkdir -p $PACKAGE_DIR/$NAME/share/yosys
cp -r share/* $PACKAGE_DIR/$NAME/share/yosys

strip_binaries bin/{yosys,yosys-abc,yosys-filterlib}$EXE

clean_build $dir_name
clean_build $dir_name_gyp
