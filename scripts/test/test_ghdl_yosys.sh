#!/usr/bin/env bash
# -- Test VHDL synthesis with ghdl-yosys-plugin

set -e

dir_name=ghdl-yosys-plugin
commit=master
git_url=https://github.com/ghdl/ghdl-yosys-plugin.git

git_clone_direct $dir_name $git_url $commit

cd $BUILD_DIR/$dir_name/examples/icestick/leds/

yosys -p 'ghdl leds.vhdl spin1.vhdl -e leds; synth_ice40 -json leds.json'
nextpnr-ice40 --package hx1k --pcf leds.pcf --asc leds.asc --json leds.json
icepack leds.asc leds.bin
