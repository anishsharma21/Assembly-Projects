.data
.align 2

newline: .asciiz "\n"

.text
.globl main

main:
    # TODO

factorial:
    addi $sp, $sp, -8           # make space for 2 items
    sw $ra, 4($sp)              # store return address
    sw $a0, 0($sp)              # store argument
