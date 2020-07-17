#!/usr/bin/env bash
# -- Test binaries execute with --help

set -e

dir_name=sby_test
commit=master
git_url=https://github.com/YosysHQ/SymbiYosys.git

git_clone_direct $dir_name $git_url $commit

cd $BUILD_DIR/$dir_name/docs/examples/quickstart
# smtbmc
sby cover.sby
# smtbmc
sby demo.sby
# smtbmc boolector
sby memory.sby
# smtbmc
sby prove.sby

cd ../puzzles
# yices
sby djb2hash.sby

cd ../demos
# z3
sby fib.sby
