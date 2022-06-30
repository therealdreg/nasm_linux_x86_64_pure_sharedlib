# NASM Linux x86_64 pure (no deps) shared library (.so)

Tested with "Reflective SO injection". A library injection technique in which the concept of reflective programming is employed to perform the loading of a library from memory into a host process

https://github.com/infosecguerrilla/ReflectiveSOInjection

## Reflective ELF SO Injection (Linux x86_64)

Download & compile injector

```
git clone https://github.com/infosecguerrilla/ReflectiveSOInjection
cd ReflectiveSOInjection/inject/src
gcc inject.c ptrace.c utils.c -ldl -o inject
```

launch a victim process, ex nc:
```
nc -l 6969
```

Inject sharedlib.so in nc (nc PID is 26558):
```
./inject -p 26558 /home/dreg/nasm_linux_x86_64_pure_sharedlib/sharedlib.so

[i] targeting process with pid 26558
[+] shared object mapped at 0x7fc8c7723000
[+] found dynamic segment at 0x7fc8c7725f50
[+] dynsym found at address 0x7fc8c7723218
[+] dynstr found at address 0x7fc8c7723260
[+] Resolved ReflectiveLoader offset to 0x1051
[i] Setting target registers to appropriate values
[i] Overwriting target memory region with shellcode
[+] Transfering execution to stage 0 shellcode
[+] Returned from Stage 0 shell code RIP of target is 0x5613de86c06e
[i] Stage 0 mmap returned memory address of 0x7fa898c22000.. verifying allocation succeeded..
[+] Okay.. mmap allocation was successful!
[+] Writing our shared object into the victim process address space MUAHAHAHA!!!
[+] Setting RIP to ReflectiveLoader function
[+] Calling ReflectiveLoader function! Let's hope this works ;D
ptrace(PTRACE_GETSIGINFO) failed
```

Just ignore the last failed msg

Done! you can see the injected SO code in nc terminal:
```
nc -l 6969
Hello Dreg from the sharedlib ASM from ReflectiveLoader
```

## How to compile sharedlib
```
cd nasm_linux_x86_64_pure_sharedlib
chmod +x *
chmod +x withlibc/*
./build.sh 

+ sudo apt-get install build-essential nasm
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
build-essential is already the newest version (12.9).
nasm is already the newest version (2.15.05-1).
0 upgraded, 0 newly installed, 0 to remove and 410 not upgraded.
+ rm -rf loader.o sharedlib.o sharedlib.so withlibc/sharedlib.so withlibc/loader
+ nasm -felf64 -o sharedlib.o sharedlib.asm
+ ld -lc --dynamic-linker /lib64/ld-linux-x86-64.so.2 -shared -soname sharedlib.so -o withlibc/sharedlib.so sharedlib.o -R .
+ gcc -nostdlib -ffreestanding -fno-builtin -no-pie -shared sharedlib.o -o sharedlib.so
+ gcc loader.c -ldl -o loader
+ cp loader withlibc/
```

