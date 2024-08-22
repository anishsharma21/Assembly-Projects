.global _main

_main:
  mov x0, #5
  mov x1, #3
  add x2, x1, x0
  mov x16, #1
  mov x0, #0
  svc #0
