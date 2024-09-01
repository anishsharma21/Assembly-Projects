.data
.align 2

array: .word 3, 2, 3, 4         # first word gives length
newline: .asciiz "\n"

.text
.globl main

main:
    li $t0, 1                   # running sum
    li $t1, 0                   # current index
    la $t2, array               # address of array
    lw $t3, 0($t2)              # length of array
    j loop

loop:
    addi $t2, 4
    addi $t1, 1
    lw $t4, 0($t2)
    j multiply

multiply:
    add $t0, $t0, $t0
    addi $t4, -1
    bgtz $t4, multiply
    beq $t1, $t3, printsum
    j loop  

printsum:
    li $v0, 1
    move $a0, $t0
    syscall
    li $v0, 4
    la $a0, newline
    syscall
    li $v0, 10
    syscall
