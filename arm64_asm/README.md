# How to Assemble and Link ARM64 RISC Assembly Programs on M3 MacBook Pro

## Prerequisites

- Ensure you have `clang` installed. Check by typing:
```sh
clang -v
```

## Writing an ARM64 Assembly Program

Write your program in ARM64 assembly. Here's an example:

```nasm
.global _main

_main:
  mov x0, #1
  mov x16, #1
  svc #0
```



