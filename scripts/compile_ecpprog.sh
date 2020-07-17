#!/usr/bin/env bash

set -e

dir_name=ecpprog
commit=master
git_url=https://github.com/gregdavill/ecpprog.git

git_clone $dir_name $git_url $commit

cd $BUILD_DIR/$dir_name/ecpprog

# -- Compile it
if [ $ARCH == "darwin" ]; then
    sed -i "" "s/-ggdb //;" Makefile
    # pkg-config is used to set LDLIBS in this Makefile and doesn't quite do what we want
    sed -i "" "s/\$^ \$(LDLIBS)/\$^ \$(LDSTATICLIBS)/g" Makefile
    $MAKE -j$J CC="$CC" \
              PKG_CONFIG=":" \
              LDSTATICLIBS="$LIBFTDI_ROOT/lib/libftdi1.a $LIBUSB_ROOT/lib/libusb-1.0.a  -Wl,-framework,IOKit -Wl,-framework,CoreFoundation" \
              CFLAGS="-MD -O0 -Wall -std=c99 -I$LIBFTDI_ROOT/include/libftdi1 $CFLAGS"
elif [ ${ARCH:0:7} = "windows" ]
then
  sed -i "s/-ggdb //;" Makefile
  $MAKE -j$J CC="$CC" \
              LDFLAGS="-static -pthread" 
else
  sed -i "s/-ggdb //;" Makefile
  sed -i "s/\$^ \$(LDLIBS)/\$^ \$(LDLIBS) \$(LDUSBSTATIC)/g" Makefile
  $MAKE -j$J CC="$CC" \
            LDFLAGS="-static -pthread -L$WORK_DIR/build-data/lib/$ARCH " \
            LDUSBSTATIC="-lusb-1.0"\
            CFLAGS="-MD -O0 -Wall -std=c99 -I$WORK_DIR/build-data/include/libftdi1 -I$WORK_DIR/build-data/include/libusb-1.0"
fi

# -- Test the generated executable
test_bin ecpprog$EXE

# -- Copy the executable to the bin dir
cp ecpprog$EXE $PACKAGE_DIR/$NAME/bin/ecpprog$EXE

strip_binaries bin/ecpprog$EXE

clean_build $dir_name
