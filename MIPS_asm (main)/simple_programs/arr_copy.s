.data

array: .word 5, 3, 2, 1, 4, 7
buffer: .space 24
initArr: .asciiz "Initial array: "
copiedArr: .asciiz "Copied array: "
newline: .asciiz "\n"
sep: .asciiz ", "

.text

main:
    la $a0, initArr
    li $v0, 4
    syscall

    la $a0, array                   # arr base addr
    li $a1, 0                       # cur idx
    lw $a2, ($a0)                   # arr length
    addi $a0, 4
    jal printArr
    jal printNewline

    la $a0, array
    la $a1, buffer
    li $a2, -1                      # to add first val which is len of arr
    lw $a3, ($a0)
    jal copyArr

    la $a0, copiedArr
    li $v0, 4
    syscall

    la $a0, buffer
    li $a1, 0
    lw $a2, ($a0)
    addi $a0, 4
    jal printArr
    jal printNewline

    li $v0, 10
    syscall

copyArr:
    lw $t0, ($a0)
    sw $t0, ($a1)
    addi $a0, 4
    addi $a1, 4
    addi $a2, 1
    bne $a2, $a3, copyArr
    jr $ra

printArr:
    move $t0, $a0
    lw $t1, ($t0)
    move $a0, $t1
    li $v0, 1
    syscall
    move $a0, $t0
    addi $a0, 4
    addi $a1, 1
    blt $a1, $a2, printSep
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
