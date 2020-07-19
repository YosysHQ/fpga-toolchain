#!/usr/bin/env bash

set -e

dir_name=openfpgaloader
commit=master
git_url=https://github.com/trabucayre/openFPGALoader.git

git_clone $dir_name $git_url $commit

mkdir -p $BUILD_DIR/$dir_name/build
cd $BUILD_DIR/$dir_name
patch -p1 < $WORK_DIR/scripts/openfpgaloader.diff
cd build

# -- Compile it
if [ $ARCH == "darwin" ]; then
    cmake -DENABLE_UDEV=OFF ../
    $MAKE -j$J
    # ./configure --libdir=/opt/local/lib \
    #     --includedir=/opt/local/include \
    #     USB_CFLAGS="-I$LIBUSB_ROOT/include/libusb-1.0" \
    #     USB_LIBS="$LIBUSB_ROOT/lib/libusb-1.0.a -Wl,-framework,IOKit -Wl,-framework,CoreFoundation"
elif [ ${ARCH:0:7} = "windows" ]
then
    cmake -DENABLE_UDEV=OFF -DBUILD_STATIC=ON ../
    $MAKE -j$J
    # ./configure USB_LIBS="-static -lpthread -lusb-1.0"
    # $MAKE
else
# $WORK_DIR/build-data/lib/$ARCH/libusb-1.0.a $WORK_DIR/build-data/lib/$ARCH/libftdi1.a
# -L$WORK_DIR/build-data/lib/$ARCH
#  -I$WORK_DIR/build-data/include/libusb-1.0
# LDFLAGS="-static   -lpthread" 
        # -DCMAKE_EXE_LINKER_FLAGS="-lpthread -lrt"

    sed -i 's/pkg_check_modules.LIBFTDI REQUIRED libftdi1.//' ../CMakeLists.txt
    sed -i 's/pkg_check_modules.LIBUSB REQUIRED libusb-1.0.//' ../CMakeLists.txt
    VERBOSE=1 \
        cmake -DENABLE_UDEV=OFF -DBUILD_STATIC=ON \
        -DLIBUSB_LIBRARIES=$WORK_DIR/build-data/lib/$ARCH/libusb-1.0.a \
        -DLIBFTDI_LIBRARIES=$WORK_DIR/build-data/lib/$ARCH/libftdi1.a \
        -DLIBFTDI_VERSION=1.4 \
        -DCMAKE_CXX_FLAGS="-I$WORK_DIR/build-data/include/libusb-1.0 -I$WORK_DIR/build-data/include/libftdi1" \
        ../
    VERBOSE=1 $MAKE -j$J
fi

test_bin openFPGALoader$EXE
cp openFPGALoader$EXE $PACKAGE_DIR/$NAME/bin/openFPGALoader$EXE

strip_binaries bin/openFPGALoader$EXE

clean_build $dir_name
