option casemap:none							; Labels and func names are case-sensitive

public start								; Otherwise linker throws an error
public getValFromASM 

.data ; Data segment
Myvar1 db 12d
Myvar2 dw 512d
Myvar2reserve dw 1d

.code ; Code segment
start: ; Compulsory label. Program starting point

getValFromASM proc ; Procedure being called from C++

	; 8, 16, 32, 64 bit registers
	mov rax, 65536d
	mov al, 10d ; Adds 10d to RAX. Same 64 bit register's bits can be altered in chunks of bytes (AL, AH), word (AX), double word (EAX)
	mov eax, 256d
	mov ax, 128d
	mov ah, 5d
	mov al, 10d

	mov rdi, 65536d
	mov edi, 256d
	mov di, 128d
	mov dil, 5d

	mov r8, 65536d
	mov r8d, 256d
	mov r8w, 128d
	mov r8b, 10d

	;mov rax, rip ; Not supported!
	;mov eax, eip
	;mov ax, ip
	;push rip
	;push eip
	;push ip

	; MOV 
	mov eax, 5 ; Immediate to register
	mov bl, Myvar1 ; Memory to register
	mov Myvar1, al ; Register to memory
	mov rcx, rsp ; Register to register
	;mov Myvar1, Myvar2 ; Memory to memory - illegal
	mov rcx, [rsp] ; Copies value RSP points at to RCX
	mov rax, label1 ; Copies address of label1 in memory to RAX

	; LEA
	lea rcx, [rbp + 10h] ; Address RBP holds + 16d bytes -> new address in RCX
	mov rcx, [rbp + 10h] ; Copies value RBP + 16d bytes points at

	; ADD
	mov rax, 10h
	mov rbx, 5h
	add rax, 10h ; Immediate to register
	add rax, rbx ; Register to register
	add rax, qword ptr Myvar2 ; Register to memory. Adds an 8 byte (quadword) value to RAX. Myvar2 is just a doubleword, so 4 extra bytes must be reserved in .data
	add Myvar1, 5 ; Memory to Immediate
	add Myvar1, al ; Memory to register

	; SUB
	mov rax, 10d
	mov rbx, 5d
	sub rax, rbx ; Register from register
	sub rax, 1d ; Immediate from register
	mov Myvar1, 255d ; Immediate from memory
	sub Myvar1, al ; Register from memory

	; NEG
	mov rax, 5d
	neg rax ; Register
	neg Myvar1 ; Memory

	; INC
	mov rax, 255d
	inc rax ; Register
	inc Myvar1 ; Memory

	; DEC
	dec rax ; Register
	dec Myvar1 ; memory

	; XCHG
	mov rax, 5d
	mov rbx, 2 ; Register
	xchg rax, qword ptr Myvar2 ; Memory

	; JMP
	jmp label1 ; Label
	mov rax, 0d ; Will be skipped (jumped over)
label1: ; Marks an address in memory. Used by jumps and loops
	mov rbx, label2 ; Could be label2 + 12d (offset)
	jmp rbx ; Register
	mov rbx, 0d
label2:

	; CMP
	mov rax, 50d
	mov rbx, 51d
	cmp rax, rbx
	cmp rax, 51d
	cmp rbx, 51d
	mov Myvar2, 65535d
	cmp Myvar2, bx

	; JE, JNE, JG, JA, JL, JGE, JZ, JNZ
	JE l_equal ; IF - ELSE construct. Can only jump to labels (plus optionally offset)
	JMP l_not_equal
l_equal:
	mov rax, 0
	jmp l_end
l_not_equal:
	mov rax, 1
l_end:

	; Loops
	mov ecx, 6d
loop1:
	dec ecx
	jnz loop1 ; Jump if not zero

	ret
getValFromASM endp
end