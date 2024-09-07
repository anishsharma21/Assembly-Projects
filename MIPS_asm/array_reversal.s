.data

.align 2
array: .word 5, -3, 4, 18, 9, -4

.align 2
newline: .asciiz "\n"

.text
.globl main

main:
    la $a0, array                           # base address of array
    lw $a1, ($a0)                           # length of array
    addi $a0, 4                             # first value in array
    li $t0, 1                               # current index + 1
    jal reverse

reverse:
    sub $t2, $a1, $t0                       # index of swap value in t2
    sll $t2, $t2, 2                         # multiplies by 4 for word length
    add $t2, $a0, $t2                       # now t2 holds address of swap value
