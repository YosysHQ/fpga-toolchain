#!/bin/bash
##################################
#   Icestorm toolchain builder   #
##################################

# Set english language for propper pattern matching
export LC_ALL=C

VERSION="${TRAVIS_TAG}"

# -- Target architectures
ARCH=$1
TARGET_ARCHS="linux_x86_64 linux_i686 linux_armv7l linux_aarch64 windows_x86 windows_amd64 darwin"

# -- Toolchain name
NAME=toolchain-icestorm

# -- Debug flags
INSTALL_DEPS=1
COMPILE_DFU_UTIL=1
COMPILE_ICESTORM=1
COMPILE_YOSYS=1
CREATE_PACKAGE=1

# -- Store current dir
WORK_DIR=$PWD
# -- Folder for building the source code
BUILDS_DIR=$WORK_DIR/_builds
# -- Folder for storing the generated packages
PACKAGES_DIR=$WORK_DIR/_packages
# --  Folder for storing the source code from github
UPSTREAM_DIR=$WORK_DIR/_upstream

# -- Create the build directory
mkdir -p $BUILDS_DIR
# -- Create the packages directory
mkdir -p $PACKAGES_DIR
# -- Create the upstream directory and enter into it
mkdir -p $UPSTREAM_DIR

# -- Directory for compiling the tools
BUILD_DIR=$BUILDS_DIR/build_$ARCH

# -- Directory for installation the target files
PACKAGE_DIR=$PACKAGES_DIR/build_$ARCH

# -- Create the build dir
mkdir -p $BUILD_DIR

# -- Create the package folders
mkdir -p $PACKAGE_DIR/$NAME/bin
mkdir -p $PACKAGE_DIR/$NAME/share

# -- Test script function
function test_bin {
  . $WORK_DIR/test/test_bin.sh $1
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

# --------- Install dependencies ------------------------------------
if [ $INSTALL_DEPS == "1" ]; then
  print ">> Install dependencies"
  . $WORK_DIR/scripts/install_dependencies.sh
fi

# --------- Install dependencies ------------------------------------
print ">> Set build flags"
. $WORK_DIR/scripts/build_setup.sh

# --------- Compile dfu-utils ------------------------------------------
if [ $COMPILE_DFU_UTIL == "1" ]; then
  print ">> Compile dfu-utils"
  . $WORK_DIR/scripts/compile_dfu_util.sh
fi

# --------- Compile yosys ------------------------------------------
if [ $COMPILE_YOSYS == "1" ]; then
  print ">> Compile yosys"
  . $WORK_DIR/scripts/compile_yosys.sh
fi

# --------- Compile icestorm ---------------------------------------
if [ $COMPILE_ICESTORM == "1" ]; then
  print ">> Compile icestorm"
  . $WORK_DIR/scripts/compile_icestorm.sh
fi

# --------- Create the package -------------------------------------
if [ $CREATE_PACKAGE == "1" ]; then
  print ">> Create package"
  . $WORK_DIR/scripts/create_package.sh
fi
