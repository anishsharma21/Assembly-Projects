# pretty simple, store val, then addr right after of the next val, using sbrk for dynamic mem alloc, head, next, and val strings to navigate through linkedlist

.data

userchoice: .word 4

intro: .asciiz "Linked List initialised."
choice1: .asciiz "\nChoose head (h), next (n), val (v), or push (p)\n"
choice2: .asciiz "Choice: "
headstr: .asciiz "You are at the head node"
nextstr: .asciiz "You are at the next node"
pushedstr: .asciiz "Pushed node"
valstr: .asciiz "The value of this node is: "

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
    li $v0, 4
    syscall

    li $v0, 10
    syscall

displayOptions:
    la $a0, choice1
    li $v0, 4
    syscall
    la $a0, choice2
    syscall
    li $v0, 8                                   # read str
    la $a0, userchoice                          # buffer for choice char
    li $a1, 4                                   # len of choice str (1 char)
    jr $ra
