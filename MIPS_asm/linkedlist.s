# pretty simple, store val, then addr right after of the next val, using sbrk for dynamic mem alloc, head, next, and val strings to navigate through linkedlist

.data

userchoice: .space 1

intro: .asciiz "Linked List initialised."
choice1: .asciiz "\nChoose head (h), next (n), val (v), or push (p)\n"
choice2: .asciiz "Choice: "
headstr: .asciiz "You are at the head node"
nextstr: .asciiz "You are at the next node"
pushedstr: .asciiz "Pushed node"
valstr: .asciiz "The value of this node is: "

choiceerr: .asciiz "Invalid choice. Choose from h, n, v, or p."
nexterrstr: .asciiz "There is no next value."
valerrstr: .asciiz "This node has no value"
newline: .asciiz "\n"

.text

main:
    la $a0, intro
    li $v0, 4
    syscall

    jal displayOptions
    syscall                                     # read str, setup in displayOptions

    la $a0, userchoice
    lb $a0, ($a0)
    # switch statement
    beq $a0, 72, goToHead
    beq $a0, 78, goToNext
    beq $a0, 86, showVal
    beq $a0, 80, pushNode

    la $a0, choiceerr
    li $v0, 4
    syscall
    j main

displayOptions:
    la $a0, choice1
    li $v0, 4
    syscall
    la $a0, choice2
    syscall
    li $v0, 8                                   # read str
    la $a0, userchoice                          # buffer for choice char
    li $a1, 1                                   # len of choice str (1 char/byte)
    jr $ra
