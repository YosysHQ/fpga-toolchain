#!/usr/bin/env bash
##################################
#   FPGA toolchain builder       #
##################################

set -e

# -- Toolchain name
export NAME=ecp5-bba

# -- Debug flags
INSTALL_DEPS=1

. scripts/_common.sh linux_x86_64

print ">> Compile nextpnr-ecp5-bba"
. $WORK_DIR/scripts/compile_nextpnr_ecp5_bba.sh

print ">> Create package"
. $WORK_DIR/scripts/create_package.sh
