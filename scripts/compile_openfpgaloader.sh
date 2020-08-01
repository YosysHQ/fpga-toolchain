#!/usr/bin/env bash

set -e

dir_name=openfpgaloader
commit=master
git_url=https://github.com/trabucayre/openFPGALoader.git

git_clone $dir_name $git_url $commit

mkdir -p $BUILD_DIR/$dir_name/build
cd $BUILD_DIR/$dir_name/build


# -- Compile it
if [ $ARCH == "darwin" ]; then
    cmake -DENABLE_UDEV=OFF ../
    $MAKE -j$J
elif [ ${ARCH:0:7} = "windows" ]
then
    cmake -G "MinGW Makefiles" -DENABLE_UDEV=OFF -DBUILD_STATIC=ON ../
    $MAKE -j$J
else
    cmake -DLINK_CMAKE_THREADS=ON -DUSE_PKGCONFIG=OFF -DENABLE_UDEV=OFF -DBUILD_STATIC=ON \
        -DLIBUSB_LIBRARIES=$WORK_DIR/build-data/lib/$ARCH/libusb-1.0.a \
        -DLIBFTDI_LIBRARIES=$WORK_DIR/build-data/lib/$ARCH/libftdi1.a \
        -DLIBFTDI_VERSION=1.4 \
        -DCMAKE_CXX_FLAGS="-I$WORK_DIR/build-data/include/libusb-1.0 -I$WORK_DIR/build-data/include/libftdi1" \
        ../
    $MAKE -j$J
fi

test_bin openFPGALoader$EXE
cp openFPGALoader$EXE $PACKAGE_DIR/$NAME/bin/openFPGALoader$EXE

strip_binaries bin/openFPGALoader$EXE

if [ ${ARCH:0:7} = "windows" ]; then
  cp $PACKAGE_DIR/$NAME/bin/openFPGALoader$EXE $PACKAGE_DIR/${NAME}-progtools/bin/openFPGALoader$EXE
fi

clean_build $dir_name
