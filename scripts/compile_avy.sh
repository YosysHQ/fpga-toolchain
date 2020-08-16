#!/usr/bin/env bash

set -e

if [ $ARCH = "darwin" ]
then
    # TODO: might not be too hard to hack a static link: libz.1.dylib and libboost_program_options-mt.dylib
    print "Skipping building Avy"
    # cmake -DCMAKE_BUILD_TYPE=Release ../
    # $MAKE -j$J
elif [ ${ARCH:0:7} = "windows" ]
then
    # steps I took so far to try and get this working on windows:
    # 1. replace abc submodule with yosys version (which is maintained by yosys team and supports mingw)
    # 2. copy in the abc/cmake dir from the avy version
    # 3. replace contents of abc/lib/pthread.h with "#include <pthread.h>" to use mingw system winpthreads headers
    # 4. patch abc/arch_flags.c for NT64/NT instead of LIN64/LIN
    # 5. remove these lines in abc/Makefile:
    # ifneq ($(OS), FreeBSD)
    # LIBS += -ldl
    # endif
    # ifneq ($(findstring Darwin, $(shell uname)), Darwin)
    # LIBS += -lrt
    # endif
    # 6. minisat - commented out various lines using setrlimit and SIGXCPU
    # 7. glucose - basically the same patches that minisat needed
    # 8. (stopped at this point) The newer version of ABC I used has made some minor breaking changes to the API
    # e.g.: extavy\avy\src\Pdr.cc:886:60: error: too few arguments to function 'int abc::Pdr_ManCheckCube(abc::Pdr_Man_t*, int, abc::Pdr_Set_t*, abc::Pdr_Set_t**, int, int, int)'

    # cmake -G "MinGW Makefiles" -DABC_CXXFLAGS="-DABC_USE_STDINT_H" -DCMAKE_BUILD_TYPE=Release -DAVY_STATIC_EXE=ON -DABC_SOURCE_DIR=../abc ../
    # $MAKE -j$J
    print "Skipping building Avy"

else
    dir_name=avy
    commit=master
    git_url=https://bitbucket.org/arieg/extavy.git

    git_clone $dir_name $git_url $commit 1 # enable submodule update

    cd $BUILD_DIR/$dir_name
    mkdir -p build
    cd build

    cmake -DCMAKE_BUILD_TYPE=Release -DAVY_STATIC_EXE=ON ../
    $MAKE -j$J

    test_bin avy/src/avy$EXE
    cp avy/src/avy$EXE $PACKAGE_DIR/$NAME/bin
    strip_binaries bin/avy$EXE

    clean_build $dir_name
fi
