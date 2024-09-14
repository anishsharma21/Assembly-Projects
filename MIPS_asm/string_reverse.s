.data

buffer: .space 100
prompt: .asciiz "Type in a string: "
newline: .asciiz "\n"

.text

main:
    la $a0, prompt
    li $v0, 4
    syscall

    la $a0, buffer
    li $a1, 20
    li $v0, 8
    syscall

    # print inputted string
    la $a0, buffer
    li $v0, 4
    syscall

    # find str length
    la $a0, buffer
    li $t1, 10                      # ascii encoding for line feed, checked later in code
    li $v0, -1                      # to not count line feed byte
    jal str_len
    move $a1, $v0

    # reverse str
    addi $a1, -1                    # final byte idx (not len)
    la $a0, buffer
    li $a2, 0                       # cur byte idx
    jal reverse_str

    # print reversed string
    la $a0, buffer
    li $v0, 4
    syscall

    li $v0, 10
    syscall

str_len:
    lb $t0, ($a0)
    addi $v0, 1
    addi $a0, 1
    bne $t0, $t1, str_len           # if not line feed, keep going
    jr $ra

reverse_str:
    bgt $a2, $a1, jump_main         # beq check might be needed, odd num of bytes causes redundant swap

    add $t0, $a2, $a0               # addr of low byte
    add $t1, $a1, $a0               # addr of high byte
    lb $t2, ($t0)                   # load low byte
    lb $t3, ($t1)                   # load high byte
    sb $t2, ($t1)                   # store low in high
    sb $t3, ($t0)                   # store high in low

    addi $a2, 1                     # cur idx +1
    addi $a1, -1                    # len -1
    j reverse_str

jump_main:
    jr $ra
