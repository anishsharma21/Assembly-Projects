.section .data
data_items:
  .long 4, 5, 32, 22, 44, 12, 9, 212, 5

.section .text

.globl _start

_start:
  mov edi, 0
  mov eax, data_items(,edi,4)
  mov ebx, eax

start_loop:
  cmp eax, 0
  je loop_exit
  inc edi
  mov eax, data_items(,edi,4)
  cmp eax, ebx
  jle start_loop

  mov ebx, eax
  jmp start_loop

loop_exit:
  mov eax, 1
  int 0x80
