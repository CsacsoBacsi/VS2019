extrn MessageBoxA: PROC
extrn ExitProcess: PROC

.data
mytit db 'The 64-bit world of Windows & assembler...', 0
mymsg db 'Hello World!', 0

.code
Main proc
  sub rsp, 28h     ; shadow space, aligns stack
  mov rcx, 0       ; hWnd = HWND_DESKTOP
  lea rdx, mymsg   ; LPCSTR lpText
  lea r8,  mytit   ; LPCSTR lpCaption
  mov r9d, 0       ; uType = MB_OK
  call MessageBoxA
  mov ecx, eax     ; uExitCode = MessageBox(...)  
  add rsp, 28h     ; free shadow space. Has to be done!
  call ExitProcess
Main endp

End