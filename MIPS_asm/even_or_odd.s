.data
.align 2

even: .asciiz " is even\n"
odd: .asciiz " is odd\n"
values: .word 23, 14, 2, 99, 10001, 0

.text
.globl main

main:
    la $s0, values          # load in array address
    j check

check:
    lw $a0, ($s0)           # load value at address
    beq $a0, 0, end         # if 0, end
    addi $s0, 4             # set to next value address

    li $v0, 1               # print the value
    syscall

    li $t1, 2
    div $a0, $t1            # divide value by 2
    mfhi $a0                # remainder
    mflo $a1                # quotient

    li $v0, 4               # preparing for print ascii
    beq $a0, 0, printeven   # if remainder 0, even

    la $a0, odd             # print odd string
    syscall
    j check

printeven:
    la $a0, even            # print even string
    syscall
    j check

end:
    li $v0, 10
    syscall
