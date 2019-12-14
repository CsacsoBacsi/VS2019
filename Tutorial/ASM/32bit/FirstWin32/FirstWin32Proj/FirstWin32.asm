.386													; Processor instruction set
.model flat,stdcall										; Under Win32, there is only one model: FLAT
														; Parameters from right to left with callee cleaning up
option casemap:none										; Labels and func names are case-sensitive

WinMain	proto :DWORD,:DWORD,:DWORD,:DWORD				; Function prototype to tell Assembler what we expect for name/param checking
DlgProc	proto :DWORD,:DWORD,:DWORD,:DWORD				; Dialog message processing proc prototype

EXTERNDEF Proc1:proc
Proc1 proto :DWORD, :DWORD

include \masm32\include\windows.inc						; Include header files. Constants, function protos, etc.
include \masm32\include\user32.inc
include \masm32\include\kernel32.inc
include \masm32\include\gdi32.inc
include \masm32\include\comdlg32.inc
includelib \masm32\lib\user32.lib						; Tells assembler to put linker info to link functions from lib file
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\gdi32.lib
includelib \masm32\lib\comdlg32.lib

RGB macro red, green, blue								; Macro with 3 params
        xor eax, eax									; Zero out
        mov ah, blue	
        shl eax, 8										; Shift left
        mov ah, green
        mov al, red
endm

.data													; Initialized data section
ClassName		db "SimpleWinClass", 0					; Null terminated string, otherwise len must be specified. Name of our window class
AppName			db "Our First Window", 0				; Define byte = db. name of our window
TestString		db "Win32 assembly is great and easy!", 0
OurText			db "Our string!", 0
FontName		db "script",0
MsgBoxCaption	db "MsgBox caption", 0
MsgBoxText		db "MsgBox text!", 0
char			WPARAM 20h								; Key pressed in char representation. Initially space
MouseClick		db 0d									; No click yet
LMouseClick		db 0d									; No click yet
RMouseClick		db 0d									; No click yet
LeftClickStr	db "L*", 0								; Put this where left double click occurred
RightClickStr	db "R*", 0								; Put this where right double click occurred
NumChar			db 250d									; Number that will be converted to string
fmtInt			db "%d", 0								; Integer formatting string for wsprintf   
CharNum			db 10 dup (0)							; String represenation of a number
MyMenu			db "MyFirstMenu", 0						; My menu's name as in the resource file
Menu1			db "Menu11 clicked!", 0					; MsgBox msg to show menu clicked
BtnClass		db "button", 0							; Button Class. Must be button 
ButtonText 		db "My First Button", 0 				; Button text
EditClass		db "edit", 0 							; Edit textbox Class. Must be edit
EditString		db "Some text", 0						; Text that get programmatically put in the edit textbox

; Dialog box stuff
DlgName			db "MyDialog1", 0 
DlgAppName		db "Dialog Box as main window", 0 
DlgTestString	db "Edit box text", 0

; Open dialog stuff
ofn				OPENFILENAME <>							; OpenFileName structure
FilterString 	db "All Files", 0, "*.*", 0 
				db "Text Files", 0, "*.txt", 0, 0		; Description - pattern pairs. Last one must be terminated by extra 0
buffer2			db 260 dup (0)							; Holds filename selected by user. Can be initialized upon opening the dialog
OurTitle		db "-= Open File Dialog Box =-: Choose a file to open", 0 
FullPathName	db "The Full Filename with Path is: ", 0 
FullName		db "The Filename is: ", 0 
Extension		db "The Extension is: ", 0 
OutputString	db 512 dup (0)							; We produce an output in a msgbox using this string
CrLf			db 0Dh, 0Ah, 0							; Carriage return + Line feed

.data?													; Uninitialized data section
hInstance		HINSTANCE ?								; Instance handle of our program. Linear adress of our program
CommandLine		LPSTR ?									; Instance handle of command line
hitpoint		POINT <>								; To store the point of the double click
hMenu			HMENU ?									; Menu handle
hwndButton		HWND ? 									; Button handle
hwndEdit		HWND ?									; Edit textbox handle
buffer			db 512 dup (?)							; Buffer to retrieve what was typed in the edit textbox
hwndMainW		HWND ?									; Save main window handle here

