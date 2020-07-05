#!/usr/bin/env bash

set -e

# Try one ICE40 and one ECP5 target to check yosys + nextpnr-ice40 + nextpnr-ecp5
$PYTHON -m nmigen_boards.icestick
$PYTHON -m nmigen_boards.versa_ecp5
