#!/usr/bin/env bash
# -- Compile dfu-util script

set -e

dir_name=dfu-util
commit=master
git_url=https://git.code.sf.net/p/dfu-util/dfu-util

git_clone $dir_name $git_url $commit

cd $BUILD_DIR/$dir_name

./autogen.sh
# -- Compile it
if [ $ARCH == "darwin" ]; then
    ./configure --libdir=/opt/local/lib \
        --includedir=/opt/local/include \
        USB_CFLAGS="-I$LIBUSB_ROOT/include/libusb-1.0" \
        USB_LIBS="$LIBUSB_ROOT/lib/libusb-1.0.a -Wl,-framework,IOKit -Wl,-framework,CoreFoundation"
    $MAKE SUBDIRS=src
elif [ ${ARCH:0:7} = "windows" ]
then
    ./configure USB_LIBS="-static -lpthread -lusb-1.0"
    $MAKE SUBDIRS=src
elif [ ${ARCH} == "linux_armv6" ] || [ ${ARCH} == "linux_armv7l" ] || [ ${ARCH} == "linux_aarch64" ]
then
    ./configure $HOST_FLAGS USB_CFLAGS="-I$WORK_DIR/build-data/include/libusb-1.0" USB_LIBS="-static $WORK_DIR/build-data/lib/$ARCH/libusb-1.0.a -lpthread"
    $MAKE SUBDIRS=src
else
    ./configure USB_CFLAGS="-I$WORK_DIR/build-data/include/libusb-1.0" USB_LIBS="-static $WORK_DIR/build-data/lib/$ARCH/libusb-1.0.a -lpthread"
    $MAKE SUBDIRS=src
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

strip_binaries bin/{dfu-util,dfu-prefix,dfu-suffix}$EXE

if [ ${ARCH:0:7} = "windows" ]; then
  cp $PACKAGE_DIR/$NAME/bin/{dfu-util,dfu-prefix,dfu-suffix}$EXE $PACKAGE_DIR/${NAME}-progtools/bin/
fi

clean_build $dir_name
