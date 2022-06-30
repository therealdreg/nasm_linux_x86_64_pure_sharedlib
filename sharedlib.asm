; By Dreg

global _start
global  ReflectiveLoader:function

section .text

_start:
  mov rax, 1        ; write
  mov rdi, 1        ; STDOUT_FILENO,
  call nxt
msg: db "Hello Dreg from the sharedlib ASM from _start", 10
msglen: equ $ - msg
  times 10 db 90h ; to fix disas
nxt:
  pop rsi
  mov rdx, msglen
  syscall
  jmp ext

ReflectiveLoader:
  mov rax, 1        ; write
  mov rdi, 1        ; STDOUT_FILENO,
  call sgt
msg2: db "Hello Dreg from the sharedlib ASM from ReflectiveLoader", 10
msglen2: equ $ - msg2
  times 10 db 90h ; to fix disas
sgt:
  pop rsi
  mov rdx, msglen2
  syscall
  jmp ext

ext:
  mov rax, 60       ; exit
  mov rdi, 0        ; EXIT_SUCCESS
  syscall
