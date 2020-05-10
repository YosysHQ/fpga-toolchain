#!/bin/bash

set -e

ecpprog=ecpprog
commit=master
git_ecpprog=https://github.com/gregdavill/ecpprog.git

cd $UPSTREAM_DIR

# -- Clone the sources from github
test -e $ecpprog || git clone $git_ecpprog $ecpprog
git -C $ecpprog pull
git -C $ecpprog checkout $commit
git -C $ecpprog log -1

# -- Copy the upstream sources into the build directory
rsync -a $ecpprog $BUILD_DIR --exclude .git

cd $BUILD_DIR/$ecpprog/ecpprog

# -- Compile it
if [ $ARCH == "darwin" ]; then
    sed -i "" "s/-ggdb //;" Makefile
    # pkg-config is used to set LDLIBS in this Makefile and doesn't quite do what we want
    sed -i "" "s/\$^ \$(LDLIBS)/\$^ \$(LDSTATICLIBS)/g" Makefile
    make -j$J CC="$CC" \
              PKG_CONFIG=":" \
              LDSTATICLIBS="$LIBFTDI_ROOT/lib/libftdi1.a $LIBUSB_ROOT/lib/libusb-1.0.a  -Wl,-framework,IOKit -Wl,-framework,CoreFoundation" \
              CFLAGS="-MD -O0 -Wall -std=c99 -I$LIBFTDI_ROOT/include/libftdi1 $CFLAGS"
else
  sed -i "s/-ggdb //;" Makefile
  sed -i "s/\$^ \$(LDLIBS)/\$^ \$(LDLIBS) \$(LDUSBSTATIC)/g" Makefile
  make -j$J CC="$CC" \
            LDFLAGS="-static -L$WORK_DIR/build-data/lib/$ARCH " \
            LDUSBSTATIC="-lusb-1.0"\
            CFLAGS="-MD -O0 -Wall -std=c99 -I$WORK_DIR/build-data/include/libftdi1 -I$WORK_DIR/build-data/include/libusb-1.0"
fi

# -- Test the generated executable
test_bin ecpprog$EXE

# -- Copy the executable to the bin dir
cp ecpprog$EXE $PACKAGE_DIR/$NAME/bin/ecpprog$EXE
