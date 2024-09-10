.data

terminate: .asciiz "0 terminates program\n"
first_str: .asciiz "First int: "
second_str: .asciiz "Second int: "
is_larger_str: .asciiz " is larger\n\n"
equal_str: .asciiz "They're both equal\n\n"

.text

main:
    la $a0, terminate
    li $v0, 4
    syscall

main_loop:
    la $a0, first_str
    syscall

    li $v0, 5
    syscall
    move $a1, $v0
    beq $a1, 0, perm_end

    la $a0, second_str
    li $v0, 4
    syscall

    li $v0, 5
    syscall
    move $a2, $v0
    beq $a2, 0, perm_end

    j find_larger

find_larger:
    li $v0, 1
    blt $a1, $a2, print2
    beq $a1, $a2, equal_print
    move $a0, $a1
    syscall
    j end

print2:
    move $a0, $a2
    syscall
    j end

equal_print:
    la $a0, equal_str
    li $v0, 4
    syscall

end:
    la $a0, is_larger_str
    li $v0, 4
    syscall

    j main

perm_end:
    li $v0, 10
    syscall
