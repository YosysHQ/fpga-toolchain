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

# -- Compile it
cd src
cat > config.h <<EOF
#define HAVE_GETPAGESIZE 1
#define HAVE_INTTYPES_H 1
#define HAVE_MEMORY_H 1
#define HAVE_NANOSLEEP 1
#define HAVE_STDINT_H 1
#define HAVE_STDLIB_H 1
#define HAVE_STRINGS_H 1
#define HAVE_STRING_H 1
#define HAVE_SYS_STAT_H 1
#define HAVE_SYS_TYPES_H 1
#define HAVE_UNISTD_H 1
#define PACKAGE "dfu-util"
#define PACKAGE_BUGREPORT "http://sourceforge.net/p/dfu-util/tickets/"
#define PACKAGE_NAME "dfu-util"
#define PACKAGE_STRING "dfu-util 0.9"
#define PACKAGE_TARNAME "dfu-util"
#define PACKAGE_URL "http://dfu-util.sourceforge.net"
#define PACKAGE_VERSION "0.9"
#define STDC_HEADERS 1
#define VERSION "0.9"
EOF
if [ $ARCH == "darwin" ]; then
    $CC -g -O2 \
        -o dfu-util$EXE \
        -I/tmp/conda/include/libusb-1.0 \
        main.c dfu_load.c dfu_util.c dfuse.c dfuse_mem.c dfu.c dfu_file.c quirks.c \
        -lpthread \
        -lobjc -Wl,-framework,IOKit -Wl,-framework,CoreFoundation /tmp/conda/lib/libusb-1.0.a \
        -DHAVE_CONFIG_H=1
    $CC -o dfu-prefix$EXE -I/tmp/conda/include/libusb-1.0 prefix.c dfu_file.c -DHAVE_NANOSLEEP=1 -DHAVE_CONFIG_H=1
    $CC -o dfu-suffix$EXE -I/tmp/conda/include/libusb-1.0 suffix.c dfu_file.c -DHAVE_NANOSLEEP=1 -DHAVE_CONFIG_H=1
else
    $CC -g -O2 -I$WORK_DIR/build-data/include/libusb-1.0 \
        -o dfu-util$EXE \
        main.c dfu_load.c dfu_util.c dfuse.c dfuse_mem.c dfu.c dfu_file.c quirks.c \
        -static $WORK_DIR/build-data/lib/$ARCH/libusb-1.0.a -lpthread \
        -DHAVE_CONFIG_H=1
    $CC -o dfu-prefix$EXE prefix.c dfu_file.c -static -DHAVE_NANOSLEEP=1 -DHAVE_CONFIG_H=1
    $CC -o dfu-suffix$EXE suffix.c dfu_file.c -static -DHAVE_NANOSLEEP=1 -DHAVE_CONFIG_H=1
fi
cd ..

TOOLS="dfu-util dfu-prefix dfu-suffix"

# -- Test the generated executables
for tool in $TOOLS; do
  test_bin src/$tool$EXE
done

# -- Copy the executables to the bin dir
for tool in $TOOLS; do
  cp src/$tool$EXE $PACKAGE_DIR/$NAME/bin/$tool$EXE
done