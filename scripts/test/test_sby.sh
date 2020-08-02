#!/usr/bin/env bash
# -- Test binaries execute with --help

set +e

dir_name=sby_test
commit=master
git_url=https://github.com/YosysHQ/SymbiYosys.git

git_clone_direct $dir_name $git_url $commit
# mkdir -p ~/Work
# rm -rf  ~/Work/picorv32
# git clone https://github.com/cliffordwolf/picorv32.git ~/Work/picorv32
# cd $BUILD_DIR/$dir_name/sbysrc
# sby demo1.sby
cd $BUILD_DIR/$dir_name/docs/examples/quickstart
# smtbmc
echo ==============COVER
sby -f cover.sby || :
echo exitcode: $?
# smtbmc
echo ==============DEMO
sby -f demo.sby || :
echo exitcode: $?
# smtbmc boolector
echo ==============MEMORY
sby -f memory.sby
echo exitcode: $?
# smtbmc
echo ==============PROVE
sby -f prove.sby
echo exitcode: $?

cd ../puzzles
# yices
echo ==============HASH
sby -f djb2hash.sby
echo exitcode: $?
# z3
echo ==============PRIME
sby -f primegen.sby
echo exitcode: $?

cd ../demos
# z3
# sby fib.sby

set -e