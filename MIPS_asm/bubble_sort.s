.data

array: .word 5, 4, 2, 5, 3, 1
init_array_str: .asciiz "Initial array: "
sorted_array_str: .asciiz "Sorted array: "
sep: .asciiz ", "
newline: .asciiz "\n"

.text

main:
    la $a0, init_array_str
    li $v0, 4
    syscall

    la $a0, array
    lw $a1, ($a0)
    addi $a0, 4
    li $a2, 0
    jal print_arr

    j end

print_arr:
    move $t0, $a0
    lw $a0, ($a0)
    li $v0, 1
    syscall

    move $a0, $t0
    addi $a0, 4
    addi $a2, 1
    beq $a1, $a2, jrra              # idx === arr len

    move $t0, $a0                   # print separator
    la $a0, sep
    li $v0, 4
    syscall

    move $a0, $t0
    j print_arr

jrra:
    la $a0, newline
    li $v0, 4
    syscall
    jr $ra

end:
    li $v0, 10
    syscall
