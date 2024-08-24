.global _main
.align 4

_main:
	mov x0, #1
	adr x1, helloworld
	mov x2, #16
	mov x16, #4
	svc #0x80

	mov x0, #0
	mov x16, #1
	svc #0xfff

helloworld: 	.ascii "Hello M1-World!\n"
