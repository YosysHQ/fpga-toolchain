docker run -d --name fomu-build --restart unless-stopped --log-opt max-size=10m -v /disk/xobs-data/fomu-build:/build ubuntu:bionic /bin/bash -c "while true; do sleep 3600; done"

docker exec -it fomu-build /bin/bash

apt-get update
apt-get install -y sudo git rsync vim
echo 'builder ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

adduser --system --disabled-password --shell /bin/bash --uid 1000 builder
su - builder
git clone https://github.com/xobs/toolchain-nextpnr-ice40.git
cd toolchain-nextpnr-ice40

export ARCH=linux_x86_64

# -- Toolchain name
export NAME=toolchain-nextpnr-ice40

export VERSION=$(git describe --tags)

# -- Store current dir
export WORK_DIR=$PWD
# -- Folder for building the source code
export BUILDS_DIR=$WORK_DIR/_builds
# -- Folder for storing the generated packages
export PACKAGES_DIR=$WORK_DIR/_packages
# --  Folder for storing the source code from github
export UPSTREAM_DIR=$WORK_DIR/_upstream
# -- Directory for compiling the tools
export BUILD_DIR=$BUILDS_DIR/build_$ARCH
# -- Directory for installation the target files
export PACKAGE_DIR=$PACKAGES_DIR/build_$ARCH

# -- Create the build directory
mkdir -p $BUILDS_DIR
# -- Create the packages directory
mkdir -p $PACKAGES_DIR
# -- Create the upstream directory and enter into it
mkdir -p $UPSTREAM_DIR
# -- Create the build dir
mkdir -p $BUILD_DIR
# -- Create the package folders
mkdir -p $PACKAGE_DIR/$NAME/bin
mkdir -p $PACKAGE_DIR/$NAME/share

export PATH=$WORK_DIR/test:$PATH
export DEBIAN_FRONTEND=noninteractive
. ./scripts/build_setup.sh
./scripts/install_dependencies.sh




        stepi 1000

server define find_error
    run
    cont
    while($_thread != 0)
        set $old_pc = $pc
        stepi 1000
    end
end

sed -i 's/ gcc / $(CC) /' backends/smt2/Makefile.inc
make -j$J YOSYS_VER="$VER (Fomu build)"               ENABLE_TCL=0 ENABLE_PLUGINS=0 ENABLE_READLINE=0 ENABLE_COVER=0 ENABLE_ZLIB=0 ENABLE_PYOSYS=0 PRETTY=0 ENABLE_ABC=0