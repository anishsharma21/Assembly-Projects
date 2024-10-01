.data

array: .word 5, 2, 5, 1, 3, 4
init: .asciiz "Initial array: "
sorted: .asciiz "Sorted array: "
sep: .asciiz ", "
newline: .asciiz "\n"

.text

main:
    la $a0, init
    li $v0, 4
    syscall

    la $a0, array
    li $a1, 0
    lw $a2, ($a0)
    addi $a0, 4
    jal printArr
    jal printNewline

    # insertion_sort call
    la $a0, array                   # base address
    li $a1, 0                       # key idx
    lw $a2, ($a0)                   # length of arr
    addi $a0, 4
    li $s0, 4                       # word length, used later
    jal insertionSort

    la $a0, sorted
    li $v0, 4
    syscall

    la $a0, array
    li $a1, 0
    lw $a2, ($a0)
    addi $a0, 4
    jal printArr
    jal printNewline

    li $v0, 10
    syscall

# PSEUDOCODE
# main insertion sort proc adds 1 to key idx, if >= len arr, end sort, else add 4 to a0 for key addr, load key into temp var, set comp idx to -1 of key idx, then call iter. In iter, if key idx < 0, call main insertionSort, else get addr and val of comp val from comp idx, if key val >= comp val, call insert, else call shift. In insert, add 4 to comp idx and store key at that addr, call insertionSort. In shift, store comp val at comp idx + 4, call iter to loop.

insertionSort:
    addi $a1, 1
    bge $a1, $a2, endSort
    addi $a0, 4
    lw $t0, ($a0)                       # key val stored in temp
    move $t1, $a1
    addi $t1, -1                        # set comp idx
    j iter

iter:
    blt $t1, $zero, set
    move $t3, $t1
    sub $t1, $a1, $t1
    mul $t1, $t1, $s0
    sub $t1, $a0, $t1                   # addr of comp val
    lw $t2, ($t1)                       # comp val
    bge $t0, $t2, insert
    j shift

set:
    addi $t1, 1
    sub $t1, $a1, $t1
    mul $t1, $t1, $s0
    sub $t1, $a0, $t1                   # addr of comp val
    sw $t0, ($t1)
    j insertionSort

insert:
    addi $t1, 4
    sw $t0, ($t1)
    j insertionSort

shift:
    addi $t1, 4
    sw $t2, ($t1)
    move $t1, $t3
    addi $t1, -1
    j iter

endSort:
    jr $ra

printArr:
    move $t0, $a0
    lw $a0, ($a0)
    li $v0, 1
    syscall

    move $a0, $t0
    addi $a0, 4
    addi $a1, 1
    bne $a1, $a2, printSep
    jr $ra

printSep:
    move $t0, $a0
    la $a0, sep
    li $v0, 4
    syscall
    move $a0, $t0
    j printArr

printNewline:
    la $a0, newline
    li $v0, 4
    syscall
    jr $ra
