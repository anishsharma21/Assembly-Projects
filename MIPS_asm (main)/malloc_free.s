.data

# heap space for memory blocks - where variable data is stored
.align 2
ManagedHeapBP: .space 4
ManagedHeapNP: .space 4
ManagedHeapCap: .word 1024

# FIXME malloc and free list need to use linked list data structure with head and tail node pointers - to resolve the bug with array offsets being unreliable when addressed become unused

# malloc/allocation list - linked list data structure used to track details about allocated nodes in the managed heap
.align 2
MallocListHeadPointer: .space 4
.align 2
MallocListTailPointer: .space 4
MallocListBP: .space 4
MallocListCount: .byte 0
MallocListCap: .byte 4

# free list - linked list data structure used to track details about deallocated/freed nodes
.align 2
FreeListHeadPointer: .space 4
.align 2
FreeListTailPointer: .space 4
FreeListBP: .space 4
FreeListCount: .byte 0
FreeListCap: .byte 4

NameBuffer: .space 200
ChoiceBuffer: .space 4
UserFreeInputStr: .space 200

IntroStr: .asciiz "############################################\n#                                          #\n#    Welcome to the malloc/free program    #\n#                                          #\n############################################\n\nThis program has been written in MIPS assembly and involves the allocation and deallocation of memory. You will be prompted to either malloc or free data during the program.\n\nLet's start by allocating a variable.\n"
NamePromptStr: .asciiz "\nPick a name for the variable: "
SpacePromptStr: .asciiz "How much space do you want to store: "
MallocSuccessStr: .asciiz " was allocated at "
AllocatedBlockStr: .asciiz "\nMemory block allocated: "
BlockAllocatedStr: .asciiz "\n### You've allocated a block of memory! ###\n"
ChoiceStr: .asciiz "\nNow, would you like to allocate (a), free (f), or display (d) memory?"
ChoicePromptStr: .asciiz "\nChoice: "
OpenBracketStr: .asciiz "["
ClosedBracketStr: .asciiz "]"
MemoryStr: .asciiz "\nMemory: "
BlockNamesStr: .asciiz "\nVariable names: "
BlockNamePromptStr: .asciiz "Variable you'd like to free: "
AllocatedBlockCountStr: .asciiz "\nNumber of variables: "
FreeListAllocAddr: .asciiz "\n ### Reusing a freed block ###\n"

MallocErr: .asciiz "\nMemory allocation error occurred!\n"
NameLenErr: .asciiz "\nName must be at least 1 char long\n"
NameNotUniqueErr: .asciiz "\nChoose a unique name\n"
HeapOverflowErr: .asciiz "\nManaged heap is full\n"
ChoiceErr: .asciiz "\nInvalid choice. Choose from a, f, d or q.\n"
HeapEmptyErr: .asciiz "\nHeap is empty\n"
MallocListOverflowErr: .asciiz "\nManaged malloc list is full\n"
FreeListOverflowErr: .asciiz "\nManaged free list is full\n"
MallocListCountErr: .asciiz "\nNegative malloc list count encountered."
NameNotFoundErr: .asciiz "\nName not found.\nTry again.\n\n"

newline: .asciiz "\n"
sep: .asciiz ", "
space: .asciiz " "

.text
.globl main
.globl malloc
.globl free

main:
    # allocate mem for managed heap
    li $a0, 1024                                        # 1024 bytes of space in managed heap
    li $v0, 9
    syscall

    # store base pointer of heap
    la $a0, ManagedHeapBP
    sw $v0, ($a0)

    # store next pointer of heap (same as base pointer initially)
    la $a0, ManagedHeapNP
    sw $v0, ($a0)

    la $a0, IntroStr
    li $v0, 4
    syscall

    # initiate memory allocation flow immediately
    j malloc

