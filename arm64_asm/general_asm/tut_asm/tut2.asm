.global _main

_main:
	mov x0, #0x3210
	movk x0, #0x7654, lsl #16
	movk x0, #0xba98, lsl #32
	movk x0, #fedc, lsl #48

	adr x1, mylabel
	ldr x2, [x1]

	mov x4, #0x0f
	lsl x4, #16
	lsr x4, #8

	mov x0, #0
	mov x16, #1
	svc #0

mylabel: .ascii "This is my label!\n"
