#!/usr/bin/env bash
##################################
#   FPGA toolchain builder       #
##################################

set -e

# -- Toolchain name
export NAME=fpga-toolchain

# -- Debug flags
INSTALL_DEPS="${INSTALL_DEPS:-1}"
CLEAN_AFTER_BUILD="${CLEAN_AFTER_BUILD:-1}"
COMPILE_DFU_UTIL="${COMPILE_DFU_UTIL:-1}"
COMPILE_YOSYS="${COMPILE_YOSYS:-1}"
COMPILE_SBY="${COMPILE_SBY:-1}"
COMPILE_ICESTORM="${COMPILE_ICESTORM:-1}"
COMPILE_NEXTPNR_ICE40="${COMPILE_NEXTPNR_ICE40:-1}"
COMPILE_NEXTPNR_ECP5="${COMPILE_NEXTPNR_ECP5:-1}"
COMPILE_ECPPROG="${COMPILE_ECPPROG:-1}"
COMPILE_OPENFPGALOADER="${COMPILE_OPENFPGALOADER:-1}"
COMPILE_IVERILOG="${COMPILE_IVERILOG:-0}"
COMPILE_GHDL="${COMPILE_GHDL:-1}"
COMPILE_Z3="${COMPILE_Z3:-1}"
COMPILE_BOOLECTOR="${COMPILE_BOOLECTOR:-1}"
COMPILE_AVY="${COMPILE_AVY:-0}" # deliberately disabled - does not yet work
BUNDLE_PYTHON="${BUNDLE_PYTHON:-1}"
COMPILE_YICES2="${COMPILE_YICES2:-1}"
BUNDLE_MAKE="${BUNDLE_MAKE:-1}"
CREATE_PACKAGE="${CREATE_PACKAGE:-1}"

. scripts/_common.sh $1

if [ $BUNDLE_PYTHON == "1" ]; then
  print ">> Bundle Python"
  . $WORK_DIR/scripts/bundle_python.sh
fi

if [ $BUNDLE_MAKE == "1" ]; then
  print ">> Bundle GNU Make"
  . $WORK_DIR/scripts/bundle_make.sh
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

if [ $COMPILE_SBY == "1" ]; then
  print ">> Compile SymbiYosys"
  . $WORK_DIR/scripts/compile_sby.sh
fi

if [ $COMPILE_YICES2 == "1" ]; then
  print ">> Compile Yices2"
  . $WORK_DIR/scripts/compile_yices2.sh
fi

if [ $COMPILE_Z3 == "1" ]; then
  print ">> Compile Z3"
  . $WORK_DIR/scripts/compile_z3.sh
fi

if [ $COMPILE_BOOLECTOR == "1" ]; then
  print ">> Compile Boolector"
  . $WORK_DIR/scripts/compile_boolector.sh
fi

if [ $COMPILE_AVY == "1" ]; then
  print ">> Compile Avy"
  . $WORK_DIR/scripts/compile_avy.sh
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

if [ $COMPILE_OPENFPGALOADER == "1" ]; then
  print ">> Compile openFPGALoader"
  . $WORK_DIR/scripts/compile_openfpgaloader.sh
fi

if [ $COMPILE_IVERILOG == "1" ]; then
  print ">> Compile iverilog"
  . $WORK_DIR/scripts/compile_iverilog.sh
fi

if [ $CREATE_PACKAGE == "1" ]; then
  print ">> Create package"
  mkdir -p $PACKAGE_DIR/publish $PACKAGE_DIR/publish_symbols
  create_package "$PACKAGE_DIR" "$NAME" "publish/$NAME-$ARCH-$VERSION"
  create_package "$PACKAGE_DIR" "${NAME}_symbols" "publish_symbols/symbols_${NAME}-$ARCH-$VERSION"

  if [ ${ARCH:0:7} = "windows" ]; then
    create_package "$PACKAGE_DIR" "${NAME}-progtools" "publish/${NAME}-progtools-$ARCH-$VERSION"
  fi
fi
