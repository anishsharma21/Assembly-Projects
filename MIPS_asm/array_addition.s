.data
.align 2

array: .word 1, 2, 3, 4, 5

.text
.globl main

main:
    li $t0, 0                   # running sum
    la $t1, array               # array address
    move $t2, $t1               # set base of final index
    addi $t2, 16                # final index with length offset
    j loop

loop:
    lw $t3, 0($t1)
    add $t0, $t0, $t3
    beq $t1, $t2, printsum      # print sum if end of array
    addu $t1, 4
    j loop

printsum:
    move $a0, $t0
    li $v0, 1
    syscall
    j end
    
end:
    li $v0, 10
    syscall
