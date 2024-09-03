.data
.align 2

start: .asciiz "Once upon a time..."
middle: .asciiz "there was an assembly program..."
end: .asciiz "and an exit syscall\n"

.text
.globl main

main:
    la $a0, start
    li $v0, 4
    syscall
    la $a0, middle
    syscall
    la $a0, end
    syscall
    li $v0, 10
    syscall
