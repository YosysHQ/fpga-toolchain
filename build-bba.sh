#!/bin/bash
##################################
#   FPGA toolchain builder       #
##################################

set -e

# Set english language for propper pattern matching
export LC_ALL=C

# export VERSION="${TRAVIS_TAG}"
export VERSION=nightly

# -- Target architectures
export ARCH=linux_x86_64

# -- Toolchain name
export NAME=ecp5-bba

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

print ">> Install dependencies"
. $WORK_DIR/scripts/install_dependencies.sh

print ">> Set build flags"
. $WORK_DIR/scripts/build_setup.sh

print ">> Compile nextpnr-ecp5-bba"
$WORK_DIR/scripts/compile_nextpnr-ecp5-bba.sh

print ">> Create package"
. $WORK_DIR/scripts/create_package.sh
