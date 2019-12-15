option casemap:none							; Labels and func names are case-sensitive

public start								; Otherwise linker throws an error

;include \masm32\include\user32.inc
;include \masm32\include\kernel32.inc
;include \masm32\include\gdi32.inc
;include \masm32\include\comdlg32.inc
;includelib \masm32\lib\user32.lib

;includelib \masm32\lib\kernel32.lib
;includelib \masm32\lib\gdi32.lib
;includelib \masm32\lib\comdlg32.lib

.data										; Initialized data section
label1:
			param1		dq 1d
			param2		dq 2d
			param3		dq 3d
			param4		dq 5d
			param5		dq 6d
			param6		dq 7d
			high_q		dq 0d
			low_q		dq 0d
			multiplier	dq 16d
			source		dq 'abcdefgh', 'ijklmnop', 'qrstuvwx', 'yyyyzzzz'
			dest		dq '        ', '        ', '        ', 'yyyyzzzz'
			bittest		dw 1010101010101010b
			ALIGN 16
			scalarSP	REAL4 1234567.89
			scalarSPl	REAL4 1234566.89
			scalarDP	REAL8 1234567890.12345
			storedSP	dd 0.0
			mytable		db 'abcdefghijklm '
			myint		dw 258				; 0102 = 0000 0001 0000 0010
			float8		REAL8 12.375f		; 4028c0 = 0|100 0000 0010 | 1000 1100 0000
											; Sign: 1 bit: 0 Exponent: 11 bits: 1023 + 3  Mantissa: Implicit first bit is always 1, not stored. 1|1000 1100
											; 12.375 in binary = 1100.011. After dec point: 0*1/2 + 1*1/4 + 1*1/8 = 0*0.5 + 1*0.250 + 1*0.125 = 0.375
											; Move decimal left 3x. That is the exponent (3). Normalized value: 1.100011 *2^3
											; Exponent = bias (1023) + 3 = 1026
											; Mantissa = Implicit first bit is always 1 - not stored
											; then the number: 1000 1100 Rest is all zeros
			f8_zero		REAL8 0.0f			; Zero all bits
			f8_small	REAL8 0.375f		; 3fd8 = 0|011 1111 1101 | 1000
											; Binary = 0.011. Move decimal point right 2x
											; Exponent = bias (1023) - 2 = 1021
											; Mantissa = Implicit first bit is always 1 - not stored
											; then the number: 1000 Rest is all zeros
			f8_tiny		REAL8 0.001f		; 3f50624dd2f1a9fc3fd8

.data?										; Uninitialized data section
			retval		dq ?
			scalarDP2	dq ?
			mylabel1	db ?
			mylabel2	db ?
			mylabel3	db ?
			mylabel4	db ?
			VendorString db 12 dup (?)

.code										; Code section
start:
			call	main
			xor		rax, rax				; Exitcode = 0
			xor     rbx, rbx
;			call	ExitProcess

	main proc

			; *** Mov/lea value, pointer, address ***
			mov		rax, param1				; Both are the same though the opcode is different!
			mov		rax, [param1]			; Loads 1 into RAX
			lea		rax, param1				; Address of param1
			lea		rax, [param1]			; Same, though the opcode is different!
			mov     rax, label1				; This is the address of param1. Same as LEA
			mov		qword ptr [rax], 11d	; RAX is a pointer, store 11 there. Param1 is now 11. Overwrites 8 bytes
			mov		word ptr [rax], 22d	    ; Overwrites only 2 bytes
			mov		rax, param1				; Check it!

			mov		rbp, rsp				; Save RSP
			; mov	rsp, rbp+10h			; Invalid use of register. LEA can do it
			mov		rsp, [rbp+10h]			; RSP = value at address RBP + 10h
			lea		rsp, [rbp+10h]			; RSP = RBP + 10h
			lea		rsp, [rbp+rsi+10h]		; RSP = RBP + RSI + 10h
			mov		rsp, rbp				; Restore RSP

			; [label + offset], [reg, offset], [reg, reg], [reg, reg, scale] addressing modes. Offset can be a calculation such as (12 + 5) * 8
			mov bl, 5
			mov byte ptr [mylabel1 + 3], bl	; Stores 5 in mylabel4
			lea rax, mylabel1
			mov byte ptr [rax + 2], bl		; Stores 5 in mylabel3
			lea rax, mylabel1
			mov rcx, 1
			mov byte ptr [rax + rcx], bl	; Stores 5 in mylabel2
			mov byte ptr [rax + (12 * 8) + 3 - (11 * 9)], bl	; Stores 5 in mylabel1
			mov byte ptr [rax + (12 * 8) + 3 - (11 * 9)], 5		; Same as previous but with an immediate
			mov rbx, 1
			mov byte ptr [rax + rbx * 2], 10					; Scale Index Base (scale can be 1, 2, 4 or 8) Stores 10 in mylabel3
			; Increment RBX and we can traverse an array in words (2 bytes)


			; *** Embedded data ***
			jmp		overd1
			embeddedq dq 1
	overd1:	mov		rax, embeddedq			; It can be read
			lea		rax, embeddedq			; Its address can be read
