    .data         # data section

    .text         # code section

main:
    li $v0, 10    # syscall 10 is exit
    syscall       # call the kernel