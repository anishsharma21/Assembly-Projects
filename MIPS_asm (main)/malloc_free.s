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
UserFreeInputBuffer: .space 200

IntroStr: .asciiz "############################################\n#                                          #\n#    Welcome to the malloc/free program    #\n#                                          #\n############################################\n\nThis program has been written in MIPS assembly and involves the allocation and deallocation of memory. You will be prompted to either malloc or free data during the program.\n\nLet's start by allocating a variable.\n"
NamePromptStr: .asciiz "\nPick a name for the variable: "
SpacePromptStr: .asciiz "How much space do you want to store: "
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
HeapEmptyErr: .asciiz "\nHeap is empty\n"
ChoiceErr: .asciiz "\nInvalid choice. Choose from a, f, d or q.\n"
NoAllocationErr: .asciiz "\nNothing to free\n"
MallocListCountErr: .asciiz "\nNegative malloc list count encountered."
NameNotFoundErr: .asciiz "\nName not found.\nTry again.\n\n"

newline: .asciiz "\n"
sep: .asciiz ", "
space: .asciiz " "

.text
.globl main

main:
    # entry point to program
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

    # intro str printed only at start of program
    la $a0, IntroStr
    li $v0, 4
    syscall

    # initiate memory allocation flow immediately
    j malloc

MainLoop:
    # prompting user for a choice (1 char)
    li $v0, 4
    la $a0, ChoiceStr
    syscall
    la $a0, ChoicePromptStr
    syscall

    # store user choice in buffer
    la $a0, ChoiceBuffer
    li $a1, 4
    li $v0, 8
    syscall

    # switch-case for users choice
    la $a0, ChoiceBuffer
    lb $a0, ($a0)
    beq $a0, 97, malloc
    beq $a0, 102, free
    beq $a0, 100, DisplayHeap
    beq $a0, 113, end

    # if not from options, retry main loop logic
    la $a0, ChoiceErr
    li $v0, 4
    syscall
    j MainLoop


######################### MALLOC #########################

.globl malloc
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

    # read integer for additional space
    li $v0, 5
    syscall
    move $a2, $v0

    # proceed to main subroutine of malloc implementation
    la $a0, NameBuffer
    j MallocMain

# a0 is base addr for name buffer, v0 is len returned
FindNameLen:
    # load byte and incr pointer and len count
    lb $t0, ($a0)
    addi $v0, 1
    addi $a0, 1

    # if line feed not encountered, continue with subroutine
    bne $t0, 10, FindNameLen

    # else decr count by 1 (went over by 1) and return back to malloc
    addi $v0, -1
    jr $ra

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

    # print success for block alloc
    la $a0, BlockAllocatedStr
    li $v0, 4
    syscall

    j MainLoop

# a0 is new block size
GetAllocAddr:
    # check if we can allocate to free list node before heap alloc
    la $t0, FreeListCount
    lb $t0, ($t0)
    beq $t0, 0, ManagedHeapAlloc

    # TODO using the free list linked list pointers instead
    la $t1, FreeListBP
    lw $t1, ($t1)
    lw $t1, ($t1)                                       # pointer to first addr in free list
    j SearchFreeList

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

# TODO not complete
SearchFreeList:
    lb $a0, ($t1)
    li $v0, 1
    syscall
    j end

# a0 is base addr of name buffer, a1 is addr for alloc
StoreName:
    # load in byte (char) from name buffer and store in alloc space
    lb $t0, ($a0)
    sb $t0, ($a1)

    # incr buffer and alloc pointers
    addi $a0, 1
    addi $a1, 1

    # check if line feed encountered, if not, continue copying
    lb $t0, ($a0)
    bne $t0, 10, StoreName

    # null terminate the string and return to MallocMain
    li $t0, 0
    sb $t0, ($a1)
    jr $ra

