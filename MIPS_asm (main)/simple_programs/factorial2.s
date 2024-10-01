# recursive factorial program using stack pointer #

# checks if argument passed in is less than 1, if not, keeps decrementing and returning
# to same spot until its able to continue. Then, it loads in previous return address
# and sets v0 to 1. Return address would be L1, so it multiplies and sets that to v0. 
# Continues to do this through the entire stack its created at each point where it 
# decremented and added new values to the stack, those being, the return address and the
# current state of the argument at that point. So it multiplies in ascending order,
# i.e. 1 x 2 x 3 x ... x (n - 1) x n

.data
.align 2

newline: .asciiz "\n"

.text
.globl main

main:
    li $a0, 5
    jal fact
    jal print_total
    j end

fact:
    addi $sp, $sp, -8
    sw $a0, 0($sp)
    sw $ra, 4($sp)
    slti $t0, $a0, 1
    beq $t0, $zero, L1
    lw $a0, 0($sp)
    lw $ra, 4($sp)
    li $v0, 1
    addi $sp, $sp, 8
    jr $ra

L1:
    addi $a0, $a0, -1
    jal fact
    lw $a0, 0($sp)
    lw $ra, 4($sp)
    addi $sp, $sp, 8
    mul $v0, $v0, $a0
    jr $ra

print_total:
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
