#!/usr/bin/env bash
##################################
#   FPGA toolchain builder       #
##################################

set -e

# Set english language for propper pattern matching
export LC_ALL=C

[ -f .env ] && source .env

export VERSION="${VERSION:-nightly-$(date +%Y%m%d | tr -d '\n')}"

# -- Target architectures
export ARCH=$1
# TARGET_ARCHS="linux_x86_64 linux_i686 linux_armv7l linux_aarch64 windows_x86 windows_amd64 darwin"
TARGET_ARCHS="linux_x86_64 linux_aarch64 windows_amd64 darwin linux_armv7l linux_aarch64"

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
mkdir -p $PACKAGE_DIR/$NAME/{bin,lib,share}
mkdir -p $PACKAGE_DIR/${NAME}_symbols/{bin,lib}
mkdir -p $PACKAGE_DIR/${NAME}-progtools/bin

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
    local dir_name=$1
    local git_url=$2
    local git_commit=$3
    local update_submodules=$4

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

function git_clone_direct {
    local dir_name=$1
    local git_url=$2
    local git_commit=$3
    local update_submodules=$4

    pushd $BUILD_DIR

    # -- Clone the sources from github
    test -e $dir_name || git clone $git_url $dir_name
    git -C $dir_name pull
    git -C $dir_name checkout $git_commit
    [[ ! -z "$update_submodules" ]] && git -C $dir_name submodule init
    [[ ! -z "$update_submodules" ]] && git -C $dir_name submodule update
    git -C $dir_name log -1

    popd
}

function clean_build {
    local dir_name=$1

    if [ $CLEAN_AFTER_BUILD == "1" ]; then
        cd $WORK_DIR
        rm -rf $UPSTREAM_DIR/$dir_name
        rm -rf $BUILD_DIR/$dir_name
    fi
}

function strip_binaries() {
    local binary_paths="$1"
    for path in $binary_paths
    do
        local src_file=$PACKAGE_DIR/$NAME/$path

        if [ ! -f "$src_file" ]; then
            echo "Skipping strip of $src_file - does not exist."
        fi

        if [ $ARCH = "darwin" ]
        then
            local dst_file=$PACKAGE_DIR/${NAME}_symbols/$path.dSYM
            dsymutil -o $dst_file $src_file
            strip $src_file
        else
            local dst_file=$PACKAGE_DIR/${NAME}_symbols/$path.debug
            ${TARGET_PREFIX}objcopy --only-keep-debug "${src_file}" "${dst_file}"
            ${TARGET_PREFIX}strip $src_file --strip-debug --strip-unneeded
        fi
    done
}

function create_package() {
    local base_dir=$1
    local compress_dir=$2
    local package_name=$3

    pushd $base_dir
    echo $VERSION > ./$compress_dir/VERSION

    if [ ${ARCH:0:7} = "windows" ]
    then
        zip -r $package_name.zip $compress_dir
        7z a $package_name.7z $compress_dir
    else
        tar -czf $package_name.tar.gz $compress_dir
        tar cf - $compress_dir | xz -z - > $package_name.tar.xz
    fi
    popd
}

function wget_retry {
    local max_retry=3
    local counter=0
    until wget "$@"
    do
        sleep 1
        [[ counter -eq $max_retry ]] && echo "Failed!" && exit 1
        echo "Trying again. Try #$counter"
        ((counter++))
    done
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
