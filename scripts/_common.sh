#!/usr/bin/env bash
##################################
#   FPGA toolchain builder       #
##################################

set -e

# Set english language for propper pattern matching
export LC_ALL=C

export VERSION="${VERSION:-nightly-$(date +%Y%m%d | tr -d '\n')}"

# -- Target architectures
export ARCH=$1
# TARGET_ARCHS="linux_x86_64 linux_i686 linux_armv7l linux_aarch64 windows_x86 windows_amd64 darwin"
TARGET_ARCHS="linux_x86_64 windows_amd64 darwin"

# -- Store current dir
export WORK_DIR=$PWD
# -- Folder for building the source code
export BUILDS_DIR=$WORK_DIR/_builds
# -- Folder for storing the generated packages
export PACKAGES_DIR=$WORK_DIR/_packages
# --  Folder for storing the source code from github
export UPSTREAM_DIR=$WORK_DIR/_upstream

# -- Create the build directory
mkdir -p $BUILDS_DIR
# -- Create the packages directory
mkdir -p $PACKAGES_DIR
# -- Create the upstream directory and enter into it
mkdir -p $UPSTREAM_DIR

# -- Directory for compiling the tools
export BUILD_DIR=$BUILDS_DIR/build_$ARCH

# -- Directory for installation the target files
export PACKAGE_DIR=$PACKAGES_DIR/build_$ARCH

# -- Create the build dir
mkdir -p $BUILD_DIR

# -- Create the package folders
mkdir -p $PACKAGE_DIR/$NAME/bin
mkdir -p $PACKAGE_DIR/$NAME/share

# -- Test script function
function test_bin {
    . $WORK_DIR/scripts/test_bin.sh $1
    if [ $? != "0" ]; then
        exit 1
    fi
}


# -- Print function
function print {
  echo ""
  echo $1
  echo ""
}

function git_clone {
    dir_name=$1
    git_url=$2
    git_commit=$3
    update_submodules=$4

    pushd $UPSTREAM_DIR

    # -- Clone the sources from github
    test -e $dir_name || git clone $git_url $dir_name
    git -C $dir_name pull
    git -C $dir_name checkout $git_commit
    [[ ! -z "$update_submodules" ]] && git -C $dir_name submodule init
    [[ ! -z "$update_submodules" ]] && git -C $dir_name submodule update
    git -C $dir_name log -1

    # -- Copy the upstream sources into the build directory
    rsync -a $dir_name $BUILD_DIR --exclude .git

    popd
}

# -- Check ARCH
if [[ $# > 1 ]]; then
  echo ""
  echo "Error: too many arguments"
  exit 1
fi

if [[ $# < 1 ]]; then
  echo ""
  echo "Usage: bash build.sh TARGET"
  echo ""
  echo "Targets: $TARGET_ARCHS"
  exit 1
fi

if [[ $ARCH =~ [[:space:]] || ! $TARGET_ARCHS =~ (^|[[:space:]])$ARCH([[:space:]]|$) ]]; then
  echo ""
  echo ">>> WRONG ARCHITECTURE \"$ARCH\""
  exit 1
fi

echo ""
echo ">>> ARCHITECTURE \"$ARCH\""

if [ $INSTALL_DEPS == "1" ]; then
  print ">> Install dependencies"
  . $WORK_DIR/scripts/install_dependencies.sh
fi

print ">> Set build flags"
. $WORK_DIR/scripts/build_setup.sh
