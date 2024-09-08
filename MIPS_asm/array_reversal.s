.data

.align 2
array: .word 5, -3, 4, 18, 9, -4

.align 2
newline: .asciiz "\n"

.text
.globl main

main:
    li $v0, 1                               # setting up syscall early
    la $a0, array
    lw $a1, ($a0)
    jal printarr                            # initial array print
    la $a0, array                           # base address of array
    lw $a1, ($a0)                           # length of array
    addi $a0, 4                             # first value in array
    li $t0, 1                               # current index + 1
    jal reverse
    j end

reverse:
    sub $t1, $a1, $t0                       # index of swap value in t1
    blt $t1, $t0, printarr                  # if high idx lower than low idx, print reversed arr
    sll $t1, $t1, 2                         # multiplies by 4 for word length

    add $t4, $t0, $zero                     # copy of index
    addi $t4, -1                            # finding offset from current index
    sll $t4, $t4, 2                         # for word length

    add $t1, $a0, $t1                       # now t1 holds address of swap value
    sub $t1, $t1, $t4                       # account for increasing a0

    lw $t2, ($t1)                           # t2 holds value at swap address
    lw $t3, ($a0)                           # t3 holds lower value
    sw $t3, ($t1)                           # store low into high address
    sw $t2, ($a0)                           # store high into low address
    addi $a0, 4                             # next value
    addi $t0, 1                             # next index
    j reverse

printarr:
    addi $a0, 4
    syscall                                 # no need to specify v0, already done
    addi $a1, -1
    bgt $a1, 0, printarr
    jr $ra

end:
    li $v0, 10
    syscall
