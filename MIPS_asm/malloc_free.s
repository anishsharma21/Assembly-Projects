.data

NameBuffer: .space 200
CurMallocListAddr: .byte 0
CurFreeListAddr: .byte 0

IntroStr: .asciiz "############################################\n#                                          #\n#    Welcome to the malloc/free program    #\n#                                          #\n############################################\n\nThis program has been written in MIPS assembly and involves the allocation and deallocation of memory. You will be prompted to either malloc or free data during the program.\n\nLet's start by allocating a variable.\n"
NamePromptStr: .asciiz "Pick a name for the variable: "
SpacePromptStr: .asciiz "How much space do you want to store: "
MallocSuccessStr: .asciiz " was allocated at "

MallocErr: .asciiz "\nMemory allocation error occurred!\n"
NameLenErr: .asciiz "\nName must be at least 1 char long\n"

newline: .asciiz "\n"
sep: .asciiz ", "

.text
.globl main
.globl malloc

main:
    # create malloc-list
    li $a0, 5                                           # space for 5 bytes (addresses)
    li $v0, 9
    syscall
    la $a0, CurMallocListAddr
    sb $v0, ($a0)

    # create free-list
    li $a0, 5
    li $v0, 9
    syscall
    la $a0, CurFreeListAddr
    sb $v0, ($a0)

    la $a0, IntroStr
    li $v0, 4
    syscall

    # TODO name len check should happen right after allocation
    # TODO name must be unique
    la $a0, NamePromptStr
    syscall

    la $a0, NameBuffer
    la $a1, 200                                         # large enough buffer for long names (up to 50 char)
    li $v0, 8
    syscall

    la $a0, SpacePromptStr
    li $v0, 4
    syscall

    li $v0, 5
    syscall

    la $a0, NameBuffer
    move $a1, $v0                                       # space val
    j malloc

    j end

malloc:
    # find length of name
    move $s0, $a0
    li $v0, 0
    jal FindNameLen
    move $a0, $s0
    ble $v0, 0, NameLenError

    move $a0, $v0
    li $v0, 1
    syscall

    j end

FindNameLen:
    # lb until line feed (10)
    lb $t0, ($a0)
    addi $v0, 1
    addi $a0, 1
    bne $t0, 10, FindNameLen
    addi $v0, -1
    jr $ra

NameLenError:
    la $a0, NameLenErr
    li $v0, 4
    syscall

    # TODO jumps to alloc loop, only temp going to end
    j end

end:
    li $v0, 10
    syscall

#################################################################################################################
# NOTE THIS IS IMPORTANT: you can do block coalescing, movement, defragmentation, etc, if you just start by allocating a chunk of space in the heap, and then manually moving and assiging each and every block in that area, i.e. you only need to make the sbrk syscall once! THIS IS SUPER CRUCIAL - this would be a true memory manager, a truly malloc/free implementation - first implementation will be simpler though, this is much tougher

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
