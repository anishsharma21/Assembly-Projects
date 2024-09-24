.data

IntroStr: .asciiz "############################################\n#                                          #\n#    Welcome to the malloc/free program    #\n#                                          #\n############################################\n\nThis program has been written in MIPS assembly and involves the allocation and deallocation of memory. You will be prompted to either malloc or free data during the program.\n\nLet's start by allocating a variable.\n"
NamePromptStr: .asciiz "Pick a name for the variable: "
SpacePromptStr: .asciiz "How much space do you want to store: "
MallocSuccessStr: .asciiz " was allocated at "

MallocErr: .asciiz "Memory allocation error occurred!"

newline: .asciiz "\n"
sep: .asciiz ", "

.text

main:
    la $a0, IntroStr
    li $v0, 4
    syscall

    la $a0, NamePromptStr
    syscall

    j end

end:
    li $v0, 10
    syscall

#################################################################################################################

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
