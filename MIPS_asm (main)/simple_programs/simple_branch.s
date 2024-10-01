.data

a_string: .asciiz "a\n"
b_string: .asciiz "b\n"

.text

main:
    li $t0, 9
    li $t1, 5
    blt $t0, $t1, printa
    j printb

printa:
    la $a0, a_string
    li $v0, 4
    syscall
    j end

printb:
    la $a0, b_string
    li $v0, 4
    syscall
    j end

end:
    li $v0, 10
    syscall
