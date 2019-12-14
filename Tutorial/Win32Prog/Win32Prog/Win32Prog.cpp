#include <windows.h>
#include <commctrl.h>
#include <stdio.h>
#include <io.h>
#include <fcntl.h>
#include <time.h>
#include "Resource.h"

#define IDC_MAIN_EDIT	1000
#define IDC_MYTIMER		1001
#define IDC_MYTHREAD    1111
#define IDC_CONTEXTMENU1 1999
#define IDC_CONTEXTMENU2 2000
const char g_szClassName[] = "myWindowClass";// The variable above stores the name of our window class, we will use it shortly to register our window class with the system
// sz = null (zero) terminated string
// Function proto types
LRESULT		CALLBACK WndProc(HWND, UINT, WPARAM, LPARAM);
BOOL		CALLBACK AboutDlgProc(HWND, UINT, WPARAM, LPARAM);
BOOL		CALLBACK ToolDlgProc(HWND, UINT, WPARAM, LPARAM);
BOOL		CALLBACK ControlDlgProc(HWND, UINT, WPARAM, LPARAM);
BOOL		CALLBACK ButtonDlgProc(HWND, UINT, WPARAM, LPARAM);
BOOL		CALLBACK FileDlgProc(HWND, UINT, WPARAM, LPARAM);
BOOL		CALLBACK TreeViewDlgProc(HWND, UINT, WPARAM, LPARAM);
void		CALLBACK qTimerProc(void * lpParameter, BOOLEAN TimerOrWaitFired);
int			CALLBACK Thread3FuncEvent(long int *);
int			CALLBACK Thread4FuncEvent(long int *);
int			CALLBACK Thread5Func(long int *);
int			CALLBACK Thread6Func(long int *);
int			CALLBACK Thread7Func(long int *);
int			CALLBACK Thread8MsgFunc(long int *);
BOOL		LoadTextFile(HWND, LPCTSTR);
BOOL		SaveTextFile(HWND, LPCTSTR);
HBITMAP		CreateBitmapMask(HBITMAP, COLORREF);
int			ThreadFunc (long int *);
void		ResizeConsole(HANDLE, SHORT, SHORT);
void		PopulateTreeView (HWND) ;
void		GetTreeViewItem(HWND) ;
// Handles, local variables
HWND		hToolbar = NULL;
HWND		hButtonDialog = NULL;
HWND		hControlDialog = NULL;
HWND		hFileDialog = NULL;
HWND		hTreeViewDialog = NULL ;
HWND		hToolBar = NULL;
TBBUTTON	tbb[3];
TBADDBITMAP tbab;
HWND		hStatusBar;
HMENU		hMenu, hSubMenu;
HICON		hIcon, hIconSm;
HWND		hMainWindow = NULL;
HBRUSH		hbrBackground = NULL; 
HBRUSH		whiteBrush; 
HFONT		hfDefault;
HWND		hEdit;
char		repaintNumChar[40];
int			repaintNum = 0;
PAINTSTRUCT pstruct;
PAINTSTRUCT * ppstruct = &pstruct;
HDC			hDC;
RECT		rcClient, invRegion ;
HBITMAP		hbmBall = NULL;
HBITMAP		hbmTrpBall = NULL;
HBITMAP     hbmOrigBall = NULL;
HBITMAP		hbmMask = NULL;
HFONT		hFont, oldFont;
HPEN		hPen, oldPen;
HBRUSH		hBrush, oldBrush;
const int	MaxCount = 20;
volatile int	Count = 0;
int			ThreadFuncParam;
int			TimerCount = 0;
long int	ThreadId1, ThreadId2;
long int	ThreadId3, ThreadId4;
long int	ThreadId5, ThreadId6;
long int	ThreadId7, ThreadId8;
HANDLE		qTimerHandle = NULL;
PHANDLE		pqTimerHandle = &qTimerHandle;
int			qTimerFuncParam = 16;
HANDLE		hTimerQueue = NULL;
FILE		* stream;
HANDLE		hThread;
HANDLE		hThread1, hThread2;
HANDLE		hThread3, hThread4;
HANDLE		hThread5, hThread6;
HANDLE		hThread7, hThread8;
HANDLE		hMutex;
HANDLE		hEventThread3;
HANDLE		hEventThread4;
HANDLE		Array_Of_Events_Handles[2];
int			suspended = 0;
CRITICAL_SECTION gCS; // Critical section – very similar to mutexes, actually this must be a mutex in the background. Must be declared a shared structure basically a mutex object
HANDLE		hSemaphore;

int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow)
// hInstance	= Handle to the programs executable module (the .exe file in memory). It is used for things like loading resources and any other task which is 
//				  performed on a per-module basis. A module is either the EXE or a DLL loaded into your program
// hPrevInstance= Is used to be the handle to the previously run instance of your program (if any) in Win16. This no longer applies. In Win32 you ignore this parameter
// lpCmdLine	= The command line arguments as a single string. NOT including the program name
// nCmdShow		= An integer value which may be passed to ShowWindow()
// WINAPI		= _stdcall = Parameters passed from right to left. Callee cleans up. In __cdecl the caller cleans up
//				  Function name is decorated by prepending an underscore character and appending a '@' character and the number of bytes of stack space required
// LPSTR		= char * (long pointer to a string)
{
	WNDCLASSEX wc;
	HWND hwnd;
	MSG Msg;

	// Step 1: Registering the Window Class
	// A Window Class stores information about a type of window, including it's Window Procedure which controls the window, the small and large icons for the window, 
	// and the background color. This way, you can register a class once, and create as many windows as you want from it, without having to specify all those attributes
	// over and over. Most of the attributes you set in the window class can be changed on a per-window basis if desired. 
	// A Window Class has NOTHING to do with C++ classes

	wc.cbSize = sizeof(WNDCLASSEX);						// Window Class size
	wc.style = 0;										// Class Styles (CS_*)
	wc.lpfnWndProc = WndProc;							// The callback function
	wc.cbClsExtra = 0;									// Amount of extra data allocated for this class in memory. Usually 0
	wc.cbWndExtra = 0;									// Amount of extra data allocated in memory per window of this type. Usually 0
	wc.hInstance = hInstance;							// The program's handle
														//	wc.hIcon		 = LoadIcon (NULL, IDI_APPLICATION);	// Large (usually 32x32) icon shown when the user presses Alt+Tab
	wc.hIcon = NULL;
	wc.hCursor = LoadCursor(NULL, IDC_ARROW);			// Cursor that will be displayed over our window
	wc.hbrBackground = NULL; // (HBRUSH)(COLOR_WINDOW + 1);	// Background Brush to set the color of our window
	//	wc.lpszMenuName  = MAKEINTRESOURCE(IDR_MENU1);	// Name of a menu resource to use for the windows with this class
	wc.lpszMenuName = NULL;								// Create menu via WM_CREATE and custom code not setting this parameter to the main menu ID
	wc.lpszClassName = g_szClassName;					// Name to identify the class with
	wc.hIconSm = NULL;									// Small (usually 16x16) icon to show in the taskbar and in the top left corner of the window

	if (!RegisterClassEx(&wc))
	{
		MessageBox(NULL, "Window Registration Failed!", "Error!", MB_ICONEXCLAMATION | MB_OK);
		return 0;
	}

	// Step 2: Creating the Window
	hwnd = CreateWindowEx(
		WS_EX_CLIENTEDGE,						// The first parameter (WS_EX_CLIENTEDGE) is the extended windows style, in this case I have set it to give it a sunken inner border around the window
		g_szClassName,							// The class name tells the system what kind of window to create
		"The title of my window",				// Our window name or title which is the text that will be displayed in the Caption, or Title Bar on our window. 
		WS_OVERLAPPEDWINDOW,					// It is the Window Style parameter
		CW_USEDEFAULT, CW_USEDEFAULT, 1150, 900,// These are the X and Y co-ordinates for the top left corner of your window, and the width and height of the window
		NULL, NULL, hInstance, NULL);			// The Parent Window handle, the menu handle, the application instance handle, and a pointer to window creation data.
												// In windows, the windows on your screen are arranged in a heirarchy of parent and child windows. When you see a button on a window, the button is the Child 
												// and it is contained within the window that is it's Parent. In this example, the parent handle is NULL because we have no parent, this is our main or Top 
												// Level window. The menu is NULL for now since we don't have one yet. The instance handle is set to the value that is passed in as the first parameter to WinMain().
												// The creation data (which is almost never used) that can be used to send additional data to the window that is being created is also NULL. NULL is a pointer zero

	if (hwnd == NULL)
	{
		MessageBox(NULL, "Window Creation Failed!", "Error!", MB_ICONEXCLAMATION | MB_OK);
		return 0;
	}

	ShowWindow(hwnd, nCmdShow);					// The nCmdShow parameter is optional, you could pass in SW_SHOWNORMAL all the time and be done with it. 
	UpdateWindow(hwnd);							// However using the parameter passed into WinMain() gives whoever is running your program to specify whether
												// or not they want your window to start off visible, maximized, minimized, etc

	// Step 3: The Message Loop
	while (GetMessage(&Msg, NULL, 0, 0) > 0)	// By calling GetMessage () you are requesting the next available message to be removed from the queue and returned to you for processing
	{											// If there is no message, GetMessage () Blocks. 
		if (!IsDialogMessage(hToolbar, &Msg)	// IsDialogMessage handles the modless dialog (toolbar) messages and does not let the main window handle it
			&& !IsDialogMessage(hControlDialog, &Msg)
			&& !IsDialogMessage(hFileDialog, &Msg))
		{										// The toolbar window has no message loop unlike the modal dialog
			TranslateMessage(&Msg);				// It does some additional processing on keyboard events like generating WM_CHAR messages to go along with WM_KEYDOWN messages
			DispatchMessage(&Msg);				// Sends the message out to the window that the message was sent to. This could be our main window or it could be another one, or a control
		}
		// Checks which window it is for and then looks up the Window Procedure for the window. It then calls that procedure, sending as parameters 
		// the handle of the window, the message, and wParam and lParam
		// WNDPROC fWndProc = (WNDPROC) GetWindowLong (Msg.hwnd, GWL_WNDPROC);	// Get the function pointer to the callback function
		// fWndProc (Msg.hwnd, Msg.message, Msg.wParam, Msg.lParam);			// Send the message to the callback function directly. Same as DispatchMessage ()

	}
	return Msg.wParam;
}

