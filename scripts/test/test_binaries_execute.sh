#!/usr/bin/env bash
# -- Test binaries execute with --help

set -e

# yosys-smtbmc is omitted because it is broken on windows for now
# https://github.com/open-tool-forge/fpga-toolchain/issues/37
for i in dfu-prefix dfu-suffix dfu-util ecpbram ecpmulti ecppack ecppll \
    ecpprog ecpunpack ghdl icebram icemulti icepack icepll iceprog icetime \
    nextpnr-ecp5 nextpnr-ice40 yosys yosys-abc yosys-config yosys-filterlib
do
  if $i --help 2&> /dev/null
  then
    echo exit code $? OK: $i
  else
    stored_exit_code=$?
    if [ "$stored_exit_code" = "1" ] || [ "$stored_exit_code" = "64" ]
    then
        echo exit code $stored_exit_code OK: $i
    else
        echo exit code $stored_exit_code FAIL: $i
        exit $stored_exit_code
    fi
  fi

done
