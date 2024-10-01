.data

.align 2
newline: .asciiz "\n"

.align 2
prompt: .asciiz "Number of fibonacci numbers to print: "

.text
.globl main

main:
    la $a0, prompt
    li $v0, 4
    syscall
    li $v0, 5
    syscall
    move $a1, $v0                       # num of values required
    li $a2, 1                           # prev
    li $a3, 1                           # next
    li $t0, 0                           # num complete
    jal fib
    j end

fib:
    beq $t0, $a1, jump_main
    blt $t0, 2, print_1
    add $t2, $a2, $a3
    move $a2, $a3
    move $a3, $t2
    move $a0, $a3
    li $v0, 1
    syscall
    addi $sp, -4
    sw $ra, ($sp)
    jal print_newline
    lw $ra, ($sp)
    addi $t0, 1
    j fib

print_1:
    li $a0, 1
    li $v0, 1
    syscall
    addi $sp, -4
    sw $ra, ($sp)
    jal print_newline
    lw $ra, ($sp)
    addi $sp, 4
    addi $t0, 1
    j fib

print_newline:
    la $a0, newline
    li $v0, 4
    syscall
    jr $ra

jump_main:
    jr $ra

end:
    li $v0, 10
    syscall
