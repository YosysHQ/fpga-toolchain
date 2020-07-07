#!/usr/bin/env bash
# -- Test ICE40 design with yosys and nextpnr-ice40

set -e

# -- Toolchain name
export NAME=fpga-toolchain-tests

# -- Debug flags
INSTALL_DEPS=0 # stops _common.sh installing dev deps
TEST_BINARIES_EXECUTE="${TEST_BINARIES_EXECUTE:-1}"
TEST_ICE40_BLINKY="${TEST_ICE40_BLINKY:-1}"
TEST_ECP5_BLINKY="${TEST_ECP5_BLINKY:-1}"
TEST_NMIGEN="${TEST_NMIGEN:-1}"
TEST_GHDL_YOSYS="${TEST_GHDL_YOSYS:-1}"
TEST_NEXTPNR_PYTHON="${TEST_NEXTPNR_PYTHON:-1}"

. scripts/_common.sh $1
. $WORK_DIR/scripts/test/install_toolchain.sh

if [ $TEST_BINARIES_EXECUTE == "1" ]; then
  print ">> Test binaries execute"
  . $WORK_DIR/scripts/test/test_binaries_execute.sh
fi

if [ $TEST_ICE40_BLINKY == "1" ]; then
  print ">> Test ICE40 Blinky"
  . $WORK_DIR/scripts/test/test_ice40_blinky.sh
fi

if [ $TEST_ECP5_BLINKY == "1" ]; then
  print ">> Test ECP5 Blinky"
  . $WORK_DIR/scripts/test/test_ecp5_blinky.sh
fi

if [ $TEST_ECP5_BLINKY == "1" ]; then
  print ">> Test nMigen"
  . $WORK_DIR/scripts/test/test_nmigen.sh
fi

if [ $TEST_GHDL_YOSYS == "1" ]; then
    print ">> Test ghdl-yosys-plugin"
  . $WORK_DIR/scripts/test/test_ghdl_yosys.sh
fi

if [ $TEST_NEXTPNR_PYTHON == "1" ]; then
    print ">> Test nextpnr embedded python"
  . $WORK_DIR/scripts/test/test_nextpnr_python.sh
fi
