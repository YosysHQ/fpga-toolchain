#!/bin/bash
##################################
#   FPGA toolchain builder       #
##################################

set -e

# Set english language for propper pattern matching
export LC_ALL=C

# export VERSION="${TRAVIS_TAG}"
export VERSION="nightly-$(date +%Y%m%d | tr -d '\n')"

# -- Target architectures
export ARCH=$1
# TARGET_ARCHS="linux_x86_64 linux_i686 linux_armv7l linux_aarch64 windows_x86 windows_amd64 darwin"
TARGET_ARCHS="linux_x86_64 windows_amd64 darwin"

# -- Toolchain name
export NAME=fpga-toolchain

# -- Debug flags
INSTALL_DEPS=1
COMPILE_DFU_UTIL=0
COMPILE_YOSYS=1
COMPILE_ICESTORM=0
COMPILE_NEXTPNR_ICE40=0
COMPILE_NEXTPNR_ECP5=0
COMPILE_ECPPROG=0
COMPILE_IVERILOG=0
COMPILE_GHDL=1
BUNDLE_PYTHON=0
CREATE_PACKAGE=1

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

if [ $BUNDLE_PYTHON == "1" ]; then
  print ">> Bundle Python"
  . $WORK_DIR/scripts/bundle_python.sh
fi

if [ $COMPILE_NEXTPNR_ECP5 == "1" ]; then
  print ">> Compile nextpnr-ecp5"
  . $WORK_DIR/scripts/compile-nextpnr-ecp5.sh
fi

if [ $COMPILE_DFU_UTIL == "1" ]; then
  print ">> Compile dfu-utils"
  . $WORK_DIR/scripts/compile_dfu_util.sh
fi

if [ $COMPILE_GHDL == "1" ]; then
  print ">> Compile ghdl"
  . $WORK_DIR/scripts/compile_ghdl.sh
fi

if [ $COMPILE_YOSYS == "1" ]; then
  print ">> Compile yosys"
  . $WORK_DIR/scripts/compile_yosys.sh
fi

if [ $COMPILE_ICESTORM == "1" ]; then
  print ">> Compile icestorm"
  . $WORK_DIR/scripts/compile_icestorm.sh
fi

if [ $COMPILE_NEXTPNR_ICE40 == "1" ]; then
  print ">> Compile nextpnr-ice40"
  . $WORK_DIR/scripts/compile_nextpnr-ice40.sh
fi

if [ $COMPILE_ECPPROG == "1" ]; then
  print ">> Compile ecpprog"
  . $WORK_DIR/scripts/compile_ecpprog.sh
fi

if [ $COMPILE_IVERILOG == "1" ]; then
  print ">> Compile iverilog"
  . $WORK_DIR/scripts/compile_iverilog.sh
fi

if [ $CREATE_PACKAGE == "1" ]; then
  print ">> Create package"
  . $WORK_DIR/scripts/create_package.sh
fi
