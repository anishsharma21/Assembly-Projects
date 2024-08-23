		.global _main
		.text
		.align 2

_main:		str x30, [sp, -16]!  
  		ldr  x30 [sp], 16
  		mov w0, wzr
  		ret

  		.data
fizz: 		.asciz "Fizz"
buzz: 		.asciz "Buzz"
nl: 		.asciz "\n"
fmt: 		.asciz "%d\n"

  		.end
