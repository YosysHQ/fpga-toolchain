# Install dependencies script

base_packages="build-essential bison flex libreadline-dev \
               gawk tcl-dev libffi-dev git rsync \
               pkg-config python3"

if [ $ARCH == "linux_x86_64" ]; then
    sudo apt-get update
    sudo apt-get install -y $base_packages
    gcc --version
    g++ --version
fi

if [ $ARCH == "linux_i686" ]; then
    sudo apt-get update
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y $base_packages \
                            gcc-7-multilib g++-7-multilib
    gcc --version
    g++ --version
fi

if [ $ARCH == "linux_armv7l" ]; then
    sudo apt-get update
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y $base_packages \
                            gcc-arm-linux-gnueabihf g++-arm-linux-gnueabihf \
                            gcc-7-arm-linux-gnueabihf g++-7-arm-linux-gnueabihf \
                            binfmt-support qemu-user-static
    arm-linux-gnueabihf-gcc --version
    arm-linux-gnueabihf-g++ --version
fi

if [ $ARCH == "linux_aarch64" ]; then
    sudo apt-get update
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y $base_packages \
                            gcc-aarch64-linux-gnu g++-aarch64-linux-gnu \
                            binfmt-support qemu-user-static
    sudo apt-get autoremove -y
    aarch64-linux-gnu-gcc --version
    aarch64-linux-gnu-g++ --version
fi

if [ $ARCH == "windows_x86" ]; then
    sudo apt-get update
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y $base_packages \
                            mingw-w64 mingw-w64-tools mingw-w64-i686-dev \
                            zip
    i686-w64-mingw32-gcc --version
    i686-w64-mingw32-g++ --version
fi

if [ $ARCH == "windows_amd64" ]; then
    sudo apt-get update
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y $base_packages \
                            mingw-w64 mingw-w64-tools mingw-w64-x86-64-dev \
                            zip
    x86_64-w64-mingw32-gcc --version
    x86_64-w64-mingw32-g++ --version
fi

if [ $ARCH == "darwin" ]; then
    export PATH=/tmp/conda/bin:$PATH
    for dep in $(ls -1 $WORK_DIR/build-data/darwin/*.bz2)
    do
        mkdir -p /tmp/conda
        pushd /tmp/conda
        echo "Extracting $dep..."
        tar xjf $dep
        if [ -e info/has_prefix ]
        then
            python3 $WORK_DIR/build-data/darwin/convert.py /tmp/conda
            rm -f info/has_prefix
        fi
        popd
    done
    echo copying libftdi1 to libftdi
    cp /tmp/conda/lib/libftdi1.a /tmp/conda/lib/libftdi.a
    cp /tmp/conda/lib/libftdi1.dylib /tmp/conda/lib/libftdi.dylib
else
    cp $WORK_DIR/build-data/lib/$ARCH/libftdi1.a $WORK_DIR/build-data/lib/$ARCH/libftdi.a
fi

