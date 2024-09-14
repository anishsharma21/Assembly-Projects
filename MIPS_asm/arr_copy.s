.data

.align 2
array: .word 5, 3, 2, 1, 4, 7
buffer: .space 5
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
    jal copyArr

    la $a0, copiedArr
    li $v0, 4
    syscall

    jal printCopyBuffer
    jal printNewLine

    li $v0, 10
    syscall

printArr:
    move $t0, $a0
    lw $t1, ($t0)
    move $a0, $t1
    li $v0, 1
    syscall
    move $a0, $t0
    addi a0, 4
    addi $a1, 1
    blt $a1, $a2, printSep
    jr $ra

printSep:
    la $a0, sep
    li $v0, 4
    syscall
    j printArr

printNewline:
    la $a0, newline
    li $v0, 4
    syscall
    jr $ra
