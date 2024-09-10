.data
.align 2

string:
    .ascii "hello world"
    .byte 0

newline: .asciiz "\n"

.text
.globl main

main:
    la $a1, string
    li $a2, 0

find_length:
    lb $a0, ($a1)
    beqz $a0, end
    addi $a2, $a2, 1
    addi $a1, $a1, 1
    j find_length

end:
    move $a0, $a2
    li $v0, 1
    syscall

    la $a0, newline
    li $v0, 4
    syscall

    li $v0, 10
    syscall
