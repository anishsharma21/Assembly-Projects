.data

arr1: .word 5, 2, 4, 7, 7, 12
arr2: .word 4, -3, 0, 10, 33
buffer: .space 100
arr1Str: .asciiz "Array 1: "
arr2Str: .asciiz "Array 2: "
mergedArrStr: .asciiz "Merged array: "
newline: .asciiz "\n"
sep: .asciiz ", "

.text

main:
    la $a0, arr1Str
    li $v0, 4
    syscall

    la $a0, arr1
    li $a1, 0
    lw $a2, ($a0)
    addi $a0, 4
    jal printArr
    jal printNewline

    la $a0, arr2Str
    li $v0, 4
    syscall

    la $a0, arr2
    li $a1, 0
    lw $a2, ($a0)
    addi $a0, 4
    jal printArr
    jal printNewline

    la $a0, mergedArrStr
    li $v0, 4
    syscall

    la $a0, arr1
    la $a1, arr2
    lw $a2, ($a0)
    lw $a3, ($a1)
    addi $a0, 4
    addi $a1, 4
    li $t0, 0
    li $t1, 0
    la $t2, buffer
    jal mergeArrays

    la $a0, buffer
    li $a1, 0
    li $a2, 9                       # HARDCODED LENGTH, fix in next iteration
    # addi $a0, 4
    jal printArr
    jal printNewline

    li $v0, 10
    syscall

# PSEUDOCODE
# a0 base addr of arr1, a1 base addr of arr2, a2 len arr1, a3 len arr2, t0 cur idx arr1, t1 cur idx arr2, s0 base addr of buffer (addr of merged arr)
# simple explanation: load val at cur idx of arr1, load val at cur idx of arr2, if val1 < val2, idx1 + 1, buffer idx equals val1, buffer idx +1, and back to mergeArrays, else, idx2 + 1, buffer idx equals val2, buffer idx +1, back to mergeArrays.
# start by checking if arr1 is finished, if so, j to proc where arr2 is just appended on, in this proc, also check if arr2 is finished, if it is, then return. if arr1 not finished, load next val in arr1, then next line check if arr2 finished, if it is, then j to proc where arr1 is just appended on, then return at the end. otherwise, if arr2 not finished either, load next value in arr2. if arr1 val < arr2 val, j to proc that sets next buffer val to arr1 val, incremements arr1 idx, then j to mergeArrays, else, continue by setting arr2 as next buffer value, in each, buffer idx incremented before j to mergeArrays again (increment by word length), optional check if buffer overflow occurs
# TODO first val in final arr must be length of the final array, needs to be set, referenced by a constant address, and incrememented each time a new value is added, not difficult but necessary for printing full array
# TODO buffer overflow check at the start of mergeArrays proc each time

mergeArrays:
    beq $t0, $a2, L1                        # arr1 finished
    lw $t3, ($a0)                           # load next arr1 val
    beq $t1, $a3, L2                        # arr2 finished
    lw $t4, ($a1)                           # load next arr2 val

    blt $t3, $t4, L3                        # val1 < val2
    j L4                                    # val2 < val1

L1:
    beq $t1, $a3, endSort                   # arr2 finished
    # setup for finishMerge arr2
    move $a0, $a1                           # base addr of arr2
    move $a1, $t1                           # cur idx of arr2
    move $a2, $a3                           # len of arr2
    j finishMerge

L2:
    # setup for finishMerge of arr1
    # addr and len coincidentally already set
    move $a1, $t0                           # cur idx of arr1
    j finishMerge

L3:
    sw $t3, ($t2)                           # store val1 in buffer
    addi $t0, 1                             # increment arr1 idx
    addi $a0, 4                             # next arr1 addr
    addi $t2, 4                             # next buffer addr
    j mergeArrays

L4:
    sw $t4, ($t2)                           # store val2 in buffer
    addi $t1, 1                             # increment arr2 idx
    addi $a1, 4                             # next arr2 addr
    addi $t2, 4                             # next buffer addr
    j mergeArrays

finishMerge:
    lw $t0, ($a0)
    sw $t0, ($t2)
    addi $a0, 4
    addi $t2, 4
    addi $a1, 1
    bne $a1, $a2, finishMerge
    jr $ra

endSort:
    jr $ra

printArr:
    move $t0, $a0
    lw $a0, ($a0)
    li $v0, 1
    syscall

    addi $a1, 1
    bne $a1, $a2, printSep
    jr $ra

printSep:
    la $a0, sep
    li $v0, 4
    syscall
    move $a0, $t0
    addi $a0, 4
    j printArr

printNewline:
    la $a0, newline
    li $v0, 4
    syscall
    jr $ra
