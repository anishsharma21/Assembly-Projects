.data

.align 2
ManagedHeapBP: .space 4
ManagedHeapNP: .space 4
ManagedHeapCap: .word 1024

.align 2
MallocListBP: .space 4
MallocListCount: .byte 0
MallocListCap: .byte 4

.align 2
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

main:
    # allocate mem for managed heap
    li $a0, 1024                                        # 1024 bytes of space in managed heap
    li $v0, 9
    syscall
    la $a0, ManagedHeapBP                               # base pointer for managed heap
    sw $v0, ($a0)
    la $a0, ManagedHeapNP                               # next pointer for managed heap
    sw $v0, ($a0)

    # allocate mem for malloc-list
    li $a0, 16                                          # space for 4 malloc addresses
    li $v0, 9
    syscall
    la $a0, MallocListBP
    sw $v0, ($a0)

    # allocate mem for free-list
    li $a0, 16                                          # space for 4 free addresses
    li $v0, 9
    syscall
    la $a0, FreeListBP
    sw $v0, ($a0)

    la $a0, IntroStr
    li $v0, 4
    syscall

    j malloc

main_loop:
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
    j main_loop

malloc:
    la $a0, NamePromptStr
    li $v0, 4
    syscall

    # TODO cannot call name q
    la $a0, NameBuffer
    la $a1, 200                                         # large enough buffer for long names (up to 50 char)
    li $v0, 8
    syscall

    la $a0, NameBuffer
    li $v0, 0
    jal FindNameLen
    ble $v0, 0, NameLenError
    move $a1, $v0
    addi $a1, 1
    # TODO check that name is unique

    la $a0, SpacePromptStr
    li $v0, 4
    syscall

    li $v0, 5
    syscall
    move $a2, $v0

    la $a0, NameBuffer
    j malloc_main

# a0 is name buffer base addr, a1 is name len (accounting for null byte too), a2 is space len
malloc_main:
    # TODO find block with minimum size requirement rather than first suitable one
    # TODO free list should be sorted by len of each block so binary search can be used
    # TODO binary search to find block with enough space
    # TODO block splitting: check free list for large blocks that can be split
    # TODO use binary tree DS for free and malloc list for faster insert/delete of new nodes

    # first find total mem block size based on metadata format
    li $t0, 0
    add $t0, $a1, $a2
    addi $t0, 1                                         # for len byte at start 
    addi $sp, -4
    sw $t0, ($sp)
    move $a0, $t0                                       # a0 block size as arg
    jal GetAllocAddr
    lw $t0, ($sp)
    addi $sp, 4
    move $s1, $v0                                       # v0 is returned addr in heap to alloc

    # update heap next-pointer
    add $t1, $t0, $v0                                   # add returned addr and block size
    la $t2, ManagedHeapNP
    sw $t1, ($t2)                                       # store updated managed heap next pointer

    # begin alloc at return addr
    sb $t0, ($v0)                                       # store len in first byte
    addi $v0, 1
    la $a0, NameBuffer
    move $a1, $v0
    jal StoreName

    la $a0, AllocatedBlockStr
    li $v0, 4
    syscall

    la $a0, OpenBracketStr
    li $v0, 4
    syscall
    move $a0, $s1
    lb $a1, ($a0)
    jal PrintAllocBlock

    la $a0, BlockAllocatedStr
    li $v0, 4
    syscall

    j main_loop

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

    j main_loop

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
    beq $a0, 113, main_loop

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

    la $t0, FreeListBP
    lw $t0, ($t0)

    # TODO complete this subroutine using free list
    j end

# a0 is new block size
ManagedHeapAlloc:
    la $t0, ManagedHeapBP
    lw $t0, ($t0)
    la $t1, ManagedHeapNP
    lw $t1, ($t1)
    la $t2, ManagedHeapCap
    lw $t2, ($t2)

    # max addr in managed heap in bytes
    add $t0, $t0, $t2

    # addr for last byte in managed heap if allocated
    add $t3, $t1, $a0
    addi $t3, -1                                        # 0 based idxing

    # TODO instead of err, should dynamically resize heap
    bgt $t3, $t0, HeapOverflowError

    # store malloc addr in the malloc list
    la $a0, MallocListBP
    lw $a0, ($a0)                                       # pointer to pointer
    la $a1, MallocListCount
    move $t2, $a1                                       # malloc list count addr
    lb $a1, ($a1)
    la $a2, MallocListCap
    lb $a2, ($a2)

    move $t0, $a1
    addi $t0, 1
    sb $t0, ($t2)
    bgt $t0, $a2, MallocListOverflowError
    sll $a1, $a1, 2
    add $a0, $a0, $a1
    sw $t1, ($a0)
    move $v0, $t1
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
    # TODO complete this subroutine - using the malloc list to print the memory blocks in the right format
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
    j main_loop

# TODO when first mem block displayed, get the next one from the malloc list arr, requires refactoring, think through it carefully
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
    j main_loop

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
    j main_loop

NameNotUniqueError:
    la $a0, NameNotUniqueErr
    li $v0, 4
    syscall

    j end

end:
    li $v0, 10
    syscall
