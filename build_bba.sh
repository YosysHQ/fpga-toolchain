#!/usr/bin/env bash
##################################
#   FPGA toolchain builder       #
##################################

set -e

# -- Toolchain name
export NAME=ecp5-bba

# -- Debug flags
INSTALL_DEPS=1

export VERSION=nightly
. scripts/_common.sh linux_x86_64

print ">> Compile nextpnr-ecp5-bba"
. $WORK_DIR/scripts/compile_nextpnr_ecp5_bba.sh

print ">> Create package"
create_package "$PACKAGE_DIR" "$NAME" "$NAME-noarch-$VERSION"
