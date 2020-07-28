#!/usr/bin/env bash

# Test script

FILE=$1

echo "" >&2
echo "Testing $FILE file" >&2
echo "------------------------------" >&2

function test_base {
    # Arg $1: Description of test
    # Arg $2: expression to eval
    if "${@:2}"
    then
        echo "$1" >&2
    else
        echo "$1 [FAILED]" >&2
        exit 1
    fi
}

function test_exists {
    test_base "- 1. File exists" test -e $1
}

function test_exec {
    test_base "- 2. File is executable" test -x $1
}

function test_static {
    msg="- 3. File is static"
    # edbordin: darwin and windows always have a few system libs linked dynamically
    # so we resort to checking for anything not on this hardcoded "whitelist"
    # (I won't be surprised if this breaks outside of the CI environment)
    if [ $ARCH == "darwin" ]; then
        pat='^\s*(/usr/lib/libSystem.B.dylib|'
        pat+='/usr/lib/libc\+\+.1|'
        pat+='/System/Library/Frameworks/IOKit.framework/Versions/A/IOKit|'
        pat+='/System/Library/Frameworks/CoreFoundation.framework/'
        pat+='Versions/A/CoreFoundation).*$'

        output=$(otool -L -X $1 2>&1 | grep -E -v "$pat" || true)
        # show the output for debugging if test fails
        [[ -n "$output" ]] && otool -L -X $1
        test_base "$msg" test -z "$output"
    elif [ ${ARCH:0:7} = "windows" ]
    then
        pat='^\s*(ntdll|KERNEL32|KERNELBASE|msvcrt|'
        pat+='ADVAPI32|sechost|RPCRT4|dbghelp|ucrtbase|'
        pat+='USER32|win32u|GDI32|gdi32full|WS2_32)\.(dll|DLL).*$'

        output=$(ldd $1 2>&1 | grep -E -v "$pat" || true)
        [[ -n "$output" ]] && ldd $1
        test_base "$msg" test -z "$output"
    else
        output=$(ldd $1 2>&1 | grep "not a dynamic executable" || true)
        [[ -z "$output" ]] && ldd $1
        test_base "$msg" test -n "$output"
    fi
}

file $FILE

echo "------------------------------" >&2

test_exists $FILE
test_exec $FILE
test_static $FILE

echo "------------------------------" >&2
echo "All tests [PASSED]" >&2
echo "" >&2
