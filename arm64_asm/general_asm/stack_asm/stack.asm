.global _main
.align 4

_main:
	mov x8, #0x480a
	movk x8, #0x6c65, lsl #16
	movk x8, #0x6f6c, lsl #32
	movk x8, #0x4d20, lsl #48
	
	mov x9, #0x2d31
	movk x9, #0x6f57, lsl #16
	movk x9, #0x6c72, lsl #32
	movk x9, #0x2164, lsl #48
	
	stp x8, x9, [sp, #-16]!
	mov x2, xzr

loop:
	cmp x2, #16
	b.cs end_loop
	add x2, x2, #1
	mov x0, #1
	mov x1, sp
	mov x16, #4
	svc #0
	b loop

end_loop:
	mov x0, #0
	mov x16, #1
	svc #0

helloworld: .ascii "\nHello world!"
