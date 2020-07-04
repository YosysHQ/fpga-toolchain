#!/usr/bin/env bash
# -- Test ICE40 design with yosys and nextpnr-ice40

set -e

git clone https://github.com/emard/ulx3s-examples.git
cd ulx3s-examples/blinky/OpenSource
$MAKE ulx3s.bit