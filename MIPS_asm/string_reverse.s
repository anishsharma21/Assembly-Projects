.data

buffer: .space 20
prompt: .asciiz "Type in a string: "
newline: .asciiz "\n"

.text

main:
    la $a0, prompt
    li $v0, 4
    syscall

    la $a0, buffer
    li $a1, 20
    li $v0, 8
    syscall

    la $a0, buffer
    li $v0, 4
    syscall

    lb $a0, ($a0)
    li $v0, 1
    syscall

    la $a0, newline
    li $v0, 4
    syscall

    li $v0, 10
    syscall

print_str_dec:
    lb $t0, ($a0)
    beq $t0, $zero, jump_main
    move $t1, $a0
    move $a0, $t0
    li $v0, 1
    syscall
    la $a0, newline
    li $v0, 4
    syscall
    move $a0, $t1
    addi $a0, 1
    j print_str_dec

jump_main:
    jr $ra