// Step 4: the Window Procedure
LRESULT CALLBACK WndProc (HWND hwnd,		// Handle of the window. There can be multiple windows of the same class
						  UINT msg,			// The message structure
						  WPARAM wParam,	// Message parameters
						  LPARAM lParam)
{
	hMainWindow = hwnd;
	switch(msg)
	{
		case WM_CREATE:
		{
			// Create menu
			hMenu = CreateMenu ();

			hSubMenu = CreatePopupMenu ();
			AppendMenu(hSubMenu, MF_STRING, ID_FILE_FILEDIALOG_SHOW, "File Dialog");
			AppendMenu (hSubMenu, MF_STRING, ID_FILE_EXIT, "E&xit");
			AppendMenu (hMenu, MF_STRING | MF_POPUP, (UINT)hSubMenu, "&File");

			hSubMenu = CreatePopupMenu();
			AppendMenu (hSubMenu, MF_STRING, ID_EDIT_ADD_TEXT, "&Click Add text");
			AppendMenu (hSubMenu, MF_STRING, ID_EDIT_DISABLE_CTRLDLG_OK, "&Disable Control Dialog OK");
			AppendMenu (hSubMenu, MF_STRING, ID_EDIT_ABOUT, "&About");
			AppendMenu (hMenu, MF_STRING | MF_POPUP, (UINT)hSubMenu, "&Edit");

			hSubMenu = CreatePopupMenu();
			AppendMenu (hSubMenu, MF_STRING, ID_TOOLBAR_SHOW, "&Show Toolbar");
			AppendMenu (hSubMenu, MF_STRING, ID_TOOLBAR_HIDE, "&Hide Toolbar");
			AppendMenu (hMenu, MF_STRING | MF_POPUP, (UINT)hSubMenu, "&Toolbar");

			hSubMenu = CreatePopupMenu();
			AppendMenu (hSubMenu, MF_STRING, ID_CONTROLDIALOG_SHOW, "&Show Control Dialog");
			AppendMenu(hSubMenu, MF_STRING, ID_CONTROLDIALOG_RECREATE, "&Re-create Control Dialog");
			AppendMenu (hMenu, MF_STRING | MF_POPUP, (UINT)hSubMenu, "ControlDialog");

			hSubMenu = CreatePopupMenu();
			AppendMenu(hSubMenu, MF_STRING, ID_BUTTONDIALOG_SHOW, "&Show Button Dialog");
			AppendMenu(hSubMenu, MF_STRING, ID_BUTTONDIALOG_HIDE, "&Hide Button Dialog");
			AppendMenu(hMenu, MF_STRING | MF_POPUP, (UINT)hSubMenu, "ButtonDialog");

			hSubMenu = CreatePopupMenu();
			AppendMenu(hSubMenu, MF_STRING, ID_THREADS_MUTEX, "&Mutex");
			AppendMenu(hSubMenu, MF_STRING, ID_THREADS_EVENT, "&Event");
			AppendMenu(hSubMenu, MF_STRING, ID_THREADS_SEMAPHORE, "&Semaphore");
			AppendMenu(hSubMenu, MF_STRING, ID_THREADS_MESSAGE, "&Message");
			AppendMenu(hSubMenu, MF_STRING, ID_THREADS_TIMER, "&Timers");
			AppendMenu(hMenu, MF_STRING | MF_POPUP, (UINT)hSubMenu, "Threads and Timers");

			hSubMenu = CreatePopupMenu();
			AppendMenu(hSubMenu, MF_STRING, ID_CONSOLE_CREATE, "&Set up console");
			AppendMenu(hSubMenu, MF_SEPARATOR, 0, NULL);
			AppendMenu(hSubMenu, MF_STRING, ID_CONSOLE_RANDOM, "&Random number");
			AppendMenu(hSubMenu, MF_STRING, ID_CONSOLE_PRINTF, "&Printf () demo");
			AppendMenu(hSubMenu, MF_STRING, ID_CONSOLE_DATETIME, "&Date and time");
			AppendMenu(hMenu, MF_STRING | MF_POPUP, (UINT)hSubMenu, "Console");

			hSubMenu = CreatePopupMenu();
			AppendMenu(hSubMenu, MF_STRING, ID_TREEVIEWDIALOG_SHOW, "&Show dialog");
			AppendMenu(hMenu, MF_STRING | MF_POPUP, (UINT)hSubMenu, "T&ree view") ;

			SetMenu(hwnd, hMenu);
			EnableMenuItem(GetSubMenu(GetMenu(hMainWindow), 3), ID_CONTROLDIALOG_RECREATE, MF_DISABLED | MF_GRAYED| MF_BYCOMMAND);

			// Set icons
			hIcon = (HICON)LoadImage(NULL, "MyIcon.ico", IMAGE_ICON, 32, 32, LR_LOADFROMFILE);	// LoadIcon if a resource is loaded
			if (hIcon)
				SendMessage(hwnd, WM_SETICON, ICON_BIG, (LPARAM)hIcon);
			else
				MessageBox(hwnd, "Could not load large icon!", "Error", MB_OK | MB_ICONERROR);

			hIconSm = (HICON)LoadImage(NULL, "MyIcon.ico", IMAGE_ICON, 16, 16, LR_LOADFROMFILE);
			if (hIconSm)
				SendMessage(hwnd, WM_SETICON, ICON_SMALL, (LPARAM)hIconSm);
			else
				MessageBox(hwnd, "Could not load small icon!", "Error", MB_OK | MB_ICONERROR);
			
			// Create toolbar dialog (modless)
			hToolbar = CreateDialog (GetModuleHandle(NULL), MAKEINTRESOURCE (IDD_TOOLBAR), hwnd, ToolDlgProc);
			if (hToolbar == NULL)
			{
				MessageBox (hwnd, "CreateDialog for Toolbar returned NULL", "Warning!", MB_OK | MB_ICONINFORMATION);
			}

			// Create button dialog (modless)
			hButtonDialog = CreateDialog(GetModuleHandle(NULL), MAKEINTRESOURCE(IDD_DIALOG_BUTTON), hwnd, ButtonDlgProc);
			if (hButtonDialog == NULL)
			{
				MessageBox(hwnd, "ButtonDialog returned NULL", "Warning!", MB_OK | MB_ICONINFORMATION);
			}

			// Create control dialog (modless)
			hControlDialog = CreateDialog (GetModuleHandle(NULL), MAKEINTRESOURCE(IDD_DIALOG_CONTROL), hwnd, ControlDlgProc);
			if (hControlDialog == NULL)
			{
				MessageBox(hwnd, "CreateDialog for Control Dialog returned NULL", "Warning!", MB_OK | MB_ICONINFORMATION);
			}

			// Create file dialog (modless)
			hFileDialog = CreateDialog (GetModuleHandle(NULL), MAKEINTRESOURCE(IDD_DIALOG_FILE), hwnd, FileDlgProc);
			if (hFileDialog == NULL)
			{
				MessageBox(hwnd, "CreateDialog File Dialog returned NULL", "Warning!", MB_OK | MB_ICONINFORMATION);
			}

			// Create tree view dialog (modless)
			hTreeViewDialog = CreateDialog (GetModuleHandle (NULL), MAKEINTRESOURCE (IDD_DIALOG_TREEVIEW), hwnd, TreeViewDlgProc);
			if (hTreeViewDialog == NULL)
			{
				MessageBox(hwnd, "CreateDialog Tree View Dialog returned NULL", "Warning!", MB_OK | MB_ICONINFORMATION);
			}

			// Create toolbar
			hToolBar = CreateWindowEx(0, TOOLBARCLASSNAME, NULL, WS_CHILD | WS_VISIBLE, 0, 0, 0, 0,
				hwnd, (HMENU)IDR_TOOLBAR, GetModuleHandle(NULL), NULL);
			if (hToolBar == NULL)
				MessageBox(hwnd, "Could not create tool bar.", "Error", MB_OK | MB_ICONERROR);

			// Send the TB_BUTTONSTRUCTSIZE message, which is required for
			// backward compatibility.
			SendMessage(hToolBar, TB_BUTTONSTRUCTSIZE, (WPARAM)sizeof(TBBUTTON), 0);

			tbab.hInst = HINST_COMMCTRL;							// Common controls
			tbab.nID = IDB_STD_SMALL_COLOR;							// Built in standard set
			SendMessage(hToolBar, TB_ADDBITMAP, 0, (LPARAM)&tbab);	// Add bitmaps first via a message

			ZeroMemory(tbb, sizeof(tbb));
			tbb[0].iBitmap = STD_FILENEW;
			tbb[0].fsState = TBSTATE_ENABLED;
			tbb[0].fsStyle = TBSTYLE_BUTTON;
			tbb[0].idCommand = IDC_TOOLBAR_NEW;

			tbb[1].iBitmap = STD_FILEOPEN;
			tbb[1].fsState = TBSTATE_ENABLED;
			tbb[1].fsStyle = TBSTYLE_BUTTON;
			tbb[1].idCommand = IDC_TOOLBAR_OPEN;

			tbb[2].iBitmap = STD_FILESAVE;
			tbb[2].fsState = TBSTATE_ENABLED;
			tbb[2].fsStyle = TBSTYLE_BUTTON;
			tbb[2].idCommand = IDC_TOOLBAR_SAVE;

			SendMessage(hToolBar, TB_ADDBUTTONS, sizeof(tbb) / sizeof(TBBUTTON),(LPARAM) &tbb);
			//ShowWindow(hToolBar, TRUE);

			// Status bar
			int statwidths[] = {120, 240, -1};								// Cummulative widths! Not individual! They are equal as window width is 360
			hStatusBar = CreateWindowEx(0, STATUSCLASSNAME, NULL,
				WS_CHILD | WS_VISIBLE | SBARS_SIZEGRIP, 0, 0, 0, 0,
				hwnd, (HMENU)130, GetModuleHandle(NULL), NULL);

			SendMessage(hStatusBar, SB_SETPARTS, (WPARAM)3, (LPARAM)statwidths); // sizeof(statwidths) / sizeof(int)
			SendMessage(hStatusBar, SB_SETTEXT, (WPARAM)0, (LPARAM)"Statusbar 1");
			SendMessage(hStatusBar, SB_SETTEXT, (WPARAM)1, (LPARAM)"Statusbar 2");
			SendMessage(hStatusBar, SB_SETTEXT, (WPARAM)2, (LPARAM)"Statusbar 3");

			// Background brush
			hbrBackground = CreateSolidBrush(RGB(0, 0, 0));	// Create a brush to be used later (for the toolbar dialog background)

			// Create an edit control at run-time
			/*hEdit = CreateWindowEx(WS_EX_CLIENTEDGE, "EDIT", "", 
				WS_CHILD | WS_VISIBLE | WS_VSCROLL | WS_HSCROLL | ES_MULTILINE | ES_AUTOVSCROLL | ES_AUTOHSCROLL,
				0, 0, 100, 100, hwnd, (HMENU)IDC_MAIN_EDIT, GetModuleHandle(NULL), NULL);	// The parent window is the main window
																							// GetModuleHandle with NULL returns the handle to the main executable (exe, the caller process)
			if (hEdit == NULL)
				MessageBox(hwnd, "Could not create edit box.", "Error", MB_OK | MB_ICONERROR);
			*/
			hfDefault = (HFONT)GetStockObject(DEFAULT_GUI_FONT);
			SendMessage(hEdit, WM_SETFONT, (WPARAM)hfDefault, MAKELPARAM(FALSE, 0));

			// Bitmap
			hbmBall = LoadBitmap (GetModuleHandle(NULL), MAKEINTRESOURCE(IDB_BITMAP_RED_BALL));
			if (hbmBall == NULL)
				MessageBox(hwnd, "Could not load IDB_BITMAP_RED_BALL!", "Error", MB_OK | MB_ICONEXCLAMATION);

			hbmOrigBall = LoadBitmap(GetModuleHandle(NULL), MAKEINTRESOURCE(IDB_BITMAP_TRP_BALL));
			if (hbmOrigBall == NULL)
				MessageBox(hwnd, "Could not load IDB_BITMAP_TRP_BALL!", "Error", MB_OK | MB_ICONEXCLAMATION);

			hbmTrpBall = LoadBitmap(GetModuleHandle(NULL), MAKEINTRESOURCE(IDB_BITMAP_TRP_BALL));
			if (hbmTrpBall == NULL)
				MessageBox(hwnd, "Could not load IDB_BITMAP_TRP_BALL!", "Error", MB_OK | MB_ICONEXCLAMATION);

			hbmMask = CreateBitmapMask(hbmTrpBall, RGB(0, 255, 0));						// The background is set to green (0, 255, 0)
			if (hbmMask == NULL)
				MessageBox(hwnd, "Could not create mask!", "Error", MB_OK | MB_ICONEXCLAMATION);
			break;

			BUTTON_SPLITINFO MyInfo ;
			MyInfo.mask = BCSIF_STYLE ; // | BCSIF_GLYPH;
			MyInfo.uSplitStyle = BCSS_STRETCH;
			//MyInfo.himlGlyph = [A Glyph from an Image List]
			HANDLE hSplitButton = GetDlgItem (hwnd, IDC_SPLIT1) ;
			SendMessage ((HWND)hSplitButton, BCM_SETSPLITINFO, 0, (LPARAM)&MyInfo);

			// *** Resources ***
			// #include "resource.h"
			//
			// IDI_MYICON ICON "my_icon.ico" - In the header file give it an ID: #define IDI_MYICON  101
			// HICON hMyIcon = LoadIcon(hInstance, MAKEINTRESOURCE(IDI_MYICON)); - MAKEINTRESOURCE converts the ID to  String
			// HICON hMyIcon = LoadIcon(hInstance, "MYICON");
			// It is possible to reference it by name and not by ID. ID must be <= 65535

		}
		break;
		case WM_PAINT:
		{/*
		 1.The system asks the control to erase its background with the message WM_ERASEBKGND.Parameter wParam is set to the window's device context.
		 If the control passes the message into DefWindowProc(), this is exactly what happens. DefWindowProc() simply gets the brush which was specified
		 during window class registration (WNDCLASS::hbrBackground) and fills the control with it. The return value is also important, the message
		 should return non-zero if it performs the erase, or zero if it does not. (DefWindowProc() follows it and returns non-zero if it filled the
		 control with the background brush, or zero if it did not because the WNDCLASS::hbrBackground was set to NULL.
		 2.If the update region also intersects the non - client area of the window, the system sends WM_NCPAINT.For top - level windows, this message is
		 responsible for painting window caption, the minimize and maximize buttons, and also the menu if the window has any.For child windows(i.e., controls),
		 it is often used for painting a border and also scrollbars if the control supports them in a similar way as, for examples, the standard
		 list - view and tree - view controls do.If the control just passes the message into DefWindowProc(), it paints a border as specified by the window
		 style WS_BORDER and / or extended style WS_EX_CLIENTEDGE and the scrollbars as set by SetScrollInfo().
		 3. Finally, the WM_PAINT is sent.However, note that the system treats this message specially and it comes only after all other messages from the message
		 queue are handled and it is empty.If you think about it, it makes sense.As long as there are other messages in the queue, they may change the state of
		 the control, resulting in a need for yet another repainting. Not always sent. When ERASE background fills the rectangle, no such message!
		 */

			repaintNum++;
			GetUpdateRect(hwnd, &invRegion, FALSE);
			// Draw text
			//hDC = GetDC(hwnd);												// Gives access to the whole client area. Graphics Device Context directly
			hDC = BeginPaint(hwnd, ppstruct);									// This gives access to the invalid region ONLY!

																				//SetTextColor(hDC, 0x00000000);
			SetBkMode(hDC, TRANSPARENT);										// Whatever the current background is, TextOut will use that as background
			GetClientRect(hwnd, &rcClient);

			//rcClient.left = 40;
			//rcClient.top = 10;

			//whiteBrush = CreateSolidBrush(RGB(255, 255, 255));
			//FillRect(hDC, &rcClient, whiteBrush);								// Erase background
			//FillRect(ppstruct->hDC, &rcClient, (HBRUSH)GetStockObject(WHITE_BRUSH));	// Same
			//DeleteObject(whiteBrush);

			wsprintf(repaintNumChar, "WP_REPAINT message received: %d times", repaintNum);
			//DrawText(hDC, repaintNumChar + 0, -1, &rcClient, DT_SINGLELINE);	// Only affects the invalidated region that is why WM_ERASEBKGND must invalidate the full client area
			TextOut(hDC, 0, 200, repaintNumChar + 0, 40);						// Only updates if it is in the invalidated region

			//EndPaint(hwnd, ppstruct);											// Tells windows that the region had been repainted
			//ReleaseDC(hwnd, hDC);												// This does not tell Windows that the region is valid now. Call ValidateRect to do that
			//ValidateRect(hwnd, &rcClient);

			// Bitmap
			/* 1. Set up mask and inverted image :
			      Mask = monochrome original bitmap.White(bit value 1) background that needs to transparent and black(bit value 0) foreground(everything else).SRCCOPY original bitmap, monochrome mask
			      Inverted original bitmap = mask XOR original bitmap.White background XOR original bitmap background colour(byte - wise XOR!) = 0 (1 XOR 1), Black foreground XOR original bitmap foreground colour = 1 (0 XOR 1 unchanged).SRCINVERT monochrome mask, original bitmap
			   2. Get transparent background with black foreground :
			      Mask : white background, black foreground
			      Canvas background grey
			      Mask AND canvas = white AND grey = grey background, black AND grey = black foreground.The background is already transparent, we just need the foreground to be set to the original colours.SRCAND canvas, mask
			   3. Get transparent background and colourful foreground :
			      Mask and canvas(2.) = grey background, black foreground
			     Inverted original bitmap(1.) = black background, colourful foreground
			     Mask and canvas(2.) OR inverted original bitmap(1.) = grey OR black = grey background(transparent), black OR colourful = colourful foreground.SRCPAINT mask and canvas, inverted original bitmap
			*/

			// Drawing bitmaps
			// 0. Get the DC first
			// 1. Load the bitmap from the resource
			//bmp = LoadBitmap(hInst, MAKEINTRESOURCE(IDB_EXERCISING));
			// 2. Create a memory device compatible with the above DC variable
			//MemDC = CreateCompatibleDC(hDC);
			// 3. Select the new bitmap into it
			//SelectObject(MemDC, bmp);
			// 4. Copy the bits from the memory DC into the current DC to show the bitmap
			//BitBlt(hDC, 10, 10, 450, 400, MemDC, 0, 0, SRCCOPY);

			BITMAP bm;															// It is a struct that holds info about the bitmap. GetObject uses it
			HDC hdcMem = CreateCompatibleDC(hDC);								// Can not draw to bitmaps directly. Needs an in-,e,ory DC
			HBITMAP hbmOld = (HBITMAP)SelectObject(hdcMem, hbmBall);						// Then select the bitmap into that in-memory DC. Saves old object at the same time (return value)
			GetObject(hbmBall, sizeof(bm), &bm);								// should really be GetObjectInfo as we are after its size
			BitBlt(hDC, 0, bm.bmHeight * 3 + 50, bm.bmWidth, bm.bmHeight, hdcMem, 0, 0, SRCCOPY);	// The destination, the position and size, the source and source position, the Raster Operation (ROP code).
			SelectObject(hdcMem, hbmOld);										// Restore previous object. Compulsory!

			GetClientRect(hwnd, &rcClient);
			//FillRect(hDC, &rcClient, (HBRUSH)GetStockObject(LTGRAY_BRUSH));					// Set gray background

			// Transparent bitmap
			hbmOld = (HBITMAP)SelectObject(hdcMem, hbmOrigBall);
			BitBlt(hDC, 0, bm.bmHeight * 2 + 50, bm.bmWidth, bm.bmHeight, hdcMem, 0, 0, SRCCOPY); // Original bitmap that  we make transparent (the green area)
			SelectObject(hdcMem, hbmOld);

			hbmOld = (HBITMAP)SelectObject(hdcMem, hbmMask);
			BitBlt(hDC, 0, 50, bm.bmWidth, bm.bmHeight, hdcMem, 0, 0, SRCCOPY);					// Show the mask. White background, black foreground
			BitBlt(hDC, bm.bmWidth, 50, bm.bmWidth, bm.bmHeight, hdcMem, 0, 0, SRCAND);			// To the right, grey background AND white = grey, foreground will be black as it is 0 (grey AND black)
			BitBlt(hDC, bm.bmWidth, bm.bmHeight * 2 + 50, bm.bmWidth, bm.bmHeight, hdcMem, 0, 0, SRCAND);	// First we AND then OR. Background = grey, foreground = black. Same as previous step

			SelectObject(hdcMem, hbmTrpBall);
			BitBlt(hDC, 0, bm.bmHeight + 50, bm.bmWidth, bm.bmHeight, hdcMem, 0, 0, SRCCOPY);	// Background - black, foreground = colourful. Mask background must be white whereas the inverted bitmap must have a black background
			BitBlt(hDC, bm.bmWidth, bm.bmHeight + 50, bm.bmWidth, bm.bmHeight, hdcMem, 0, 0, SRCPAINT);		// Grey background OR black = grey, grey foreground OR colourful = mix (translucent)
			BitBlt(hDC, bm.bmWidth, bm.bmHeight * 2 + 50, bm.bmWidth, bm.bmHeight, hdcMem, 0, 0, SRCPAINT);	// First we AND then OR to get transparency. Grey background OR black = grey, black (set before) foreground OR colourful = colourful.
																											// So grey background, colourful foreground. Job done.

			SelectObject(hdcMem, hbmOld);
			DeleteDC(hdcMem);													// Release in-memory DC

			// Drawing on the canvas
			// Single-line draw
			MoveToEx(hDC, 60, 260, NULL);										// Starting point
			LineTo(hDC, 60, 362);												// Draw to here
			LineTo(hDC, 264, 362);												// From the new end point to here
			LineTo(hDC, 60, 260);												// Etc.

			// Poly-line draw
			POINT Pt1[7];
			Pt1[0].x = 320;  Pt1[0].y = 290;									// All these are LineTo coordinates from the previous ending. No need for DrawToEx
			Pt1[1].x = 480; Pt1[1].y = 290;
			Pt1[2].x = 480; Pt1[2].y = 260;
			Pt1[3].x = 530; Pt1[3].y = 310;
			Pt1[4].x = 480; Pt1[4].y = 360;
			Pt1[5].x = 480; Pt1[5].y = 330;
			Pt1[6].x = 320;  Pt1[6].y = 330;

			Polyline(hDC, Pt1, 7);												// Array holding the coordinates, number of points
			//PolylineTo(hDC, Pt1, 7);											// Draws the first line from 0,0 to 20,50

			// Poly-poly line draw
			POINT	Pt2[15];													// Total number of points (x, y coordinates)
			DWORD	lpPts[] = { 4, 4, 7 };										// How many points each polygon

			// Left Triangle
			Pt2[0].x = 630, Pt2[0].y = 260;
			Pt2[1].x = 600, Pt2[1].y = 300;
			Pt2[2].x = 680, Pt2[2].y = 300;
			Pt2[3].x = 630, Pt2[3].y = 260;
			// Second Triangle
			Pt2[4].x = 670, Pt2[4].y = 260;
			Pt2[5].x = 700, Pt2[5].y = 320;
			Pt2[6].x = 730, Pt2[6].y = 260;
			Pt2[7].x = 670, Pt2[7].y = 260;
			// Hexagon
			Pt2[8].x = 745, Pt2[8].y = 260;
			Pt2[9].x = 730, Pt2[9].y = 280;
			Pt2[10].x = 745, Pt2[10].y = 300;
			Pt2[11].x = 765, Pt2[11].y = 300;
			Pt2[12].x = 780, Pt2[12].y = 280;
			Pt2[13].x = 765, Pt2[13].y = 260;
			Pt2[14].x = 745, Pt2[14].y = 260;

			PolyPolyline(hDC, Pt2, lpPts, 3);									// Array of POINTs, number of polygon points array, number of polygons

			// Rectangle
			Rectangle(hDC, 50, 410, 256, 534);									// From x1,y1 to x2,y2

			// Draw edge
			RECT Recto1 = { 300, 410, 525, 534 };
			DrawEdge(hDC, &Recto1, BDR_RAISEDOUTER |
				BDR_SUNKENINNER, BF_RECT);										// Coordinates in a RECT struct, type of the edge, where the edge should be drawn (right, left, bottom, all, across, etc.)

			// Ellipse and circle
			Ellipse(hDC, 600, 410, 710, 455);									// Same as a rectangle, as it can fit inside one. Circles are the same in a quadrat

			// Round rectangle
			RoundRect(hDC, 600, 470, 710, 515, 32, 30);							// The corners are rounded with an ellipse. Ellipse width and height the last two parameters

			// Pie
			Pie (hDC, 600, 530, 826, 700, 355, 232, 602, 415);					// Draws an ellipse in the rectangle then to complete the pie, a line is drawn from (p5, p6) to the center
																				// and from the center to (p7, p8) points.
			// Arc
			Arc(hDC, 20, 580, 226, 700, 202, 670, 105, 590);					// Is part of an ellipse. Draw a rectangle, then arc start point (x1,y1) and end arc point (x2,y2)
			SetArcDirection(hDC, AD_CLOCKWISE);									// Default drawing direction of an arc: right to left, bottom to top
			//Arc(hDC, 20, 20, 226, 144, 202, 115, 105, 32);

			/* Colors
			   31-24	23-16	15-8	7-0
			   Reserved	Red		Green	Blue
			   It is a 32 bit value.The most significant byte must be set to zero.
			   When all 3 are equal but not 0 nor 255, the colour is grey.
			   COLORREF	NewColor1 = 16711935;
			   COLORREF	NewColor2 = RGB(255, 0, 255);							// With the RGB macro. Use GetRValue(), GetGValue() and/or GetBValue() macros to extract the value of each
			   COLORREF	SetPixel(hDC hDC, int X, int Y, COLORREF crColor);
			*/

			// Drawing text
			COLORREF	clrRedish = RGB(255, 25, 2);
			SetTextColor(hDC, clrRedish);
			SetBkMode(hDC, OPAQUE);
			SetBkColor(hDC, RGB(255, 255, 255));
			TextOut(hDC, 100, 610, "Example text", 13);							// Last param is the length of the string

			//int SetBkMode(hDC hDC, int iBkMode);								// TRANSPARENT or OPAQUE. Should the background show or not
			RECT		Recto2 = { 350, 570, 500, 690 };
			SetTextColor(hDC, RGB(0,0,255));
			ExtTextOut(hDC, 370, 610, ETO_OPAQUE,								// Starting point for the text, style, the coloured rectangle around the text, length of the text, space between characters
				&Recto2, "Example text", 13, NULL);

			// Font
			/*HFONT CreateFont(int nHeight,	int nWidth,
			int nEscapement,             // Angle used to orient the text
			int nOrientation,            // Angular orientation of the text with regards to the horizontal axis
			int fnWeight,                // FW_THIN, FW_BOLD, FW_HEAVY
			DWORD fdwItalic, DWORD fdwUnderline, DWORD fdwStrikeOut,
			DWORD fdwCharSet,            // ANSI_CHARSET, OEM_CHARSET, DEFAULT_CHARSET
			DWORD fdwOutputPrecision, DWORD fdwClipPrecision, DWORD fdwQuality,
			DWORD fdwPitchAndFamily, LPCTSTR lpszFace // Name of the font
			);*/

			hFont = CreateFont(24, 24, 45, 0, FW_NORMAL, FALSE, FALSE, FALSE, ANSI_CHARSET, OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS, DEFAULT_QUALITY, DEFAULT_PITCH | FF_ROMAN, "Times New Roman");
			oldFont = (HFONT)SelectObject(hDC, hFont);
			TextOut(hDC, 200, 128, "Times New Roman", 15);
			SelectObject(hDC, oldFont);
			DeleteObject(hFont);

			// Fonts can also be created using a font struct
			LOGFONT LogFont;
			LogFont.lfStrikeOut = 0;
			LogFont.lfUnderline = 0;
			LogFont.lfHeight = 36;
			LogFont.lfEscapement = 0;
			LogFont.lfItalic = TRUE;

			hFont = CreateFontIndirect(&LogFont);
			oldFont = (HFONT)SelectObject(hDC, hFont);
			TextOut(hDC, 200, 70, "Times New Roman italic", 22);
			SelectObject(hDC, oldFont);
			DeleteObject(hFont);

			// Pen
			/*HPEN CreatePen(
			int fnPenStyle,              // PS_SOLID, PS_DASH, PS_DOT and PS_COSMETIC (width can only be 1) or PS_GEOMETRIC (line must be SOLID or NULL)
			int nWidth,                  // Width in pixels
			COLORREF crColor);*/
			
			hPen = CreatePen(PS_DASHDOTDOT, 1, RGB(255, 25, 5));
			oldPen = (HPEN)SelectObject(hDC, hPen);
			Rectangle(hDC, 700, 50, 800, 120);
			SelectObject(hDC, oldPen);
			DeleteObject(hPen);

			// Pens can also be created using a pen struct
			LOGPEN LogPen;
			POINT penPt;
			LogPen.lopnStyle = PS_SOLID;
			penPt.x = 10;
			LogPen.lopnWidth = penPt;				// POINT.y is not used in this case
			LogPen.lopnColor = RGB(235, 115, 5);
			hPen = CreatePenIndirect(&LogPen);

			oldPen = (HPEN)SelectObject(hDC, hPen);
			Rectangle(hDC, 700, 150, 800, 220);
			SelectObject(hDC, oldPen);
			DeleteObject(hPen);

			// Brush
			hBrush = CreateSolidBrush (RGB(250, 25, 5));
			oldBrush = (HBRUSH)SelectObject(hDC, hBrush);
			Rectangle(hDC, 850, 50, 950, 120);
			SelectObject(hDC, oldBrush);
			DeleteObject(hBrush);

			// Hatched brushes
			HBRUSH hDiagonal = CreateHatchBrush(HS_BDIAGONAL, RGB(0, 0, 255)); // HS_HORIZONTAL, HS_VERTICAL, HS_FDIAGONAL
			oldBrush = (HBRUSH)SelectObject(hDC, hDiagonal);
			Rectangle(hDC, 850, 150, 950, 220);
			SelectObject(hDC, oldBrush);
			DeleteObject(hDiagonal);
			
			// Patterned brushes
			/*HBITMAP BmpBrush;
			HBRUSH  brPattern;
			BmpBrush = LoadBitmap(hInst, MAKEINTRESOURCE(IDB_PATTERN));
			brPattern = CreatePatternBrush(BmpBrush);                    // Create a brush using a bitmap
																		 // Brushes can also be created using a struct
			*/
			LOGBRUSH LogBrush;
			LogBrush.lbStyle = BS_HATCHED;
			LogBrush.lbColor = RGB(255, 0, 255);
			LogBrush.lbHatch = HS_DIAGCROSS;
			hBrush = CreateBrushIndirect(&LogBrush);
			HBRUSH oldBrush = (HBRUSH)SelectObject(hDC, hBrush);
			Rectangle(hDC, 1000, 50, 1100, 120);
			SelectObject(hDC, oldBrush);
			DeleteObject(hBrush);

			// Get object (info)
			/*int GetObject(
			_In_  HGDIOBJ hgdiobj,       // Handle to an object
			_In_  int     cbBuffer,      // Size of the struct that receives the info
			_Out_ LPVOID  lpvObject      // pointer to a struct of BITMAP, LOGPEN, LOGBRUSH, LOGFONT
			);*/

			/*Double-Buffer Multiple or Expensive Rendering Operations
			To implement a double-buffered solution, you perform the following steps:
			1. Use the CreateCompatibleDC function to create a memory device context
			that is compatible with the target display device.
			2. Create an appropriately sized device-dependent bitmap or DIB section bitmap
			that will serve as the "memory" of the memory device context.
			You can use the CreateCompatibleBitmap function to create a device-dependent bitmap
			or the CreateDIBSection function to create a DIB section bitmap.
			3. Use the SelectObject function to select the bitmap into the memory device context.
			4. Direct any rendering to the memory device context. You can simply modify your existing
			code by replacing all references to the original target device context with references
			to the memory device context.
			5. When the rendering is complete, use the BitBlt function to transfer the bits of the bitmap
			to the original target device context.

			HDC hdc;
			HDC memHdc;
			HBITMAP bitmap;
			
			hdc = GetDC(hwnd);											// Instead of BeginPaint use GetDC or GetWindowDC
			hdcMem = CreateCompatibleDC(hdc);
			bitmap = CreateCompatibleBitmap(hdc, width, height);		// always create the bitmap for the memDC from the window DC

			SelectObject(hdcMem, bitmap);

			// You only need to create the back buffer once you can reuse it over and over again after that
			Rectangle(hdcMem, 126, 0, 624, 400);						// Draw on hdcMem
			// etc.

			BltBit(hdc, 0, 0, width, height, hdcMem, 0, 0, SRCCOPY);	// when finished drawing blit the hdcMem to the hdc

			// Clean up
			DeleteDC(hdcMem);
			DeleteObject(bitmap);
			ReleaseDC(hwnd, hdc); */

			EndPaint(hwnd, ppstruct);									// GetDC() - ReleaseDC(), BeginPaint() - EndPaint(). CreateCompatibleDC() - DeleteDC()

			return 0;
			break;
		}
		case WM_ERASEBKGND:
		{
			GetUpdateRect(hwnd, &invRegion, FALSE);								// Size of the resize increment
			//InvalidateRect(hwnd, &rcClient, FALSE);							// This is key! Otherwise just the increment of the resizing will be invalidated. 
			//GetUpdateRect(hwnd, &invRegion, FALSE);							// InvalidateRect queues WM_REPAINT. It will be processed later. With UpdateWindow it is immediate!

			GetClientRect(hwnd, &rcClient);
			whiteBrush = CreateSolidBrush(RGB(255, 255, 255));
			hDC = GetDC(hwnd);
			FillRect(hDC, &rcClient, (HBRUSH)GetStockObject(LTGRAY_BRUSH));		// GetStockObject(WHITE_BRUSH));
			DeleteObject(whiteBrush);
			ReleaseDC(hwnd, hDC);
			InvalidateRect(hwnd, &rcClient, FALSE);								// Without this, no WM_PAINT message is sent
			UpdateWindow(hwnd);													// Sends instant WM_PAINT, not queued one
			return 1L;
		}
		break;
		case WM_SIZE:
		{
			//GetClientRect(hwnd, &rcClient);									// Get size of the main window without caption, menu and status bar

			// hEdit = GetDlgItem(hwnd, IDC_MAIN_EDIT);
			//SetWindowPos (hEdit, NULL, 0, 0, rcClient.right -50, rcClient.bottom -50, SWP_NOZORDER);

			RECT rcTool;
			int iToolHeight;
			RECT rcStatus;
			int iStatusHeight;

			// Size toolbar and get height
			hToolBar = GetDlgItem(hwnd, IDR_TOOLBAR);
			SendMessage(hToolBar, TB_AUTOSIZE, 0, 0);

			GetWindowRect(hToolBar, &rcTool);
			iToolHeight = rcTool.bottom - rcTool.top;

			// Size status bar and get height
			hStatusBar = GetDlgItem(hwnd, 130);
			SendMessage(hStatusBar, WM_SIZE, 0, 0);
			GetWindowRect(hStatusBar, &rcStatus);
			iStatusHeight = rcStatus.bottom - rcStatus.top;
			break;
		}
		case WM_COMMAND:
		{
			switch (LOWORD(wParam))															// Contains the ID of the command or menu item that generated the message
			{
			case ID_FILE_EXIT:
			{
				PostMessage(hwnd, WM_CLOSE, 0, 0);											// Send a WM_CLOSE message handled further down
			}
			break;
			case ID_EDIT_ADD_TEXT:
			{
				SendMessage(hControlDialog, WM_COMMAND, IDC_BUTTON_ADD, IDC_BUTTON_ADD);	// Send message to window proc of control dialog to ADD button to add text
				// SendDlgItemMessage(hControlDialog, IDC_LIST1, LB_RESETCONTENT, 0, 0);	// Send message to ListBox control directly
			}
			break;
			case ID_EDIT_DISABLE_CTRLDLG_OK:
			{
				EnableWindow(GetDlgItem(hControlDialog, ID_BUTTON_COK), FALSE);				// Get the handle to the window (dialog) first then set control
			}
			break;
			case ID_EDIT_ABOUT:
			{
				int ret = DialogBox(GetModuleHandle(NULL), MAKEINTRESOURCE(IDD_DIALOG_ABOUT), hwnd, AboutDlgProc); // Creates a modal dialog. Blocks until closed
				if (ret == IDC_BUTTON_OK) {
					MessageBox(hwnd, "Dialog exited with OK.", "Notice", MB_OK | MB_ICONINFORMATION);
				}
				else if (ret == IDC_BUTTON_CANCEL) {
					MessageBox(hwnd, "Dialog exited with Cancel.", "Notice", MB_OK | MB_ICONINFORMATION);
				}
				else if (ret == -1) {
					MessageBox(hwnd, "Dialog failed!", "Error", MB_OK | MB_ICONINFORMATION);
				}
				break;
			}
			case ID_TOOLBAR_SHOW:
			{
				ShowWindow(hToolbar, SW_SHOW);
			}
			break;
			case ID_TOOLBAR_HIDE:
			{
				ShowWindow(hToolbar, SW_HIDE);
			}
			break;
			case ID_BUTTONDIALOG_SHOW:
			{
				ShowWindow(hButtonDialog, SW_SHOW);
			}
			break;
			case ID_BUTTONDIALOG_HIDE:
			{
				ShowWindow(hButtonDialog, SW_HIDE);
			}
			break;
			case ID_CONTROLDIALOG_SHOW:
			{
				ShowWindow(hControlDialog, SW_SHOW);
			}
			break;
			case ID_CONTROLDIALOG_RECREATE:
			{
				hControlDialog = CreateDialog(GetModuleHandle(NULL), MAKEINTRESOURCE(IDD_DIALOG_CONTROL), hwnd, ControlDlgProc);
				if (hControlDialog == NULL)
				{
					MessageBox(hwnd, "CreateDialog returned NULL", "Warning!", MB_OK | MB_ICONINFORMATION);
				}
				EnableMenuItem(GetSubMenu(GetMenu(hMainWindow), 3), ID_CONTROLDIALOG_SHOW, MF_ENABLED | MF_BYCOMMAND);
				EnableMenuItem(GetSubMenu(GetMenu(hMainWindow), 3), ID_CONTROLDIALOG_RECREATE, MF_DISABLED | MF_GRAYED | MF_BYCOMMAND);
			}
			break;
			case ID_FILE_FILEDIALOG_SHOW:
			{
				ShowWindow (hFileDialog, SW_SHOW) ;
			}
			break;
			case ID_TREEVIEWDIALOG_SHOW:
			{
				ShowWindow (hTreeViewDialog, SW_SHOW) ;
				break ;
			}
			case IDC_TOOLBAR_NEW:
			{
				SendMessage(hStatusBar, SB_SETTEXT, 0, (LPARAM)"New");
				SendMessage(hStatusBar, SB_SETTEXT, 1, (LPARAM)"Statusbar 2");
				SendMessage(hStatusBar, SB_SETTEXT, 2, (LPARAM)"Statusbar 3");
			}
			break;
			case IDC_TOOLBAR_OPEN:
			{
				SendMessage(hStatusBar, SB_SETTEXT, 1, (LPARAM)"Open");
				SendMessage(hStatusBar, SB_SETTEXT, 0, (LPARAM)"Statusbar 1");
				SendMessage(hStatusBar, SB_SETTEXT, 2, (LPARAM)"Statusbar 3");
			}
			break;
			case IDC_TOOLBAR_SAVE:
			{
				SendMessage(hStatusBar, SB_SETTEXT, 2, (LPARAM)"Save");
				SendMessage(hStatusBar, SB_SETTEXT, 0, (LPARAM)"Statusbar 1");
				SendMessage(hStatusBar, SB_SETTEXT, 1, (LPARAM)"Statusbar 2");
			}
			break;
			// Threads
			// Processes have their own address space. A particular address is the same for all the processes. They have their own stack as well as their own heap
			// Threads share the address space however they have their own stack. They also share the heap

			//hThread = OpenThread(THREAD_ALL_ACCESS, TRUE, (DWORD)ThreadId2); // Retrieves the thread handle using the thread ID
			// Yield is now deprecated. Use Sleep (0) to yield execution to other threads
			case IDC_MYTHREAD:
			{
				printf("Thread 8 sent a message once it has woken up!\n");
				CloseHandle(hThread8);
			}
			break;
			case ID_THREADS_MUTEX:
			{
				// Mutex threads
				printf("\n*** Mutex threads ***\n");
				hMutex = CreateMutex(NULL, FALSE, "myMutex");

				// Main thread must create it. Critical section. This is an alternative
				InitializeCriticalSection(&gCS);
				int SpinCount = 4000;
				//InitializeCriticalSectionAndSpinCount(&gCS, SpinCount); // The thread enters a loop (spins) before tries to re-acquire the lock if first time was unlucky. Only then does it go to WaitForSingleObject

				// Create Two Threads
				ThreadFuncParam = 1;
				hThread1 = CreateThread(NULL, 0, (LPTHREAD_START_ROUTINE)ThreadFunc,	// Security attributes, stack size (0 = default),
										&ThreadFuncParam,								// function pointer to thread function (entry point), pointer to a variable to be passed to the thread function,
										CREATE_SUSPENDED, (LPDWORD) &ThreadId1);					// control of creation (0 – run immediately, CREATE_SUSPENDED can run before the CreateThread returns), pointer to a variable receiving the thread id
				printf("Created thread ID: %d\n", ThreadId1);
				ThreadFuncParam = 5;													// This value (and not 1) is passed as the parameter for both threads' function
				hThread2 = CreateThread(NULL, 0, (LPTHREAD_START_ROUTINE)ThreadFunc, &ThreadFuncParam, CREATE_SUSPENDED, (LPDWORD) &ThreadId2);
				printf("Created thread ID: %d\n", ThreadId2);

				if (ResumeThread(hThread1) == -1) {
					printf("Thread %d failed to resume.\n", ThreadId1);
				}
				if (ResumeThread(hThread2) == -1) {
					printf("Thread %d failed to resume.\n", ThreadId2);
				}

				while (Count < MaxCount) {								// Main is blocked here. The window is not responding until this while-loop exits
					WaitForSingleObject(hMutex, INFINITE);				// Waits for the other two threads to relinquish the mutext
					printf("Main thread (internal ID: %d) Count = %d\n", GetCurrentThreadId(), Count);
					if (Count > 10 && suspended == 0)
					{
						printf("Suspending thread 1...\n");
						int suspendCount = SuspendThread(hThread1);		// Suspend the thread
						suspended = 1;
						printf("Previous suspend count: %d\n", suspendCount);
					}
					if (Count > 16 && suspended == 1)
					{
						printf("Resuming thread...");
						int suspendCount = ResumeThread(hThread1);		// Decrements the suspend count
						suspended = 2;
						printf("Previous suspend count: %d\n", suspendCount);
					}

					ReleaseMutex(hMutex);
				}

				printf("Main thread (internal ID: %d) exited loop and waits for threads to terminate\n", GetCurrentThreadId());

				// Exit from both threads, check exit codes
				long int exitCode1, exitCode2;
				while (TRUE) {
					GetExitCodeThread(hThread1, (LPDWORD)&exitCode1);
					GetExitCodeThread(hThread2, (LPDWORD)&exitCode2);
					if (exitCode1 != STILL_ACTIVE && exitCode2 != STILL_ACTIVE)	// Not safe as STILL_ACTIVE = 259 and if the function returns with that value then it stays in the loop forever
						break;
					else
						Sleep(1000);									// Waits a sec for the threads to terminate then does the check again
				}

				GetExitCodeThread(hThread1, (LPDWORD)&exitCode1);				// Gets the return value of the thread functions
				GetExitCodeThread(hThread2, (LPDWORD)&exitCode2);
				printf("Thread (internal ID: %d) exited with code %d\n", ThreadId1, exitCode1);
				printf("Thread (internal ID: %d) exited with code %d\n", ThreadId2, exitCode2);
				CloseHandle(hThread1);									// Handles are not needed anymore
				CloseHandle(hThread2);

				DeleteCriticalSection(&gCS);							// The main thread should delete it at last

				printf("All threads terminated. Main thread is now unblocked and listens to messages\n");
			}
			break;
			case ID_THREADS_EVENT:
			{
				// Event threads
				// Create an Manual Reset Event where events must be reset manually to non signaled state otherwise auto which Resets itself
				printf("\n*** Event threads ***\n");
				printf("Creating two events...\n");
				hEventThread3 = CreateEvent(NULL, TRUE, FALSE, "EventThread3");	// Default security attributes, TRUE = manual reset, FALSE = event created in a non-signalled state, event name
				if (!hEventThread3) {
					printf("Thread event 3 creation failed.\n");
				}
				hEventThread4 = CreateEvent(NULL, TRUE, FALSE, "EventThread4");
				if (!hEventThread4) {
					printf("Thread event 4 creation failed.\n");
				}
				Array_Of_Events_Handles[0] = hEventThread3;
				Array_Of_Events_Handles[1] = hEventThread4;

				printf("Creating two threads...\n");
				hThread3 = CreateThread(NULL, 0, (LPTHREAD_START_ROUTINE)Thread3FuncEvent, &ThreadFuncParam, CREATE_SUSPENDED, (LPDWORD)&ThreadId3);	// Create two threads
				hThread4 = CreateThread(NULL, 0, (LPTHREAD_START_ROUTINE)Thread4FuncEvent, &ThreadFuncParam, CREATE_SUSPENDED, (LPDWORD)&ThreadId4);
				if (ResumeThread(hThread3) == -1) {
					printf("Thread %d failed to resume.\n", ThreadId3);
				}
				if (ResumeThread(hThread4) == -1) {
					printf("Thread %d failed to resume.\n", ThreadId4);
				}

				printf("Waiting for Thread 3 and 4 to signal the events...\n");
				while (TRUE)
				{
					WaitForMultipleObjects(2, Array_Of_Events_Handles, TRUE, 7000); // Main thread waits until both events signal
					break;
				}
				printf("Both threads signaled, execution of the Main thread blocked no more\n");
			}
			break;
			case ID_THREADS_SEMAPHORE:
			{
				// Semaphore threads
				// The state of a semaphore is signalled when its count is greater than zero and non-signalled when it is zero. 
				// The count is decreased by one whenever a wait function releases a thread that was waiting for the semaphore.
				// The count is increased by a specified amount by calling the ReleaseSemaphore function.
				printf("\n*** Semaphore threads ***\n");
				hSemaphore = CreateSemaphore(
					NULL,           // Default security attributes
					2,				// Initial count
					2,				// Maximum count
					NULL);          // Unnamed semaphore

				if (hSemaphore == NULL)
				{
					printf("CreateSemaphore error: %d\n", GetLastError());
				}
				printf("Creating three threads...\n");
				hThread5 = CreateThread(NULL, 0, (LPTHREAD_START_ROUTINE)Thread5Func, &ThreadFuncParam, CREATE_SUSPENDED, (LPDWORD)&ThreadId5);	// Create three threads
				hThread6 = CreateThread(NULL, 0, (LPTHREAD_START_ROUTINE)Thread6Func, &ThreadFuncParam, CREATE_SUSPENDED, (LPDWORD)&ThreadId6);
				hThread7 = CreateThread(NULL, 0, (LPTHREAD_START_ROUTINE)Thread7Func, &ThreadFuncParam, CREATE_SUSPENDED, (LPDWORD)&ThreadId7);
				if (ResumeThread(hThread5) == -1) {
					printf("Thread %d failed to resume.\n", ThreadId5);
				}
				if (ResumeThread(hThread6) == -1) {
					printf("Thread %d failed to resume.\n", ThreadId6);
				}
				if (ResumeThread(hThread7) == -1) {
					printf("Thread %d failed to resume.\n", ThreadId7);
				}
			}
			break;
			case ID_THREADS_MESSAGE:
			{
				// Message thread
				// This thread sends a message when slept for a period
				printf("\n*** Message thread ***\n");
				hThread8 = CreateThread(NULL, 0, (LPTHREAD_START_ROUTINE)Thread8MsgFunc, &ThreadFuncParam, CREATE_SUSPENDED, (LPDWORD)&ThreadId8);
				if (ResumeThread(hThread8) == -1) {
					printf("Thread %d failed to resume.\n", ThreadId8);
				}
			}
			break;
			case ID_THREADS_TIMER:
			{
				// Timers
				// Standard timer
				/* Create a timer, specify its elapse time, and (optionally) attach it to a window. After the timer is created, it sends WM_TIMER messages to the window message queue
				Not very accurate as the message sent to the queue may only be processed later. Not reliable for accurate measuring but good for most applications*/
				printf("\n*** Timer thread ***\n");
				printf("Setting a standard timer to fire in every 3 secs 5x...\n");
				int ret = SetTimer(hwnd, IDC_MYTIMER, 3000, NULL);		// Set it to 50 milliseconds (20 frames per second)
																		// Last parameter (often NULL): application-defined callback function that is called after WM_TIMER
				if (ret == 0)
					MessageBox(hwnd, "Could not set timer!", "Error", MB_OK | MB_ICONEXCLAMATION);

				// Queue timer
				/*These are lightweight kernel objects that reside in timer queues. Like most timers, they enable us to specify the callback function
				to be called when the specified due time arrives. In this case, the operation is performed by a thread in the Windows thread pool.*/
				printf("Setting a queue timer to fire after 10 secs...\n");
				// Create the timer queue.
				hTimerQueue = CreateTimerQueue();
				if (NULL == hTimerQueue)
				{
					printf("CreateTimerQueue failed (%d)\n", GetLastError());
				}

				BOOL success = CreateTimerQueueTimer(
					pqTimerHandle,			// Out value, the timer's handle
					hTimerQueue,			// Timer queue handle. For default use NULL
					qTimerProc,				// Pointer to a callback function when the timer fires
					&qTimerFuncParam,		// Value passed to the callback function
					10000,					// Due time, time (milliseconds), before the timer is set to the signaled state for the first time
					0,						// Elapsed time when the timer signals. If zero then only signals once otherwise periodic
					WT_EXECUTEINTIMERTHREAD);
			}
			break;
			case ID_CONSOLE_CREATE:
			{
				// Step 2b Add console window to a Win32 application
				AllocConsole();
				AttachConsole(GetCurrentProcessId());
				freopen_s(&stream, "CON", "w", stdout);
				ResizeConsole(GetStdHandle(STD_OUTPUT_HANDLE), 100, 40);
				SetConsoleTitle("Console for a Win32 application");
				printf("*** Console for a Win32 application ***\n\n");
			}
			break;
			case ID_CONSOLE_RANDOM:
			{
				// Random generator
				printf("\nGenerate random number\n");
				srand((unsigned)time(NULL));											// Seed the random-number generator with the current time so that the numbers will be different every time we run.
				int range_min = 100, range_max = 200;
				double randNumber = (double)rand() / (RAND_MAX)* (range_max - range_min) + range_min; // The rand function returns a pseudorandom integer in the range 0 to RAND_MAX (32767)
				printf("Random number: %.2f\n", randNumber);
			}
			break;
			case ID_CONSOLE_PRINTF:
			{
				printf("\nDemonstrate the printf() function\n");
				int count = -123;
				char ch = 'h';
				char * string = "Computer";
				double fp = 251.7366;
				printf("Integer: %d Justified: %.6d Unsigned: %u\n", count, count, count);
				printf("Hex: %Xh C hex : 0x % x Radix Hex : %i\n", count, count, count);
				printf("Char: %10c String: %25s Floating: %f\n", ch, string, fp);
				printf("Rounded: %.2f E-notation: %E Pointer: %p\n", fp, fp, &count);
			}
			break;
			case ID_CONSOLE_DATETIME:
			{
				// Time and Date
				printf("\nDate and Time demo\n");
				SYSTEMTIME st = { 0 };
				GetLocalTime(&st);							// Local time
				printf("The local time is: %02d:%02d:%02d\n", st.wHour, st.wMinute, st.wSecond);
				printf("Today is: %02d-%02d-%04d\n", st.wDay, st.wMonth, st.wYear);

				GetSystemTime(&st);							// UTC time
				printf("The system time is: %02d:%02d:%02d\n", st.wHour, st.wMinute, st.wSecond);

				//Arithmetic
				#define NSECS 60*60*3 // 3 hours in seconds
				FILETIME ft = { 0 }; // The FILETIME structure contains a 64-bit value representing the number of 100-nanosecond intervals since January 1, 1601 (UTC). This is the epoch (a start time or date)
				GetLocalTime(&st);
				printf("Current date and time: %02d/%02d/%04d %02d:%02d:%02d\n", st.wDay, st.wMonth, st.wYear, st.wHour, st.wMinute, st.wSecond);
				SystemTimeToFileTime(&st, &ft);				// Convert from human readable date time to number of 100 nanoseconds since 01/01/1601

				ULARGE_INTEGER u = { 0 };
				memcpy(&u, &ft, sizeof(u));
				u.QuadPart += NSECS * 10000000LLU;			// 100th of a nano-seconds. Nano = 9 zeros
				memcpy(&ft, &u, sizeof(ft));

				FileTimeToSystemTime(&ft, &st); // Convert back to human readable format
				printf("Current time + 3 hours: %02d/%02d/%04d %02d:%02d:%02d\n", st.wDay, st.wMonth, st.wYear, st.wHour, st.wMinute, st.wSecond);

				// Computer uptime
				DWORD tc = GetTickCount(); // Number of milliseconds since switch on
				short seconds = tc / 1000 % 60;
				short minutes = tc / 1000 / 60 % 60;
				short hours = tc / 1000 / 60 / 60 % 24;
				short days = tc / 1000 / 60 / 60 / 24 % 7;
				short weeks = tc / 1000 / 60 / 60 / 24 / 7 % 52;
				// After 49.71 days, the value overflows
				printf("Computer uptime: W:%d D:%d H:%d M:%d S:%d\n", weeks, days, hours, minutes, seconds);
				break;
			}
			}
		}
		break;
		case WM_LBUTTONDOWN:										// These are numeric constants (each message has an ID)
		{
			char szFileName [MAX_PATH];								// It is a macro that returns the max allowable path length
			HINSTANCE hInstance = GetModuleHandle (NULL);			// If this parameter is NULL, GetModuleHandle returns a handle to the file used to create the calling process (.exe file)

			GetModuleFileName (hInstance, szFileName, MAX_PATH);	// Gets the file name
			MessageBox (hwnd, szFileName, "This program is:", MB_OK | MB_ICONINFORMATION);
		}
		break;
		case WM_TIMER:
		{
			TimerCount++;
			printf("Normal timer\'s tick down count: %d\n", TimerCount);
			if (TimerCount == 5) {
				KillTimer(hwnd, IDC_MYTIMER);						// Kill it after 5 counts (if not needed just once) or when the window is destroyed
				printf("Normal timer killed.\n");
			}
		}
		break;
		case WM_CLOSE:						// WM_CLOSE is sent when the user presses the Close Button 
			DestroyWindow (hwnd);			// The system sends the WM_DESTROY message to the window getting destroyed
		break;
		case WM_DESTROY:					// We can do any clean up here
		{
			DestroyWindow (hToolbar);		// No EndDialog, we must destroy it this way
			DestroyWindow (hControlDialog);
			DestroyWindow(hFileDialog);
			DestroyMenu(hMenu);
			DeleteObject(hbmBall);
			DeleteObject(hbmTrpBall);
			DeleteObject(hbmMask);
			PostQuitMessage (0);			// This posts the WM_QUIT message to the message loop which in turn terminates the loop. GetMessage returns false (0)
		}
		break;
		default:
			return DefWindowProc (hwnd, msg, wParam, lParam);	// Anything else we do not want to process
	}
	return 0;
	// SendMessage () and PostMessage (). The latter puts the message into the Message Queue and returns immediately. That means once the call to PostMessage() is done
	// the message may or may not have been processed yet. SendMessage () sends the message directly to the window and does not return until the window has finished processing it
	// SendDlgItemMessage() you give it a window handle and a child ID and it will get the child handle, and then send it the message
}

