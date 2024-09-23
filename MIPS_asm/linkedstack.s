# this is a linked list stack - head always points to the latest pushed stack, new nodes point to previous nodes 
.data

userchoice: .space 4
headNodeAddr: .word 0
curNodeAddr: .word 0
# TODO dynamic resizing of this addrArr for amortised runtime/memory gains
addrArr: .space 100
addrArrCount: .space 1

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
reusestr: .asciiz "\nReusing memory for node\n"
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

# TODO check that dynamic mem allocation works as anticipated with manual testing
pushNode:
    # first check if node exists for reuse
    la $a0, addrArrCount
    lb $t0, ($a0)

    # this jal proc checks for mem reuse or just dynamic alloc as usual, places addr in v0
    jal allocateMemForNode

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

allocateMemForNode:
    # if addr count not 0, reuse prev node addr space, else proceed with dyn alloc
    bne $t0, 0, reuseMemForNode

    # dynamic alloc 8 bytes for new node, 4b for val, 4b for addr
    li $a0, 8
    li $v0, 9
    syscall
    jr $ra

reuseMemForNode:
    addi $t0, -1                                # 0 based idxing, 1 item means start at idx 0
    sll $t0, $t0, 2                             # calc offset for node reuse addr

    # -1 from addr arr count
    la $t1, addrArrCount
    lb $t2, ($t1)
    addi $t2, -1
    sb $t2, ($t1)

    la $a0, reusestr
    move $t1, $v0
    li $v0, 4
    syscall
    move $v0, $t1

    la $v0, addrArr
    add $v0, $v0, $t0                           # pointer to addr
    lw $v0, ($v0)                               # load the actual addr
    jr $ra

saveAddr:
    # TODO we don't need to iteratively check, we can just use addrArrCount
    # iteratively check for next free space in addr management array
    lw $t0, ($a0)
    addi $a0, 4                                 # pre-emptive next addr
    bne $t0, 0, saveAddr

    # store popped node addr for future use in addr management arr
    addi $a0, -4                                # negate pre-emptive next addr
    sw $a1, ($a0)

    la $a0, addrArrCount                        # incr addrArrCount
    lb $t0, ($a0)
    addi $t0, 1
    sb $t0, ($a0)
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
