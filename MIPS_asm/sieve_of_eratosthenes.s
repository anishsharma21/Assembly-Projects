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
    lw $a1, ($a0)                                   # final idx (mutates)
    addi $a0, 4                                     # set to addr of first val in buffer
    li $a2, 2                                       # jump val (mutates)

    j end

# issue I feel like I will encounter is the difference between final idx and the final value
sieve:
    bgt $a2, $a1, printPrimes                       # jump val >= final idx
    move $t0, $a0                                   # copy of first val addr
    sll $t1, $a2, 2                                 # jump val set to word length
    # t2 meant to be cur idx, but actually 1 more I believe
    move $t2, $a2                                   # cur idx that will be updated each iter
    addi $t2, -1                                    # a2 is j val, 0 + addr gives val 1, 4 + addr is 2, etc
    beq $t2, 2, handle1n2                           # first iteration is weird, handle 1 and 2 jump vals
    j sieveJumps                                    # null out all multiples of jump vals

sieveJumps:
    sw $zero, ($t0)                                 # set word at cur addr to 0
    add $t0, $t0, $t1                               # next addr incr by sll jump val
    add $t2, $t2, $a2                               # increment cur idx
    blt $t2, $a1, sieveJumps                        # while cur idx <= final idx
    j nextJumpVal

nextJumpVal:
    move $t0, $a0                                   # copy of base addr (first val)
    add $t0, $t0, $t1                               # incr addr by sll jump val
    move $t2, $a2                                   # copy of cur jump val
    j nextJumpValLoop

nextJumpValLoop:
    addi $t0, 4                                     # addr of next potential jump val
    addi $t2, 1                                     # incr cur jump val to next
    bgt $t2, $a1, printPrimes                       # if cur jump val > final idx, sieve finished
    lw $t1, ($t0)                                   # load next jump val
    beq $t1, $zero, nextJumpValLoop                 # if jump val has been set to 0, go to next
    move $a2, $t1                                   # update jump val to next val
    j sieve

handle1n2:
    sw $zero, ($t0)                                 # set the value 1 to 0 immediately
    addi $a0, 4                                     # 1 value handled, move to 2 jump val and handle
    j sieveJumps

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
# start with 2, add to base addr, set those values to 0, during loop iteration check if value already set to 0, if it is, increment by 2 and next iteration, end of loop iteration, find next val for jump val in buffer (next val not set to 0), then repeat that again with next jump val, repeat until jump val cannot be found (end of buffer reached), then final run through the buffer, printing values with separations that aren't equal to 0, those are the primes, newline, back to main
# start with 2, add to base addr, set those values to 0, during loop iteration check if value already set to 0, if it is, increment by 2 and next iteration, end of loop iteration, find next val for jump val in buffer (next val not set to 0), then repeat that again with next jump val, repeat until jump val cannot be found (end of buffer reached), then final run through the buffer, printing values with separations that aren't equal to 0, those are the primes, newline, back to main

MaxValueError:
    la $a0, MaxValueErrorStr
    li $v0, 4
    syscall

    j main

end:
    li $v0, 10
    syscall