BOOL CALLBACK AboutDlgProc (HWND hwnd, UINT Message, WPARAM wParam, LPARAM lParam)
{
	switch (Message)
	{
		case WM_INITDIALOG:
			return TRUE;								// After processed messages must return TRUE
		case WM_COMMAND:
			switch (LOWORD (wParam))
			{
				case IDC_BUTTON_OK:
					EndDialog (hwnd, IDC_BUTTON_OK);	// Modal dialog so has to call EndDialog
					break;
				case IDC_BUTTON_CANCEL:
					EndDialog (hwnd, IDC_BUTTON_CANCEL);
					break;
			}
		break;

		default:
		return FALSE;						// Messages that not handled must return FALSE
	}
	return TRUE;
}

BOOL CALLBACK ToolDlgProc (HWND hwnd, UINT Message, WPARAM wParam, LPARAM lParam)
{
	switch (Message)
	{
		case WM_CTLCOLORDLG:					// Set background colour.
			return (LONG)hbrBackground;			// Must return a brush
		case WM_CTLCOLORSTATIC:
		{
			HDC hDCStatic = (HDC)wParam;
			SetTextColor(hDCStatic, RGB(255, 255, 255));
			SetBkMode(hDCStatic, TRANSPARENT);
			return (LONG)hbrBackground;
		}
		break;
		case WM_COMMAND:
			switch (LOWORD (wParam))
			{
				case IDC_BUTTON_PRESS:
					MessageBox (hwnd, "Hi!", "This is a message", MB_OK | MB_ICONEXCLAMATION);
					break;
				case IDC_BUTTON_OTHER:
					MessageBox (hwnd, "Bye!", "This is also a message", MB_OK | MB_ICONEXCLAMATION);
					break;
			}
			break;
		default:
			return FALSE;						// Messages not handled. Must return FALSE
	}
	return TRUE;
}