;			mov		qword ptr [rax], 2		; It can not be written to: Access violation - runtime error
;			mov		qword ptr embeddedq, 2	; Access violation - runtime error

			; *** Sign and/or zero extension ***
			mov		al, 080h
			movsx	rax, al					; Convert byte to word
			movsx	eax, ax					; Convert word to double word. Sign extends to EAX then zero extends up to RAX
			movsx	rax, ax					; Convert Word to quad word
			movsxd	rax, eax				; Convert double word to quad word

			movzx	rax, al					; Zero extend RAX

			; *** Conditional move ***
			xor		rax, rax				; Set to zero
			mov		rcx, 1d
			cmovz	rax, rcx				; Move if zero flag set
			xor		rax, rax
			cmovnz	rax, rcx				; Move if zero flag not set (not zero)
			sub		rax, 5d
			cmovl	rax, rcx				; Move if result was negative
			cmovle	rax, rcx				; Move if result was negative or zero
			cmovg	rax, rcx				; Move if result was positive
			cmovge	rax, rcx				; Move if result was positive or zero

			; *** Arithmetic ***
			; Signed multiplication
			; One operand
			mov		rax, 07FFFFFFFFFFFFFFFh
			imul	qword ptr [multiplier]	; Multiply RAX with single operand
			mov		high_q, rdx				; Store result in RDX:RAX if it is more than 64 bit
			mov		low_q, rax

			; Two operands
			imul	rax, 16d				; First operand * second. Store result in first operand
			mov		r8, 16d
			imul	r8, [multiplier]
			mov		r9, 128d
			imul	r9, r8

			; Three  operands
			imul	rax, [multiplier], 16d	; Store x*16 in rax

			; Signed division
			; Divide RDX:RAX by operand. Store quotient in RDX, store remainder in RAX
			mov		rdx, 0					; Sign extend 21 into higher order dividend
			mov		rax, 21					; Divident
			mov		rbx, -5					; Put -5 into RBX for divisor
			idiv	rbx						; Divide RDX:RAX by RBX: RAX=-4, RDX=1 - correct

			; *** Negative numbers ***
			mov		al, 128d
			movzx	rax, al				; Last bit (left most) is set. If it is a signed value then it is negative
			push	ax
			not		ax					; Sets all bits to its inverse. 1 -> 0 and 0 -> 1
			pop		ax
			neg		ax					; Complement all bits (1's complement) and add 1 to get a negative value
										; First bit the sign bit. All the other bits must be summed and added to the value of the negative sign bit.
										; So 1011: First bit is -8 (sign bit) + 3 = -5
										; To get hte positive value, complement all bits 1011 -> 0100 and add 1 = 0101 = 5
			jl		negative1			; the result is negative
			xor		rax, rax
negative1:	neg		ax					; The result is positive (neg negative = positive)
			jl		negative2
			jmp		positive1
negative2:	xor		rax, rax
positive1:	xor		rax, rax

			; *** String operations ***
			; Move byte from source to destination: MOVSB, W, D, Q
			; RSI: source index, RDI: destination index, RCX: counter
			lea		rsi, source
			lea		rdi, dest
			mov		rcx, 3d
			rep		movsq

			; Store byte in destination: STOSB, W, D, Q
			; RDI: destination index, RAX: value to store in memory, RCX: counter
			mov		rax, 65d
			mov		rcx, 2
			lea		rdi, dest
			rep		stosq

			; Load byte from source
			; RSI: source index, RAX: loaded value from memory
			; Not much sense to use repeat with this though
			lea		rsi, source
			mov		rcx, 1
			lodsq
 
			; Scan byte
			; RCX will hold the index of the value in RAX found in the array
			; RDI: source index, RAX: value to search for, RCX: counter
			cld								; Prepare to increment rdi – direction flag
			lea		rdi, source
			mov		rcx, 10					; Maximum number of iterations
			mov		rax, 'ijklmnop'			; Scans for 'ijklmnop'
			repne	scasq
			; Both RSI and RDI are incremented/decremented in each iteration
			; If cld then incremented. Once found, RDI is set 8 bytes ahead (overruns)
			; RCX start value minus end value = index. E.g. 10 - 8 = 2

			; Compare byte to byte
			; RSI: source index, RDI: destination index, RCX: counter
			cld
			lea		rsi, source
			lea		rdi, dest
			mov		rcx, 4					; If set to 3, then it becomes zero and we do not know if there was a match or not
			repne	cmpsq					; Compare until end or difference
			cmp		rcx, 0					; Counted down to zero without finding a difference
			jz		equal					; Reached the end
			sub		rdi, 8					; RSI and RDI incremented by one too far, hence the -1
			sub		rsi, 8
	equal:	xor		rax, rax				; Could not find

			; *** Bit test ***
			mov		rax, 11111101b			; 0FDh
			clc								; Clear Carry
			bt		rax, 2					; Bit test. CF is set to the value of the bit being tested
			bts		rax, 1					; Bit test and set the bit to 1
			btr		rax, 7					; Bit test and reset the bit to 0

			lea rbx, bittest
			clc
			mov		rcx, 3d					; Test 4th bit from right. Must be 1
			xor		rdx, rdx
			bt		[rbx], rcx				; Bit test bit RCX in value defined by RBX
			setc	dl						; Set byte (DL) with Carry flag value (tested bit value). Extracts bit basically into DL

			mov		al, 10101010b
			test	al, 01010101b			; Sets the sign flag, parity flag and zero flag

			; Scan bit
			mov		rax, 64 + 256 * 4
			xor		rbx, rbx
			bsf		rbx, rax				; Bit scan forward (from bit zero forwards) = 6
			bsr		rbx, rax				; Bit scan reverse (from last bit down to bit 0) = 10

			; *** Shifting ***
			; Shift left-right
			mov		rax, 10101010b
			shl		al, 2					; Multiply by 4 (2**2)
			shr		al, 2					; Divide by 4. Falling out bits get discarded. CF is set with last flag value that dropped out
			mov		rax, 11111101b
			sar		al, 2					; Sign extend the shift so that the number stays negative (last bit is negative, after the right shift it stays the same)
			sal		al, 2					; Same as shl as the sign bit can not be saved

			; Shift left-right double precision
			mov		rax, 1d
			mov		rbx, 2d
			mov		rcx, 18d
			mov		rdx, 228d
			shrd	rdi, rax, 16			; Shifts RDI (64 bit) 16 bits to the right and bits of AX (LSB) gets shifted in from the left
			shrd	rdi, rbx, 16			; RBX -> RDI from the left
			shrd	rdi, rcx, 16
			shrd	rdi, rdx, 16			; RDI now contains the values of the four 8 bit registers. Packs the numbers into one register. RAX, RBX, RCX, RDX do not change

			xor		rax, rax
			xor		rbx, rbx
			xor		rcx, rcx
			xor		rdx, rdx
			mov		rdi, 0123456789ABCDEF0h
			shld	rax, rdi, 16			; Unpacks the numbers from a 64 bit register into four 16 bit registers
			shl		rdi, 16					; Because the shift did not alter the source operand RDI. We must move everything to the left so that BX is next
			shld	rbx, rdi, 16			; Shifts the target to the left and second operand provides the bits
			shl		rdi, 16
			shld	rcx, rdi, 16			; RCX <- RDI from the right
			shl		rdi, 16
			shld	rdx, rdi, 16
			shl		rdi, 16

			; Rotating
			mov		rax, 10101010b
			ror		rax, 2
			rol		rax, 2

			stc								; Set Carry flag to 1
			rcr		rax, 2					; Rotate through Carry
			rcl		rax, 2

			; *** Call a function with 6 parameters ***
			mov		rbp, rsp				; Save current RSP before 16 byte alignment
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

			call	func6
			mov		qword ptr [retval], rax	; Return value in RAX

			mov		rsp, rbp				; Restore RSP as it was before the alignment

			; *** Floating point binary representation ***
			; Converting a binary represented float to decimal
			; In decimal notation 22.589 is merely 2 * 10^1 + 2 * 10^0 + 5*10^-1 + 8*10^-2 + 9*10^-3. 
			; Similarly, the binary number 101.001 is simply 1*2^2 + 0*2^1 + 1*2^0 + 0*2^-1 + 0*2^-2 + 1*2^-3, 
			; or rather simply 2^2 + 2^0 + 2^-3 = 4 + 1 + 1/8 = 5.125
			; 101011.101 (which is 43.625) would be represented using scientific notation as 1.01011101 * 2^5
			; Sign (bit 31 – 1 bit) bit = 0
			; Exponent (bit 30 – 23 – 8 bits)t: 10000100 = 132 which is with the bias of 127 gives us 132 – bias = 5 so 2^5
			; Mantissa (bit : 22 – 0 – 23 bits) = 01011101000000000000000. The 1. is implied so no need to store it

			; 1.01011101 * 2^5
			; = 2^0 + 2^-2 + 2^-4 + 2^-5 + 2^-6 + 2^-8 = 2^5 + 2^3 + 2^1 + 2^0 + 2^-1 + 2^-3
			; = 32 + 8 + 2 + 1 + 0.5 + 0.125 = 43.625

			; Formula: sign * 2^exponent * mantissa
			; Bit 23 has a value of 1/2, bit 22 has value 1/4, bit 21 has a value 1/8 etc. As a result, the mantissa has a value between 1.0 and 2.

			; Converting decimal numbers to floating point ones.
			; Decimal number: 329.390625

			; Take the integer part first: 329
			;		Quotient	Remainder
			; 329/2	164			1
			; 164/2	82			0
			; 82/2	41			0
			; 41/2	20			1
			; 20/2	10			0
			; 10/2	5			0
			; 5/2	2			1
			; 2/2	1			0
			; 1/2	0			1

			; So, in binary format: 00000001 01001001 (see before). 
			; What is left on the right we take. 0.390625
			; Multiply it by two and record on the right whatever is on the left of the decimal point (either 0 or 1). 
			; Then we keep multiplying by two whatever is left on the right of the decimal point.

			; 0.390625 * 2 = 0.78125	0
			; 0.78125 * 2 = 1.5625		1
			; 0.5625 * 2 = 1.125		1
			; 0.125 * 2 = 0.25			0
			; 0.25 * 2 = 0.5			0
			; 0.5 * 2 = 1				1
			; 0

			; The binary representation on the number then: 0.011001. Together with the whole number on the left of the original number (329) it looks as this: 101001001.011001
			; In binary scientific notation this is 1.01001001011001 * 2^8 
			; The sign is positive, so the sign field is 0.
			; The exponent is 8. 8 + 127 = 135, so the exponent field is 10000111.
			; The mantissa is merely 01001001011001000000000 (the implied 1 of the mantissa means we don't include the leading 1)

			; Data section (code-embedded)
			jmp overd2						; Jump over embedded data section
			ALIGN 16						; To use MOVAPS (aligned move) properly
			p4doubles	REAL8	34.0, 51.0, 68.0, 85.0
			p8floats	REAL4	102.0, 119.0, 136.0, 153.0
			p4floats	REAL4	170.0, 187.0, 204.0, 221.0
			mulfloat	REAL4	2.5, 25.5, 5.7, 6.2
			muldouble	REAL8	4.5, 12.7
			mydword		dw		200d
			zero		dq		0d
			ALIGN 16
			divfloat	REAL4	1.8, 2.3, 5.1, 12.8
			divdouble	REAL8	2.25, 3.33
			xsign		db		'X', 'X', 'X', 'X', 'X'
			ALIGN 8
			ysign		db		'Y'			; Just to see how ALIGN works
			ALIGN 16						; Fills up with NOPs

			; Moving scalars
			; xmm registers are 128 bit, ymm registers are 256 bit wide - this machine does not have the latter one
	overd2:	movss	xmm0, dword ptr scalarSP; Single precision (32 bit) - float
			movsd	xmm1, scalarDP			; Double precision (64 bit) - double
			movsd	scalarDP2, xmm1
			movsd	xmm0, xmm1

			; Moving packed (packed means more than one value)
			movups	xmm0, p4floats			; Move 4 floats to xmmO (move un-aligned data. Not on 16 byte boundary)
			vmovups	ymm0, p8floats			; Move 8 floats to ymmO
			vmovupd	ymm1, p4doubles			; Move 4 doubles to ymm1
			movupd	xmm1, p4doubles			; Move 2 doubles to xmm1
			movaps	xmm2, p4floats			; Move aligned data (on 16 byte boundary)

			; Addition
            movss	xmm0, scalarSP
			addss	xmm0, scalarSP			; Add the scalar value to it
			movss	storedSP, xmm0			; Store sum in storedSP
			movapd	xmm0, p4doubles			; Load 2 doubles 
			addpd	xmm0, p4doubles			; Add xmm0[0] + p4doubles[0] and xmm0[1] + p4doubles[1] - packed addition. Result: 64.0 and  102.0

			; Subtraction
			movss	xmm0, scalarSP
			movss	xmm1, scalarSP
			subss	xmm0, xmm1				; Subtract xmm1 from xmm0 – scalar subtraction. Result: 0
			movapd	xmm0, p4doubles + 16	; Load 2 doubles from p4doubles
			addpd	xmm0, p4doubles + 16	; Result: 170 and 136
			subpd	xmm0, p4doubles + 16	; Subtract xmm0[O] - [p4doubles+16][O] and xmm0[1] - [p4doubles+16][1] – packed subtraction
			subpd	xmm0, p4doubles + 16	; Result: 0

			; Multiplication
			movss	xmm0, scalarSP
			mulss	xmm0, mulfloat			; Multiply scalar float
			movsd	xmm1, scalarDP
			mulsd	xmm1, muldouble			; Multiply scalar double
			movups	xmm0, p4floats
			mulps	xmm0, mulfloat			; Multiply packed float
			movapd	xmm0, p4doubles
			mulpd	xmm0, muldouble			; Multiply packed double
			
			; Division
			movss	xmm0, scalarSP
			divss	xmm0, divfloat			; Divide scalar float
			movsd	xmm0, scalarDP
			divsd	xmm0, divdouble			; Divide scalar double
			movups	xmm0, p4floats
			divps	xmm0, divfloat			; Divide packed float
			movapd	xmm0, p4doubles
			divpd	xmm0, divdouble			; Divide packed double

			; Converting
			movsd	xmm0, zero
			cvtss2sd xmm0, scalarSP			; From float to double
			cvtsd2ss xmm0, xmm0				; Convert to float
			movapd	xmm0, p4doubles
			cvtpd2ps xmm1, xmm0				; Packed version

			; From float to integer
			movss	xmm0, scalarSP
			movsd	xmm1, scalarDP
			cvtss2si rax, xmm0				; Converts a float to a double or quad word integer
			cvtsd2si rax, xmm1				; Converts a double to a double or quad word integer
			cvttss2si rax, xmm0				; Convert by truncating
			cvttsd2si rax, xmm1				; Convert by truncating

			; From integer to float
			mov		rax, 100
			cvtsi2ss xmm0, rax				; Converts a double or quad word integer to a float
			cvtsi2sd xmm1, rax				; Converts a double or quad word integer to a double

			mov		rax, 12345678
			cvtsi2sd xmm0, rax				; Convert qword to double
			cvtsi2sd xmm0, dword ptr mydword; Convert dword integer (when converting memory, we need to use dword or qword)

			; Comparing floats
			movss	xmm0, scalarSP
			divss	xmm0, scalarSP
			ucomiss	xmm0, scalarSP ; 
			jbe		bel_eq
			jmp		misc
	bel_eq:	xor		rax, rax

			; Minimum – maximum
			movss	xmm0, scalarSPl			; Single floating point less
			movss	xmm1, scalarSP
			maxss	xmm0, xmm1				; xmmO has max (scalarSP , scalarSPl)
			movapd	xmm0, p4doubles
			movapd	xmm1, p4doubles + 16
			minpd	xmm0, xmm1				; xmm0[O] has min (xmm0[O], xmm1[O]), xmm0[1] has min (xmm0[1], xmm1[1])

			; Square root
			movss	xmm0, scalarSP
			sqrtss	xmm1, xmm0				; Computes 1 float square root
			movups	xmm0, p4floats
			sqrtps	xmm1, xmm0				; Computes 4 float square roots
			movsd	xmm0, scalarDP
			sqrtsd	xmm1, xmm0				; Computes 1 double square root
			movapd	xmm0, p4doubles
			sqrtpd	xmm1, xmm0				; Computes 2 double square roots

			; *** Flags ***
			; Carry - CF/CY					; 255 + 1 = 0 and CF = 1. CLC, STC (clear, set carry)
			; Parity - PF/PE				; Even number of 1 bits then PF = 1 else if odd then 0
			; Auxiliary - AF/AC				; Used to be used for BCD. It is like CF on bit 4 (5th bit) if set to 1 then AF = 1
			; Zero - ZF/ZR					; If a result of an operation is zero then ZF = 1 else 0
			; Sign - SF/PL					; If a result of an operation is negative then SF = 1 else 0
			; Direction - DF/UP				; Set by CLD (clear) and STD (set to 1). String operations use it.If 1 then RSI/RDI are incremented else decremented
			; OVerflow - OF/OV				; A signed number overflowed. 127 + 1 sets the last bit (sign bit) so the number becomes -128

			pushfq							; Pushes all flags to the stack
			popfq							; Pops them out from the stack

			; *** Misc instructions ***
	misc:	mov		ebx, 1010101010101010b
			popcnt	eax, ebx				; Counts the number 1 bits in the second operand

			mov		eax, 0FFEEDDCCh
			bswap	eax						; Little Endian: Low Order byte at lowest address. Swaps first with fourth and two with third byte

			mov		rcx, 20d
	looplb:	xor		rax, rax
			loop	looplb					; Loops until RCX (counter) is zero

			call	pusheip					; Calls a label. Pushes rip onto stack
	pusheip:pop		rbx						; RIP -> RBX

			mov		rax, 1
			mov		rbx, 2
			xadd	rax, rbx				; Adds two operands, stores result in destination (first operand) but saves the original destination value in source
											; temp := dest; dest := dest + source; source := temp
			mov		rax, 5
			mov		rbx, 5
			mov		rcx, 6
			cmpxchg rbx, rcx				; Compares EAX to op1. If equal, copies op2 into op1. If not, copies op1 into EAX
											; if ({al/ax/eax} = op1) then zero := 1; op1 := op2 else zero := 0; {al/ax/eax} := op1 endif
											; CMPXCHG8B – 64 bit version

			lea		rbx, mytable
			mov		al, 5 
			xlat							; No operand. EBX points at a table in the data segment. XLAT replaces the value in AL with 
											; the byte at the offset originally in AL. Offset starts with 0. temp := al+bx; al := ds:[temp];
			
			xchg	rax, rbx				; The instruction swaps two values. The general form is 

			; CPUID
			; Flag bit 21 if can be set to 1 and the system does not set it back to 0, it is CPUID capable
			pushfq							; Push the flags to the stack
			pop		rax
			xor		rax, 200000h			; Set bit 
			push	rax
			popfq							; It is at this point when the CPU either leaves it or resets it to zero

			; Get Vendor String function
			mov		rax, 0
			cpuid
			push	rax
			lea		rax, VendorString

			mov		dword ptr [rax], ebx
			mov		dword ptr [rax + 4], edx
			mov		dword ptr [rax + 8], ecx

			; Largest standard function this CPU knows
			pop		rax

			; Logical Process count
			mov		rax, 1
			cpuid
			and		ebx, 00ff0000h			; Mask out bits other than 16-23
			mov		eax, ebx
			shr		eax, 16d				; Returns 16

			; *** MASM ***
			jmp masmcode					; Jump over the definition block
			; Note: no more support for high level syntax. .IF, .WHILE, PROTO, INVOKE etc.
			; Bad syntax
			
			;1TooMany						; Begins with a digit
			;Hello.There					; Contains a period in the middle of the symbol
			;$								; Cannot have $ or ? by itself
			;LABEL							; Assembler reserved word
			;Right Here						; Symbols cannot contain spaces or other special symbols besides _ ? $ and @

			; Literals
			decimalnum	equ 123d			; Decimal number
			floatingnum	equ 43.14159
			strconst	equ "String Const"
			hexanum		equ 0FABCh			; Hexa number
			charA		equ 'A'
			textconst	equ <Text Constant>	; E.g. mrax textequ <mov rax,>
			binnum		equ 101101011101b	; Binary number
			specchar	equ 'Isn''t it?'	; Special chars
			scinum		equ 5.34e+12		; Scientific notation

			; Equates
			One			equ 1
			Minus1		equ -1
			TryAgain	equ 'Y'
			StringEqu	equ "Hello there"
			mova		equ <mov rax,>
			
			HTString	byte StringEqu		; Same as HTString equ "Hello there"

			; Variables (label types)
			; BYTE, DB (byte)				Allocates unsigned numbers from 0 to 255 
			; SBYTE (signed byte)			Allocates signed numbers from -128 to +127 
			; WORD, DW (word = 2 bytes)		Allocates unsigned numbers from 0 to 65,535 (64K)
			; SWORD (signed word)			Allocates signed numbers from -32,768 to +32,767
			; DWORD, DD (doubleword = 4 bytes)	Allocates unsigned numbers from 0 to 4,294,967,295 (4 megabytes)
			; SDWORD (signed doubleword)	Allocates signed numbers from -2,147,483,648 to +2,147,483,647
			; FWORD, DF (farword = 6 bytes)	Allocates 6-byte (48-bit) integers. These values are normally used only as pointer variables on the 80386/486 processors
			; QWORD, DQ (quadword = 8 bytes)	Allocates 8-byte integers used with 8087-family coprocessor instructions
			; TBYTE, DT (10 bytes)			Allocates 10-byte (80-bit) integers if the initializer has a radix specifying the base of the number
			; REAL4							Short (32-bit) real numbers	Short real 32 6-7 1.18 x 10-38 to 3.40 x 1038
			; REAL8							Long (64-bit) real numbers	Long real 64 15-16 2.23 x 10-308 to 1.79 x 10308		
			; REAL10						10-byte (80-bit) real numbers and BCD numbers	10-byte real 80 19 3.37 x 10-4932 to 1.18 x 104932	
			; C-like types
			char	TYPEDEF SBYTE
			integer	TYPEDEF WORD
			long	TYPEDEF DWORD
			float	TYPEDEF REAL4
			double	TYPEDEF REAL8
			long_double	TYPEDEF	REAL10

			; Operators
			; this, equ, dup
			WArray	equ  this word		; "this" is the location counter pointing really at BArray
			BArray	byte 200 dup (?)

			; sizeof, lengthof, type
			a1		byte	?			; SIZEOF(a1) = 1
			a2		word	?			; SIZEOF(a2) = 2
			a4		dword	?			; SIZEOF(a4) = 4
			a8		real8	?			; SIZEOF(a8) = 8
			ary0	byte	10 dup (0)	; SIZEOF(ary0) = 10
			ary1	word	10 dup (10 dup (0))	; SIZEOF(ary1) = 200
			ary2	dword	10 dup (0)	; SIZEOF(ary2) = 40

			; EQ, LT, GT, etc.
			bool1	byte type (a2) eq word	; value = 0FFh = TRUE
			bool2	byte type (a2) eq dword	; value = 0 = FALSE
			bool3	byte type (a4) lt type (a2)	; value = 0 = FALSE

			; Typedef
			integer			typedef word	; Typedef defines a type
			Array			integer 16 dup (?)

			; low, high, lowword, highword
			hword			dw highword (098F2h)	; Should be 098h
			lword			dw lowword (098F2h)	; Should be 0F2h

			Asm64bit	equ 	1
			Defined		db		8
			op1			textequ		<op1>
			op2			textequ		<op2>

			; Predefined macros
			OldStr		textequ <1234567890>
			SubStri		textequ <56>
			NewStr1 substr OldStr, 1, 3		; substr string start length
			Pos instr 2, OldStr, SubStri	; instr start string substr
			StrSize sizestr OldStr			; sizestr string
			NewStr2 catstr OldStr			; catstr string string ...

			; *** Assembly time variables ***
			; @Date
			; @Time
			orapath textequ <@Environ (ORACLE_PATH)>
			filenm	textequ <@FileName>
			; @Line

			; Macros
			COPY macro Dest, Source			; Macro codes are always inserted at points where they are referenced
				mov		rax, Source			; Procedure code however is only written once but used many times
				mov     Dest, rax
			endm

			LJE macro Dest					; Jump if equal macro
				local   SkipIt				; Prevents the error of redefinition by redefining SkipIt each time the macro is encountered. Local must come right after the macro definition
				jne     SkipIt
				jmp     Dest				; Label defined somewhere
	SkipIt:									; It will get redefined each time it is inserted in the code which results in an error.
				xor		rax, rax
				exitm						; Leaves the macro. Could be enclosed by IF statements. The text after exitm does not get copied in the code
				xor		rbx, rbx
			endm

			; Structures
			stype		struct				; This should really go in an .INC (include) file
				member1		db ?
				member2		dw ?
			stype	    ends
			mystruct stype {5, 12345}		; Reserve space and initialize structure members

			stypeprnt	struct				; Embed a structure into another one
				member1 stype {}
				member2 stype {}
				member3 db ?
			stypeprnt ends
			mystructprnt stypeprnt {{1,2}, {3,4}, 5}

	masmcode:
			mova	rbx						; Same as mov rax, rbx (defined by textequ macro)
			mov		al, mystruct.member1	; Accessing a struct member
			mov		rax, stype				; Moves the size of the structure (1 + 2) into RAX
			mov		rax, stype.member1		; Returns the offset of the member. It is not instantiated!
			mov		rax, stype.member2
			mov		ax, mystructprnt.member1.member2	; Access the embedded structure member
			mov		al, mystructprnt.member3; Access the parent structure's member
			mov		ax, WArray+8			; Does not generate an error (wanting word ptr)
			mov		rbx, sizeof a8 + sizeof ary1	; All done at assembly time (the addition too!)
			mov		rbx, lengthof ary2		; Returns 10, sizeof returned 40
			mov		rbx, type (a2)			; Returns 2 (bytes)

			; Classes
			; Same as a struct. Without member functions. These functions are name mangled to define which class they belong to
			; The methods have their first parameter set as a pointer (this) and passed in RCX. So the actual first parameter is in RDX
			; This pointer will point at a memory location automatically allocated. The NEW operator will allocate it
			; Static variables are globals, defined in the data segment with a mangled name telling you which class they belong to
			; In ASM:
			; public ?statvar@StaticExample@@0MA
			; .data
			; ?statvar@StaticExample@@0MA dw 100
			; .code
			; ?GetStatVar@StaticExample@@QEAAHXZ proc
			; mov	rax, ?statvar@StaticExample@@0MA
			; ret
			; endp ?GetStatVar@StaticExample@@QEAAHXZ
			; end
			; Access modifiers are just a compiler safety veneer.
			; The constructor returns "this" and also initializes the members


			; Conditional MASM directives
			IF Asm64bit eq 1
				mov rax, 0					; Since Asm64bit is set 1, this line is included in the assembled code
			ELSE
				mov eax, 0
			ENDIF

			IFNDEF Defined					; Checks whether it is defined or not
				Defined db	-1
			ENDIF

			mov ax, @Line
			COPY rbx, rcx					; Call a macro. MASM copies macro body here
	 
			ret		0						; Return to the Operating System with exit code 0 in RAX
	main endp

	func6 proc								; Function with 6 parameters

			mov		qword ptr [rsp+20h], r9	; Function Prolog Start. Save register used for parameter passing onto the stack's preserved space
			mov		qword ptr [rsp+18h], r8  
			mov		qword ptr [rsp+10h], rdx  
			mov		qword ptr [rsp+8], rcx 	; Because the 8 byte return address is already on the stack

			jmp		alternative

			push	rbp						; Save the base pointer
			push	rdi  					; Save any of the non-volatile registers (RBX, RBP, RDI, RSI, RSP, R12, R13, R14, and R15) that may be used by the function
			; mov	rbp, rsp				; It could also be done this way. Local vars under RBP, parameters above. See alternative
			sub		rsp, 10h				; Allocate space for 2, 64 bit local variables
			mov		rbp, rsp				; This should have been done earlier, so parameters via RBP, local variable access via RSP

			mov		qword ptr [rbp+08h], 10d; Local variables on the stack
			mov		qword ptr [rbp], 8d		; Prolog End

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
			; add     rsp, 10h
			pop		rdi
			pop		rbp						; Epilog End
			ret

			; Alternative. Uses RBP to address parameters (above the return address) and RSP to address local variables
alternative:
			push	rbp
			push	rdi						; RBX, RBP, RDI, RSI, RSP, R12, R13, R14, R15 are considered non-volatile so need saving on stack
			mov		rbp, rsp				; It could also be done this way. Local vars under RBP, parameters above.
			sub		rsp, 10h				; Allocate space for 2, 64 bit local variables

			mov		qword ptr [rsp+08h], 10d; Local variables on the stack
			mov		qword ptr [rsp], 8d		; Prolog End

			; Stack
			; RBP + 40h -> param6			; Param6 and 5 passed via the stack
			; RBP + 38h -> param5
			; RBP + 30h -> R9 (param4)		; Param4 in R9
			; RBP + 28h -> R8 (param3)		; Param3 in R8
			; RBP + 20h -> RDX (param2)		; Param2 in RDX
			; RBP + 18h -> RCX (param1)		; Param1 in RCX
			; RBP + 10h -> Return address
			; RBP + 08h -> RBP				; Saved RBP
			; RBP + 00h -> RDI				; Saved RDI as non-volatile
			; RSP + 08h -> lvar2			; Local variables
			; RSP + 00h -> lvar1

			; Parameters are RBP related, local variables RSP - that is the convention. Add the 6 parameters and the 2 local variables together
			mov		rax, qword ptr [rbp+18h] ; Could be mov rax, rcx
			mov		rcx, qword ptr [rbp+20h] ; Could be add rax, rdx
			add		rax, rcx				 ; Should be non-existent
			add		rax, qword ptr [rbp+28h] ; Could be mov rcx, r8
			add		rax, qword ptr [rbp+30h] ; Could be mov rcx, r9
			add		rax, qword ptr [rbp+38h] 
			add		rax, qword ptr [rbp+40h]
			add		rax, qword ptr [rsp+08h]
			add		rax, qword ptr [rsp]

			add     rsp, 10h				; Discard local variables. Move stack pointer 16 bytes up. Function Epilog Start
			pop		rdi
			pop		rbp						; Epilog End
			ret
	func6 endp

	MyProc proc								; Function

			LOCAL	var1:WORD				; Allocates space on the stack
			LOCAL	var2:WORD				; Can not initialize them

			mov		var1, ax
			mov		var2, bx
			mov		rcx, 10

			ret

	MyProc endp								; End of my procedure
end											; Terminates the source file

