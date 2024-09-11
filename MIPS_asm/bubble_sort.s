.data

array: .word 5, 4, 2, 5, 3, 1
init_array_str: .asciiz "Initial array: "
sorted_array_str: .asciiz "Sorted array: "

.text

main:
    la $a0, init_array_str
    li $v0, 4
    syscall

    j end

end:
    li $v0, 10
    syscall
