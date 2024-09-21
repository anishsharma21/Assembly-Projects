# pretty simple, store val, then addr right after of the next val, using sbrk for dynamic mem alloc, head, next, and val strings to navigate through linkedlist

.data

userchoice: .space 4
headNodeAddr: .word 0
curNodeAddr: .word 0

intro: .asciiz "\nLinked List initialised.\n"
choice1: .asciiz "\nChoose head (h), next (n), val (v), push (p), or quit (q)\n"
choice2: .asciiz "Choice: "

headstr: .asciiz "\nYou are at the head node\n"
nextstr: .asciiz "\nYou are at the next node\n"
pushedstr: .asciiz "\nPushed node\n"
valstr: .asciiz "\nThe value of this node is: "
newline: .asciiz "\n"

choiceerr: .asciiz "\nInvalid choice. Choose from h, n, v, or p.\n"
nexterrstr: .asciiz "\nThere is no next value.\n"
valerrstr: .asciiz "\nThis node has no value\n"

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
    beq $a0, 113, quit

    la $a0, choiceerr
    li $v0, 4
    syscall
    j mainLoop

goToHead:
    la $a0, headNodeAddr
    lw $a0, ($a0)

    la $a1, curNodeAddr
    sw $a0, ($a1)

    la $a0, headstr
    li $v0, 4
    syscall

    j mainLoop

goToNext:
    la $a0, curNodeAddr
    lw $a0, ($a0)                               # load addr of cur node
    lw $a0, 4($a0)                              # load next mem addr

    beq $a0, 0, NextError                       # if next addr is 0, err

    la $a1, curNodeAddr
    sw $a0, ($a1)                               # store next mem addr into cur

    la $a0, nextstr
    li $v0, 4
    syscall

    j mainLoop

NextError:
    la $a0, nexterrstr
    li $v0, 4
    syscall

    j mainLoop

showVal:
    la $a0, valstr
    li $v0, 4
    syscall

    la $a0, curNodeAddr
    lw $a0, ($a0)                               # load addr of cur node
    lw $a0, ($a0)                               # load val at cur node addr
    li $v0, 1
    syscall

    la $a0, newline
    li $v0, 4
    syscall

    j mainLoop

pushNode:
    la $a0, pushedstr
    li $v0, 4
    syscall
    j mainLoop

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

    li $t0, 5
    sw $t0, ($v0)

    la $a0, headNodeAddr                        # store head node addr in headNodeAddr
    sw $v0, ($a0)

    la $a0, curNodeAddr
    sw $v0, ($a0)

    jr $ra

quit:
    li $v0, 10
    syscall
