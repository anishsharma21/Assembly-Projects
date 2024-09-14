.data

prompt: .asciiz "Input an int: "
factorial: .asciiz "Factorial of int: "
newline: .asciiz "\n"

.text

main:
    la $a0, prompt
    li $v0, 4
    syscall

    li $v0, 5
    syscall

    move $a0, $v0
    jal fact
    move $s0, $a0

    la $a0, factorial
    li $v0, 4
    syscall
    move $a0, $s0
    li $v0, 1
    syscall
    la $a0, newline
    li $v0, 4
    syscall

    li $v0, 10
    syscall

# In simple terms, check if number is less than or equal to 1, if so, return, otherwise, continue, when you do continue, you'll minus one from a0, and jal to fact again with the new a0, then, eventually, you will each the a0 is 1 case, at this point, you return address, which will take you to the point where fact was called with 2, after this, a0 is equal to the current a0 value at that point multiplied by the value popped off the stack, which is 1 x 2 in order, then you once again ra, and this repeats all the way to the initial number where the final ra actually returns you to the main loop
# now, we need to figure out when to push values on and off the stack, but basically, when the value is less than 2, we can immediately jr $ra, which for now can be in a separate procedure to keep things simple
# then if that check doesn't pass, the value is great than 1, so we can now push the value onto the stack and the return address, minus 1 from it, and call fact again, when it eventually returns, we can set pop the a0 value of the stack into a temporary variable and set a0 to multiple that value, the ra is also set to the value popped off the stack, then, we return address again, thats it I think
fact:
    blt $a0, 2, jra
    addi $sp, -8
    sw $ra, 4($sp)
    sw $a0, 0($sp)
    addi $a0, -1
    jal fact
    lw $ra, 4($sp)
    lw $t0, 0($sp)
    addi $sp, 8
    mul $a0, $a0, $t0
    jr $ra

jra:
    # addi $sp, 8
    jr $ra