BOOL CALLBACK ControlDlgProc (HWND hwnd, UINT Message, WPARAM wParam, LPARAM lParam)
{
	switch (Message)
	{
		case WM_COMMAND:
			switch (LOWORD(wParam))
			{
				case ID_BUTTON_CCANCEL:
					EnableMenuItem(GetSubMenu(GetMenu(hMainWindow), 3), ID_CONTROLDIALOG_SHOW, MF_DISABLED | MF_GRAYED | MF_BYCOMMAND);
					EnableMenuItem(GetSubMenu(GetMenu(hMainWindow), 3), ID_CONTROLDIALOG_RECREATE, MF_ENABLED | MF_BYCOMMAND);
					PostMessage(hControlDialog, WM_CLOSE, 0, 0);
					break;
				case ID_BUTTON_COK:
					EnableMenuItem(GetSubMenu (GetMenu (hMainWindow), 3), ID_CONTROLDIALOG_SHOW, MF_DISABLED | MF_GRAYED | MF_BYCOMMAND);
					EnableMenuItem(GetSubMenu(GetMenu(hMainWindow), 3), ID_CONTROLDIALOG_RECREATE, MF_ENABLED | MF_BYCOMMAND);
					PostMessage(hControlDialog, WM_CLOSE, 0, 0);
					break;
				case IDC_BUTTON_ADD:
				{
					int len = GetWindowTextLength (GetDlgItem (hControlDialog, IDC_EDIT_INPUT));
					if (len > 0)
					{
						char * buffer = (char*) GlobalAlloc (GPTR, len + 1);
						GetDlgItemText (hControlDialog, IDC_EDIT_INPUT, buffer, len + 1);	// Gets the text from the edit box

						BOOL bSuccess;
						int nTimes = GetDlgItemInt (hControlDialog, IDC_EDIT_NUMBER, &bSuccess, FALSE);

						for (int i = 1; i <= nTimes; i++)
						{
							int index = SendDlgItemMessage (hControlDialog, IDC_LIST1, LB_ADDSTRING, 0, (LPARAM)buffer);
						}
						GlobalFree ((HANDLE) buffer);
					}
					break;
				}
				case IDC_BUTTON_REMOVE:
				{
					HWND hList1 = GetDlgItem(hwnd, IDC_LIST1);
					int itemIndex = (int)SendMessage(hList1, LB_GETCURSEL, (WPARAM)0, (LPARAM)0);
					SendMessage(hList1, LB_DELETESTRING, (WPARAM)itemIndex, 0);
					break;
				}
				case IDC_BUTTON_CLEAR:
					SendDlgItemMessage (hControlDialog, IDC_LIST1, LB_RESETCONTENT, 0, 0);
					break;
				case IDC_LIST1:
					switch (HIWORD(wParam))
					{
						case LBN_SELCHANGE:
						{
							HWND hList1 = GetDlgItem(hControlDialog, IDC_LIST1);							// Get handle as this is just another window
							int itemIndex = (int)SendMessage(hList1, LB_GETCURSEL, (WPARAM)0, (LPARAM)0);	// Get current selection index in listbox
							if (itemIndex == LB_ERR)
								return TRUE;	// No selection
							int textLen = (int)SendMessage(hList1, LB_GETTEXTLEN, (WPARAM)itemIndex, 0);	// Get length of text in listbox
							char * textBuffer = (char*)GlobalAlloc(GPTR, textLen + 1);						// Allocate buffer to store text (consider +1 for end of string)
							SendMessage(hList1, LB_GETTEXT, (WPARAM)itemIndex, (LPARAM)textBuffer);			// Get actual text in buffer
							SetDlgItemText(hControlDialog, IDC_EDIT_SELECTED, textBuffer);					// Read only
							GlobalFree((HANDLE)textBuffer);
							break;
						}
						break;
					}
	}
	break;
	case WM_CLOSE:
		DestroyWindow (hControlDialog);
	default:
		return FALSE;						// Messages not handled. Must return FALSE
	}
	return TRUE;
}

