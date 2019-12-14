.486									; Processor instruction set
.model flat,stdcall						; Under Win32, there is only one model: FLAT
										; Parameters from right to left with callee cleaning up
option casemap:none						; Labels and func names are case-sensitive

include \masm32\include\windows.inc		; Include header files. Constants, function protos, etc.
include \masm32\include\user32.inc
include \masm32\include\kernel32.inc
include \masm32\include\gdi32.inc
include \masm32\include\comdlg32.inc
includelib \masm32\lib\user32.lib

includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\gdi32.lib
includelib \masm32\lib\comdlg32.lib

.data									; Initialized data section
_data_		byte ?
CrLf		byte 0Dh, 0Ah, 0			; Carriage return + Line feed
MyStr		byte 65, 66, 0
MyNum		word 255*255
MyN2		sword 1023
MyN3		sword 1024
bcd			tbyte 12345
buff		db 5 dup (5)
str1		byte 'Fatima', 0
str2		byte 7 dup ('x')
str3		byte '1234567890', 0
str4		byte '1234557890', 0

.data?									; Uninitialized data section
; buffer	db 512 dup (?)				; Buffer to retrieve what was typed in the edit textbox

.const									; Constants
c1			equ	4

.code									; Code section
Main:									; Has to start and end with a label. Label name arbitrary
			xor	eax, eax
			mov bx, ax
			call pusheip				; Calls a label. Pushes eip onto stack
pusheip:	pop ebx

			mov bx, word ptr CrLf		; word ptr = two bytes from CrLf
			mov ebx, offset CrLf		; offset = address of CrLf
			lea esi, CrLf				; Same as above. Load effective address of CrLf

			jmp overdata
MyStr2 		byte 67						; Embedded data
overdata:
			mov bx, MyN2
			mov ax, MyN3
			cmp bx, ax
			jb less						; Signed jump
			xor eax, eax
less: 		sub bx, ax

			xor cx, cx
			mov ch, 5
			mov ebx, offset _data_ + 5	; _data_ is at the beginning of data segment. +5 is MyStr's second byte
			mov cl, byte ptr [ebx]		; Get second byte of MyStr
			mov cl, byte ptr MyStr		; Get first byte of MyStr

			mov ax, 2
			mov bx, -2
			mul bx
			mov al, 111
			mov ebx, 5
			mov ecx, 5
			sub ebx, ecx
			setz al						; Previous operation resulted in ZF set. AL = 1

			mov ecx, 5
			cld
looplab:	mov buff [ecx - 1], cl		; Populate 5 element buffer
			loop looplab				; Decrements ECX
			mov al, byte ptr buff [2]	; Get third value from buffer

			cld
			mov esi, 2100000000
			mov edi, 2120000000
			lea esi, str1				; Source string
			lea edi, str2				; Destination string
			mov ecx, 7					; How many bytes
			rep movsb					; Copy source into target byte by byte
			mov al, byte ptr str2[0]	; Check first copied value

			lea edi, str2         		; For STOS only EDI must be set
			mov al, 3					; Value to be stored
			mov ecx, 7
			rep stosb					; Store same value (3) in target string 7 times

			mov al, 't'
			mov ecx, 6
			lea edi, str1
			repne scasb					; Search for 't' in str1
          
			lea esi, str3
			lea edi, str4
			cld
			mov ecx, 10
			repe cmpsb					; Compares two string byte by byte and stops when not equal

			mov ax, 0
			mov bl, 01010100b
			bsf ax, bx					; Find first bit set in BX and store index in AX
          
			mov cx, 800
			shl ecx, 16
			mov cx, 400
			bswap ecx					; Swap byte order of reg32
          
			mov ax, 1010101010011010b
			bt ax, 5					; Test 5th bit and set Carry accordingly
			;btc, ax, 5					; Same as before but also complements the bit
			;btr, ax, 5					; Same as before but also sets bit to zero
			;bts, ax, 5					; Same as before but also sets bit to one
			jnc zero
one:		mov eax, eax
zero:		mov eax, eax

			xor ax, ax
			mov al, -2
			cbw							; Convert byte to word. If negative, msb is extended to high byte
          
			invoke ExitProcess, 0

end Main
