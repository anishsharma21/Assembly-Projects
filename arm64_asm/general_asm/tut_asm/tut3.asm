.global _main
.align 4

_main:
	mov x2, xzr

loop:
	cmp x2, #16
	b.cs end_loop
	add x2, x2, #1
	mov x0, #1
	adr x1, notdone
	mov x16, #4
	svc #0
	b loop

end_loop:
	mov x0, #69
	mov x16, #1
	svc #0

notdone: .ascii "\nnot done yet..."
