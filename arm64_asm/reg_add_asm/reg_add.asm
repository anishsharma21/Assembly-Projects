.global _main

_main:
  movz x0, 0xdef0, lsl #0
  movk x0, 0x9abc, lsl #16
  movk x0, 0x5678, lsl #32
  movk x0, 0x1234, lsl #48
  mov w0, w0
  mov x16, #1
  mov x0, #0
  svc #0
