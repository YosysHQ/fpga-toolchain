#!/usr/bin/env bash
# -- Test VHDL synthesis

set -e

dir_name=ghdl-yosys-plugin
commit=master
git_url=https://github.com/ghdl/ghdl-yosys-plugin.git

git_clone_direct $dir_name $git_url $commit
cd $BUILD_DIR/$dir_name/examples
$SED -i 's/\$\(YOSYS\) -m \$\(GHDLSYNTH\)/\$\(YOSYS\)/;' ghdlsynth.mk
cd ecp5_versa

$MAKE YOSYS=yosys GHDL=ghdl NEXTPNR=nextpnr-ecp5 ECPPACK=ecppack
