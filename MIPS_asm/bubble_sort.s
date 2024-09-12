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

# a2 is cur idx, $t0 is next idx (for swap)
bubble_sort:
    beq $a2, $a1, end_sort                                  # end sort if cur idx == len arr
    add $t0, $a2, 1                                         # otherwise, set next idx
    bgt $t0, $a1, update_cur_idx                            # reset next idx if > than arr len

    sll $a2, $a2, 2                                         # word length for cur idx
    sll $t0, $t0, 2                                         # word length for next idx
    add $t1, $a0, $a2                                       # cur idx mem addr
    add $t2, $a0, $t0                                       # next idx mem addr
    j swap

update_cur_idx:
    addi $a2, 1
    move $t0, $a2
    j bubble_sort

swap:
    lw $t3, ($t1)
    lw $t4, ($t2)
    sw $t3, ($t2)
    sw $t4, ($t1)
    addi $t0, 1
    j bubble_sort

end_sort:
    jr $ra

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
