.data

string: .asciiz "hello"
buffer: .space 100
prompt: .asciiz "The string is: "
incorrect: .asciiz "Incorrect! Try again...\n"
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

    li $v0, 4
    la $a0, buffer
    la $a1, string
    j compare_str

compare_str:
    lb $t0, ($a0)
    lb $t1, ($a1)
    addi $a0, 1
    addi $a1, 1
    beq $t0, 10, end_str_check                  # when line feed found
    bne $t0, $t1, incorrect_str
    j compare_str

end_str_check:
    beq $t1, 0, correct_str
    j incorrect_str

correct_str:
    la $a0, correct
    syscall

    la $a0, newline
    li $v0, 4
    syscall

    li $v0, 10
    syscall

incorrect_str:
    la $a0, incorrect
    syscall
    j main
