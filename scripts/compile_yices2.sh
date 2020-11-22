#!/usr/bin/env bash

set -e

dir_name=yices2
commit=master
git_url=https://github.com/SRI-CSL/yices2.git

# gperf files don't work with CRLF line endings on windows
# TODO: handle this better so I don't mess with people's dev envs
git config --global core.autocrlf false
git_clone $dir_name $git_url $commit
cd $BUILD_DIR/$dir_name
autoconf

if [ $ARCH == "darwin" ]
then
    ./configure
    $MAKE -j$J static-bin
    YICES2_BINDIR=./build/x86_64-apple-darwin*-release/static_bin
elif [ ${ARCH:0:7} = "windows" ]
then
    ./configure --host=x86_64-pc-mingw64
    # this is a hack to make the Makefile behave like we are on cygwin
    # (they have not implemented MSYS2 support but it seems to work anyway)
    echo 'echo "cygwin"' > autoconf/os
    MAKE=/usr/bin/make OPTION=mingw64 /usr/bin/make -j$J static-bin
    YICES2_BINDIR=./build/x86_64-pc-mingw64-release/static_bin
elif [ ${ARCH} == "linux_armv6" ] || [ ${ARCH} == "linux_armv7l" ] || [ ${ARCH} == "linux_aarch64" ]
then
    # This is not very precise - the test for libgmp being "usable" gives up for cross builds so
    # this overrides that behaviour. TODO: use a proper patch file
    sed -i "s/run_ok=no/run_ok=yes/;" configure
    LDFLAGS="-L$BUILDROOT_SYSROOT/usr/lib/" ./configure $HOST_FLAGS
    $MAKE OPTION= ARCH=${TARGET_PREFIX::-1} -j$J static-bin
    YICES2_BINDIR=./build/${TARGET_PREFIX}release/static_bin
else
    ./configure
    $MAKE -j$J static-bin
    YICES2_BINDIR=./build/x86_64-pc-linux-gnu-release/static_bin
fi

cp $YICES2_BINDIR/yices$EXE $PACKAGE_DIR/$NAME/bin/yices$EXE
cp $YICES2_BINDIR/yices_sat$EXE $PACKAGE_DIR/$NAME/bin/yices-sat$EXE
cp $YICES2_BINDIR/yices_smt$EXE $PACKAGE_DIR/$NAME/bin/yices-smt$EXE
cp $YICES2_BINDIR/yices_smt2$EXE $PACKAGE_DIR/$NAME/bin/yices-smt2$EXE

TOOLS="yices yices-sat yices-smt yices-smt2"

for tool in $TOOLS; do
  test_bin $PACKAGE_DIR/$NAME/bin/$tool$EXE
  strip_binaries bin/$tool$EXE
done

clean_build $dir_name
