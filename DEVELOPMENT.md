# General Guidelines

The goal of this project is to make it as easy as possible to get up and running with open source FPGA tools. A secondary goal is to provide the same set of tools and features on all platforms, wherever possible.

To achieve these goals, some compromises have been made:
 * Static linking is used in almost all cases - removing dependencies on external shared libraries means this package should be all you need to run the tools. The major downside of this approach is that some tools are not designed to be built statically, which can make it harder or near-impossible to include them.
 * The goal is not to rely on any absolute install prefixes - tools must be able to find any files they need at runtime by using relative paths wherever possible. This also enables multiple versions of the tools to be installed without conflicting.
 * The package is provided as a simple compressed archive - no package managers are used. This makes installation simple, but the downside is that **before accepting a contribution adding a new tool, we need to consider how much larger it makes the overall package**.

# Development

## Build Prerequisites
At present, all of the builds are run on their native platform (no cross-compiling).

**Windows**

 1. Install MSYS2 - install options:
    * Use [chocolately](https://chocolatey.org/) and run `choco install msys2`
    * Install using instructions on [the MSYS2 website](https://www.msys2.org/)
 2. Run the MinGW64 bash environment `mingw64.exe` (not the MSYS2 or MinGW32 environments).

**macOS**

1. Install [Xcode 11.4.1](https://developer.apple.com/services-account/download?path=/Developer_Tools/Xcode_11.4.1/Xcode_11.4.1.xip) to `/Applications/Xcode_11.4.1.app` (other versions might work but this is untested and unsupported)

*Note that this requires macOS 10.15.2+ as a build-time dependency. The resulting builds should work on versions as old as macOS 10.10*

2. Install [Homebrew](https://brew.sh/)

**Linux**
 1. Create an Ubuntu 20.04 environment:
    * The `ubuntu:20.04` docker container is a good option and this is the approach the CI build uses
    * A virtual machine or even WSL on Windows will work too
    * Running on bare metal is of course fine too, but other versions of Ubuntu are untested and unsupported.

*Note that Ubuntu 20.04 is only a build-time dependency. The resulting builds are intended to run on any Linux distro*

 2. Make sure the `sudo` package is installed (it is not installed by default in the docker image)

## Running a Build

**WARNING**: The scripts will attempt to automatically install build dependencies by default! If you don't want this you can disable it first with `export INSTALL_DEPS=0`.

The details of the required dependencies will not be documented here, so it is recommended to just let the scripts handle it - you can see what will be installed in `scripts/install_dependencies.sh`

Build:

```
bash build.sh <arch>
```
*Note: the build will automatically check the number of cores on your system and run parallel jobs.*

Clean:

```
bash clean.sh <arch>
```

*Note: various parts of the scripts currently assume a clean working directory so it is best to run a clean before starting a new build.*

Current architectures:
* linux_x86_64
* windows_amd64
* darwin

Final packages will be deployed in the `./_packages/build_<arch>/` directory.

By default the scripts will not build nextpnr-ecp5. See [this section](#building-nextpnr-ecp5) for details on how to build this too.

## Disabling parts of the build

The build scripts define many variables that may be used to disable parts of the build during development - see `build.sh` for details.

If you place a `.env` file in the root of the repo then the bash scripts will source it. You can use this as a convenient way to locally override these variables without accidentally committing changes (the file is already in `.gitignore`).

## Building nextpnr-ecp5

These scripts currently require an Ubuntu 20.04 environment ([as specified here](#prerequisites)) to generate the ECP5 device databases. The device databases are represented as a text-based set of instructions for the nextpnr Binary Blob Assembler (a "BBA file"). It is important that the same nextpnr and libtrellis git commits are used for the whole build to avoid the BBA files getting out of sync with the compiled code.

In the Ubuntu 20.04 environment, run:

`./build_bba.sh`

This will result in a package generated at:

`./_packages/build_linux_x86_64/ecp5-bba-noarch-nightly.tar.gz`

If you are building in the same working folder, you can then simply run:

`COMPILE_NEXTPNR_ECP5=1 ./build.sh <arch>`

If you are building the bba files in a separate working folder, you will need to `mkdir -p ./_packages/build_linux_x86_64/` and then copy the bba package into `./_packages/build_linux_x86_64/ecp5-bba-noarch-nightly.tar.gz` before running `build.sh` (this is how the CI build works)

Some other info that may be useful if trying to build nextpnr on a new platform:

 * The text BBA files are architecture independent.
 * The binary output from bbasm works for any architecture provided that the correct endianness was set. This is worth paying attention to if e.g. cross-building for a big-endian platform on an x86 host
 * The BBA files cannot be generated without a version of libtrellis built with python bindings enabled (they are used by a python script).
 * Nextpnr-ecp5 links against libtrellis but does not need the python bindings.
 * Nextpnr is linked against a static libpython.a to enable an embedded python interpreter that may be used to set up clock constraints, manually place elements, etc. This embedded interpreter needs the modules in `lib/python3.<x>` to function. It is far from perfect - many modules that have been copied over are likely to fail to load since they have dependencies on shared libraries from the build host that we have not bundled.
 * Normally nextpnr's CMakeLists.txt will handle the bba generation transparently during the build. The reason for pre-generating BBA files on a linux host was historically because the Windows builds were built with MSVC. Using MSVC enabled linking the official Windows CPython builds as the embedded python interpreter, but building libtrellis with python bindings enabled was difficult under MSVC. Since then, the embedded python interpreter has been changed to a MinGW built version of python. The BBA generation has remained the same because:

   1. It was easier not to change things. Getting libtrellis to build with python bindings on all platforms should be possible in theory but might require a little more work.
   2. This foundation should hopefully make it slightly easier to set up a cross-compile for other platforms (e.g. ARM)
   3. We can slightly reduce the size of the resulting executable by disabling the python bindings in libtrellis.
   4. The BBA files take a while to generate and it seems silly to generate the same thing multiple times.

## Misc Information:

*libftdi1.a* and *libusb-1.0.a* files have been generated for Linux using the [Tools-system scripts](https://github.com/FPGAwars/tools-system) to allow static linking without a dependency on libudev (which is part of systemd and doesn't make for very portable binaries).