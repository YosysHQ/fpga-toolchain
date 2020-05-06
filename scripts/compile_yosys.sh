#!/bin/bash -x
# -- Compile Yosys script

set -e

REL=0 # 1: load from release tag. 0: load from source code

VER=master
YOSYS=yosys-yosys-$VER
TAR_YOSYS=yosys-$VER.tar.gz
REL_YOSYS=https://github.com/YosysHQ/yosys/archive/$TAR_YOSYS
GIT_YOSYS=https://github.com/YosysHQ/yosys.git

cd $UPSTREAM_DIR

if [ $REL -eq 1 ]; then
    # -- Check and download the release
    test -e $TAR_YOSYS || wget $REL_YOSYS
    # -- Unpack the release
    tar zxf $TAR_YOSYS
else
    # -- Clone the sources from github
    VER=$(git ls-remote ${GIT_YOSYS} ${VER} | cut -f 1)
    YOSYS=yosys-yosys-$VER
    git clone $GIT_YOSYS $YOSYS
    git -C $YOSYS pull
    VER=$(git -C $YOSYS rev-parse ${VER})
    echo ""
    git -C $YOSYS reset --hard $VER
    git -C $YOSYS log -1
fi

# -- Copy the upstream sources into the build directory
rsync -a $YOSYS $BUILD_DIR --exclude .git

cd $BUILD_DIR/$YOSYS

# -- Compile it
if [ $ARCH == "darwin" ]; then
    make config-clang
    sed -i "" "s/-Wall -Wextra -ggdb/-w/;" Makefile
    CXXFLAGS="-I/tmp/conda/include -std=c++11 $CXXFLAGS" LDFLAGS="-L/tmp/conda/lib $LDFLAGS" make \
            -j$J YOSYS_VER="$VER (open-tool-forge build)" \
            ENABLE_TCL=0 ENABLE_PLUGINS=0 ENABLE_READLINE=0 ENABLE_COVER=0 ENABLE_ZLIB=0 ENABLE_ABC=1 \
            ABCMKARGS="CC=\"$CC\" CXX=\"$CXX\" OPTFLAGS=\"-O\" \
                       ARCHFLAGS=\"$ABC_ARCHFLAGS\" ABC_USE_NO_READLINE=1"

elif [ ${ARCH:0:7} == "windows" ]; then
    make config-msys2-64
    make -j$J YOSYS_VER="$VER (open-tool-forge build)" PRETTY=0 \
              LDLIBS="-static -lstdc++ -lm" \
              ABCMKARGS="CC=\"$CC\" CXX=\"$CXX\" LIBS=\"-static -lm\" OPTFLAGS=\"-O\" \
                         ARCHFLAGS=\"$ABC_ARCHFLAGS\" \
                         ABC_USE_NO_READLINE=1 \
                         ABC_USE_NO_PTHREADS=1 \
                         ABC_USE_LIBSTDCXX=1" \
              ENABLE_TCL=0 ENABLE_PLUGINS=0 ENABLE_READLINE=0 ENABLE_COVER=0 ENABLE_ZLIB=0 ENABLE_ABC=1

else
    make config-gcc
    sed -i "s/-Wall -Wextra -ggdb/-w/;" Makefile
    sed -i "s/LD = gcc$/LD = $CC/;" Makefile
    sed -i "s/CXX = gcc$/CXX = $CC/;" Makefile
    sed -i "s/LDFLAGS += -rdynamic/LDFLAGS +=/;" Makefile
    make -j$J YOSYS_VER="$VER (open-tool-forge build)" \
                LDLIBS="-static -lstdc++ -lm" \
                ENABLE_TCL=0 ENABLE_PLUGINS=0 ENABLE_READLINE=0 ENABLE_COVER=0 ENABLE_ZLIB=0 ENABLE_ABC=1 \
                ABCMKARGS="CC=\"$CC\" CXX=\"$CXX\" LIBS=\"-static -lm -ldl -pthread\" \
                           OPTFLAGS=\"-O\" \
                           ARCHFLAGS=\"$ABC_ARCHFLAGS -Wno-unused-but-set-variable\" \
                           ABC_USE_NO_READLINE=1"
fi

EXE_O=
if [ -f yosys.exe ]; then
    EXE_O=.exe
    PY=.exe
fi

# -- Test the generated executables
test_bin yosys$EXE_O
test_bin yosys-abc$EXE_O
test_bin yosys-config
test_bin yosys-filterlib$EXE_O
test_bin yosys-smtbmc$EXE_O

# -- Copy the executable files
cp yosys$EXE_O $PACKAGE_DIR/$NAME/bin/yosys$EXE
cp yosys-abc$EXE_O $PACKAGE_DIR/$NAME/bin/yosys-abc$EXE
cp yosys-config $PACKAGE_DIR/$NAME/bin/yosys-config
cp yosys-filterlib$EXE_O $PACKAGE_DIR/$NAME/bin/yosys-filterlib$EXE
cp yosys-smtbmc$EXE_O $PACKAGE_DIR/$NAME/bin/yosys-smtbmc$PY

# -- Copy the share folder to the package folder
mkdir -p $PACKAGE_DIR/$NAME/share/yosys
cp -r share/* $PACKAGE_DIR/$NAME/share/yosys
