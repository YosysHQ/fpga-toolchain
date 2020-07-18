#!/usr/bin/env bash
# -- Test binaries execute with --help

set -e

tools_to_check=(dfu-prefix dfu-suffix dfu-util ecpbram ecpmulti ecppack ecppll \
    ecpprog ecpunpack ghdl icebram icemulti icepack icepll iceprog icetime \
    nextpnr-ecp5 nextpnr-ice40 yosys yosys-abc yosys-config yosys-filterlib \
    yosys-smtbmc)
    # sby yices yices-sat yices-smt yices-smt2 z3 boolector
    # btorsim btoruntrace btormc btorimc

if [ ${ARCH:0:7} = "windows" ]
then
    tools_to_check+=(make)
else
    tools_to_check+=(btormbt)
fi

for i in "${tools_to_check[@]}";
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
