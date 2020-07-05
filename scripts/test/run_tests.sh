#!/usr/bin/env bash
# -- Test ICE40 design with yosys and nextpnr-ice40

set -e

# -- Toolchain name
export NAME=fpga-toolchain-tests

# -- Debug flags
INSTALL_DEPS=0
TEST_ICE40_BLINKY="${TEST_ICE40_BLINKY:-1}"
TEST_ECP5_BLINKY="${TEST_ECP5_BLINKY:-1}"

. scripts/_common.sh $1

if [ $TEST_ICE40_BLINKY == "1" ]; then
  print ">> Test ICE40 Blinky"
  . $WORK_DIR/scripts/test/test_ice40_blinky.sh
fi

if [ $TEST_ECP5_BLINKY == "1" ]; then
  print ">> Test ECP5 Blinky"
  . $WORK_DIR/scripts/test/test_ecp5_blinky.sh
fi
