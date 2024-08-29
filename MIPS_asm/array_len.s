.data
.align 2

array: .word 1, 2, 3, 4, 5, 0
newline: .asciiz "\n"

.text
.globl main

main:
    li $t1, 0                   # array length
    la $t2, array               # array address
    j loop

loop:
    lw $t3, 0($t2)
    beq $t3, $zero, end
    addi $t1, 1
    addi $t2, 4
    j loop

end:
    move $a0, $t1
    li $v0, 1
    syscall
    la $a0, newline
    li $v0, 4
    syscall
    li $v0, 10
    syscall
