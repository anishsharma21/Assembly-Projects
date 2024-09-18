.data

array1: .word 10, -5, -2, 3, 4, 9, 11, 23, 24, 65, 78
array2: .word 5, 1, 2, 3, 4, 5
arrayChoice: .asciiz "Pick array (1 or 2): "
arrayStr: .asciiz "Array: "
prompt: .asciiz "Find index of: "
index: .asciiz "Index of '"
is: .asciiz "' is: "
invalidChoice: .asciiz "Invalid choice\n"
notFoundError: .asciiz "Value '"
notFoundError2: .asciiz "' was not found"
binarySearchError: .asciiz "Error occurred in binary search"
newline: .asciiz "\n"
sep: .asciiz ", "

.text

main:
    la $a0, arrayChoice
    li $v0, 4
    syscall

    li $v0, 5
    syscall
    move $t0, $v0

    beq $t0, 0, end

    la $a0, arrayStr
    li $v0, 4
    syscall

    beq $t0, 1, arr1
    beq $t0, 2, arr2

    la $a0, invalidChoice
    li $v0, 4
    syscall

    j main

arr1:
    la $a0, array1
    li $a1, 0
    lw $a2, ($a0)
    addi $a0, 4
    jal printArr
    jal promptIndex

    la $a0, newline
    li $v0, 4
    syscall

    la $a0, array1
    li $a1, 0                           # low idx
    lw $a2, ($a0)                       # high idx
    addi $a0, 4
    j binarySearch

arr2:
    la $a0, array2
    li $a1, 0
    lw $a2, ($a0)
    addi $a0, 4
    jal printArr
    jal promptIndex

    la $a0, newline
    li $v0, 4
    syscall

    la $a0, array2
    li $a1, 0                           # low idx
    lw $a2, ($a0)                       # high idx
    addi $a0, 4
    j binarySearch

promptIndex:
    la $a0, prompt
    syscall

    li $v0, 5
    syscall
    move $a3, $v0
    jr $ra

# high and low value, placed in a1 and a2, used to find middle index. add high and low, divide by 2 (get quotient) and use sll 2 to find addr of idx val, and then the val itself. if the inputted val is the same as the pivot val,we jump and return that val in v0, otherwise, if its larger, we set low to the middle index (so this should not be mutated), or high is set to the middle index, and binarySearch is called again. if low > high, go to not found and return
binarySearch:
    bgt $a1, $a2, notFound
    add $t0, $a1, $a2
    li $t1, 2
    div $t0, $t0, $t1                   # quotient in t0 (middle index)
    sll $t1, $t0, 2                     # word based offset
    add $t1, $a0, $t1                   # addr of val in t1
    lw $t1, ($t1)                       # val in t1

    move $s0, $a0
    move $a0, $t1
    li $v0, 1
    syscall
    la $a0, sep
    li $v0, 4
    syscall
    move $a0, $s0

    beq $t1, $a3, found
    bgt $t1, $a3, setLow
    blt $t1, $a3, setHigh
    j BinarySearchError

setHigh:
    move $a1, $t0
    addi $a1, 1
    j binarySearch

setLow:
    move $a2, $t0
    addi $a2, -1
    j binarySearch

found:
    la $a0, index
    li $v0, 4
    syscall

    move $a0, $a3
    li $v0, 1
    syscall

    la $a0, is
    li $v0, 4
    syscall

    move $a0, $t0
    li $v0, 1
    syscall

    la $a0, newline
    li $v0, 4
    syscall
    syscall

    j main

notFound:
    la $a0, notFoundError
    li $v0, 4
    syscall

    move $a0, $a3
    li $v0, 1
    syscall

    la $a0, notFoundError2
    li $v0, 4
    syscall

    la $a0, newline
    syscall

    j main

BinarySearchError:
    la $a0, newline
    li $v0, 4
    syscall

    la $a0, binarySearchError
    syscall

    li $v0, 10
    syscall

printArr:
    move $t0, $a0
    lw $a0, ($a0)
    li $v0, 1
    syscall
    addi $a1, 1
    bne $a1, $a2, printSep
    la $a0, newline
    li $v0, 4
    syscall
    jr $ra

printSep:
    la $a0, sep
    li $v0, 4
    syscall
    move $a0, $t0
    addi $a0, 4
    j printArr

end:
    li $v0, 10
    syscall
