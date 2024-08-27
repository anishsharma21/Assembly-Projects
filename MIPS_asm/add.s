        .data

var1:   .word 23 

        .text
main:
    li $t0, 10
    add $t0, $t0, 10
    move $a0, $t0       # int to be printed
    li $v0, 1           # syscall for printing int
    syscall

    lw $t0, var1
    li $t1, 5
    sw $t1, var1
    li $v0, 10
    syscall
