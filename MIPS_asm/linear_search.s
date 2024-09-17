.data

array: .word 10, 2, -5, 8, 33, 2, 19, 11, 9, 3, 0
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

    li $v0, 10
    syscall

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
