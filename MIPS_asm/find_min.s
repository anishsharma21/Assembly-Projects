.data

.align 2
array: .word 5, 3, -4, -2, 0, 8

.align 2
newline: .asciiz "\n"

.text
.globl main

main:
    la $a0, array
    lw $a1, ($a0)
    addi $a0, 4
    lw $v0, ($a0)           # first value

find_min:
    addi $a0, 4
    lw $t0, ($a0)
    addi $a1, -1
    blt $t0, $v0, set_min
    blt $a1, 1, print_min
    j find_min

set_min:
    move $v0, $t0
    blt $a1, 1, print_min
    j find_min

print_min:
    move $a0, $v0
    li $v0, 1
    syscall
    la $a0, newline
    li $v0, 4
    syscall
    j end

end:
    li $v0, 10
    syscall
