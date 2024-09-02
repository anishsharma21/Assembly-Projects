.data
.align 2

array: .word 5, 1, 2, 3, 4, 12
newline: .asciiz "\n"

.text
.globl main

main:
    la $a0, array               # array base address
    lw $a1, 0($a0)              # length of array
    addi $a0, 4
    li $v0, 0
    jal array_sum
    move $a0, $s0
    li $v0, 1
    syscall
    la $a0, newline
    li $v0, 4
    syscall
    li $v0, 10
    syscall

array_sum:
    lw $t0, 0($a0)
    add $s0, $s0, $t0
    addi $a1, -1
    addi $a0, 4
    bne $a1, $zero, array_sum
    jr $ra
