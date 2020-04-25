# FPGA-Toolchain

## Introduction
*WIP - USE AT YOUR OWN RISK*

Multi-platform nightly builds of open source FPGA tools.

## Usage

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
* linux_i686
* linux_armv7l
* linux_aarch64
* windows_x86
* windows_amd64
* darwin

Final packages will be deployed in the **\_packages/build_ARCH/** directories.

NOTE: *libftdi1.a* and *libusb-1.0.a* files have been generated for each architecture using the [Tools-system scripts](https://github.com/FPGAwars/tools-system).

# Credits
This is built on the work done by FPGAWars:
* [Jesús Arroyo Torrens](https://github.com/Jesus89)
* [Juan González (Obijuan)](https://github.com/Obijuan)
* [Carlos Venegas](https://github.com/cavearr)
* [Miodrag Milanovic](https://github.com/mmicko)

And also built on subsequent work by [fomu-toolchain](https://github.com/im-tomu/fomu-toolchain) team.

## License

Licensed under a GPL v3 and [Creative Commons Attribution-ShareAlike 4.0 International License](http://creativecommons.org/licenses/by-sa/4.0/).
