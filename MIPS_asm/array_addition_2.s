# No need for hardcoded length of array - format of array includes length as first word

.data
.align 2

array: .word 5, 1, 9, 3, 4, 5           # first word is length of array
newline: .asciiz "\n"

.text
.globl main

main:
    li $t0, 0                           # running sum
    la $t1, array                       # base address of array
    lw $t2, 0($t1)                      # load length into t1
    li $t3, 0                           # index value
    j loop

loop:
    addu $t1, 4                         # next memory address in array, unsigned to avoid overflow
    lw $t4, 0($t1)                      # load next word in array
    add $t0, $t0, $t4                   # add value to running sum
    addi $t3, 1                         # increment index
    beq $t2, $t3, printsum              # print if reached last length
    j loop

printsum:
    move $a0, $t0
    li $v0, 1                           # syscall for printing int
    syscall
    la $a0, newline
    li $v0, 4                           # syscall for printing asciiz
    syscall
    j end

end:
    li $v0, 10                          # syscall for exiting
    syscall
