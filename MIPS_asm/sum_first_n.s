.data

prompt: .asciiz "Type in a number: "
sum_str1: .asciiz "Sum of first "
sum_str2: .asciiz " numbers is: "
newline: .asciiz "\n"

.text

main:
    # prompt for int
    la $a0, prompt
    li $v0, 4
    syscall

    # get int
    li $v0, 5
    syscall
    move $t0, $v0

    # present sum of first N values up to int
    la $a0, sum_str1
    li $v0, 4
    syscall
    move $a0, $t0
    li $v0, 1
    syscall
    la $a0, sum_str2
    li $v0, 4
    syscall

    move $a0, $t0
    li $v0, 0
    jal sum_first_n
    move $a0, $v0
    li $v0, 1
    syscall
    la $a0, newline
    li $v0, 4
    syscall

    j end

sum_first_n:
    add $v0, $v0, $a0
    addi $a0, -1
    bne $a0, $zero, sum_first_n
    jr $ra

end:
    li $v0, 10
    syscall