BOOL CALLBACK FileDlgProc(HWND hwnd, UINT Message, WPARAM wParam, LPARAM lParam)
{
	switch (Message)
	{
	case WM_COMMAND:
		switch (LOWORD(wParam))
		{
			case IDC_BUTTON_LOADFILE:
			{
				OPENFILENAME ofn;
				char szFileName[MAX_PATH] = "";						// Largest file name possible

				ZeroMemory(&ofn, sizeof(ofn));

				ofn.lStructSize = sizeof(OPENFILENAME);
				ofn.hwndOwner = hFileDialog;
				ofn.lpstrFilter = "Text Files (*.txt)\0*.txt\0All Files (*.*)\0*.*\0";
				ofn.lpstrFile = szFileName;							// File name
				ofn.nMaxFile = MAX_PATH;
				ofn.Flags = OFN_EXPLORER | OFN_FILEMUSTEXIST | OFN_HIDEREADONLY;	// No read-only files, file must exist
				ofn.lpstrDefExt = "txt";							// Default extension

				if (GetOpenFileName(&ofn))
				{
					HWND hEditControl = GetDlgItem(hFileDialog, IDC_EDIT_FILE);
					LoadTextFile(hEditControl, szFileName);
				}
			}
			break;
			case IDC_BUTTON_SAVEFILE:
			{
				OPENFILENAME ofn;
				char szFileName[MAX_PATH] = "";

				ZeroMemory(&ofn, sizeof(ofn));

				ofn.lStructSize = sizeof(OPENFILENAME);
				ofn.hwndOwner = hwnd;
				ofn.lpstrFilter = "Text Files (*.txt)\0*.txt\0All Files (*.*)\0*.*\0";
				ofn.lpstrFile = szFileName;
				ofn.nMaxFile = MAX_PATH;
				ofn.lpstrDefExt = "txt";
				ofn.Flags = OFN_EXPLORER | OFN_PATHMUSTEXIST | OFN_HIDEREADONLY | OFN_OVERWRITEPROMPT;	// Ask to overwrite if exists

				if (GetSaveFileName(&ofn))
				{
					HWND hEditControl = GetDlgItem(hwnd, IDC_EDIT_FILE);
					SaveTextFile(hEditControl, szFileName);
				}
			}
			break;
		case IDC_BUTTON_FILE_CLOSE:
			ShowWindow(hFileDialog, SW_HIDE);
			break;
		}
		break;
	default:
		return FALSE;						// Messages not handled. Must return FALSE
	}
	return TRUE;
}

