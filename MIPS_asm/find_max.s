.data
.align 2

newline: .asciiz "\n"
array: .word 5, 2, 4, 99, -8, 23

.text
.globl main

main:
    la $a2, array               # load address of array
    lw $a1, ($a2)               # length of array
    addi $a2, 4                 # next value
    lw $a0, ($a2)               # set first value to max
    addi $a1, -1
    jal find_max
    li $v0, 1
    syscall
    la $a0, newline
    li $v0, 4
    syscall
    j end

find_max:
    addi $a2, 4
    lw $t0, ($a2)
    bgt $t0, $a0, set_max
    j end_or_loop

set_max:
    move $a0, $t0
    j end_or_loop

end_or_loop:
    addi $a1, -1
    bgt $a1, $zero, find_max
    jr $ra

end:
    li $v0, 10
    syscall
