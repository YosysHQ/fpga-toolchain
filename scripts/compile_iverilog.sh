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

patch -p1 < $WORK_DIR/scripts/iverilog.diff

bash ./autoconf.sh
# -- Compile it
if [ $ARCH == "darwin" ]; then
    OLDPATH=$PATH
    export PATH="/usr/local/opt/bison/bin:/usr/local/opt/flex/bin:$PATH"

    ./configure --prefix=$PACKAGE_DIR/$NAME \
        --exec-prefix=$PACKAGE_DIR/$NAME \

    $MAKE

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

    # $MAKE
    # ivlpp vhdlpp vvp vpi libveriuser cadpli tgt-null tgt-stub tgt-vvp \
        #    tgt-vhdl tgt-vlog95 tgt-pcb tgt-blif tgt-sizer driver

    $MAKE SUBDIRS="ivlpp vhdlpp vvp driver" LDFLAGS="-static-libgcc -static -lstdc++ -lm -lc"
fi

$MAKE install
