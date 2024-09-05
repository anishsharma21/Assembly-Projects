.data
.align 2

newline: .asciiz "\n"
dividend: .word 20
divisor: .word 4

.text
.globl main

main:
    la $a0, dividend
    la $a1, divisor
    li $v0, 0                   # quotient
    li $v1, 0                   # remainder
    jal divide
    jal printout
    j end

divide:
    addi $v0, 1
    sub $a0, $a0, $a1
    slti $t0, $a0, 0
    beq $t0, 0, divide
    sub $v0, $v0, 1
    add $a0, $a0, $a1
    move $v1, $a0
    jr $ra

printout:
    move $a0, $v0
    li $v0, 1
    syscall
    la $a0, newline
    li $v0, 4
    syscall
    move $a0, $a1
    li $v0, 1
    syscall
    la $a0, newline
    li $v0, 4
    syscall
    jr $ra

end:
    li $v0, 10
    syscall