.const													; Constants
ISDIALOG		equ 0									; Set to TRUE to set up  Dialog box as the main window
IDM_MNU12		equ 1005								; Menuitem ids
IDM_MNU11		equ 1007
IDM_MNU22		equ 1009
IDM_MNU21 		equ 1011
IDM_ABOUT		equ 1012
IDM_OPEN		equ 1010
IDM_MNUEXIT		equ 1013
ButtonID 		equ 1 									; The control ID of the button control 
EditID 			equ 2									; The control ID of the edit control 

; Dialog box stuff
IDC_EDIT		equ 3000								; IDC is COMMAND 
IDC_BUTTON		equ 3001 
IDC_EXIT		equ 3002 
IDM_GETTEXT		equ 32000								; IDM is MENU
IDM_CLEAR		equ 32001 
IDM_EXIT		equ 32002 

.code													; Code section
Main:													; Has to start and end with a label. Label name arbitrary
	xor eax, eax
	cmp eax, ISDIALOG
	jne dlg
	invoke GetModuleHandle, NULL						; Get instance handle of our program. eax, ecx and edx are not preserved in API calls
	mov	hInstance, eax									; Return value in eax after return from invoke
	invoke GetCommandLine								; Get instance of command line if processing cmdline input
	mov CommandLine, eax
	invoke MessageBox, NULL, addr MsgBoxText, addr MsgBoxCaption, MB_OK	; Invoke MsgBox. Addr = lea eax, MsgBoxText then push eax
	xor eax, eax

	invoke WinMain, hInstance, NULL, CommandLine, SW_SHOWDEFAULT	; Call the main procedure
	invoke ExitProcess,eax								; Exit program with return value from main procedure in eax

dlg:
	invoke GetModuleHandle, NULL						; Get instance handle of our program. eax, ecx and edx are not preserved in API calls
	mov    hInstance, eax								; Return value in eax after return from invoke
	invoke DialogBoxParam, hInstance, addr DlgName, NULL, addr DlgProc, NULL	; Creates a modal dialog
	invoke ExitProcess, eax								; Exit program with return value from main procedure in eax

; Main window procedure
WinMain proc hInst:HINSTANCE, hPrevInst:HINSTANCE, CmdLine:LPSTR, CmdShow:DWORD	; Procedure could be called anything
	LOCAL wc:WNDCLASSEX									; Create local variables on stack. Size is important to tell how many bytes need push-ing
	LOCAL msg:MSG										; LOCAL must be the first command after proc declaration
	LOCAL hwnd:HWND

	mov eax, 5
	push eax
	push eax
	call Proc1
	sub esp, 8

	; Populate window class structure
	mov wc.cbSize, SIZEOF WNDCLASSEX					; Size of our class
	mov wc.style, CS_HREDRAW or CS_VREDRAW
	mov wc.lpfnWndProc, offset WndProc					; Long pointer to call back function
	mov wc.cbClsExtra, NULL								; Extra space to use for anything in the class
	mov wc.cbWndExtra, NULL								; Extra space in the window instance (on top of class extra space)
	push  hInst
	pop wc.hInstance									; Instance handle of the program
	mov wc.hbrBackground, COLOR_WINDOW+1
	mov wc.lpszMenuName, NULL
	mov wc.lpszClassName, OFFSET ClassName				; The name of the window class
	mov wc.style, CS_DBLCLKS							; To enable handling of double clicks
	invoke LoadIcon,NULL,IDI_APPLICATION
	mov   wc.hIcon,eax
	mov   wc.hIconSm,eax
	invoke LoadCursor,NULL,IDC_ARROW
	mov   wc.hCursor,eax
	invoke RegisterClassEx, addr wc						; Register our window class

	invoke LoadMenu, hInstance, addr MyMenu				; Load menu from resource file
	mov hMenu, eax										; Store handle returned

	INVOKE CreateWindowEx, NULL,\						; No prev instance of our program in Win32.
	ADDR ClassName,\	 								; Our window class' name
	ADDR AppName,\										; Title bar
	WS_OVERLAPPEDWINDOW,\								; If no style, no min/max buttons, menu, etc..
	CW_USEDEFAULT, CW_USEDEFAULT,\						; X, Y coordinates
	CW_USEDEFAULT, CW_USEDEFAULT,\						; Width + height of window
	NULL, hMenu,\										; Parent: when closed, children close. Menu pointer
	hInst, NULL											; Instance handle of program
	
	mov hwnd, eax										; Window handle in eax
	mov hwndMainW, eax									; Save main window handle for dialog box to communicate
	INVOKE ShowWindow, hwnd,SW_SHOWNORMAL				; Display window
	INVOKE UpdateWindow, hwnd							; Refresh client area. Can be omitted

	; Enter infinite message loop until WM_QUIT message received. One msg loop for a window
	.WHILE TRUE
		INVOKE GetMessage, addr msg, NULL, 0, 0			; Does not return until there is a message. Yields control to other apps
		.BREAK .IF (!eax)								; Returns FALSE if WM_QUIT message received
		INVOKE TranslateMessage, addr msg				; Generates WM_CHAR from WM_KEYUP and WM_KEYDOWN messages. If keyboard is used
		INVOKE DispatchMessage, addr msg				; Send message to call back window proc (WndProc)
	.ENDW	
	mov     eax, msg.wParam								; Return exit code in eax
	ret													; Segment registers, ebx,edi, esi, ebp must be preserved when Windows calls our functions

