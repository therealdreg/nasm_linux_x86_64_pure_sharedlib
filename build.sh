#!/bin/bash

echo "by Dreg"
set -x
sudo apt-get install build-essential nasm
rm -rf loader.o sharedlib.o sharedlib.so withlibc/sharedlib.so withlibc/loader
nasm -felf64 -o sharedlib.o sharedlib.asm
ld -lc --dynamic-linker /lib64/ld-linux-x86-64.so.2 -shared -soname sharedlib.so -o withlibc/sharedlib.so sharedlib.o -R .
gcc -nostdlib -ffreestanding -fno-builtin -no-pie -shared sharedlib.o -o sharedlib.so
gcc loader.c  -ldl -o loader
cp loader withlibc/