## Test pure .so
```
cd nasm_linux_x86_64_pure_sharedlib
chmod +x *
chmod +x withlibc/*
./testlib.sh

testing no deps
+ objdump -x ./sharedlib.so

./sharedlib.so:     file format elf64-x86-64
./sharedlib.so
architecture: i386:x86-64, flags 0x00000150:
HAS_SYMS, DYNAMIC, D_PAGED
start address 0x0000000000001000

Program Header:
    LOAD off    0x0000000000000000 vaddr 0x0000000000000000 paddr 0x0000000000000000 align 2**12
         filesz 0x0000000000000279 memsz 0x0000000000000279 flags r--
    LOAD off    0x0000000000001000 vaddr 0x0000000000001000 paddr 0x0000000000001000 align 2**12
         filesz 0x00000000000000b8 memsz 0x00000000000000b8 flags r-x
    LOAD off    0x0000000000002000 vaddr 0x0000000000002000 paddr 0x0000000000002000 align 2**12
         filesz 0x0000000000000000 memsz 0x0000000000000000 flags r--
    LOAD off    0x0000000000002f50 vaddr 0x0000000000002f50 paddr 0x0000000000002f50 align 2**12
         filesz 0x00000000000000b0 memsz 0x00000000000000b0 flags rw-
 DYNAMIC off    0x0000000000002f50 vaddr 0x0000000000002f50 paddr 0x0000000000002f50 align 2**3
         filesz 0x00000000000000b0 memsz 0x00000000000000b0 flags rw-
    NOTE off    0x00000000000001c8 vaddr 0x00000000000001c8 paddr 0x00000000000001c8 align 2**2
         filesz 0x0000000000000024 memsz 0x0000000000000024 flags r--
   RELRO off    0x0000000000002f50 vaddr 0x0000000000002f50 paddr 0x0000000000002f50 align 2**0
         filesz 0x00000000000000b0 memsz 0x00000000000000b0 flags r--

Dynamic Section:
  GNU_HASH             0x00000000000001f0
  STRTAB               0x0000000000000260
  SYMTAB               0x0000000000000218
  STRSZ                0x0000000000000019
  SYMENT               0x0000000000000018

Sections:
Idx Name          Size      VMA               LMA               File off  Algn
  0 .note.gnu.build-id 00000024  00000000000001c8  00000000000001c8  000001c8  2**2
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
  1 .gnu.hash     00000028  00000000000001f0  00000000000001f0  000001f0  2**3
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
  2 .dynsym       00000048  0000000000000218  0000000000000218  00000218  2**3
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
  3 .dynstr       00000019  0000000000000260  0000000000000260  00000260  2**0
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
  4 .text         000000b8  0000000000001000  0000000000001000  00001000  2**4
                  CONTENTS, ALLOC, LOAD, READONLY, CODE
  5 .eh_frame     00000000  0000000000002000  0000000000002000  00002000  2**3
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
  6 .dynamic      000000b0  0000000000002f50  0000000000002f50  00002f50  2**3
                  CONTENTS, ALLOC, LOAD, DATA
SYMBOL TABLE:
0000000000000000 l    df *ABS*  0000000000000000 sharedlib.asm
000000000000100f l       .text  0000000000000000 msg
000000000000002e l       *ABS*  0000000000000000 msglen
0000000000001047 l       .text  0000000000000000 nxt
0000000000001060 l       .text  0000000000000000 msg2
0000000000000038 l       *ABS*  0000000000000000 msglen2
00000000000010a2 l       .text  0000000000000000 sgt
00000000000010ac l       .text  0000000000000000 ext
0000000000000000 l    df *ABS*  0000000000000000 
0000000000002f50 l     O .dynamic       0000000000000000 _DYNAMIC
0000000000001000 g       .text  0000000000000000 _start
0000000000001051 g     F .text  0000000000000000 ReflectiveLoader


+ ldd ./sharedlib.so
        statically linked
+ file ./sharedlib.so
./sharedlib.so: ELF 64-bit LSB shared object, x86-64, version 1 (SYSV), dynamically linked, not stripped
+ ./loader
Hello from loader by Dreg
calling to ReflectiveLoader....
Hello Dreg from the sharedlib ASM from ReflectiveLoader
+ ./sharedlib.so
Hello Dreg from the sharedlib ASM from _start
+ /lib64/ld-linux-x86-64.so.2 ./sharedlib.so
Hello Dreg from the sharedlib ASM from _start
+ ldd ./sharedlib.so
        statically linked
```


## Test .so version with libc dep