# a0 is base addr of new mem block, a1 is size of new mem block
PrintAllocBlock:
    # save base of mem block in temp since a0 will be overwritten
    move $t0, $a0

    # load in byte at cur mem block pointer and print int
    lb $a0, ($a0)
    li $v0, 1
    syscall

    # incr pointer, decr size of block (for len check)
    addi $t0, 1
    addi $a1, -1

    # if not last byte, print sep
    bgt $a1, 0, PrintSepAllocBlock

    # else last byte printed, no sep, just closed bracket, newline
    la $a0, ClosedBracketStr
    li $v0, 4
    syscall
    la $a0, newline
    li $v0, 4
    syscall

    # return to MallocMain
    jr $ra

PrintSepAllocBlock:
    # load in sep str and print it
    la $a0, sep
    li $v0, 4
    syscall

    # a0 has been overwritten entire time, move cur mem block pointer into it for next iter
    move $a0, $t0
    j PrintAllocBlock


######################### FREE #########################

# FIXME BIG issue - free and malloc lists will end up with holes when alloc/dealloc occurs and offset from base won't work when loading or storing values - the entire list needs to be adjusted so that addresses after the alloc/dealloc addr need to be moved 1 down to fill the space and to ensure the offset still works
.globl free
free:
    # first check if malloc list is empty (no mem blocks alloc)
    la $t0, MallocListCount
    lb $t0, ($t0)
    beq $t0, 0, NoAllocationError

    # begin by showing how many mem blocks have been allocated in heap
    la $a0, AllocatedBlockCountStr
    li $v0, 4
    syscall
    la $t0, MallocListCount
    lb $a0, ($t0)
    li $v0, 1
    syscall

    # str for prefixing block names, displayed for user to choose from
    la $a0, BlockNamesStr
    li $v0, 4
    syscall

    # print names of all currently allocated blocks, user can choose which to free
    la $a0, MallocListHeadPointer
    lw $a0, ($a0)
    la $a1, MallocListCount
    lb $a1, ($a1)
    jal DisplayBlockNames

    # v0 will contain bp addr to mem block to free
    jal FindNameMallocList

    # TODO remove node from malloc list and decr count
    move $a0, $v0
    jal RemoveMallocNode

    # TODO add node to tail of free list and incr count

    j MainLoop

# a0 is cur node bp, a1 is total node count
DisplayBlockNames:
    # save cur node bp to access np later, a0 will be overwritten
    move $s0, $a0

    # load addr to mem block from cur node bp
    lw $t0, ($a0)

    # skip len byte and begin displaying name in next subroutine
    addi $t0, 1
    j DisplayBlockNameLoop

# t0 is pointer to byte of interest in mem block
DisplayBlockNameLoop:
    # load and print first byte/char of name string
    lb $a0, ($t0)
    li $v0, 11
    syscall

    # check if next byte is not null, then continue printing char in name
    addi $t0, 1
    lb $a0, ($t0)
    bne $a0, 0, DisplayBlockNameLoop

    # else j to subroutine for next name (if exists)
    j NextBlockName

# a1 is total node count (mut), s0 is saved cur node bp
NextBlockName:
    # decr block count, if 0, all block names printed
    addi $a1, -1
    ble $a1, 0, FinishDisplayBlockNames

    # print sep since next block name still exists
    la $a0, sep
    li $v0, 4
    syscall

    # load in next pointer from saved cur node bp
    lw $a0, 4($s0)

    # cont by printing next block name
    j DisplayBlockNames

FinishDisplayBlockNames:
    # print newline then return to free
    la $a0, newline
    li $v0, 4
    syscall
    jr $ra

