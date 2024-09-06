.data
.align 2

even: .asciiz " is even\n"
odd: .asciiz " is odd\n"
value: .word 23

.text
.globl main

main:
    la $t0, value
    lw $t0, 0($t0)
    move $a0, $t0
    li $v0, 1
    syscall
    li $t1, 2
    div $t0, $t1
    mfhi $a0                # remainder
    mflo $a1                # quotient
    li $v0, 4
    beq $a0, 0, printeven
    la $a0, odd
    syscall
    j end

printeven:
    la $a0, even
    syscall
    j end

end:
    li $v0, 10
    syscall 