MainLoop:
    li $v0, 4
    la $a0, ChoiceStr
    syscall
    la $a0, ChoicePromptStr
    syscall

    la $a0, ChoiceBuffer
    li $a1, 4
    li $v0, 8
    syscall

    la $a0, ChoiceBuffer
    lb $a0, ($a0)
    beq $a0, 97, malloc
    beq $a0, 102, free
    beq $a0, 100, DisplayHeap
    beq $a0, 113, end

    la $a0, ChoiceErr
    li $v0, 4
    syscall
    j MainLoop

malloc:
    # prompt user for name of new memory block / variable
    la $a0, NamePromptStr
    li $v0, 4
    syscall

    # TODO cannot call name q, this will quit flow
    la $a0, NameBuffer
    la $a1, 200                                         # large enough buffer for long names (up to 50 char)
    li $v0, 8
    syscall

    # TODO check name is unique
    # check that name is unique and length > 0
    la $a0, NameBuffer
    li $v0, 0
    jal FindNameLen
    ble $v0, 0, NameLenError
    move $a1, $v0
    addi $a1, 1

    # prompt user for additional memory space to store in memory block / variable
    la $a0, SpacePromptStr
    li $v0, 4
    syscall

    li $v0, 5
    syscall
    move $a2, $v0

    # proceed to main subroutine of malloc implementation
    la $a0, NameBuffer
    j MallocMain

# a0 is name buffer base addr, a1 is name len (accounting for null byte too), a2 is space len
MallocMain:
    # TODO find block with minimum size requirement rather than first suitable one
    # TODO free list should be sorted by len of each block so binary search can be used
    # TODO binary search to find block with enough space
    # TODO block splitting: check free list for large blocks that can be split
    # TODO use binary tree DS for free and malloc list for faster insert/delete of new nodes

    # first find total mem block size based on metadata format
    add $s0, $a1, $a2
    addi $s0, 1                                         # for len byte at start 

    # push mem block size value on the stack
    addi $sp, -4
    sw $s0, ($sp)

    # get base addr of mem block to begin allocating memory
    move $a0, $s0
    jal GetAllocAddr

    # v0 is bp to new mem block
    move $s1, $v0

    # pop mem block size value off the stack
    lw $s0, ($sp)
    addi $sp, 4

    # store len of memory block in first byte
    sb $s0, ($v0)
    addi $v0, 1

    # store name of memory block at incremented addr
    la $a0, NameBuffer
    move $a1, $v0
    jal StoreName

    # print formatted memory block
    la $a0, AllocatedBlockStr
    li $v0, 4
    syscall
    la $a0, OpenBracketStr
    syscall

    # a0 base addr of mem block, a1 size of mem block (from len byte)
    move $a0, $s1
    lb $a1, ($a0)
    jal PrintAllocBlock

    la $a0, BlockAllocatedStr
    li $v0, 4
    syscall

    j MainLoop

# FIXME BIG issue - free and malloc lists will end up with holes when alloc/dealloc occurs and offset from base won't work when loading or storing values - the entire list needs to be adjusted so that addresses after the alloc/dealloc addr need to be moved 1 down to fill the space and to ensure the offset still works
free:
    # first check if heap is empty
    la $a0, ManagedHeapBP
    lw $a0, ($a0)
    la $a1, ManagedHeapNP
    lw $a1, ($a1)
    beq $a0, $a1, HeapEmptyError

    la $a0, AllocatedBlockCountStr
    li $v0, 4
    syscall
    la $a0, MallocListCount
    lb $a0, ($a0)
    li $v0, 1
    syscall

    la $a0, BlockNamesStr
    li $v0, 4
    syscall

    # begin by printing names of variables in memory
    la $a0, ManagedHeapBP
    lw $a0, ($a0)
    la $a1, ManagedHeapNP
    lw $a1, ($a1)
    jal DisplayBlockNames

    # v0 will contain bp addr to mem block to free
    jal FindNameMallocList
    move $a1, $v0

    # place freed mem addr in free list and update free list count
    la $t0, FreeListBP
    lw $t0, ($t0)
    la $t1, FreeListCount
    move $t2, $t1
    lb $t1, ($t1)
    la $t4, FreeListCap
    lb $t4, ($t4)
    move $t3, $t1
    addi $t3, 1
    bge $t3, $t4, FreeListOverflowError
    sll $t1, $t1, 2
    add $t0, $t0, $t1
    sw $a1, ($t0)
    sb $t3, ($t2)

    j MainLoop

