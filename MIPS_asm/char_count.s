.data

buffer: .space 20
prompt: .asciiz "Enter a string: "
char: .asciiz "Enter a char: "
appears: .asciiz " appears "
times: .asciiz " times in "
newline: .asciiz "\n"

.text

main:
    la $a0, prompt
    li $v0, 4
    syscall

    li $v0, 8
    la $a0, buffer
    li $a1, 20
    syscall

    la $a0, char
    li $v0, 4
    syscall

    li $v0, 12
    syscall
    move $a1, $v0

    la $a0, buffer
    li $v0, 0
    j num_char

num_char:
    lb $t0, ($a0)
    beqz $t0, end
    beq $t0, $a1, incr
    addi $a0, 1
    j num_char

incr:
    addi $v0, 1
    addi $a0, 1
    j num_char

end:
    move $t0, $v0

    move $a0, $a1
    li $v0, 11
    syscall

    la $a0, appears
    li $v0, 4
    syscall

    move $a0, $t0
    li $v0, 1
    syscall

    la $a0, times
    li $v0, 4
    syscall

    la $a0, buffer
    syscall

    li $v0, 10
    syscall
