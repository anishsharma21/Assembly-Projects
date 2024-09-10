.data

array: .word 5, 2, 5, 3, 1, 4
array_str: .asciiz "Array: "
newline: .asciiz "\n"
sep: .asciiz ", "

# This is a simple and arbitrary program that swaps the first and last values in an array
# I am simply following a set of beginner exercises in MIPS and this happens to be the
# next one. I also added a procedure for printing the array so we have a before and after

.text

main:
    la $a0, array_str
    li $v0, 4
    syscall
    la $a0, array
    lw $a1, ($a0)               # length of array
    addi $a0, 4
    li $a2, 0                   # cur idx
    jal print_arr

print_arr:
    lw $a0, ($a0)
    li $v0, 1
    syscall

    addi $a0, 4
    addi $a2, 1

    beq $a2, $a1, jump_main

    move $t0, $a0
    la $a0, sep
    li $v0, 4
    syscall
    move $a0, $t0

    j print_arr

jump_main:
    la $a0, newline
    li $v0, 4
    syscall

    jr $ra
