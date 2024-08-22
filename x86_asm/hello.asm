# this isn't actually x86 - previous commits had x86 assembly, but I modified the Dockerfile in several experiments, just been too lazy to revert everything back...
.section .data
    hello: .ascii "Hello, world!\n"

.section .text
    .global _start

_start:
    mov x0, 1
    ldr x1, =hello
    mov x2, 14
    mov x8, 64
    svc 0

    mov x0, 0
    mov x8, 93
    svc 0