#!/bin/bash
# -- Compile dfu-util script

set -e

dfu_util=dfu-util
commit=master
git_dfu_util=https://git.code.sf.net/p/dfu-util/dfu-util

cd $UPSTREAM_DIR

# -- Clone the sources from github
test -e $dfu_util || git clone $git_dfu_util $dfu_util
git -C $dfu_util pull
git -C $dfu_util checkout $commit
git -C $dfu_util log -1

# -- Copy the upstream sources into the build directory
rsync -a $dfu_util $BUILD_DIR --exclude .git

cd $BUILD_DIR/$dfu_util

./autogen.sh
# -- Compile it
if [ $ARCH == "darwin" ]; then
    ./configure --libdir=/opt/local/lib \
        --includedir=/opt/local/include \
        USB_CFLAGS="-I$LIBUSB_ROOT/include/libusb-1.0" \
        USB_LIBS="$LIBUSB_ROOT/lib/libusb-1.0.a -Wl,-framework,IOKit -Wl,-framework,CoreFoundation"
    make
else
    ./configure USB_CFLAGS="-I$WORK_DIR/build-data/include/libusb-1.0" USB_LIBS="-static $WORK_DIR/build-data/lib/$ARCH/libusb-1.0.a -lpthread"
    make
fi

TOOLS="dfu-util dfu-prefix dfu-suffix"

# -- Test the generated executables
for tool in $TOOLS; do
  test_bin src/$tool$EXE
done

# -- Copy the executables to the bin dir
for tool in $TOOLS; do
  cp src/$tool$EXE $PACKAGE_DIR/$NAME/bin/$tool$EXE
done
