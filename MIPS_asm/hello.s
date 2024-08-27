    .data

helloworld: .asciiz "Hello, World!\n"     # declare a string

    .text
    .globl main                           # make the main function globally accessible

main:
    li $v0, 4                             # syscall 4 is print_str
    la $a0, helloworld                    # load the address of the string into $a0
    syscall                               # call the kernel

    li $v0, 10                            # syscall 10 is exit
    syscall                               # call the kernel