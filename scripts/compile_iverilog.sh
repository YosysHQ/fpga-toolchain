#!/usr/bin/env bash

set -e

dir_name=iverilog
commit=master
git_url=https://github.com/steveicarus/iverilog.git

git_clone $dir_name $git_url $commit

cd $BUILD_DIR/$dir_name

bash ./autoconf.sh
# -- Compile it
if [ $ARCH == "darwin" ]; then
    OLDPATH=$PATH
    export PATH="/usr/local/opt/bison/bin:/usr/local/opt/flex/bin:$PATH"

    ./configure --prefix=$PACKAGE_DIR/$NAME \
        --exec-prefix=$PACKAGE_DIR/$NAME \

    $MAKE LIBS="-lm /usr/local/opt/zlib/lib/libz.a \
        /usr/local/opt/bzip2/lib/libbz2.a \
        /usr/local/opt/ncurses/lib/libncurses.a \
        /usr/local/opt/libedit/lib/libedit.a"

    export PATH=$OLDPATH
elif [ ${ARCH:0:7} = "windows" ]
then
    ./configure --prefix=$PACKAGE_DIR/$NAME \
        --exec-prefix=$PACKAGE_DIR/$NAME \
        LDFLAGS="-static -lstdc++ -lm" \

    $MAKE
else
    ./configure --prefix=$PACKAGE_DIR/$NAME \
        --exec-prefix=$PACKAGE_DIR/$NAME \

    $MAKE SUBDIRS="ivlpp vhdlpp vvp driver"
    # LDFLAGS="-static-libgcc -Wl,-Bstatic -lstdc++ -ldl -lm -lc -Wl,-Bdynamic"
fi

$MAKE install

TOOLS="bin/iverilog bin/vvp lib/ivl/ivl lib/ivl/ivlpp lib/ivl/vhdlpp"

# -- Test the generated executables
for tool in $TOOLS; do
  test_bin $PACKAGE_DIR/$NAME/$tool$EXE
done