# no args, returns addr to malloc list mem block to free in v0
FindNameMallocList:
    la $a0, BlockNamePromptStr
    li $v0, 4
    syscall
    la $a0, UserFreeInputStr
    li $a1, 200
    li $v0, 8
    syscall
    la $a0, UserFreeInputStr
    lb $a0, ($a0)
    beq $a0, 113, MainLoop

    la $a1, UserFreeInputStr
    la $a2, MallocListBP
    lw $a2, ($a2)                                       # points to first addr in arr
    la $a3, MallocListCount
    lb $a3, ($a3)                                       # mutable, decr each addr covered
    j SearchNameMallocList

SearchNameMallocList:
    move $t0, $a1                                       # bp to user free input (immutable)
    lw $t1, ($a2)                                       # addr in malloc list arr at a2 (mutable)
    addi $t1, 1                                         # skip len byte
    j CompareName

CompareName:
    lb $t3, ($t0)                                       # char from user input buffer
    lb $t2, ($t1)                                       # char from malloc
    addi $t0, 1
    addi $t1, 1
    beq $t3, 10, HandleLF                               # either LF found in user input (not null terminated)
    beq $t2, 0, NameNotFoundNextIter                    # or null byte in name
    bne $t2, $t3, NameNotFoundNextIter
    j CompareName

HandleLF:
    beq $t2, 0, FoundName
    j NameNotFoundNextIter

FoundName:
    # remove addr from malloc list and update malloc list count
    li $t0, 0
    sw $t0, ($a2)                                       # clear mem addr
    la $a0, MallocListCount
    lb $t0, ($a0)
    addi $t0, -1
    sb $t0, ($a0)
    move $v0, $a2
    jr $ra

NameNotFoundNextIter:
    addi $a3, -1
    beq $a3, 0, NameNotFound
    addi $a2, 4
    j SearchNameMallocList

NameNotFound:
    la $a0, NameNotFoundErr
    li $v0, 4
    syscall
    j FindNameMallocList

# TODO can probably replace a0 with t0 here throughout, only use it as arg for syscalls
DisplayBlockNames:
    la $a0, MallocListBP
    lw $a0, ($a0)                                       # pointer to malloc list arr
    move $s0, $a0
    lw $a0, ($a0)                                       # pointer to first addr in malloc list arr
    addi $a0, 1                                         # skip len byte
    la $a1, MallocListCount
    lb $a1, ($a1)
    ble $a1, 0, HeapEmptyError
    move $t0, $a0
    j DisplayBlockNameLoop

DisplayBlockNameLoop:
    lb $a0, ($t0)
    li $v0, 11
    syscall
    addi $t0, 1
    lb $a0, ($t0)
    beq $a0, 0, NextBlockName
    j DisplayBlockNameLoop

NextBlockName:
    addi $a1, -1
    ble $a1, 0, FinishDisplayBlockNames
    la $a0, sep
    li $v0, 4
    syscall
    addi $s0, 4
    lw $t0, ($s0)
    addi $t0, 1                                         # skip len byte
    j DisplayBlockNameLoop

FinishDisplayBlockNames:
    la $a0, newline
    li $v0, 4
    syscall
    syscall
    jr $ra

# a0 is new block size
GetAllocAddr:
    la $t0, FreeListCount
    lb $t0, ($t0)
    beq $t0, 0, ManagedHeapAlloc

    la $t1, FreeListBP
    lw $t1, ($t1)
    lw $t1, ($t1)                                       # pointer to first addr in free list
    j SearchFreeList

# TODO not complete
SearchFreeList:
    lb $a0, ($t1)
    li $v0, 1
    syscall
    j end

