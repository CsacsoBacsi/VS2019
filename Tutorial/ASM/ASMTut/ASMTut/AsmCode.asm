extrn CalledFromASM:proc					; Defined elsewhere. Tell this to Linker

.data?										; Un-initialized data section

			retval	qword	?				; Return value when called from C++ will be stored here

.code										; Code section

ASMFunc proc								; Procedure code

			jmp		overdata				; Jump over code-embedded data. Could have been defined in data segment or even on the Stack

			param1		qword 1d
			param2		qword 2d
			param3		qword 3d
			param4		qword 4d
			param5		qword 5d
			param6		qword 6d			; 21 (sum of params passed to C++)
			local1		qword 32d
			local2		qword 64d			; 96 (sum of local vars)

			; Called from C++
overdata:	mov		qword ptr [rsp+20h], r9	; Function Prolog Start. Set up local variables and RBP
			mov		qword ptr [rsp+18h], r8  
			mov		qword ptr [rsp+10h], rdx  
			mov		qword ptr [rsp+8], rcx 	; Because the 8 byte return address is already on the stack

			push	rbp						; Save the base pointer
			push	rdi  					; Save any of the non-volatile registers (RBX, RBP, RDI, RSI, RSP, R12, R13, R14, and R15) that may be used by the function
			sub		rsp, 10h  
			mov		rbp, rsp  

			mov		rdi, local1
			mov		qword ptr [rbp+08h], rdi; Local variables on the stack
			mov		rdi, local2
			mov		qword ptr [rbp], rdi	; Prolog End

			; Stack
			; RBP + 50h -> param6			; Param6 and 5 passed via the stack
			; RBP + 48h -> param5
			; RBP + 40h -> R9 (param4)		; Param4 in R9
			; RBP + 38h -> R8 (param3)		; Param3 in R8
			; RBP + 30h -> RDX (param2)		; Param2 in RDX
			; RBP + 28h -> RCX (param1)		; Param1 in RCX
			; RBP + 20h -> Return address
			; RBP + 18h -> RBP				; Saved RBP
			; RBP + 10h -> RDI				; Saved RDI as non-volatile
			; RBP + 08h -> lvar2			; Local variables
			; RBP + 00h -> lvar1

			mov		rax, qword ptr [rbp+28h]; Add the 6 parameters and the 2 local variables together
			mov		rcx, qword ptr [rbp+30h]
			add		rax, rcx  
			add		rax, qword ptr [rbp+38h]
			add		rax, qword ptr [rbp+40h]
			add		rax, qword ptr [rbp+48h]
			add		rax, qword ptr [rbp+50h]
			add		rax, qword ptr [rbp+08h]
			add		rax, qword ptr [rbp]

			lea		rsp, [rbp+10h]			; Discard local variables. Function Epilog Start
			pop		rdi
			pop		rbp						; Epilog End

			mov		qword ptr retval, rax	; Save return value

			; Calling C++

			push	rbp						; Save current RSP in RBP before 16 byte alignment
			mov		rbp, rsp
			and		rsp, -10h				; Least significant 4 bits are 0. FFFFFFFFFFFFFFF0

			sub		rsp, 30h				; 2 qword parameters plus 4 qword shadow space for the function to save the 64 bit registers
											; At least 32 bytes shadow space is always needed even if less than 4 parameters are passed

			mov		rax, [param6]			; Last two parameters go to the stack
			mov		qword ptr [rsp+28h], rax
			mov		rax, param5
			mov		qword ptr [rsp+20h], rax  
			mov		r9, qword ptr param4	; Param4 - param1 in R9, R8, RDX and RCX
			mov		r8, qword ptr param3
			mov		rdx, qword ptr param2
			mov		rcx, qword ptr param1

			call	CalledFromASM  
			
			mov		rsp, rbp
			pop		rbp						; Restore original value as RBP was used to save RSP value before stack alignment
			add		rax, qword ptr retval

			ret

ASMFunc endp
end
