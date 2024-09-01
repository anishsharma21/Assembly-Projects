.data
.align 2

array: .word 3, 2, 3, 4         # first word gives length
newline: .asciiz "\n"

.text
.globl main

main:
    li $t1, 1                   # current index
    la $t2, array               # address of array
    lw $t3, 0($t2)              # length of array
    addi $t2, 4                 # set first value because multiplication
    lw $t0, 0($t2)              # loading initial value for final output
    j loop

loop:
    addi $t2, 4
    addi $t1, 1
    lw $t4, 0($t2)
    add $t5, $t0, $zero         # copy of current value to add
    addi $t4, -1
    j multiply

multiply:
    beq $t4, $zero, check
    add $t0, $t0, $t5
    addi $t4, -1
    j multiply

check:
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