WinMain endp

; Callback procedure to handle messages
WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM	; hWnd: message for this window. uMsg: message number. + extra params
	LOCAL hdc:HDC
	LOCAL ps:PAINTSTRUCT								; Values not really used 
	LOCAL hfont:HFONT
	LOCAL rect:RECT										; To store client area where to draw text

	.IF uMsg == WM_DESTROY								; User closes the window. Already removed from screen. Program must respond to this message. DestroyWindow
		invoke PostQuitMessage, NULL					; Posts WM_QUIT back to message queue that breaks the message loop
														; To stop users from closing window, handle WM_CLOSE
	.ELSEIF uMsg == WM_CREATE							; When window gets created 
		invoke CreateWindowEx, WS_EX_CLIENTEDGE, addr EditClass, NULL,\ 	; Create edit textbox
			WS_CHILD or WS_VISIBLE or WS_BORDER or ES_LEFT or\ 
			ES_AUTOHSCROLL,\ 
			100, 70, 200, 25, hWnd, EditID, hInstance, NULL 
		mov  hwndEdit, eax								; Store edit handle
		invoke SetFocus, hwndEdit						; Transfer focus to edit textbox
		invoke CreateWindowEx, NULL, addr BtnClass, addr ButtonText,\ 	; Create button
			WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\ 
			100, 110, 140, 25, hWnd, ButtonID, hInstance, NULL 
		mov  hwndButton, eax							; Store button handle
	.ELSEIF uMsg == WM_CHAR								; Char pressed on keyboard
		push wParam
		pop char
		invoke InvalidateRect, hWnd, NULL,TRUE			; Force a paint message
	.ELSEIF uMsg ==  WM_LBUTTONDBLCLK || uMsg == WM_RBUTTONDBLCLK	; Mouse button double click
		.IF uMsg == WM_LBUTTONDBLCLK 
			mov RMouseClick, FALSE
			mov LMouseClick, TRUE
		.ELSE
			mov RMouseClick, TRUE
			mov LMouseClick, FALSE
		.ENDIF
		mov eax, lParam									; Store click point in struct
		and eax, 0FFFFh
		mov hitpoint.x, eax
		mov eax, lParam
		shr eax, 16
		mov hitpoint.y, eax
		mov MouseClick, TRUE
		invoke InvalidateRect, hWnd, NULL,TRUE			; Force to repaint area
	.ELSEIF uMsg == WM_PAINT							; Client area needs repaint as it is invalid
		invoke BeginPaint, hWnd, addr ps				; eax will hold pointer to Device Context
		mov    hdc, eax
		invoke GetClientRect, hWnd, addr rect			; Get client area
		invoke DrawText, hdc, addr OurText, -1, addr rect, DT_SINGLELINE or DT_CENTER or DT_VCENTER	; -1 is no of chars to output since null terminated
		invoke CreateFont, 24, 16,\						; Height and width 
				0, 0,\									; Char rotation
				400, 0, 0,\								; Thickness, italic, Underline
				0, OEM_CHARSET,\						; Strike out, charset
				OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS,\
				DEFAULT_QUALITY, DEFAULT_PITCH or FF_SCRIPT,\
				ADDR FontName
		invoke SelectObject, hdc, eax					; Select font into Device Context
		mov    hfont, eax								; Handle to replaced object
		RGB    200, 200, 50
		invoke SetTextColor, hdc, eax					; Set font color
		RGB    0, 0, 255
		invoke SetBkColor, hdc, eax						; Set background color
		invoke TextOut, hdc, 0, 0, addr TestString, SIZEOF TestString	; X, Y coordinate
		invoke TextOut, hdc, 0, 25, addr char, 1		; Display keystroke char
		invoke SelectObject, hdc, hfont					; Restore old font back to Device Context
		.IF MouseClick && LMouseClick
			invoke lstrlen, addr LeftClickStr			; Get length of string to display
			invoke TextOut, hdc, hitpoint.x, hitpoint.y, addr LeftClickStr, eax
		.ENDIF
		.IF MouseClick && RMouseClick
			invoke lstrlen, addr RightClickStr			; Get length of string to display
			invoke TextOut, hdc, hitpoint.x, hitpoint.y, addr RightClickStr, eax
			invoke wsprintf, addr CharNum, addr fmtInt, NumChar	; Buffer to store result, format string, value to convert
			invoke lstrlen, addr CharNum  				; Get length
			invoke TextOut, hdc, hitpoint.x, hitpoint.y, addr CharNum, eax	; Length in eax
		.ENDIF
		invoke EndPaint, hWnd, addr ps					; Release handle to Device Context
	.ELSEIF uMsg == WM_COMMAND							; Menu item clicked
		mov eax, wParam
		.IF lParam == 0									; Command came from menu not from control 
			.IF ax == IDM_MNU11							; Menu id clicked is in ax
				invoke MessageBox, NULL, addr Menu1, addr AppName, MB_OK
			.ELSEIF ax == IDM_MNU21
				invoke SetWindowText, hwndEdit, addr EditString	; Place a string in the edit textbox control
			.ELSEIF ax == IDM_MNU12
				invoke GetWindowText, hwndEdit, addr buffer, 512	; Retrieve text from edit textbox
				invoke MessageBox, NULL, addr buffer, addr AppName, MB_OK 
			.ELSEIF ax == IDM_MNU22
				invoke SetWindowText, hwndEdit, NULL	; Clear text in edit textbox control
			.ELSEIF ax == IDM_ABOUT
				invoke DialogBoxParam, hInstance, addr DlgName, hWnd, addr DlgProc, NULL	; Create dialog box
			.ELSEIF ax == IDM_MNUEXIT
				invoke DestroyWindow, hWnd				; Close window
			.ELSEIF ax == IDM_OPEN 
				mov ofn.lStructSize, SIZEOF ofn			; Size of the OPENFILENAME struct 
				push hWnd 
				pop ofn.hwndOwner						; Handle of window calling this dialog
				push hInstance 
				pop ofn.hInstance						; Handle of program module calling this dialog 
				mov ofn.lpstrFilter, offset FilterString	; Predefined filter strings 
				mov ofn.lpstrFile, offset buffer2		; Buffer we expect the full pathname in. buffer2 can contain initial filename
				mov ofn.nMaxFile, 260					; Max fullpathname size 
				mov ofn.Flags, OFN_FILEMUSTEXIST or \	; File and path must exist 
					OFN_PATHMUSTEXIST or OFN_LONGNAMES or\	; Show long filenames
					OFN_EXPLORER or OFN_HIDEREADONLY	; Appearance is Explorer-like, hides read-only checkbox
				mov ofn.lpstrTitle, offset OurTitle		; Dialog title
				invoke GetOpenFileName, offset ofn		; Open dialog
				; Return value is TRUE if a file is selected
				.IF eax == TRUE 
					invoke lstrcat, addr OutputString, addr FullPathName	; Concatenate strings 
					invoke lstrcat, addr OutputString, ofn.lpstrFile		; Holds fullpath to file selected
					invoke lstrcat, addr OutputString, addr CrLf			; New line here 
					invoke lstrcat, addr OutputString, addr FullName
					mov eax, ofn.lpstrFile				; Pointer of the fullpathname 
					push ebx							; Save EBX
					xor ebx, ebx						; Zero out EBX 
					mov bx, ofn.nFileOffset				; Filename starts here. In BX 
					add eax, ebx						; Add two together to point at the start of the filename 
					pop ebx								; Restore EBX 
					invoke lstrcat, addr OutputString, eax	; Concatenate filename with the rest of the string  
					invoke lstrcat, addr OutputString, addr CrLf	; New line here 
					invoke lstrcat, addr OutputString, addr Extension 
					mov eax, ofn.lpstrFile 
					push ebx 
					xor ebx, ebx 
					mov bx, ofn.nFileExtension			; File extension starts here 
					add eax, ebx 
					pop ebx 
					invoke lstrcat, addr OutputString, eax 
					invoke MessageBox, hWnd, addr OutputString, addr AppName, MB_OK	; Show all in msgbox 
					invoke RtlZeroMemory, addr OutputString, 512	; Init this buffer again for next use 
				.ENDIF
			.ENDIF
		.ELSE											; Command came from a control
			.IF ax == ButtonID							; Control id is in low-word of wParam 
				shr eax, 16								; Shift high-word into low_word
				.IF ax == BN_CLICKED					; Notification code (msg) is in high-word of wParam 
					invoke SendMessage, hWnd, WM_COMMAND, IDM_MNU21, 0	; Simulate as if menuitem had been clicked 
				.ENDIF									; lParam contains handle to control
			.ENDIF 
		.ENDIF 
        .ELSE
		invoke DefWindowProc, hWnd, uMsg, wParam, lParam	; Default message processing if we are not interested in the message
		ret
	.ENDIF
	xor    eax,eax										; Window func must return LRESULT
	ret													; Segment registers, ebx,edi, esi, ebp must be preserved when Windows calls our functions
