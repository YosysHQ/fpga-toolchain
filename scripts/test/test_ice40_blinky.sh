#!/usr/bin/env bash
# -- Test ICE40 design with yosys and nextpnr-ice40

set -e

git clone https://github.com/icebreaker-fpga/icebreaker-examples.git
cd icebreaker-examples/blink_count_shift
$MAKE