BOOL CALLBACK ButtonDlgProc(HWND hwnd, UINT Message, WPARAM wParam, LPARAM lParam)
{
	switch (Message)
	{
	case WM_COMMAND:
		switch (LOWORD(wParam))
		{
		case IDC_CHECK1:
		{
			HANDLE hButtonChk1 = GetDlgItem(hButtonDialog, IDC_CHECK1); // Handle to the dialog box that contains the control, the identifier of the control
			HANDLE hButtonRadio1 = GetDlgItem(hButtonDialog, IDC_RADIO1);
			int ret = SendMessage((HWND)hButtonChk1, BM_GETCHECK, 0, 0);
			switch (ret)
			{
			case BST_CHECKED:
				printf("Checkbox IDC_CHECK1 is checked\n");
				SendMessage((HWND)hButtonRadio1, BM_SETCHECK, BST_UNCHECKED, 0);
				break;
			case BST_INDETERMINATE:
				printf("Checkbox IDC_CHECK1 is indeterminate\n");
				break;
			case BST_UNCHECKED:
				printf("Checkbox IDC_CHECK1 is unchecked\n");
				SendMessage((HWND)hButtonRadio1, BM_SETCHECK, BST_CHECKED, 0);
				break;
			}
			break;
		}
		case IDC_CANCEL:
			ShowWindow(hButtonDialog, SW_HIDE);
			break;
		case IDC_SPLIT1:
			break;
		}
		break;
	case WM_NOTIFY:
		switch (((LPNMHDR)lParam)->code)
		{
			case BCN_DROPDOWN:
			{
				NMBCDROPDOWN* pDropDown = (NMBCDROPDOWN*)lParam;		// Contains NMHDR (hdr) structure that has hFrom (from which window), id_from (which control), code (notification code) 
																		// and a RECT (rcButton) structure with the button client area
				if (pDropDown->hdr.hwndFrom = GetDlgItem(hButtonDialog, IDC_SPLIT1)) // Check if this is the button dialog the message came from
				{
					POINT pt;
					pt.x = pDropDown->rcButton.left;					// Get screen coordinates of the button.
					pt.y = pDropDown->rcButton.bottom;

					ClientToScreen(pDropDown->hdr.hwndFrom, &pt);
					// Replaces the client-area coordinates in the point structure with the screen coordinates. The screen coordinates are relative to the upper-left corner of the screen.
					// Note, a screen-coordinate point that is above the window's client area has a negative y-coordinate. Similarly, a screen coordinate to the left of a client area has a negative x-coordinate.
					// Create a menu and add items.
					HMENU hSplitMenu = CreatePopupMenu();
					AppendMenu(hSplitMenu, MF_BYPOSITION, IDC_CONTEXTMENU1, "Menu item 1");
					AppendMenu(hSplitMenu, MF_BYPOSITION, IDC_CONTEXTMENU2, "Menu item 2");

					// Displays a shortcut menu at the specified location and tracks the selection of items on the menu.
					TrackPopupMenu(hSplitMenu, TPM_LEFTALIGN | TPM_TOPALIGN, pt.x, pt.y, 0, hButtonDialog, NULL); // 0 = Reserved, must be 0. NULL is ignored
					DestroyMenu(hSplitMenu);							// The context menu is modal. Blocks. So this is correct here!
					return TRUE;
				}
				break;
			}
		}
		return FALSE;
	case WM_CLOSE:
		DestroyWindow(hControlDialog);
	default:
		return FALSE;						// Messages not handled. Must return FALSE
	}
	return TRUE;
}

