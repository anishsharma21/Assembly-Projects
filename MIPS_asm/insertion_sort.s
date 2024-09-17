.data

array: .word 5, 2, 5, 1, 3, 4
init: .asciiz "Initial array: "
sorted: .asciiz "Sorted array: "
sep: .asciiz ", "
newline: .asciiz "\n"

.text

main:
    la $a0, init
    li $v0, 4
    syscall

    la $a0, array
    li $a1, 0
    lw $a2, ($a0)
    addi $a0, 4
    jal printArr
    jal printNewline

    # insertion_sort call

    la $a0, sorted
    li $v0, 4
    syscall

    la $a0, array
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

    move $a0, $t0
    addi $a0, 4
    addi $a1, 1
    bne $a1, $a2, printSep
    jr $ra

printSep:
    move $t0, $a0
    la $a0, sep
    li $v0, 4
    syscall
    move $a0, $t0
    j printArr

printNewline:
    la $a0, newline
    li $v0, 4
    syscall
    jr $ra
