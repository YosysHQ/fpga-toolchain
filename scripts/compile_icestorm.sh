#!/usr/bin/env bash
# -- Compile Icestorm script

set -e

dir_name=icestorm
commit=master
git_url=https://github.com/YosysHQ/icestorm

git_clone $dir_name $git_url $commit

cd $BUILD_DIR/$dir_name

# -- Compile it
if [ $ARCH == "darwin" ]; then
    sed -i "" "s/-ggdb //;" config.mk
    # pkg-config is used to set LDLIBS in this Makefile and doesn't quite do what we want
    sed -i "" "s/\$^ \$(LDLIBS)/\$^ \$(LDSTATICLIBS)/g" iceprog/Makefile
    make -j$J CC="$CC" \
              SUBDIRS="iceprog" \
              PKG_CONFIG=":" \
              LDSTATICLIBS="-pthread $LIBFTDI_ROOT/lib/libftdi1.a $LIBUSB_ROOT/lib/libusb-1.0.a  -Wl,-framework,IOKit -Wl,-framework,CoreFoundation" \
              CFLAGS="-MD -O0 -Wall -std=c99 -I$LIBFTDI_ROOT/include/libftdi1 $CFLAGS"
    make -j$J CXX="$CXX" \
              CXXFLAGS="-std=c++11 $CXXFLAGS" \
              SUBDIRS="icebox icepack icemulti icepll icetime icebram"
elif [ ${ARCH:0:7} = "windows" ]
then
  sed -i "s/-ggdb //;" Makefile
  $MAKE -j$J CC="$CC" STATIC=1
else
  sed -i "s/-ggdb //;" config.mk
  sed -i "s/\$^ \$(LDLIBS)/\$^ \$(LDLIBS) \$(LDUSBSTATIC)/g" iceprog/Makefile
  make -j$J CC="$CC" \
            SUBDIRS="iceprog" \
            LDFLAGS="-static -pthread -L$WORK_DIR/build-data/lib/$ARCH " \
            LDUSBSTATIC="-lusb-1.0"\
            CFLAGS="-MD -O0 -Wall -std=c99 -I$WORK_DIR/build-data/include/libftdi1 -I$WORK_DIR/build-data/include/libusb-1.0"
  make -j$J CXX="$CXX" STATIC=1 \
            SUBDIRS="icebox icepack icemulti icepll icetime icebram"
fi

TOOLS="iceprog icepack icemulti icepll icetime icebram"

# -- Test the generated executables
for dir in $TOOLS; do
  test_bin $dir/$dir$EXE
done

# -- Copy the executables to the bin dir
for dir in $TOOLS; do
  cp $dir/$dir$EXE $PACKAGE_DIR/$NAME/bin/$dir$EXE
done

# -- Copy the chipdb*.txt data files
mkdir -p $PACKAGE_DIR/$NAME/share/icebox
cp -r icebox/chipdb*.txt $PACKAGE_DIR/$NAME/share/icebox
cp -r icefuzz/timings*.txt $PACKAGE_DIR/$NAME/share/icebox