# a0 is new block size
ManagedHeapAlloc:
    # first check there is enough space in the heap
    la $t0, ManagedHeapBP
    lw $t0, ($t0)
    la $t1, ManagedHeapNP
    move $s0, $t1
    lw $t1, ($t1)
    la $t2, ManagedHeapCap
    lw $t2, ($t2)

    # max addr in managed heap in bytes
    add $t0, $t0, $t2

    # addr for last byte in managed heap if allocated
    add $t3, $t1, $a0
    addi $t3, -1

    # TODO instead of err, should dynamically resize heap
    bgt $t3, $t0, HeapOverflowError

    # store updated np (given no heap overflow)
    addi $t3, 1
    sw $t3, ($s0)

    # create new node in malloc list
    la $a0, 8
    li $v0, 9
    syscall
    move $a1, $v0

    # check if malloc list is empty, if it is, set head and tail node, else new tail node
    la $t0, MallocListCount
    lb $t0, ($t0)
    move $a0, $t1
    beq $t0, 0, CreateFirstMallocNode
    j CreateMallocTailNode

# a0 is mem block base pointer, a1 is pointer to the new node in malloc list
CreateFirstMallocNode:
    # set first 4 bytes for cur addr of mem block
    sw $a0, ($a1)

    # set next 4 bytes for next node addr (which is same because head and tail node same for first node)
    sw $a1, 4($a1)

    # return mem block base pointer for storing data
    move $v0, $a0

    # store node pointer in head pointer
    la $a0, MallocListHeadPointer
    sw $a1, ($a0)

    # store node pointer in tail pointer (same since first node)
    la $a0, MallocListTailPointer
    sw $a1, ($a0)

    # update malloc list count (exactly 1)
    la $a0, MallocListCount
    li $t0, 1
    sw $t0, ($a0)

    jr $ra

# a0 is mem block base pointer, a1 is pointer to the new node in malloc list
CreateMallocTailNode:
    # set mem block pointer in new node
    sw $a0, 0($a1)

    # get address to cur tail node
    la $t0, MallocListTailPointer
    lw $t1, ($t0)

    # set next pointer in prev tail node to new node pointer
    sw $a1, 4($t1)

    # set global tail node pointer to new node
    sw $a1, ($t0)

    # return mem block pointer for storing data
    move $v0, $a0

    # update malloc list count
    la $t0, MallocListCount
    lb $a0, ($t0)
    addi $a0, 1
    sb $a0, ($t0)

    jr $ra

# a0 is base addr of name buffer, a1 is addr for alloc
StoreName:
    lb $t0, ($a0)
    sb $t0, ($a1)
    addi $a0, 1
    addi $a1, 1
    lb $t0, ($a0)                                       # checking next val
    bne $t0, 10, StoreName                              # keep storing until line feed encountered

    li $t0, 0                                           # null termination of ascii str
    lb $t0, ($a1)
    jr $ra

# a0 is base addr for name buffer, v0 is len returned
FindNameLen:
    # lb until line feed (10)
    lb $t0, ($a0)
    addi $v0, 1
    addi $a0, 1
    bne $t0, 10, FindNameLen
    addi $v0, -1
    jr $ra

DisplayHeap:
    ###
    la $t0, MallocListHeadPointer
    lw $t0, ($t0)
    lw $t0, ($t0)
    lb $a0, ($t0)
    li $v0, 1
    syscall
    addi $t0, 1
    lb $a0, ($t0)
    li $v0, 11
    syscall
    addi $t0, 1
    lb $a0, ($t0)
    li $v0, 11
    syscall
    addi $t0, 1
    lb $a0, ($t0)
    li $v0, 11
    syscall
    addi $t0, 1
    lb $a0, ($t0)
    li $v0, 1
    syscall
    addi $t0, 1
    lb $a0, ($t0)
    li $v0, 1
    syscall

    la $t0, MallocListHeadPointer
    lw $t0, ($t0)
    lw $t0, 4($t0)
    lw $t0, ($t0)
    lb $a0, ($t0)
    li $v0, 1
    syscall
    addi $t0, 1
    lb $a0, ($t0)
    li $v0, 11
    syscall
    addi $t0, 1
    lb $a0, ($t0)
    li $v0, 11
    syscall

    la $a0, MallocListCount
    lb $a0, ($a0)
    li $v0, 1
    syscall
    j end
    ###

    la $a0, MallocListBP
    lw $a0, ($a0)
    move $s0, $a0
    lw $a0, ($a0)                                       # pointer to the actual malloc list arr
    la $a1, MallocListCount
    lb $a1, ($a1)
    li $a2, 0

    # if malloc list count > 0, then display heap, else heap is empty
    beq $a1, 0, HeapEmptyError
    blt $a1, 0, MallocListCountError
    jal DisplayHeapLoop

    la $a0, newline
    li $v0, 4
    syscall
    j MainLoop

