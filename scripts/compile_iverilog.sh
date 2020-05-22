#!/bin/bash

set -e

iverilog=iverilog
commit=master
git_iverilog=https://github.com/steveicarus/iverilog.git

cd $UPSTREAM_DIR

# -- Clone the sources from github
test -e $iverilog || git clone $git_iverilog $iverilog
git -C $iverilog pull
git -C $iverilog checkout $commit
git -C $iverilog log -1

# -- Copy the upstream sources into the build directory
rsync -a $iverilog $BUILD_DIR --exclude .git

cd $BUILD_DIR/$iverilog

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

    $MAKE SUBDIRS="ivlpp vhdlpp vvp driver" LDFLAGS="-static-libgcc -static -lstdc++ -lm -lc"
fi

$MAKE install