BOOL CALLBACK TreeViewDlgProc(HWND hwnd, UINT Message, WPARAM wParam, LPARAM lParam)
{
	switch (Message)
	{
//	case WM_PAINT:
//		break ;
	case WM_COMMAND:
		switch (LOWORD(wParam))
		{
		case ID_BUTTON_OK:
			ShowWindow (hTreeViewDialog, SW_HIDE) ;
			break ;
		case ID_BUTTON_POPULATE:
			PopulateTreeView(hwnd);
			break;
		case ID_BUTTON_GETSELECTED:
			GetTreeViewItem (hwnd) ;
			break ;
		}
		break ;
	default:
		return FALSE ;						// Messages not handled. Must return FALSE
	case WM_NOTIFY:
		switch (((LPNMHDR)lParam)->code)
		{
			case IDC_TREEVIEW1:
				HTREEITEM Selected {0} ;
				TV_ITEM tvi ;

				HWND hTreeView = GetDlgItem(hwnd, IDC_TREEVIEW1) ;

				if (((LPNMHDR)lParam)->code == NM_CLICK) {
					char Text[255] = "";
					memset (&tvi, 0, sizeof(tvi)) ;

					Selected = (HTREEITEM) SendDlgItemMessage(hwnd, IDC_TREEVIEW1, TVM_GETNEXTITEM, TVGN_CARET, (LPARAM)Selected) ;
				}
		}
	}
	return TRUE ;
}

BOOL LoadTextFile(HWND hEdit, LPCTSTR pszFileName)
{
	HANDLE hFile;
	BOOL bSuccess = FALSE;

	hFile = CreateFile(pszFileName, GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, 0, NULL); // For read even if shared
																	// NULL = security attributes, 0 = flags and attributes, NULL = template file
	if (hFile != INVALID_HANDLE_VALUE)
	{
		long int FileSize;
		FileSize = GetFileSize(hFile, NULL);						// Get the file size to know gow many bytes to allocate
		if (FileSize != INVALID_FILE_SIZE)
		{
			char * FileText;
			FileText = (char *) GlobalAlloc (GPTR, FileSize + 1);	// Plus the null terminator
			if (FileText != NULL)
			{
				long int Read;										// Number of bytes read
				if (ReadFile(hFile, FileText, FileSize, (LPDWORD)&Read, NULL))
				{
					FileText[FileSize] = 0;							// Add null terminator. SetWindowText needs it
					if (SetWindowText(hEdit, FileText))
						bSuccess = TRUE;
				}
				GlobalFree(FileText);
			}
		}
		CloseHandle(hFile);
	}
	return bSuccess;
}

BOOL SaveTextFile(HWND hEdit, LPCTSTR pszFileName)
{
	HANDLE hFile;
	BOOL bSuccess = FALSE;

	hFile = CreateFile(pszFileName, GENERIC_WRITE, 0, NULL,	CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL);
	if (hFile != INVALID_HANDLE_VALUE)
	{
		long int TextLength;
		TextLength = GetWindowTextLength(hEdit);				// Get the size of the text in the edit control
		if (TextLength > 0)
		{
			char * Text;
			long int BufferSize = TextLength + 1;
			Text = (char *) GlobalAlloc (GPTR, BufferSize);
			if (Text != NULL)
			{
				if (GetWindowText(hEdit, Text, BufferSize))	// GetWindowText does not yield the text as a return value but as an OUT parameter
				{												// That is why first we need to store it in an allocated memory area
					long int Written;							// Number of bytes written
					if (WriteFile(hFile, Text, TextLength, (LPDWORD)&Written, NULL))
						bSuccess = TRUE;
				}
				GlobalFree(Text);
			}
		}
		CloseHandle(hFile);
	}
	return bSuccess;
}

HBITMAP CreateBitmapMask(HBITMAP hbmColour, COLORREF crTransparent)
{
	// This to work: the colour image must be black in all areas that we want to display as transparent. 
	// The mask image must be white in the areas we want transparent and black elsewhere
	BITMAP bm;
	HDC hdcMem, hdcMem2;
	HBITMAP hbmMask;

	GetObject(hbmColour, sizeof(BITMAP), &bm);
	hbmMask = CreateBitmap(bm.bmWidth, bm.bmHeight, 1, 1, NULL);			// Create monochrome (B&W) bitmap. Foreground is zeros (black) and background is 1s (white)

	hdcMem = CreateCompatibleDC(0);											// Get the work area
	hdcMem2 = CreateCompatibleDC(0);

	SelectObject(hdcMem, hbmColour);										// Select the bitmaps into the work areas
	SelectObject(hdcMem2, hbmMask);

	SetBkColor(hdcMem, crTransparent);										// If we want black to mean the transparent part (the image has a black background). 
																			// We tell the next BitBlt what to treat as the background (which will be transparent)
	BitBlt(hdcMem2, 0, 0, bm.bmWidth, bm.bmHeight, hdcMem, 0, 0, SRCCOPY);	// Copy original black and red image first. Background will be white, foreground black (every colour bit will be black)
																			// When blitting onto a monochrome bitmap from a color, pixels in the source color bitmap that are equal to the background
																			// color are blitted as white. All the remaining pixels are blitted as black.
	BitBlt(hdcMem, 0, 0, bm.bmWidth, bm.bmHeight, hdcMem2, 0, 0, SRCINVERT);// White (1) mapped to colour image background which is red. 1 XOR 1 (bytewise) = 0 (black)
																			// Black (0) mapped to everything else. If foreground > 0 then 0 XOR 1 = 1 (colour). If foreground = 0 (black) then 0 XOR 0 = 0 (stays black)

	DeleteDC(hdcMem);
	DeleteDC(hdcMem2);

	return hbmMask;
}

int ThreadFunc (long int * initValue)						// Both threads call this function but they do not share the same local variables!
{
	HANDLE hMutex;
	int localVar = * initValue;								// Initialized with a value passed in as a parameter to the function when the threads were created
															// This localVar has as many copies as threads use this function
	int threadID;

	hMutex = OpenMutex(MUTEX_ALL_ACCESS, FALSE, "myMutex"); // Get the mutex handle by its name

	for (;;)												// Infinite loop
	{
		WaitForSingleObject(hMutex, INFINITE);				// Wait for ownership then take hold of the mutex
		
		// Alternatively:
		EnterCriticalSection(&gCS);							// Enter the critical section. The thread function waits until it can acquire the mutex
		//TryEnterCriticalSection(&gCS);					// The thread function does not wait just tries once to acquire the mutex

		if (Count < MaxCount) {
			Count++;										// Both threads do this increase of the count as Count is a global variable
		}
		if (GetCurrentThreadId() == ThreadId1) {			// Thread 1 incerements its local variable by 2
			localVar += 2;
			threadID = 1;
		}
		else {
			localVar++;										// Thread 2 increments its local variable by 1
			threadID = 2;
		}
		printf ("Thread %d (internal ID: %d) with param %d set count to %d and localvar to %d\n", threadID, GetCurrentThreadId () , * initValue, Count, localVar);
		Sleep(1000); // Sleep for n ms
		ReleaseMutex(hMutex);								// Let the main thread or the other thread either display Count or increase Count

		LeaveCriticalSection(&gCS);							// Leave the critical section

		if ((localVar > 24 && ThreadId2 == GetCurrentThreadId()) || (localVar > 29 && ThreadId1 == GetCurrentThreadId())) // End this infinite loop
			return localVar;								// GetExitCodeThread receives this code
	}
}

void CALLBACK qTimerProc(void * lpParameter, BOOLEAN TimerOrWaitFired)
{
	printf("Queue timer function called with parameter %d.\n", * (int *) lpParameter);
	DeleteTimerQueueTimer(NULL, hTimerQueue, NULL);
	CloseHandle(* pqTimerHandle);
	printf("Queue timer destroyed.\n");
}

int CALLBACK Thread3FuncEvent (long int * initValue)
{
	HANDLE hEvent; 
	printf("Event thread 3 (internal ID: %d) function called with parameter %d.\n", GetCurrentThreadId(), * initValue);
	hEvent = OpenEvent (EVENT_ALL_ACCESS, FALSE, "EventThread3");
	if (!hEvent) {
		return -1;
	}

	Sleep(3000);
	ResetEvent(hEvent); // Not sure why this is needed
	if (SetEvent(hEvent)) {									// Signals back to the main thread that the event occurred. Releases half of the block on the Main thread
		printf ("Event thread 3 (internal ID: %d) sending message to main window...\n", GetCurrentThreadId());
	}

	CloseHandle(hEvent); // Get rid of the handle as we do not need it anymore
	return 0;
}

int CALLBACK Thread4FuncEvent(long int * initValue)
{
	HANDLE hEvent;
	printf("Event thread 4 (internal ID: %d) event function called with parameter %d.\n", GetCurrentThreadId(), *initValue);
	hEvent = OpenEvent(EVENT_ALL_ACCESS, FALSE, "EventThread4");
	if (!hEvent) {
		return -1;
	}

	Sleep(6000);
	ResetEvent(hEvent); // Not sure why this is needed
	if (SetEvent(hEvent)) {									// Signals back to the main thread that the event occurred. Releases half of the block on the Main thread
		printf("Event thread 4 (internal ID: %d) sending message to main window...\n", GetCurrentThreadId());
	}

	CloseHandle(hEvent); // Get rid of the handle as we do not need it anymore
	return 0;
}

