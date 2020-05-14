#!/bin/bash

# Test script

FILE=$1

echo "" >&2
echo "Testing $FILE file" >&2
echo "------------------------------" >&2

function test_base {
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
    output=$(ldd $1 2>&1 | grep "not a dynamic executable")
    test_base "- 3. File is static" test -n "$output"
}

file $FILE

echo "------------------------------" >&2

test_exists $FILE
test_exec $FILE
if [[ $ARCH != "darwin" ]]; then
	test_static $FILE
fi

echo "------------------------------" >&2
echo "All tests [PASSED]" >&2
echo "" >&2