```
cd nasm_linux_x86_64_pure_sharedlib
chmod +x *
chmod +x withlibc/*
./testwithlibc.sh 

testing with libc dep
+ cd withlibc
+ pwd
/home/dreg/nasm_linux_x86_64_pure_sharedlib/withlibc
+ objdump -x ./sharedlib.so

./sharedlib.so:     file format elf64-x86-64
./sharedlib.so
architecture: i386:x86-64, flags 0x00000150:
HAS_SYMS, DYNAMIC, D_PAGED
start address 0x0000000000001000

Program Header:
    LOAD off    0x0000000000000000 vaddr 0x0000000000000000 paddr 0x0000000000000000 align 2**12
         filesz 0x000000000000024a memsz 0x000000000000024a flags r--
    LOAD off    0x0000000000001000 vaddr 0x0000000000001000 paddr 0x0000000000001000 align 2**12
         filesz 0x00000000000000b8 memsz 0x00000000000000b8 flags r-x
    LOAD off    0x0000000000002000 vaddr 0x0000000000002000 paddr 0x0000000000002000 align 2**12
         filesz 0x0000000000000000 memsz 0x0000000000000000 flags r--
    LOAD off    0x0000000000002f10 vaddr 0x0000000000002f10 paddr 0x0000000000002f10 align 2**12
         filesz 0x00000000000000f0 memsz 0x00000000000000f0 flags rw-
 DYNAMIC off    0x0000000000002f10 vaddr 0x0000000000002f10 paddr 0x0000000000002f10 align 2**3
         filesz 0x00000000000000f0 memsz 0x00000000000000f0 flags rw-
   RELRO off    0x0000000000002f10 vaddr 0x0000000000002f10 paddr 0x0000000000002f10 align 2**0
         filesz 0x00000000000000f0 memsz 0x00000000000000f0 flags r--

Dynamic Section:
  NEEDED               libc.so.6
  SONAME               sharedlib.so
  RUNPATH              .
  HASH                 0x0000000000000190
  GNU_HASH             0x00000000000001a8
  STRTAB               0x0000000000000218
  SYMTAB               0x00000000000001d0
  STRSZ                0x0000000000000032
  SYMENT               0x0000000000000018

Sections:
Idx Name          Size      VMA               LMA               File off  Algn
  0 .hash         00000018  0000000000000190  0000000000000190  00000190  2**3
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
  1 .gnu.hash     00000028  00000000000001a8  00000000000001a8  000001a8  2**3
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
  2 .dynsym       00000048  00000000000001d0  00000000000001d0  000001d0  2**3
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
  3 .dynstr       00000032  0000000000000218  0000000000000218  00000218  2**0
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
  4 .text         000000b8  0000000000001000  0000000000001000  00001000  2**4
                  CONTENTS, ALLOC, LOAD, READONLY, CODE
  5 .eh_frame     00000000  0000000000002000  0000000000002000  00002000  2**3
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
  6 .dynamic      000000f0  0000000000002f10  0000000000002f10  00002f10  2**3
                  CONTENTS, ALLOC, LOAD, DATA
SYMBOL TABLE:
0000000000000000 l    df *ABS*  0000000000000000 sharedlib.asm
000000000000100f l       .text  0000000000000000 msg
000000000000002e l       *ABS*  0000000000000000 msglen
0000000000001047 l       .text  0000000000000000 nxt
0000000000001060 l       .text  0000000000000000 msg2
0000000000000038 l       *ABS*  0000000000000000 msglen2
00000000000010a2 l       .text  0000000000000000 sgt
00000000000010ac l       .text  0000000000000000 ext
0000000000000000 l    df *ABS*  0000000000000000 
0000000000002f10 l     O .dynamic       0000000000000000 _DYNAMIC
0000000000001051 g     F .text  0000000000000000 ReflectiveLoader
0000000000001000 g       .text  0000000000000000 _start


+ ldd ./sharedlib.so
        linux-vdso.so.1 (0x00007ffdd53e7000)
        libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007fb183bed000)
        /lib64/ld-linux-x86-64.so.2 (0x00007fb183de3000)
+ file ./sharedlib.so
./sharedlib.so: ELF 64-bit LSB shared object, x86-64, version 1 (SYSV), dynamically linked, not stripped
+ ./loader
Hello from loader by Dreg
calling to ReflectiveLoader....
Hello Dreg from the sharedlib ASM from ReflectiveLoader
+ ./sharedlib.so
Hello Dreg from the sharedlib ASM from _start
+ /lib64/ld-linux-x86-64.so.2 ./sharedlib.so
Hello Dreg from the sharedlib ASM from _start
+ ldd ./sharedlib.so
        linux-vdso.so.1 (0x00007fff801ce000)
        libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007f11dc070000)
        /lib64/ld-linux-x86-64.so.2 (0x00007f11dc266000)
```