# no args, v0 contains bp to node which should be freed
FindNameMallocList:
    # prompt user to type name of block to free
    la $a0, BlockNamePromptStr
    li $v0, 4
    syscall

    # buffer for user input (up to 50 chars)
    la $a0, UserFreeInputBuffer
    li $a1, 200
    li $v0, 8
    syscall

    # first check if q is entered (then exit)
    la $t0, UserFreeInputBuffer
    lb $a0, ($t0)
    beq $a0, 113, MainLoop

    # setup for finding name in malloc list
    la $a0, UserFreeInputBuffer
    la $a1, MallocListHeadPointer
    lw $a1, ($a1)
    la $a2, MallocListCount
    lb $a2, ($a2)
    j SearchNameMallocList

# a0 is constant bp to input buff, a1 is bp to cur node, a2 is malloc count (mut)
SearchNameMallocList:
    # load in bp to mem block, skip len byte
    lw $t0, ($a1)
    addi $t0, 1

    # copy input buff bp
    move $t1, $a0
    j CompareName

# t0 bp to mem block, t1 bp to buffer
CompareName:
    # load in mem block byte, then buffer byte
    lb $t2, ($t0)
    lb $t3, ($t1)

    # incr each pointer to prepare for next iter
    addi $t0, 1
    addi $t1, 1

    # check if line feed encountered for buffer
    beq $t3, 10, HandleLF

    # if bytes equal, continue comparing name
    beq $t2, $t3, CompareName

    # if not end of name, and bytes not equal, can't be same name, check next block
    j NameNotFoundNextBlock

# t2 is cur byte of mem block
HandleLF:
    # if block byte null, then names are same
    beq $t2, 0, FoundName

    # otherwise, try next block
    j NameNotFoundNextBlock

# a1 is bp to cur node to be freed and returned
FoundName:
    move $v0, $a1
    jr $ra

# a1 is bp to cur node, a2 is malloc list count
NameNotFoundNextBlock:
    # decr malloc list count, if <= 0, no more blocks, name not found
    addi $a2, -1
    ble $a2, 0, NameNotFound

    # set a1 to bp of next node
    lw $a1, 4($a1)
    j SearchNameMallocList

NameNotFound:
    # print err and return to prompt user for name again
    la $a0, NameNotFoundErr
    li $v0, 4
    syscall
    j FindNameMallocList

# a0 is bp to node that needs to be removed
RemoveMallocNode:
    # check if node is head pointer and remove separately if so
    la $t0, MallocListHeadPointer
    lw $t0, ($t0)
    beq $t0, $a0, RemoveMallocHeadNode

    # check if node is tail pointer and remove separately if so
    la $t0, MallocListTailPointer
    lw $t0, ($t0)
    beq $t0, $a0, RemoveMallocTailNode

    # not head or tail pointer, so must be in-between node
    # using 2 pointer method, one to head, one to next, keep incr until a0 pointer reached
    la $t0, MallocListHeadPointer
    lw $t0, ($t0)
    lw $t1, 4($t0)
    la $a1, MallocListCount
    lb $a1, ($a1)
    j FindMiddleNode

# a0 is bp to node to remove (head node)
RemoveMallocHeadNode:
    # get bp to next node after head node
    lw $t0, 4($t0)

    # store it as the new head
    la $t1, MallocListHeadPointer
    sw $t0, ($t1)

    # return with bp to removed malloc node, will be added to free list next
    move $v0, $a0
    jr $ra

# a0 is target node pointer, a1 is malloc list count, t0 is slow node pointer, t1 is fast node pointer
FindMiddleNode:
    # check if fast pointer is the target pointer to remove from malloc list
    beq $t1, $a0, MiddleNodePointerFound

    # malloc count must be > 3 at start since target can't be head or tail pointer to get to this subroutine
    # since we are always checking next pointer, we initially skip head pointer
    # hence why we check if list count is <=1
    ble $a1, 1, MallocNodeNotFound

    # set slow node bp to fast node bp (which is just next bp)
    lw $t0, 4($t0)

    # set fast node bp to it's next bp
    lw $t1, 4($t1)

    # decr malloc list count check and try finding middle node again
    addi $a1, -1
    j FindMiddleNode

