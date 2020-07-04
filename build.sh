#!/usr/bin/env bash
##################################
#   FPGA toolchain builder       #
##################################

set -e

# -- Toolchain name
export NAME=fpga-toolchain

# -- Debug flags
INSTALL_DEPS=1
COMPILE_DFU_UTIL=1
COMPILE_YOSYS=1
COMPILE_ICESTORM=1
COMPILE_NEXTPNR_ICE40=1
COMPILE_NEXTPNR_ECP5=1
COMPILE_ECPPROG=1
COMPILE_IVERILOG=0
COMPILE_GHDL=1
BUNDLE_PYTHON=1
CREATE_PACKAGE=1

. scripts/_common.sh $1

if [ $BUNDLE_PYTHON == "1" ]; then
  print ">> Bundle Python"
  . $WORK_DIR/scripts/bundle_python.sh
fi

if [ $COMPILE_NEXTPNR_ECP5 == "1" ]; then
  print ">> Compile nextpnr-ecp5"
  . $WORK_DIR/scripts/compile_nextpnr_ecp5.sh
fi

if [ $COMPILE_DFU_UTIL == "1" ]; then
  print ">> Compile dfu-utils"
  . $WORK_DIR/scripts/compile_dfu_util.sh
fi

if [ $COMPILE_GHDL == "1" ]; then
  print ">> Compile ghdl"
  . $WORK_DIR/scripts/compile_ghdl.sh
fi

if [ $COMPILE_YOSYS == "1" ]; then
  print ">> Compile yosys"
  . $WORK_DIR/scripts/compile_yosys.sh
fi

if [ $COMPILE_ICESTORM == "1" ]; then
  print ">> Compile icestorm"
  . $WORK_DIR/scripts/compile_icestorm.sh
fi

if [ $COMPILE_NEXTPNR_ICE40 == "1" ]; then
  print ">> Compile nextpnr-ice40"
  . $WORK_DIR/scripts/compile_nextpnr_ice40.sh
fi

if [ $COMPILE_ECPPROG == "1" ]; then
  print ">> Compile ecpprog"
  . $WORK_DIR/scripts/compile_ecpprog.sh
fi

if [ $COMPILE_IVERILOG == "1" ]; then
  print ">> Compile iverilog"
  . $WORK_DIR/scripts/compile_iverilog.sh
fi

if [ $CREATE_PACKAGE == "1" ]; then
  print ">> Create package"
  . $WORK_DIR/scripts/create_package.sh
fi
