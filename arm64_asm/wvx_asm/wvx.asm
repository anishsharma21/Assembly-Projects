.global _main

_main:
  movz x0, 0xcafe
  movk x0, 0xcafe, lsl #16
  movk x0, 0xcadd, lsl #32
  mov x16, #1
  mov x0, #0
  svc #0
