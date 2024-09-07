.data
.align 2

newline: .asciiz "\n"

.align 2
array: .space 24                            # 6 word spaces, 1 for length, 5 for values

prompt: .asciiz "Type in 5 numbers:\n"
max_string: .asciiz "Max value: "

.text
.globl main

main:
    # beginning with user input
    la $a2, array
    li $t0, 5
    sw $t0, ($a2)                           # storing the length first
    la $a0, prompt                          # print prompt
    li $v0, 4
    syscall
    jal user_input_loop

    la $a2, array                           # load address of array
    lw $a1, ($a2)                           # length of array
    addi $a2, 4                             # next value
    lw $a0, ($a2)                           # set first value to max
    addi $a1, -1
    jal find_max
    move $t0, $a0
    la $a0, max_string
    li $v0, 4
    syscall
    move $a0, $t0
    li $v0, 1
    syscall
    la $a0, newline
    li $v0, 4
    syscall
    j end

user_input_loop:
    # ask user input 5 times, fill up array, then return
    li $v0, 5
    syscall
    addi $a2, 4
    sw $v0, ($a2)
    addi $t0, -1
    bgt $t0, $zero, user_input_loop
    jr $ra

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
