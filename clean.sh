#!/bin/bash
##################################
#   FPGA toolchain cleaner       #
##################################

set -e

. scripts/_common.sh $1

printf "Are you sure? [y/N]: "
read RESP
case "$RESP" in
    [yY][eE][sS]|[yY])
      # -- Remove the package dir
      rm -r -f $PACKAGE_DIR

      # -- Remove the build dir
      rm -r -f $BUILD_DIR

      rm -r -f $UPSTREAM_DIR

      echo ""
      echo ">> CLEAN"
      ;;
    *)
      echo ""
      echo ">> ABORT"
      ;;
esac
