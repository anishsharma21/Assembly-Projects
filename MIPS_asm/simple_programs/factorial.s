.data
.align 2

newline: .asciiz "\n"

.text
.globl main

main:
    li $a0, 5
    jal factorial
    jal printsum
    j end

factorial:
    addi $sp, $sp, -8           # make space for 2 items
    sw $ra, 4($sp)              # store return address
    sw $a0, 0($sp)              # store argument
    slti $t0, $a0, 1
    beq $t0, $zero, L1
    addi $v0, $zero, 1
    addi $sp, $sp, 8
    jr $ra

L1:
    addi $a0, $a0, -1
    jal factorial
    lw $a0, 0($sp)
    lw $ra, 4($sp)
    addi $sp, $sp, 8
    mul $v0, $a0, $v0
    jr $ra

printsum:
    move $a0, $v0
    li $v0, 1
    syscall
    la $a0, newline
    li $v0, 4
    syscall
    jr $ra

end:
    li $v0, 10
    syscall
