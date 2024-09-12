.data

array: .word 5, 4, 2, 5, 3, 1
init_array_str: .asciiz "Initial array: "
sorted_array_str: .asciiz "Sorted array: "
sep: .asciiz ", "
newline: .asciiz "\n"

.text

main:
    # print unsorted array
    la $a0, init_array_str
    li $v0, 4
    syscall

    la $a0, array
    lw $a1, ($a0)
    addi $a0, 4
    li $a2, 0
    jal print_arr

    la $a0, newline
    li $v0, 4
    syscall

    # sort array
    la $a0, array
    lw $a1, ($a0)
    move $s0, $a1                       # s0 for length - 1 copy
    addi $s0, -1                        # useful for sort_p procedure
    addi $a0, 4
    li $a2, 0
    jal bubble_sort

    # print sorted array
    la $a0, sorted_array_str
    li $v0, 4
    syscall

    la $a0, array
    lw $a1, ($a0)
    addi $a0, 4
    li $a2, 0
    jal print_arr

    j end

bubble_sort:
    beq $a2, $a1, jump_back             # if idx == len arr, end sort
    move $t0, $a2                       # t0 copy of cur idx (for temp mutability)
    jal sort_p                          # jump to procedure
    addi $a2, 1
    j bubble_sort

sort_p:
    beq $t0, $s0, jump_back             # end cur bubble sort iteration if second-last idx
    move $t1, $t0                       # copy of cur idx to create next idx
    addi $t1, 1                         # next idx (+1 of cur idx)
    move $t2, $t0                       # move so shift left can be performed
    move $t3, $t1                       # same but for next idx (not necessary but consistent)
    sll $t2, $t2, 2
    add $t2, $a0, $t2                   # address for cur idx
    sll $t3, $t3, 2
    add $t3, $a0, $t3                   # address for next idx
    lw $t4, ($t2)                       # load value at cur idx
    lw $t5, ($t3)                       # load value at next idx
    bgt $t4, $t5, swap                  # if cur > next, swap
    addi $t0, 1                         # increment cur idx for next iteration
    j sort_p

swap:
    sw $t4, ($t3)
    sw $t5, ($t2)
    addi $t0, 1
    j sort_p

jump_back: 
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