DisplayHeapLoop:
    move $t0, $a0

    # check if all blocks have been displayed
    bge $a2, $a1, FinishHeapBlockDisplay

    la $a0, OpenBracketStr
    li $v0, 4
    syscall

    # save len, print len, decr len
    lb $a0, ($t0)
    li $v0, 1
    syscall
    move $t1, $a0

    la $a0, sep
    li $v0, 4
    syscall

    addi $t1, -1
    addi $t0, 1
    j PrintHeapBlockName

PrintHeapBlockName:
    lb $a0, ($t0)
    li $v0, 11
    syscall
    addi $t1, -1
    addi $t0, 1
    lb $a0, ($t0)
    bne $a0, 0, PrintHeapBlockName
    addi $t0, 1
    addi $t1, -1
    ble $t1, 0, FinishHeapBlockDisplay
    la $a0, sep
    li $v0, 4
    syscall
    j PrintHeapBlockSpace

PrintHeapBlockSpace:
    lb $a0, ($t0)
    li $v0, 1
    syscall
    addi $t0, 1
    addi $t1, -1
    ble $t1, 0, FinishHeapBlockDisplay
    j PrintHeapBlockSpace

FinishHeapBlockDisplay:
    la $a0, ClosedBracketStr
    li $v0, 4
    syscall

    addi $a2, 1
    addi $s0, 4
    lw $a0, ($s0)
    blt $a2, $a1, DisplayHeapLoop
    jr $ra

# a0 is base addr of new mem block, a1 is size of new mem block
PrintAllocBlock:
    move $t0, $a0
    lb $a0, ($a0)
    li $v0, 1
    syscall
    addi $t0, 1
    addi $a1, -1
    bgt $a1, 0, PrintSepA
    la $a0, ClosedBracketStr
    li $v0, 4
    syscall
    la $a0, newline
    li $v0, 4
    syscall
    jr $ra

PrintSepA:
    la $a0, sep
    li $v0, 4
    syscall
    move $a0, $t0
    j PrintAllocBlock

# a0 is base addr of malloc block, a1 is malloc block count
PrintMallocList:
    move $t0, $a0
    lw $a0, ($a0)
    li $v0, 1
    syscall
    addi $t0, 4
    addi $a1, -1
    bgt $a1, 0, PrintSepB
    la $a0, newline
    li $v0, 4
    syscall
    jr $ra

PrintSepB:
    la $a0, sep
    li $v0, 4
    syscall
    move $a0, $t0
    j PrintMallocList

HeapEmptyError:
    la $a0, HeapEmptyErr
    li $v0, 4
    syscall
    j MainLoop

MallocListCountError:
    la $a0, MallocListCountErr
    li $v0, 4
    syscall
    j end

HeapOverflowError:
    la $a0, HeapOverflowErr
    li $v0, 4
    syscall
    j end

MallocListOverflowError:
    la $a0, MallocListOverflowErr
    li $v0, 4
    syscall
    j end

FreeListOverflowError:
    la $a0, FreeListOverflowErr
    li $v0, 4
    syscall
    j end

NameLenError:
    la $a0, NameLenErr
    li $v0, 4
    syscall
    j MainLoop

NameNotUniqueError:
    la $a0, NameNotUniqueErr
    li $v0, 4
    syscall

    j end

end:
    li $v0, 10
    syscall