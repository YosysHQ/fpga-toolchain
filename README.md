# FPGA-Toolchain
[![Build Status](https://dev.azure.com/open-tool-forge/fpga-toolchain/_apis/build/status/YosysHQ.fpga-toolchain?branchName=main)](https://dev.azure.com/open-tool-forge/fpga-toolchain/_build/latest?definitionId=4&branchName=main)
[![Discord](https://img.shields.io/discord/613131135903596547?logo=discord)](https://discord.gg/s9sMfyx)

## Introduction
Multi-platform nightly builds of open source FPGA tools.

Currently included:

 * [Yosys](https://github.com/YosysHQ/yosys): RTL synthesis with extensive Verilog 2005 support
 * [GHDL Yosys Plugin](https://github.com/ghdl/ghdl-yosys-plugin): experimental VHDL synthesis, built in to Yosys for your convenience!
 * [GHDL](https://github.com/ghdl/ghdl): CLI tool supporting the Yosys plugin
 * [SymbiYosys](https://github.com/YosysHQ/SymbiYosys): Yosys-based formal hardware verification
 * [Boolector](http://fmv.jku.at/boolector/): Engine for SymbiYosys
 * [Yices2](http://yices.csl.sri.com/): Engine for SymbiYosys
 * [Z3](https://github.com/Z3Prover/z3/wiki): Engine for SymbiYosys
 * [Project Trellis](https://github.com/SymbiFlow/prjtrellis): Tools for working with Lattice ECP5 bitstreams
 * [Project IceStorm](https://github.com/cliffordwolf/icestorm): Tools for working with Lattice ICE40 bitstreams
 * [nextpnr](https://github.com/YosysHQ/nextpnr): Timing-driven place and route for both ICE40 and ECP5 architectures
 * [dfu-util](http://dfu-util.sourceforge.net/): Device Firmware Upgrade Utilities
 * [ecpprog](https://github.com/gregdavill/ecpprog): A basic driver for FTDI based JTAG probes, to program ECP5 FPGAs
 * [openFPGALoader](https://github.com/trabucayre/openFPGALoader): Universal utility for programming FPGA

<!-- * [Icarus Verilog](https://github.com/steveicarus/iverilog): Verilog simulation tool -->
<!--* [Avy](https://arieg.bitbucket.io/avy/): Engine for SymbiYosys (only included on Linux for now) -->

These tools are under active development (as are these build scripts), so
please be prepared for things to break from time to time. In most cases you should be able
to roll back to an older version while you wait for a fix.

Builds run at 0400 UTC daily from the master branch of each project.

## Installation

1. Download an archive matching your OS from [the releases page](https://github.com/YosysHQ/fpga-toolchain/releases).
2. Extract the archive to a location of your choice
3. Add the `bin` folder to your `PATH`:

```
MacOS and Linux: export PATH="<extracted_location>/fpga-toolchain/bin:$PATH"
Windows Powershell: $ENV:PATH = "<extracted_location>\fpga-toolchain\bin;" + $ENV:PATH
Windows cmd.exe: PATH=<extracted_location>\fpga-toolchain\bin;%PATH%
```

Windows users that prefer to use WSL can download `fpga-toolchain-linux*` to build under WSL and then use the native tools from `fpga-toolchain-progtools-windows*` to program their boards (since USB devices are not currently accessible in the WSL environment).

These builds should work for macOS 10.10 or newer - please report a bug if you have issues!

If you see errors about missing libraries (`.so`/`.dll`/`.dylib`) please report them in an issue here.

## Using GHDL

If you would like to use the experimental GHDL Yosys plugin for VHDL on Linux or MacOS, you will
need to set the `GHDL_PREFIX` environment variable. e.g. `export GHDL_PREFIX=<install_dir>/fpga-toolchain/lib/ghdl`. On Windows this is not necessary.

If you are using an existing Makefile set up for ghdl-yosys-plugin and see `ERROR: This version of yosys is built without plugin support` you probably need to remove `-m ghdl` from your yosys parameters. This is because the plugin is typically loaded from a separate file but it is provided built into yosys in this package.

## Getting Help

If you run into issues with these tools, please consider reporting an issue to the authors of the tools - we are just compiling them here! If you think your issue relates to *the way we have compiled them* then it is more appropriate to open a GitHub issue here.

If you aren't sure where to report your issue or don't feel it fits on GitHub, you can also try sending a message in the `#yosyshq` channel on [1BitSquared's Discord server](https://discord.gg/s9sMfyx).

## Related Projects

For portable WASM builds of these tools, check out [YoWASP](http://yowasp.org/). Also check out [nMigen](https://github.com/nmigen/nmigen) for a powerful python-based approach to hardware description.

## Credits

This is built on the work done by [Sean Cross (xobs)](https://github.com/xobs) for [fomu-toolchain](https://github.com/im-tomu/fomu-toolchain),
which was built on the original work by [FPGAWars](https://github.com/FPGAwars):

 * [Jesús Arroyo Torrens](https://github.com/Jesus89)
 * [Juan González (Obijuan)](https://github.com/Obijuan)
 * [Carlos Venegas](https://github.com/cavearr)
 * [Miodrag Milanovic](https://github.com/mmicko)

## Contributing

Contributions are welcome, see [DEVELOPMENT.md](DEVELOPMENT.md) for guidelines and technical details.

## License

Licensed under a GPL v3 and [Creative Commons Attribution-ShareAlike 4.0 International License](http://creativecommons.org/licenses/by-sa/4.0/).
