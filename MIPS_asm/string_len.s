.data

buffer: .space 20
str1: .asciiz "Enter string: "
str2: .asciiz "You wrote: "
str3: .asciiz "Length of string: "
str4: .asciiz "byte #"
sep: .asciiz ": "
newline: .asciiz "\n"

.text

main:
    la $a0, str1
    li $v0, 4
    syscall

    li $v0, 8                   # read string input
    la $a0, buffer
    li $a1, 20
    syscall

    la $a0, str2
    li $v0, 4
    syscall

    la $a0, buffer
    li $v0, 4
    syscall

    la $a0, newline
    li $v0, 4
    syscall

    la $a0, buffer
    move $a1, $a0
    li $a2, 0
    j find_length

find_length:
    lb $a0, ($a1)
    beqz $a0, end
    move $t0, $a0

    la $a0, str4
    syscall
    move $a0, $a2
    li $v0, 1
    syscall
    la $a0, sep
    li $v0, 4
    syscall
    move $a0, $t0
    li $v0, 1                   # print byte
    syscall
    la $a0, newline
    li $v0, 4
    syscall

    addi $a2, $a2, 1
    addi $a1, $a1, 1
    j find_length

end:
    la $a0, newline
    li $v0, 4
    syscall

    la $a0, str3
    li $v0, 4
    syscall

    move $a0, $a2
    li $v0, 1
    syscall

    la $a0, newline
    li $v0, 4
    syscall

    li $v0, 10
    syscall
