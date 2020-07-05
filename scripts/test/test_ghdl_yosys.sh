#!/usr/bin/env bash
# -- Test VHDL synthesis with ghdl-yosys-plugin

set -e

dir_name=ghdl-yosys-plugin
commit=master
git_url=https://github.com/ghdl/ghdl-yosys-plugin.git

git_clone_direct $dir_name $git_url $commit

cd $BUILD_DIR/$dir_name/examples/icestick/leds/

# Analyse VHDL sources
ghdl -a leds.vhdl
ghdl -a spin1.vhdl
# (it's also possible to get yosys to perform this step for us, but it's better to test the ghdl
# binary works here)

# Synthesize the design.
yosys -p 'ghdl leds; synth_ice40 -json leds.json'

# P&R
nextpnr-ice40 --package hx1k --pcf leds.pcf --asc leds.asc --json leds.json

# Generate bitstream
icepack leds.asc leds.bin
