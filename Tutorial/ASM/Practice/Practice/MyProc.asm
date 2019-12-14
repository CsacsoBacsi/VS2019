;.586													; Processor instruction set
;.model flat, C											; Under Win32, there is only one model: FLAT
														; Parameters from right to left with callee cleaning up
option casemap:none										; Labels and func names are case-sensitive

PUBLIC Proc1

;include \masm32\include\windows.inc					; Include header files. Constants, function protos, etc.
;include \masm32\include\user32.inc
;include \masm32\include\kernel32.inc
;include \masm32\include\gdi32.inc
;include \masm32\include\comdlg32.inc
;includelib \masm32\lib\user32.lib						; Tells assembler to put linker info to link functions from lib file
;includelib \masm32\lib\kernel32.lib
;includelib \masm32\lib\gdi32.lib
;includelib \masm32\lib\comdlg32.lib

.data													; Initialized data section
ClassName		db "SimpleWinClass", 0					; Null terminated string, otherwise len must be specified. Name of our window class

.data?													; Uninitialized data section

.code													; Code section Proc1

Proc1 proc par1:DWORD, par2:DWORD						; Procedure could be called anything
	LOCAL lvar1:DWORD

	mov eax, 5h
	mov lvar1, eax
	mov eax, par1
	mul par2
	add eax, lvar1

	ret													; Segment registers, ebx,edi, esi, ebp must be preserved when Windows calls our functions

Proc1 endp

end