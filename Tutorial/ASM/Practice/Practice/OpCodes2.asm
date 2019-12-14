										; Under 64 bit there is only one model: FLAT
										; Parameters from right to left with callee cleaning up
option casemap:none						; Labels and func names are case-sensitive

public start							; Otherwise linker throws an error

EXTERNDEF Proc1:proc					; Function in another source file (object file)
Proc1 proto :DWORD, :DWORD				; Must have a prototype

.data									; Initialized data section/segment
mytitle db 'The 64-bit world of Windows & assembler...', 0
mymsg db 'Hello World!', 0


CrLf		byte 0Dh, 0Ah, 0			; Carriage return + Line feed

.code									; Code section
start:									; Has to start and end with a label. Label name arbitrary
			; Parameters are passed in RCX, RDX, R8, and R9. For float types: XMM0L, XMM1L, XMM2L, and XMM3L
			; 32 (020h) bytes are reserved
			; RAX, R10, R11, XMM4, and XMM5 are volatile
			; R12:R15, RDI, RSI, RBX, RBP, RSP and XMM6:XMM15 must be preserved by callee
			; 

			sub rsp, 28h     ; shadow space, aligns stack
			mov rcx, 0       ; hWnd = HWND_DESKTOP
			lea rdx, mymsg   ; LPCSTR lpText
			lea r8,  mytitle ; LPCSTR lpCaption
			mov r9d, 0       ; uType = MB_OK
		;call MessageBoxA
			mov ecx, eax     ; uExitCode = MessageBox(...)  
			add rsp, 28h     ; free shadow space. Has to be done!

		;call ExitProcess
		;invoke ExitProcess, 0 ; Unfortunately, no more invoke under 64 bit assembly
		call Proc1
		ret 0
         
end
