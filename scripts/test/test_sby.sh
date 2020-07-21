#!/usr/bin/env bash
# -- Test binaries execute with --help

set -e

dir_name=sby_test
commit=master
git_url=https://github.com/YosysHQ/SymbiYosys.git

# git_clone_direct $dir_name $git_url $commit
# mkdir -p ~/Work
# rm -rf  ~/Work/picorv32
# git clone https://github.com/cliffordwolf/picorv32.git ~/Work/picorv32
# cd $BUILD_DIR/$dir_name/sbysrc
# sby demo1.sby
cd $BUILD_DIR/$dir_name/docs/examples/quickstart
# smtbmc
echo ==============COVER
sby -f cover.sby
# smtbmc
echo ==============DEMO
sby -f demo.sby
# smtbmc boolector
echo ==============MEMORY
sby -f memory.sby
# smtbmc
echo ==============PROVE
sby -f prove.sby

cd ../puzzles
# yices
echo ==============HASh
sby -f djb2hash.sby
# z3
echo ==============PRIME
sby -f primegen.sby

cd ../demos
# z3
sby fib.sby