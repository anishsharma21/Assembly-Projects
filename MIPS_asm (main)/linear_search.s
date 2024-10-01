.data

array: .word 10, 2, -5, 8, 33, 2, 19, 11, 9, 3, 7
arrayStr: .asciiz "Array: "
prompt: .asciiz "Find index of: "
index: .asciiz "Index of '"
is: .asciiz "' is: "
notFound: .asciiz "Not found"
newline: .asciiz "\n"
sep: .asciiz ", "

.text

main:
    la $a0, arrayStr
    li $v0, 4
    syscall

    la $a0, array
    li $a1, 0
    lw $a2, ($a0)
    addi $a0, 4
    jal printArr

    la $a0, prompt
    syscall

    # read int
    li $v0, 5
    syscall

    beq $v0, 0, exit

    la $a0, array
    move $a1, $v0                       # user input int
    li $a2, 0                           # cur idx
    lw $a3, ($a0)                       # len of array
    addi $a0, 4
    jal linearSearch

    j main

linearSearch:
    lw $t0, ($a0)
    beq $t0, $a1, found
    addi $a2, 1
    addi $a0, 4
    bne $a2, $a3, linearSearch

    la $a0, notFound
    li $v0, 4
    syscall
    la $a0, newline
    syscall
    jr $ra

found:
    la $a0, index
    li $v0, 4
    syscall

    move $a0, $t0
    li $v0, 1
    syscall

    la $a0, is
    li $v0, 4
    syscall

    move $a0, $a2
    li $v0, 1
    syscall

    la $a0, newline
    li $v0, 4
    syscall
    jr $ra

printArr:
    move $t0, $a0
    lw $a0, ($a0)
    li $v0, 1
    syscall

    addi $a1, 1
    bne $a1, $a2, printSep

    la $a0, newline
    li $v0, 4
    syscall
    jr $ra

printSep:
    la $a0, sep
    li $v0, 4
    syscall

    move $a0, $t0
    addi $a0, 4
    j printArr

exit:
    li $v0, 10
    syscall
