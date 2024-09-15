.data

string: .asciiz "hello"
buffer: .space 100
prompt: .asciiz "What do you think the string is: "
incorrect: .asciiz "Incorrect! Try again..."
correct: .asciiz "Correct!"
newline: .asciiz "\n"

.text

main:
    la $a0, prompt
    li $v0, 4
    syscall

    la $a0, buffer
    li $a1, 100
    li $v0, 8
    syscall


