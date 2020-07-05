#!/usr/bin/env bash
# -- Test embedded python works in nextpnr

set -e

cd $BUILD_DIR
mkdir -p test_nextpnr_python
cd test_nextpnr_python

echo 'print("hello from python!")' > hello.py
nextpnr-ecp5 --run hello.py
nextpnr-ice40 --run hello.py
