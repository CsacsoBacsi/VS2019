option casemap:none							; Labels and func names are case-sensitive

public getValFromASM2 

.code

getValFromASM2 proc

	; SHR, SHL, SAR, SAL
	mov al, 11010110b
	shr al, 3 ; Shift 3 bits right. 3rd bit ends up in CF. Left 3 bits filled with zeros
	mov cl, 2 ; As if divided by 4
	clc ; Clear carry flag
	shr al, cl ; Only cl can be used here as second param

	mov al, 129 ; Negativ number
	sar al, 6 ; Left 3 bits filled with ones

	; SHLD, SHRD
	mov rax, 0
	mov ax, 0101101010111010b
	mov dx, 1011010001101000b
	shrd ax, dx, 4 ; Shifts right 4 bits. 3 discarded, 4th ends up in cf. From left, 4 bits of dx shifts in (4 bits from right)

	mov ax, 1d
	mov bx, 2d
	mov cx, 3d
	mov dx, 4d

	mov rdi, 0
	shrd rdi, rax, 16 ; Pack all 4 16 bit register values into rdi. Move all bits of ax (part of rax) into rdi (from left)
	shrd rdi, rbx, 16
	shrd rdi, rcx, 16
	shrd rdi, rdx, 16

	; RCL, RCR
	mov bl, 10011001b ; Result: 11100110 = 128 + 64 + 32 + 6 = 230 = E6 CF = 0
	stc ; Set carry flag to 1
	rcr bl, 2 ; Rotate through carry. Practically, it is a 9 bit rotation. Bit 2 of bl ends up in cf, cf value ends up in bit 6 of bl

	ret

getValFromASM2 endp
end