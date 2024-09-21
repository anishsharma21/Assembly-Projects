# pretty simple, store val, then addr right after of the next val, using sbrk for dynamic mem alloc, head, next, and val strings to navigate through linkedlist

.data

userchoice: .space 4
headNodeAddr: .space 4
curNodeAddr: .space 4

intro: .asciiz "Linked List initialised."
choice1: .asciiz "\nChoose head (h), next (n), val (v), or push (p)\n"
choice2: .asciiz "Choice: "

headstr: .asciiz "You are at the head node\n"
nextstr: .asciiz "You are at the next node\n"
pushedstr: .asciiz "Pushed node\n"
valstr: .asciiz "The value of this node is: "
newline: .asciiz "\n"

choiceerr: .asciiz "Invalid choice. Choose from h, n, v, or p."
nexterrstr: .asciiz "There is no next value."
valerrstr: .asciiz "This node has no value"

.text

main:
    jal initHeadNode                            # initialise head node of ll

    la $a0, intro
    li $v0, 4
    syscall

    j mainLoop

mainLoop:
    jal displayOptions

    la $a0, userchoice
    lb $a0, ($a0)

    # switch statement
    beq $a0, 104, goToHead
    beq $a0, 110, goToNext
    beq $a0, 118, showVal
    beq $a0, 112, pushNode

    la $a0, choiceerr
    li $v0, 4
    syscall
    j mainLoop

goToHead:
    la $a0, headNodeAddr
    la $a1, curNodeAddr
    sw $a0, ($a1)

    la $a0, headstr
    li $v0, 4
    syscall

    j mainLoop

goToNext:
    la $a0, nextstr
    li $v0, 4
    syscall
    jr $ra

showVal:
    la $a0, valstr
    li $v0, 4
    syscall
    jr $ra

pushNode:
    la $a0, pushedstr
    li $v0, 4
    syscall
    jr $ra

displayOptions:
    la $a0, choice1
    li $v0, 4
    syscall
    la $a0, choice2
    syscall

    la $a0, userchoice                          # buffer for choice char
    li $a1, 4                                   # len of choice str (1 char/byte)
    li $v0, 8                                   # read str
    syscall

    jr $ra

initHeadNode:
    # initialise head node
    li $a0, 8                                   # 4 bytes for val, 4 bytes for next addr
    li $v0, 9                                   # sbrk, returns addr in v0
    syscall
    la $a0, headNodeAddr                        # store head node addr in headNodeAddr
    sw $v0, ($a0)
    la $a0, curNodeAddr
    sw $v0, ($a0)                               # store head node addr in curNodeAddr
    jr $ra


