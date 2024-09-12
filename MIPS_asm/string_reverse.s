.data

buffer: .space 20
prompt: .asciiz "Type in a string: "

.text

main:
    la $a0, prompt
    li $v0, 4
    syscall

    la $a0, buffer
    li $a1, 20
    li $v0, 8
    syscall

    la $a0, buffer
    li $v0, 4
    syscall

    li $v0, 10
    syscall
