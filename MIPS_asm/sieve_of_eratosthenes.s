.data

buffer: .space 1024
prompt: .asciiz "Find prime numbers up to: "
primesStr: .asciiz "Prime numbers: "
newline: .asciiz "\n"
sep: .asciiz ", "
MaxValueErrorStr: .asciiz "\nNumber is too large (< 256)\n\n"
NegativeValueErrorStr: .asciiz "\nNumber must be >0\n\n"

.text

# find prime numbers up to user input integer value (max is 255 for now), then buffer is filled with numbers up until that value, then sieve function called, all places where values are cut out, those values are set to 0, so on the last run through of the buffer, the values still present are printed in order

main:
    la $a0, prompt
    li $v0, 4
    syscall

    li $v0, 5
    syscall
    beq $v0, 0, end
    blt $v0, 0, NegativeValueError
    bge $v0, 255, MaxValueError                     # >= bc 1 val required for length

    move $a0, $v0                                   # max idx
    la $a1, buffer                                  # buffer addr
    li $a2, 0                                       # cur idx
    sw $a0, ($a1)
    addi $a1, 4
    jal fillBuffer

    la $a0, buffer                                  # addr of sieve buffer
    lw $a1, ($a0)                                   # length
    addi $a0, 4

    j end

# start with 2, add to base addr, set those values to 0, during loop iteration check if value already set to 0, if it is, increment by 2 and next iteration, end of loop iteration, find next val for jump val in buffer (next val not set to 0), then repeat that again with next jump val, repeat until jump val cannot be found (end of buffer reached), then final run through the buffer, printing values with separations that aren't equal to 0, those are the primes, newline, back to main
sieve:
    # TODO

fillBuffer:
    addi $t0, $a2, 1
    sw $t0, ($a1)
    addi $a2, 1
    addi $a1, 4
    bne $a2, $a0, fillBuffer
    jr $ra

NegativeValueError:
    la $a0, NegativeValueErrorStr
    li $v0, 4
    syscall

MaxValueError:
    la $a0, MaxValueErrorStr
    li $v0, 4
    syscall

    j main

end:
    li $v0, 10
    syscall