int CALLBACK Thread5Func(long int * initValue)
{
	printf("Thread 5 (internal ID: %d) function called with parameter %d\n", GetCurrentThreadId(), *initValue);
	DWORD dwWaitResult;
	long int prevCount;
	int successes = 0, timeouts = 0;

	while (successes < 10) {									// Be 10 times lucky then finish
		dwWaitResult = WaitForSingleObject (hSemaphore, 0L);	// Handle to semaphore, zero-second time-out interval. If can not get hold of it, the thread continue
		switch (dwWaitResult) {
		case WAIT_OBJECT_0:										// The semaphore object was signalled. The thread did not have to wait at all. The semaphore count is decreased by 1 by WaitForSingleObject
			successes++;
			Sleep(250);
			if (!ReleaseSemaphore(hSemaphore, 1, &prevCount)) {	// Release the semaphore, increase the count by one
				printf("Semaphore release error thread 5. Error: %d\n", GetLastError());
			}
			printf("Thread 5 (internal ID: %d) success: %d timeouts: %d semaphore prev count: %d\n", GetCurrentThreadId(), successes, timeouts, prevCount);
			break;
		case WAIT_TIMEOUT:										// Could not get hold of the shared resource as the semaphore count was zero
			printf("Thread 5 (internal ID: %d) wait timed out\n", GetCurrentThreadId());
			timeouts++;
			printf("Thread 5 (internal ID: %d) success: %d timeouts: %d\n", GetCurrentThreadId(), successes, timeouts);
			// Stay in the loop and try again
			Sleep(250);
		}
	}
	printf("Thread 5 (internal ID: %d) 10 successes reached! Returning...\n", GetCurrentThreadId());
	CloseHandle(hThread5);
	return 0;
}

int CALLBACK Thread6Func(long int * initValue)
{
	printf("Thread 6 (internal ID: %d) function called with parameter %d\n", GetCurrentThreadId(), *initValue);
	DWORD dwWaitResult;
	long int prevCount;
	int successes = 0, timeouts = 0;

	while (successes < 10) {									 // Be 10 times lucky then finish
		dwWaitResult = WaitForSingleObject(hSemaphore, 0L);		// Handle to semaphore, zero-second time-out interval. If can not get hold of it, the thread continues
		switch (dwWaitResult) {
		case WAIT_OBJECT_0:										// The semaphore object was signalled. The thread did not have to wait at all. The semaphore count is decreased by 1 by WaitForSingleObject
			successes++;
			Sleep(400);
			if (!ReleaseSemaphore(hSemaphore, 1, &prevCount)) {	// Release the semaphore, increase the count by one
				printf("Semaphore release error thread 5. Error: %d\n", GetLastError());
			}
			printf("Thread 6 (internal ID: %d) success: %d timeouts: %d semaphore prev count: %d\n", GetCurrentThreadId(), successes, timeouts, prevCount);
			break;
		case WAIT_TIMEOUT:										// Could not get hold of the shared resource as the semaphore count was zero
			printf("Thread 6 (internal ID: %d) wait timed out\n", GetCurrentThreadId());
			timeouts++;
			printf("Thread 6 (internal ID: %d) success: %d timeouts: %d\n", GetCurrentThreadId(), successes, timeouts);
			Sleep(250);
			// Stay in the loop and try again
		}
	}
	printf("Thread 6 (internal ID: %d) 10 successes reached! Returning...\n", GetCurrentThreadId());
	CloseHandle(hThread6);
	return 0;
}

int CALLBACK Thread7Func(long int * initValue)
{
	printf("Thread 7 (internal ID: %d) function called with parameter %d\n", GetCurrentThreadId(), *initValue);
	DWORD dwWaitResult;
	long int prevCount;
	int successes = 0, timeouts = 0;

	while (successes < 10) {									 // Be 10 times lucky then finish
		dwWaitResult = WaitForSingleObject(hSemaphore, 0L);		// Handle to semaphore, zero-second time-out interval. If can not get hold of it, the thread continue
		switch (dwWaitResult) {
		case WAIT_OBJECT_0:										// The semaphore object was signalled. The thread did not have to wait at all. The semaphore count is decreased by 1 by WaitForSingleObject
			successes++;
			Sleep(500);
			if (!ReleaseSemaphore(hSemaphore, 1, &prevCount)) {	// Release the semaphore, increase the count by one
				printf("Semaphore release error thread 5. Error: %d\n", GetLastError());
			}
			printf("Thread 7 (internal ID: %d) success: %d timeouts: %d semaphore prev count: %d\n", GetCurrentThreadId(), successes, timeouts, prevCount);
			break;
		case WAIT_TIMEOUT:										// Could not get hold of the shared resource as the semaphore count was zero
			printf("Thread 7 (internal ID: %d) wait timed out\n", GetCurrentThreadId());
			timeouts++;
			printf("Thread 7 (internal ID: %d) success: %d timeouts: %d\n", GetCurrentThreadId(), successes, timeouts);
			// Stay in the loop and try again
			Sleep(250);
		}
	}
	printf("Thread 7 (internal ID: %d) 10 successes reached! Returning...\n", GetCurrentThreadId());
	CloseHandle (hThread7);
	return 0;
}

int CALLBACK Thread8MsgFunc(long int * initValue)
{
	printf("Thread 8 (internal ID: %d) function called with parameter %d\n", GetCurrentThreadId(), *initValue);
	Sleep(3000);
	SendMessage (hMainWindow, WM_COMMAND, IDC_MYTHREAD, IDC_MYTHREAD);	// Send message to window proc
	return 0;
}

void ResizeConsole(HANDLE hConsole, SHORT xSize, SHORT ySize) {
	CONSOLE_SCREEN_BUFFER_INFO csbi; // Hold Current Console Buffer Info 
	BOOL bSuccess;
	SMALL_RECT srWindowRect;         // Hold the New Console Size 
	COORD coordScreen;

	bSuccess = GetConsoleScreenBufferInfo(hConsole, &csbi);
	// Get the Largest Size we can size the Console Window to 
	coordScreen = GetLargestConsoleWindowSize(hConsole);
	// Define the New Console Window Size and Scroll Position 
	srWindowRect.Right = (SHORT)(min(xSize, coordScreen.X) - 1);
	srWindowRect.Bottom = (SHORT)(min(ySize, coordScreen.Y) - 1);
	srWindowRect.Left = srWindowRect.Top = (SHORT)0;
	// Define the New Console Buffer Size    
	coordScreen.X = xSize;
	coordScreen.Y = ySize;
	// If the Current Buffer is Larger than what we want, Resize the 
	// Console Window First, then the Buffer 
	if ((DWORD)csbi.dwSize.X * csbi.dwSize.Y > (DWORD)xSize * ySize)
	{
		bSuccess = SetConsoleWindowInfo(hConsole, TRUE, &srWindowRect);
		bSuccess = SetConsoleScreenBufferSize(hConsole, coordScreen);
	}
	// If the Current Buffer is Smaller than what we want, Resize the 
	// Buffer First, then the Console Window 
	if ((DWORD)csbi.dwSize.X * csbi.dwSize.Y < (DWORD)xSize * ySize)
	{
		bSuccess = SetConsoleScreenBufferSize(hConsole, coordScreen);
		bSuccess = SetConsoleWindowInfo(hConsole, TRUE, &srWindowRect);
	}
	// If the Current Buffer *is* the Size we want, Don't do anything! 
	return;
}

int lparam = 111;
int lparam2 = 222;
int lparam3 = 333;

void PopulateTreeView (HWND hWnd) {
	//TV_ITEM tvi ;
	TV_INSERTSTRUCT tvinsert ;
	HTREEITEM Parent1, Parent2, Child1, Child2 ;
	HTREEITEM Root ;

	HWND hTreeView = GetDlgItem (hWnd, IDC_TREEVIEW1) ;

	tvinsert.item.mask = TVIF_TEXT | TVIF_PARAM ;				// These componenets are valid (are set)
	tvinsert.hParent = TVI_ROOT ;								// NULL means this is the root node
	tvinsert.hInsertAfter = TVI_FIRST ;							// This could be the handle of another tree item after which we would like ot insert
	tvinsert.item.pszText = "Root" ;							// Tree item's text as it appears in the tree
	tvinsert.item.lParam = (LPARAM) &lparam ;
	Root = (HTREEITEM)SendDlgItemMessage(hWnd, IDC_TREEVIEW1, TVM_INSERTITEM, 0, (LPARAM)&tvinsert) ; // Insert the item and return its handle

	tvinsert.item.mask = TVIF_TEXT | TVIF_PARAM ;
	tvinsert.hParent = Root ;
	tvinsert.hInsertAfter = TVI_LAST;							// Insert as the last child (default) of the root tree item
	tvinsert.item.pszText = "Parent 1";
	tvinsert.item.lParam = (LPARAM)&lparam2;
	Parent1 = (HTREEITEM)SendDlgItemMessage(hWnd, IDC_TREEVIEW1, TVM_INSERTITEM, 0, (LPARAM)&tvinsert) ; // Insert an return its handle
	tvinsert.item.pszText = "Parent 2";
	Parent2 = (HTREEITEM)SendDlgItemMessage(hWnd, IDC_TREEVIEW1, TVM_INSERTITEM, 0, (LPARAM)&tvinsert) ; // Insert an return its handle

	tvinsert.hParent = Parent1;
	tvinsert.item.pszText = "Child 1" ;
	tvinsert.item.lParam = (LPARAM)&lparam3 ;
	Child1 = (HTREEITEM)SendDlgItemMessage(hWnd, IDC_TREEVIEW1, TVM_INSERTITEM, 0, (LPARAM)&tvinsert) ; // Insert a child of the parent
	tvinsert.item.pszText = "Child 2" ;
	Child2 = (HTREEITEM)SendDlgItemMessage(hWnd, IDC_TREEVIEW1, TVM_INSERTITEM, 0, (LPARAM)&tvinsert) ; // Insert a child of the parent
	
	SendMessage (hTreeView, TVM_EXPAND, TVE_EXPAND, (LPARAM)(HTREEITEM)Root) ; // Expand this node (the root node in this case)
	SendMessage (hTreeView, TVM_EXPAND, TVE_EXPAND, (LPARAM)(HTREEITEM)Parent1) ; // Expand this node (the Parent 1 node in this case)

	UpdateWindow (hWnd) ;
}

void GetTreeViewItem (HWND hWnd) {
	HTREEITEM hSelectedItem = NULL ;
	HTREEITEM child1 = NULL, child2 = NULL ;

	HWND hTreeView = GetDlgItem(hWnd, IDC_TREEVIEW1);
	hSelectedItem = (HTREEITEM) SendMessage (hTreeView, TVM_GETNEXTITEM, TVGN_CARET, NULL) ; // TVGN_CARET = selected item

	if (hSelectedItem == NULL) // Nothing selected
		return;

	TCHAR buffer[128] ;
	TVITEM item ;
	item.hItem = hSelectedItem ;								// it is a handle
	item.mask = TVIF_TEXT | TVIF_CHILDREN | TVIF_PARAM ;		// Get these three components. These are valid
	item.cchTextMax = 128;										// Size of buffer
	item.pszText = buffer;										// Buffer that receives the node's text (description)
	BOOL success = (BOOL) SendMessage (hTreeView, TVM_GETITEM, 0, (LPARAM)&item) ; // Get info about this tree item (the selected one)

	int thisparam = *((int *)item.lParam) ;						// Get the parameter value (this is a pointer to anything like struct)
	
	child1 = (HTREEITEM) SendMessage (hTreeView, TVM_GETNEXTITEM, TVGN_CHILD, (LPARAM)hSelectedItem) ; // Get the first child of this selected tree item
	item.hItem = child1 ;										// Now this is the tree item we want to know more about
	item.mask = TVIF_TEXT | TVIF_CHILDREN | TVIF_PARAM ;		// These three pieces of info
	item.cchTextMax = 128 ;
	item.pszText = buffer ;
	success = (BOOL) SendMessage (hTreeView, TVM_GETITEM, 0, (LPARAM)&item) ; // Get info about the first child of the selected node (tree item)

	thisparam = *((int *)item.lParam) ;							// Get the parameter value too

	child2 = (HTREEITEM) SendMessage (hTreeView, TVM_GETNEXTITEM, TVGN_NEXT, (LPARAM)child1) ; // Get next sibling of Child 1
	item.hItem = child2 ;										// Now this is the tree item we want to know more about
	success = (BOOL) SendMessage (hTreeView, TVM_GETITEM, 0, (LPARAM)&item) ; // Get info about the second child of the selected node (tree item)

	item.mask = TVIF_TEXT ;
	item.pszText = "Child 2.5" ;
	success = (BOOL) SendMessage (hTreeView, TVM_SETITEM, 0, (LPARAM)&item) ; // Set the text of the item (Child 2)

	int itemcnt = (int) SendMessage (hTreeView, TVM_GETCOUNT, 0, 0L) ;
}