######################### DISPLAY #########################

DisplayHeap:
    # check that count is > 0
    la $t0, MallocListCount
    lb $t0, ($t0)
    beq $t0, 0, HeapEmptyError
    blt $t0, 0, MallocListCountError

    # print memory str
    la $a0, MemoryStr
    li $v0, 4
    syscall

    # load in args for displaying heap
    la $a0, MallocListHeadPointer
    lw $a0, ($a0)
    move $a1, $t0
    li $a2, 0
    jal DisplayHeapLoop

    # newline before returning to main loop
    la $a0, newline
    li $v0, 4
    syscall
    j MainLoop

# a0 contains base pointer to current node, a1 is node count, a2 is node idx
DisplayHeapLoop:
    # save node addr in temp bc a0 will be overwritten
    move $t0, $a0

    # save node addr in save reg to access next pointer at the end of mem block display
    move $s0, $a0

    # check if all blocks have been displayed
    ble $a1, 0, FinishHeapBlockDisplay

    # print open bracket for display formatting
    la $a0, OpenBracketStr
    li $v0, 4
    syscall

    # dereference node base pointer -> get base pointer to mem block
    lw $t0, ($t0)

    # load and print len byte from mem block
    lb $a0, ($t0)
    li $v0, 1
    syscall

    # use t1 for checking end of mem block, decr after printing first byte (len byte)
    move $t1, $a0
    addi $t1, -1

    # print sep between len and next mem block section (string name)
    la $a0, sep
    li $v0, 4
    syscall

    # incr node addr pointer to start of string name
    addi $t0, 1
    j PrintHeapBlockName

# t0 addr pointer for mem block (mut), t1 len check of mem block (mut)
PrintHeapBlockName:
    # print char (byte)
    lb $a0, ($t0)
    li $v0, 11
    syscall

    # decr len check, incr to next byte in mem block
    addi $t1, -1
    addi $t0, 1

    # load next byte, if not null, continue printing string name
    lb $a0, ($t0)
    bne $a0, 0, PrintHeapBlockName

    # if null byte, name finished, cont with space display
    # skipping null byte print, go to first space byte
    addi $t0, 1
    addi $t1, -1

    # space alloc might be 0, so block might be finished
    ble $t1, 0, FinishHeapBlockDisplay

    # sep between string name and next section, space display
    la $a0, sep
    li $v0, 4
    syscall
    j PrintHeapBlockSpace

# t0 addr pointer for mem block (mut), t1 len check of mem block (mut)
PrintHeapBlockSpace:
    # load in space byte and print
    lb $a0, ($t0)
    li $v0, 1
    syscall

    # decr len check, incr to next byte in mem block
    addi $t0, 1
    addi $t1, -1

    # finish block display if len check 0, mem block complete
    ble $t1, 0, FinishHeapBlockDisplay

    # else continue printing space in mem block
    j PrintHeapBlockSpace

# a1 is total node count, a2 is cur node idx, s0 is cur node bp
FinishHeapBlockDisplay:
    # close off mem block display format with closed bracket
    la $a0, ClosedBracketStr
    li $v0, 4
    syscall

    # load in next node from next pointer of cur node
    lw $a0, 4($s0)

    # decr node count
    addi $a1, -1

    # if node count still > 0, then display next mem block
    bgt $a1, 0, DisplayHeapLoop

    # else end heap display and return to DisplayHeap
    jr $ra


######################### ERRORS #########################

NoAllocationError:
    la $a0, NoAllocationErr
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

HeapEmptyError:
    la $a0, HeapEmptyErr
    li $v0, 4
    syscall
    j end

NameLenError:
    la $a0, NameLenErr
    li $v0, 4
    syscall
    j MainLoop

# TODO needs to be used eventually
NameNotUniqueError:
    la $a0, NameNotUniqueErr
    li $v0, 4
    syscall
    j end

end:
    li $v0, 10
    syscall
