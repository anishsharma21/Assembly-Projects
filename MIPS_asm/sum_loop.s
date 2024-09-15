.data

prompt: .asciiz "Type in an int: "
sum: .asciiz "Final sum: "
newline: .asciiz "\n"

.text

main:
    la $a0, prompt
    li $v0, 4
    syscall

    li $v0, 5
    syscall

    beq $v0, $zero, print_sum

    add $s0, $s0, $v0
    j main

print_sum:
    la $a0, sum
    li $v0, 4
    syscall

    move $a0, $s0
    li $v0, 1
    syscall

    la $a0, newline
    li $v0, 4
    syscall

    li $v0, 10
    syscall
