#!/usr/bin/env bash
# -- Test ECP5 design with yosys and nextpnr-ice40

set -e

dir_name=ulx3s-examples
commit=master
git_url=https://github.com/ulx3s/ulx3s-examples.git

git_clone_direct $dir_name $git_url $commit
cd $BUILD_DIR/$dir_name/blinky/OpenSource
$MAKE ulx3s.bit
