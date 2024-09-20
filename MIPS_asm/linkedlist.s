# pretty simple, store val, then addr right after of the next val, using sbrk for dynamic mem alloc, head, next, and val strings to navigate through linkedlist

.data

str1: .asciiz "Linked List initialised."
str2: .asciiz "Choose head (h), next (n), or val (v): "
headstr: .asciiz "You are at the head node"
nextstr: .asciiz "You are at the next node"
valstr: .asciiz "The value of this node is: "
nexterrstr: .asciiz "There is no next value."
valerrstr: .asciiz "This node has no value"

.text

main:
