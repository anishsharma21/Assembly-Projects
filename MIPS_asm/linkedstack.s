# this is a linked list stack - head always points to the latest pushed stack, new nodes point to previous nodes 
.data

userchoice: .space 4
headNodeAddr: .word 0
curNodeAddr: .word 0
addrArr: .word 100

intro: .asciiz "\nLinked Stack initialised.\n"
choice1: .asciiz "\nChoose head (h), next (n), val (v), push (p), pop/remove (r), set val (s), length (l), or quit (q)\n"
choice2: .asciiz "Choice: "

headstr: .asciiz "\nYou are at the head node\n"
nextstr: .asciiz "\nYou are at the next node\n"
pushedstr: .asciiz "\nPushed node\n"
poppedstr: .asciiz "\nPopped node\n"
valstr: .asciiz "\nThe value of this node is: "
setvalstr: .asciiz "\nSet the value to: "
setvalstr2: .asciiz "\nValue set!\n"
lengthstr: .asciiz "\nLength of linked list: "
newline: .asciiz "\n"

choiceerr: .asciiz "\nInvalid choice. Choose from h, n, v, p, r, s, l, or q.\n"
nexterrstr: .asciiz "\nThere is no next value.\n"
poperrstr: .asciiz "\nCannot pop head from stack\n"
valerrstr: .asciiz "\nThis node has no value\n"
setvalerr: .asciiz "\nInvalid value. Must be integer.\n"

.text

main:
    jal initLinkedStack                              # initialise head node

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
    beq $a0, 115, setVal
    beq $a0, 108, findLength
    beq $a0, 112, pushNode
    beq $a0, 114, popNode
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

setVal:
    la $a0, setvalstr
    li $v0, 4
    syscall

    li $v0, 5
    syscall                                     # not sure how to catch err here if not int

    la $a0, curNodeAddr                         # load addr to mem which holds cur node addr
    lw $a0, ($a0)                               # load cur node addr from the mem addr that holds it
    sw $v0, ($a0)                               # set user input int for cur node

    la $a0, setvalstr2
    li $v0, 4
    syscall

    j mainLoop

# TODO check in mem addr arr for nodes that can be used instead, print something to indicate that a previous node is being used for the new node (to see if memory allocation is working as anticipated)
pushNode:
    # dynamic alloc 8 bytes for new node, 4b for val, 4b for addr
    li $a0, 8
    li $v0, 9
    syscall

    la $a0, headNodeAddr                        # get pointer to head node addr
    lw $a0, ($a0)                               # get head node addr from pointer
    sw $a0, 4($v0)                              # set next addr of cur node to cur head node addr

    la $a0, headNodeAddr                        # get pointer to head node addr
    sw $v0, ($a0)                               # set set new node addr as head node addr

    la $a0, setvalstr
    li $v0, 4
    syscall

    li $v0, 5
    syscall

    la $a0, headNodeAddr
    lw $a0, ($a0)
    sw $v0, ($a0)

    la $a0, setvalstr2
    li $v0, 4
    syscall

    la $a0, pushedstr
    li $v0, 4
    syscall
    j mainLoop

# TODO check length first (i.e. just check if there is a next addr for the cur head node)
popNode:
    # set head node to next node of current head (this would be enough in a GC environment)
    # need to also store addr of prev head (now popped) so it can be used for future pushed nodes

    la $a0, headNodeAddr                        # get pointer to head node addr
    lw $t0, ($a0)                               # get head node addr from pointer
    lw $t1, 4($t0)                              # get next addr on cur head node
    beq $t1, 0, PopError                        # if no next addr, can't pop
    sw $t1, ($a0)                               # set head node addr to next node addr

    la $a0, poppedstr
    li $v0, 4
    syscall

    # store popped node addr for future use in a static arr for mem management
    la $a0, addrArr
    move $a1, $t0
    j saveAddr

saveAddr:
    # iteratively check for next free space in addr management array
    lw $t0, ($a0)
    addi $a0, 4
    bne $t0, 0, saveAddr

    # store popped node addr for future use in addr management arr
    sw $a1, ($a0)
    j goToHead

printArr:
    # TODO should be generalised, but immediate use case is for printing contents of addr arr

findLength:
    la $a0, headNodeAddr
    lw $t0, ($a0)                               # load addr to get node addr
    li $a1, 1                                   # all linked lists have len 1 minimum

findLengthLoop:
    lw $t0, 4($t0)                              # load next node addr using node addr

    beq $t0, 0, endFindLength                   # addr is 0, which means not next node

    addi $a1, 1                                 # incremement len
    move $a0, $t0                               # move next node addr into a0
    j findLengthLoop

endFindLength:
    la $a0, lengthstr
    li $v0, 4
    syscall

    move $a0, $a1
    li $v0, 1
    syscall

    la $a0, newline
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

initLinkedStack:
    # initialise first node
    li $a0, 8                                   # 4 bytes for val, 4 bytes for next addr
    li $v0, 9                                   # sbrk, returns addr in v0
    syscall

    la $a0, headNodeAddr                        # store head node addr in headNodeAddr
    sw $v0, ($a0)

    la $a0, curNodeAddr
    sw $v0, ($a0)

    jr $ra

NextError:
    la $a0, nexterrstr
    li $v0, 4
    syscall

    j mainLoop

PopError:
    la $a0, poperrstr
    li $v0, 4
    syscall

    j mainLoop

quit:
    li $v0, 10
    syscall
