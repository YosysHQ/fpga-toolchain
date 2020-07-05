#!/usr/bin/env bash
# -- Test ICE40 design with yosys and nextpnr-ice40

set -e

dir_name=icebreaker-examples
commit=master
git_url=https://github.com/icebreaker-fpga/icebreaker-examples.git

git_clone_direct $dir_name $git_url $commit
cd $BUILD_DIR/$dir_name/blink_count_shift

$MAKE