WndProc endp

DlgProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM 
	.IF uMsg == WM_INITDIALOG							; No WM_CREATE but this instead. Initialization code comes here 
		invoke GetDlgItem, hWnd, IDC_EDIT				; Get the control's ID
		invoke SetFocus, eax							; then set the focus
	.ELSEIF uMsg == WM_CLOSE							; No WM_DESTROY but this
		invoke SendMessage, hWnd, WM_COMMAND, IDM_EXIT, 0	; Send message to exit menu
	.ELSEIF uMsg == WM_COMMAND 
		mov eax, wParam 
		.IF lParam == 0									; Command came from menu not from control
			.IF ax == IDM_GETTEXT
				invoke GetDlgItemText, hWnd, IDC_EDIT, addr buffer, 512	; Get text in textbox 
				invoke MessageBox, NULL, addr buffer, addr DlgAppName, MB_OK
				invoke SendMessage, hwndMainW, WM_COMMAND, IDM_MNU21, 0	; Send message to main window. 
			.ELSEIF ax == IDM_CLEAR 
				invoke SetDlgItemText, hWnd, IDC_EDIT, NULL	; Set text in textbox  
			.ELSEIF ax == IDM_EXIT 
				invoke EndDialog, hWnd, NULL			; No DestroyWindow but this. Dialog box mgr handles it and closes window
			.ENDIF 
		.ELSE											; Command came from a control
			mov edx, wParam								; Control id is in low-word of wParam
			shr edx,16									; Shift high-word into low_word
			.IF dx == BN_CLICKED						; Notification code (msg) is in high-word of wParam
				.IF ax == IDC_BUTTON 
					invoke SetDlgItemText, hWnd, IDC_EDIT, addr DlgTestString 
				.ELSEIF ax == IDC_EXIT 
					invoke SendMessage, hWnd, WM_COMMAND, IDM_EXIT, 0 
				.ENDIF 
			.ENDIF 
		.ENDIF 
	.ELSE 
		mov eax, FALSE									; Dialog proc must return boolean FALSE if message is not processed 
		ret 
	.ENDIF 
	mov eax, TRUE										; Dialog proc must return boolean TRUE if message is processed
	ret 
DlgProc endp 

end Main
