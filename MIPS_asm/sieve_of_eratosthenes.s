.data

buffer: .space 1024
prompt: .asciiz "Find prime numbers up to: "
primesStr: .asciiz "Prime numbers: "
newline: .asciiz "\n"
sep: .asciiz ", "
MaxValueErrorStr: .asciiz "\nNumber is too large (< 256)\n\n"
NegativeValueErrorStr: .asciiz "\nNumber must be >0\n\n"

.text

# find prime numbers up to user input integer value (max is 256 for now), then buffer is filled with numbers up until that value, then sieve function called, all places where values are cut out, those values are set to 0, so on the last run through of the buffer, the values still present are printed in order

main:
    la $a0, prompt
    li $v0, 4
    syscall

    li $v0, 5
    syscall
    blt $v0, 0, NegativeValueError
    beq $v0, 0, end
    bge $v0, 256, MaxValueError

    move $a0, $v0
    la $a1, buffer
    jal fillBuffer

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
