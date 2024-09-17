.data

arr1: .word 5, 2, 4, 7, 7, 12
arr2: .word 4, -3, 0, 10, 33
arr1Str: .asciiz "Array 1: "
arr2Str: .asciiz "Array 2: "
mergedArrStr: .asciiz "Merged array: "
newline: .asciiz "\n"
sep: .asciiz ", "

.text

main:
    la $a0, arr1Str
    li $v0, 4
    syscall

    la $a0, arr1
    li $a1, 0
    lw $a2, ($a0)
    addi $a0, 4
    jal printArr
    jal printNewline

    la $a0, arr2Str
    li $v0, 4
    syscall

    la $a0, arr2
    li $a1, 0
    lw $a2, ($a0)
    addi $a0, 4
    jal printArr
    jal printNewline

    li $v0, 10
    syscall

printArr:
    move $t0, $a0
    lw $a0, ($a0)
    li $v0, 1
    syscall

    addi $a1, 1
    bne $a1, $a2, printSep
    jr $ra

printSep:
    la $a0, sep
    li $v0, 4
    syscall
    move $a0, $t0
    addi $a0, 4
    j printArr

printNewline:
    la $a0, newline
    li $v0, 4
    syscall
    jr $ra
