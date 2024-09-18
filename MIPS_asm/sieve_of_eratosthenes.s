.data

buffer: .space 1024
bufferStr: .asciiz "Buffer: "
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

    # fill buffer with values based on user input
    move $a0, $v0                                   # max val
    la $a1, buffer                                  # buffer addr
    li $a2, 0                                       # cur idx
    sw $a0, ($a1)
    addi $a1, 4
    jal fillBuffer

    # print buffer after filling
    la $a0, bufferStr
    li $v0, 4
    syscall

    la $a0, buffer
    lw $a1, ($a0)
    addi $a0, 4
    li $t1, 0
    jal printPrimesLoop
    jal printNewline

    # find primes and print them
    la $a0, buffer                                  # addr of sieve buffer
    lw $a1, ($a0)                                   # max val
    addi $a0, 4                                     # set to addr of first val in buffer
    li $a2, 2                                       # jump val (mutates)
    jal sieve

    j end

sieve:
    bgt $a2, $a1, printPrimes                       # jump val > max val
    move $t0, $a0                                   # copy of first val addr
    sll $t1, $a2, 2                                 # jump val set to word length
    move $t2, $a2                                   # cur val that will be updated each iter
    beq $t2, 2, handle1                             # handle case where val is 1, first case
    add $t0, $t0, $t1                               # first val is prime, should not be zeroed
    j sieveJumps                                    # null out all multiples of jump vals

sieveJumps:
    sw $zero, ($t0)                                 # set word at cur addr to 0
    add $t0, $t0, $t1                               # next addr incr by sll jump val
    add $t2, $t2, $a2                               # increment cur val
    blt $t2, $a1, sieveJumps                        # while cur val < max val
    j nextJumpVal

nextJumpVal:
    # setup, addr and val of cur jump val
    move $t0, $a0                                   # copy of base addr (first val)
    add $t0, $t0, $t1                               # incr addr by sll jump val
    addi $t0, -4                                    # 0 based indexing
    j nextJumpValLoop

nextJumpValLoop:
    addi $t0, 4                                     # addr of next potential jump val
    addi $a2, 1                                     # incr cur jump val to next
    bgt $a2, $a1, printPrimes                       # if cur jump val > final val, sieve finished
    lw $t1, ($t0)                                   # load next jump val
    beq $t1, $zero, nextJumpValLoop                 # if jump val has been set to 0, go to next
    j sieve

handle1:
    sw $zero, ($t0)                                 # set the value 1 to 0 immediately
    addi $t0, 4                                     # base addr points to val 2
    add $t0, $t0, $t1                               # first value is prime so should not be zeroed
    j sieveJumps

printPrimes:
    li $t1, 0                                       # idx used when printing primes
    move $t0, $a0
    la $a0, primesStr
    li $v0, 4
    syscall
    move $a0, $t0
    j printPrimesLoop

printPrimesLoop:
    bgt $t1, $a1, jumpMain
    lw $t0, ($a0)
    addi $a0, 4
    addi $t1, 1
    beq $t0, $zero, printPrimesLoop

    move $t2, $a0
    move $a0, $t0
    li $v0, 1
    syscall
    blt $t1, $a1, printSep

    la $a0, newline
    li $v0, 4
    syscall
    jr $ra

printSep:
    la $a0, sep
    li $v0, 4
    syscall

    move $a0, $t2
    j printPrimesLoop

fillBuffer:
    addi $t0, $a2, 1
    sw $t0, ($a1)
    addi $a2, 1
    addi $a1, 4
    bne $a2, $a0, fillBuffer
    jr $ra

jumpMain:
    jr $ra

printNewline:
    la $a0, newline
    li $v0, 4
    syscall
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
