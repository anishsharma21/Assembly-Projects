.data

array1: .word 10, 3, -5, 12, 9, 11, 4, -15, 1, 89, 7
array2: .word 5, 4, 2, 3, 1, 5
arrayChoice: .asciiz "Pick array (1 or 2): "
arrayStr: .asciiz "Array: "
prompt: .asciiz "Find index of: "
index: .asciiz "Index of '"
is: .asciiz "' is: "
invalidChoice: .asciiz "Invalid choice\n"
newline: .asciiz "\n"
sep: .asciiz ", "

.text

main:
    la $a0, arrayChoice
    li $v0, 4
    syscall

    li $v0, 5
    syscall
    move $t0, $v0

    la $a0, arrayStr
    li $v0, 4
    syscall

    beq $t0, 1, arr1
    beq $t0, 2, arr2

    la $a0, invalidChoice
    li $v0, 4
    syscall

    j main

arr1:
    la $a0, array1
    li $a1, 0
    lw $a2, ($a0)
    addi $a0, 4
    jal printArr
    j prompt

arr2:
    la $a0, array2
    li $a1, 0
    lw $a2, ($a0)
    addi $a0, 4
    jal printArr
    j promptIndex

promptIndex:
    la $a0, prompt
    syscall

    li $v0, 10
    syscall

printArr:
    move $t0, $a0
    lw $a0, ($a0)
    syscall
    addi $a1, 1
    addi $a0, 4
    bne $a1, $a2, printSep
    la $a0, newline
    syscall
    jr $ra

printSep:
    la $a0, sep
    syscall
    move $a0, $t0
    addi $a0, 4
    j printArr
