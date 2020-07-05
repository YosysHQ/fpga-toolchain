# FPGA-Toolchain

[![Build Status](https://dev.azure.com/open-tool-forge/fpga-toolchain/_apis/build/status/open-tool-forge.fpga-toolchain?branchName=master)](https://dev.azure.com/open-tool-forge/fpga-toolchain/_build?definitionId=1&branchFilter=2)
[![Discord](https://img.shields.io/discord/613131135903596547?logo=discord)](https://discord.gg/s9sMfyx)

## Introduction
Multi-platform nightly builds of open source FPGA tools.

Currently included:

 * [Yosys](https://github.com/YosysHQ/yosys): RTL synthesis with extensive Verilog 2005 support
 * [GHDL Yosys Plugin](https://github.com/ghdl/ghdl-yosys-plugin): experimental VHDL synthesis, built in to Yosys for your convenience!
 * [GHDL](https://github.com/ghdl/ghdl): CLI tool supporting the Yosys plugin
 * [Project Trellis](https://github.com/SymbiFlow/prjtrellis): Tools for working with Lattice ECP5 bitstreams
 * [Project IceStorm](https://github.com/cliffordwolf/icestorm): Tools for working with Lattice ICE40 bitstreams
 * [nextpnr](https://github.com/YosysHQ/nextpnr): Timing-driven place and route for both ICE40 and ECP5 architectures
 * [dfu-util](http://dfu-util.sourceforge.net/): Device Firmware Upgrade Utilities
 * [ecpprog](https://github.com/gregdavill/ecpprog): A basic driver for FTDI based JTAG probes, to program ECP5 FPGAs

<!-- * [Icarus Verilog](https://github.com/steveicarus/iverilog): Verilog simulation tool -->

These tools are under active development (as are these build scripts), so
please be prepared for things to break from time to time. In most cases you should be able
to roll back to an older version while you wait for a fix.

Builds run at 0400 UTC daily from the master branch of each project.

## Installation

1. Download an archive matching your OS from [the releases page](https://github.com/open-tool-forge/fpga-toolchain/releases).
2. Extract the archive to a location of your choice
3. Add the `bin` folder to your `PATH`.
4. (optional, not needed on Windows) If you would like to use the experimental GHDL Yosys plugin for VHDL, you will
need to set the `GHDL_PREFIX` environment variable. e.g. `export GHDL_PREFIX=<install_dir>/fpga-toolchain/lib/ghdl`

If you see errors about missing libraries (`.so`/`.dll`/`.dylib`) please report them in an issue here.

## Related Projects

For portable WASM builds of these tools, check out [YoWASP](http://yowasp.org/). Also check out [nMigen](https://github.com/nmigen/nmigen) for a powerful python-based approach to hardware description.

## Getting Help

If you run into issues with these tools, please consider reporting an issue to the authors of the tools - we are just compiling them here! If you think your issue relates to *the way we have compiled them* then it is more appropriate to open a GitHub issue here.

If you aren't sure where to report your issue, you can also try sending a message in the `#open-tool-forge` channel on [1BitSquared's Discord server](https://discord.gg/s9sMfyx)

## Credits

This is built on the work done by [Sean Cross (xobs)](https://github.com/xobs) for [fomu-toolchain](https://github.com/im-tomu/fomu-toolchain),
which was built on the original work by [FPGAWars](https://github.com/FPGAwars):

 * [Jesús Arroyo Torrens](https://github.com/Jesus89)
 * [Juan González (Obijuan)](https://github.com/Obijuan)
 * [Carlos Venegas](https://github.com/cavearr)
 * [Miodrag Milanovic](https://github.com/mmicko)

## Development

Build:

```
bash build.sh linux_x86_64
```

Clean:

```
bash clean.sh linux_x86_64
```

Target architectures:
* linux_x86_64
* windows_amd64
* darwin

Final packages will be deployed in the **\_packages/build_ARCH/** directories.

NOTE: *libftdi1.a* and *libusb-1.0.a* files have been generated for Linux using the [Tools-system scripts](https://github.com/FPGAwars/tools-system) to allow static linking without a dependency on libudev (which is part of systemd and doesn't make for very portable binaries).



## License

Licensed under a GPL v3 and [Creative Commons Attribution-ShareAlike 4.0 International License](http://creativecommons.org/licenses/by-sa/4.0/).
