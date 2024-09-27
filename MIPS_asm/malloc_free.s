.data

.align 2
ManagedHeapBP: .space 4
ManagedHeapNP: .space 4
ManagedHeapCap: .word 1024

.align 2
MallocListBP: .space 4
MallocListCount: .byte 0
MallocListCap: .word 4

.align 2
FreeListBP: .space 4
FreeListCount: .byte 0
FreeListCap: .word 4

NameBuffer: .space 200
ChoiceBuffer: .space 4

IntroStr: .asciiz "############################################\n#                                          #\n#    Welcome to the malloc/free program    #\n#                                          #\n############################################\n\nThis program has been written in MIPS assembly and involves the allocation and deallocation of memory. You will be prompted to either malloc or free data during the program.\n\nLet's start by allocating a variable.\n"
NamePromptStr: .asciiz "Pick a name for the variable: "
SpacePromptStr: .asciiz "How much space do you want to store: "
MallocSuccessStr: .asciiz " was allocated at "
AllocatedBlockStr: .asciiz "\nMemory block allocated: "
BlockAllocatedStr: .asciiz "\n### You've allocated a block of memory! ###\n"
ChoiceStr: .asciiz "\nNow, would you like to allocate (a) or free (f) memory?"
ChoicePromptStr: .asciiz "\nChoice: "
OpenBracketStr: .asciiz "["
ClosedBracketStr: .asciiz "]"

MallocErr: .asciiz "\nMemory allocation error occurred!\n"
NameLenErr: .asciiz "\nName must be at least 1 char long\n"
NameNotUniqueErr: .asciiz "\nChoose a unique name\n"
HeapOverflowErr: .asciiz "\nManaged heap is full\n"
ChoiceErr: .asciiz "\nInvalid choice. Choose from a, f, or q.\n"

newline: .asciiz "\n"
sep: .asciiz ", "

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
    # block allocated or memory freed str loaded in before calling main_loop
    li $v0, 4
    syscall

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
    # beq $a0, 102, free
    beq $a0, 113, end

    la $a0, ChoiceErr
    li $v0, 4
    syscall
    j main_loop

malloc:
    la $a0, NamePromptStr
    li $v0, 4
    syscall

    la $a0, NameBuffer
    la $a1, 200                                         # large enough buffer for long names (up to 50 char)
    li $v0, 8
    syscall

    la $a0, NameBuffer
    li $v0, 0
    jal FindNameLen
    ble $v0, 0, NameLenError
    move $a1, $v0
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
    # TODO also store space, cur assuming that additional space mem is default

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
    j main_loop

free:
    # TODO implement

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
    jr $ra

# TODO subroutine for printing memory space up until next pointer in managed heap

# TODO if a1 is large, should print first 5, then ..., then last 5
# a0 is base addr of new mem block, a1 is size of new mem block
PrintAllocBlock:
    move $t0, $a0
    lb $a0, ($a0)
    li $v0, 1
    syscall
    addi $t0, 1
    addi $a1, -1
    bgt $a1, 0, PrintSep
    la $a0, ClosedBracketStr
    li $v0, 4
    syscall
    la $a0, newline
    li $v0, 4
    syscall
    jr $ra

PrintSep:
    la $a0, sep
    li $v0, 4
    syscall
    move $a0, $t0
    j PrintAllocBlock

HeapOverflowError:
    la $a0, HeapOverflowErr
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

    # TODO prints malloc list to show options, then jumps to main choices
    j end

end:
    li $v0, 10
    syscall

#################################################################################################################
# NOTE we will be using a managed heap for memory allocation of blocks, so no dynamic allocation of memory blocks using sbrk, all variable address pointers are to positions on the heap so that block coalescing and defragmentation can be implemented too

# thinking through my implementation here:
# - user types in name for variable, then they enter integer for number of bytes of space for it - keeping things super simple to start with
# - initially, simple sbrk syscall, allocate space, store size meta data too (for now), and the name of the variable itself (which also acts as its value) - memory allocation is a byte for the length of the memory block, followed by ascii encoding of the variable name, and then finally the additional space as specified in bytes
# - then, returned address is a pointer to this newly allocate memory space - this needs to be stored in a dynamically allocated array (no point in storing it statically because resizing will be necessary - and also, when values arr copied into a separate array when resizing, the previous memory space can be used for other data items too)
# - then, the user can choose between allocating or freeing from the second step onwards
# - if the user chooses to free, they are presented with the names of all the variables they can choose to free, then, the user input is matched to one of the variables, if there is no match then the loop repeats for allocation or freeing, otherwise, the memory manager sets the address to free and returns the length of that array too. NOTE these are then kept in a separate array for saved memory spaces - useful for future use
# - when deallocation occurs, the pointer and length are stored in another memory reuse arr and can then be checked when making future allocations - the logic is to go through this array and find the first pointer to an address with sufficient space

# Future:
# - Sort the memory reuse arr so that we can use binary search to find the ideal length in O(logn) time
# - Instead of searching the allocated-list for the names that match the inputted variable name for freeing, we should keep a hash potentially of each value that is stored in a byte
