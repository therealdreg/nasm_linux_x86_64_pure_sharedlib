#!/bin/bash

echo "by Dreg"
set -x

echo "testing with libc dep"
cd withlibc
pwd
objdump -x ./sharedlib.so
ldd ./sharedlib.so
file ./sharedlib.so
./loader
./sharedlib.so
/lib64/ld-linux-x86-64.so.2 ./sharedlib.so
ldd ./sharedlib.so
