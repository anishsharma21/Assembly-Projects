.data

.align 2
ManagedHeapBP: .space 4
ManagedHeapNP: .space 4
ManagedHeapCap: .byte 1024

.align 2
MallocListBP: .space 4
MallocListCount: .byte 0
MallocListCap: .byte 4

.align 2
FreeListBP: .space 4
FreeListCount: .byte 0
FreeListCap: .byte 4

NameBuffer: .space 200

IntroStr: .asciiz "############################################\n#                                          #\n#    Welcome to the malloc/free program    #\n#                                          #\n############################################\n\nThis program has been written in MIPS assembly and involves the allocation and deallocation of memory. You will be prompted to either malloc or free data during the program.\n\nLet's start by allocating a variable.\n"
NamePromptStr: .asciiz "Pick a name for the variable: "
SpacePromptStr: .asciiz "How much space do you want to store: "
MallocSuccessStr: .asciiz " was allocated at "

MallocErr: .asciiz "\nMemory allocation error occurred!\n"
NameLenErr: .asciiz "\nName must be at least 1 char long\n"
NameNotUniqueErr: .asciiz "\nChoose a unique name\n"
ManagedHeapCapacityErr: .asciiz "\nManaged heap is full\n"

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

    la $a0, NamePromptStr
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
    # TODO name must be unique check
    # la $a0, NameBuffer
    # jal UniqueNameCheck
    # beq $v0, 0, NameNotUniqueError

    la $a0, SpacePromptStr
    li $v0, 4
    syscall

    li $v0, 5
    syscall
    move $a2, $v0

    la $a0, NameBuffer
    j malloc

# a0 is name buffer, a1 is name len, a2 is space len
malloc:
    # first find total mem block size based on metadata format
    add $t0, $a1, $a2
    addi $t0, 1

    # TODO find block with minimum size requirement rather than first suitable one
    # TODO free list should be sorted by len of each block so binary search can be used
    # TODO binary search to find block with enough space
    # TODO block splitting: check free list for large blocks that can be split
    # TODO use binary tree DS for free and malloc list for faster insert/delete of new nodes
    # go through malloc list until first suitable block found 
    # if no suitable block found, alloc in managed heap using next pointer, update next pointer
    move $s0, $a0
    move $a0, $t0
    jal GetAllocAddr
    move $a0, $s0

    j end

GetAllocAddr:
    la $t0, FreeListCount
    lb $t0, ($t0)
    beq $t0, 0, ManagedHeapAlloc
    la $t0, FreeListBP
    lw $t0, ($t0)

    # TODO complete this subroutine
    j end

ManagedHeapAlloc:
    la $t0, ManagedHeapNP
    lw $t0, ($t0)
    la $t1, ManagedHeapCap
    lb $t1, ($t1)

    add $t0, $t0, $a0
    # TODO this has a bug, suitable allocation is still erroring
    bge $t0, $t1, ManagedHeapCapacityError

    # TODO return addr for managed heap alloc
    j end

FindNameLen:
    # lb until line feed (10)
    lb $t0, ($a0)
    addi $v0, 1
    addi $a0, 1
    bne $t0, 10, FindNameLen
    # TODO include null terminating byte/s
    addi $v0, -1
    jr $ra

# UniqueNameCheck:

ManagedHeapCapacityError:
    la $a0, ManagedHeapCapacityErr
    li $v0, 4
    syscall

    j end

NameLenError:
    la $a0, NameLenErr
    li $v0, 4
    syscall

    # TODO jumps to choice loop, only temp going to end
    j end

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
