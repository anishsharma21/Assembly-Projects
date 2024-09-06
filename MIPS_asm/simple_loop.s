.data
.align 2

newline: .asciiz "\n"

.text
.globl main

main:
    li $t0, 10
    jal printloop
    li $v0, 10
    syscall

printloop:
    move $a0, $t0
    li $v0, 1
    syscall
    addi $t0, -1
    la $a0, newline
    li $v0, 4
    syscall
    bne $t0, 0, printloop
    jr $ra
