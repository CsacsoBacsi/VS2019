option casemap:none							; Labels and func names are case-sensitive

public start								; Otherwise linker throws an error
public getValFromASM 

.code
start:

getValFromASM proc
	mov eax, 5
	lea rcx, [rbp + 10h]
	mov rcx, [rbp + 10h]
	mov rcx, rsp
	mov rcx, [rsp]

	mov rax, 65536d
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

	;mov rax, rip
	;mov eax, eip
	;mov ax, ip
	;push rip
	;push eip
	;push ip
	mov rax, label1 + 3
label1:

	ret
getValFromASM endp
end