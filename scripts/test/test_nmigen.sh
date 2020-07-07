#!/usr/bin/env bash

set -e

# Try one ICE40 and one ECP5 target to check yosys + nextpnr-ice40 + nextpnr-ecp5

# $PYTHON -m nmigen_boards.icestick
# (but with do_program=False)
$PYTHON -c "from nmigen_boards.test.blinky import Blinky; \
            from nmigen_boards.icestick import ICEStickPlatform; \
            ICEStickPlatform().build(Blinky(), do_program=False)"

$PYTHON -c "from nmigen_boards.test.blinky import Blinky; \
            from nmigen_boards.versa_ecp5 import VersaECP5Platform; \
            VersaECP5Platform().build(Blinky(), do_program=False)"
