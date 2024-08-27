        .data

var1:   .word 23 

        .text
main:
    li $t0, 10
    add $t0, $t0, 10
    lw $t0, var1
    li $t1, 5
    sw $t1, var1
    li $v0, 10
    syscall
