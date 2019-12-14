// SuDoKuMain.cpp
/*Defines the entry point for the application. It contains all the control creation and initialization routines.
  Defines the main callback function for the entire dialog window that handles most of the Windows messages.
  Also defines the "About" dialog callback, the starting grid list view callback and the grid header callback functions.
  Handles custom draws for the two grids, facilitates the save and load of the starting grid and the saving of the log window content.
*/

#include "SuDoKuWin.h"
#include <windows.h>
#include "Resource.h"
#include <commctrl.h>
#include <stdio.h>
#include <io.h>
#include <fcntl.h>
#include <time.h>

#pragma comment (lib,"comctl32.lib")
#pragma comment (linker,"/manifestdependency:\"type='win32' name='Microsoft.Windows.Common-Controls' \
						version='6.0.0.0' processorArchitecture='*' publicKeyToken='6595b64144ccf1df' language='*'\"")
 
// Main application entry point
int WINAPI WinMain (HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow)
{
	MSG msg ;
	BOOL ret ;

	InitCommonControls () ;
	hDlg = CreateDialogParam (hInstance, MAKEINTRESOURCE (IDC_MAIN_DIALOG), 0, DialogProc, 0) ; // Create the dialog window (main window)
	hAboutDlg = CreateDialogParam (GetModuleHandle(NULL), MAKEINTRESOURCE (IDC_ABOUT_DIALOG), hDlg, AboutDlgProc, 0) ; // Creates a modal dialog. Blocks until closed
	
	changeLang () ;											// Set the strings according to the selected language
	ShowWindow (hDlg, nCmdShow) ;
	SendMessage (hDlg, WM_NCPAINT, 0, 0) ;					// Repaint the non-client area (menu structure after a language change)
	createToolbar () ;										// Create a toolbar
	createStartingGridTooltip () ;							// Create tooltip controls
	createSingleSolveTooltip () ;
	createMultiSolveTooltip () ;
	createVariationsTooltip () ;
	createLoggingTooltip () ;
	createLogWinTooltip () ;

	if (langCode == English) {								// Enable/disable the Flags
		SendMessage (hToolbar, TB_ENABLEBUTTON, IDC_TOOLBAR_HUNFLAG, true) ;
		SendMessage (hToolbar, TB_ENABLEBUTTON, IDC_TOOLBAR_ENGFLAG, false) ;
	}
	else {
		SendMessage (hToolbar, TB_ENABLEBUTTON, IDC_TOOLBAR_HUNFLAG, false) ;
		SendMessage (hToolbar, TB_ENABLEBUTTON, IDC_TOOLBAR_ENGFLAG, true) ;
	}
	UpdateWindow (hDlg) ;
	SetFocus (hListViewStart) ;								// This is paramount as the grid must have the initial focus otherwise multiple extra mouse clicks needed

	// The main message loop
	while ((ret = GetMessage (&msg, 0, 0, 0)) != 0)
	{
		if (ret == -1)
			return -1 ;

		TranslateMessage (&msg) ;
		DispatchMessage (&msg) ;
	}

	return (int) msg.wParam ;
}

// Callback function of the main dialog window
BOOL CALLBACK DialogProc (HWND hDlg, UINT message, WPARAM wParam, LPARAM lParam)
{
	int wmId, wmEvent ;
	PAINTSTRUCT ps ;
	HDC hDC ;
	//UNREFERENCED_PARAMETER (lParam) ;

	switch (message) {
		case WM_INITDIALOG:									// Most of the initialization occurs here
		{
			/*AllocConsole () ;								// Defines a console window (mainly for debug purposes if needed
			AttachConsole (GetCurrentProcessId ()) ;
			freopen_s (&stream, "CON", "w", stdout) ;
			SetConsoleTitle ("Console for a Win32 application") ;*/
			
			goto overMenu ;									// The menu structure could also be created manually as per below code
			hMenu = CreateMenu () ;							// Add a menu structure
			hSubMenu = CreatePopupMenu () ;
			AppendMenu (hSubMenu, MF_STRING, ID_MENU_FILE_SAVEGRID, "&Save grid") ;
			AppendMenu (hSubMenu, MF_STRING, ID_MENU_FILE_LOADGRID, "&Load grid") ;
			AppendMenu (hSubMenu, MF_STRING, ID_MENU_FILE_SAVELOG, "Sa&ve log") ;
			AppendMenu (hSubMenu, MF_SEPARATOR, 0, 0) ;
			AppendMenu (hSubMenu, MF_STRING, ID_MENU_FILE_EXIT, "&Exit") ;
			AppendMenu (hMenu, MF_STRING | MF_POPUP, (UINT) hSubMenu, "&File") ;

			hSubMenu = CreatePopupMenu () ;
			AppendMenu (hSubMenu, MF_STRING, ID_MENU_HELP_ABOUT, "&About SuDoKu solver") ;
			AppendMenu (hMenu, MF_STRING | MF_POPUP, (UINT) hSubMenu, "&Help") ;

			SetMenu (hDlg, hMenu) ;

overMenu:
			//HANDLE hIcon = LoadImage (NULL, "SuDoKu.ico", IMAGE_ICON, 32, 32, LR_LOADFROMFILE);	// LoadIcon if a resource is loaded
			HICON hIcon = (HICON) LoadIcon (GetModuleHandle (NULL), MAKEINTRESOURCE (IDC_SUDOKU_ICON)) ; // Load the app icon			
			if (hIcon)
				SendMessage (hDlg, WM_SETICON, ICON_BIG, (LPARAM) hIcon) ;

			HICON hIconSm = (HICON) LoadIcon (GetModuleHandle (NULL), MAKEINTRESOURCE (IDC_SUDOKU_ICON)) ;
			if (hIconSm)
				SendMessage (hDlg, WM_SETICON, ICON_SMALL, (LPARAM) hIconSm) ;

			hListViewStart = CreateListView (hDlg, GetModuleHandle (NULL), IDC_LIST_START) ; // create list views (starting and solved grid)
			hListViewSolved = CreateListView (hDlg, GetModuleHandle (NULL), IDC_LIST_SOLVED) ;
			hProgress = GetDlgItem (hDlg, IDC_PROGRESS_BAR) ; // Progress bar
			hStatusBar = CreateWindowEx (0, STATUSCLASSNAME, NULL, WS_CHILD | WS_VISIBLE | SBARS_SIZEGRIP, 0, 0, 0, 0, hDlg, NULL, GetModuleHandle (NULL), NULL) ;
			
			hFont = CreateFont (14, 0, 0, 0, FW_NORMAL, FALSE, FALSE, FALSE, ANSI_CHARSET, OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS, DEFAULT_QUALITY, DEFAULT_PITCH, "Courier New");
			SendMessage (GetDlgItem (hDlg, IDC_EDIT_LOG), WM_SETFONT, (WPARAM) hFont, true) ;
			SendMessage (GetDlgItem (hDlg, IDC_EDIT_NUMS), EM_SETLIMITTEXT, 1, 0) ;
			hRadioButtonSin = GetDlgItem (hDlg, IDC_RADIO_SINGLESOLVE) ;// Single-solve mode radio button
			hRadioButtonMul = GetDlgItem (hDlg, IDC_RADIO_MULTISOLVE) ; // Multi-solve mode radio button
			hRadioButtonVar = GetDlgItem (hDlg, IDC_RADIO_VARIATIONS) ; // Variations only mode radio button
			hCheckLog = GetDlgItem (hDlg, IDC_CHECK_LOG) ;				// Logging enable/disablecheckbox
			
			//hOutput = CreateWindowEx(WS_EX_CLIENTEDGE,"EDIT","",WS_CHILD | WS_VISIBLE |	ES_MULTILINE | ES_AUTOVSCROLL | ES_AUTOHSCROLL,
			//	257, 32, 313, 255,hDlg, (HMENU)IDC_EDIT_LOG,GetModuleHandle(NULL),NULL); // Manually create edit window
			hOutput = GetDlgItem (hDlg, IDC_EDIT_LOG) ;
			SendMessage (hOutput, EM_SETLIMITTEXT, MAXLOGTEXTSIZE, 0) ; // Set the size of the log window to 10M chars
			SendMessage (hRadioButtonSin, BM_SETCHECK, BST_CHECKED, 0) ; // Default is single-solve mode
			SendMessage (hCheckLog, BM_SETCHECK, BST_CHECKED, 0) ; // Default is logging enabled

			hListViewStartHeader = (HWND) SendMessage (hListViewStart, LVM_GETHEADER, 0, 0) ; // Get the list view header handles
			hListViewSolvedHeader = (HWND) SendMessage (hListViewSolved, LVM_GETHEADER, 0, 0) ;
			// SubClassing: add your own procedure but keep the original as well by calling it
			OrigListViewStartHeaderProc = (WNDPROC) SetWindowLong (hListViewStartHeader, GWLP_WNDPROC, (LONG) ListViewStartHeaderProc) ;
			OrigListViewSolvedHeaderProc = (WNDPROC) SetWindowLong (hListViewSolvedHeader, GWLP_WNDPROC, (LONG) ListViewSolvedHeaderProc) ;
			OrigListViewStartProc = (WNDPROC) SetWindowLong (hListViewStart, GWLP_WNDPROC, (LONG) ListViewStartProc) ;
			OrigListViewSolvedProc = (WNDPROC) SetWindowLong (hListViewSolved, GWLP_WNDPROC, (LONG) ListViewStartProc) ;

			hLogBrush = CreateSolidBrush (logBckClr) ;

			gridArea = (unsigned char *) calloc (82, sizeof (unsigned char)) ; // Grid area. 81 numbers + first char (0) is not used
			prev_gridArea = (unsigned char *) calloc (82, sizeof (unsigned char)) ; // Previous grid area. 81 numbers + first char (0) is not used
			numsDone = (unsigned char *) malloc (10 * sizeof (unsigned char)) ;	// Registers how many of each number (1-9) are still available
			pgridArea = gridArea + 1 ;						// For a better debugger view of the grid area (starts at index 1)
			prev_pgridArea = prev_gridArea + 1 ;			// For a better debugger view of the grid area (starts at index 1)
			pnumsDone = numsDone + 1 ;						// Same for the finsihed numbers
			killerGroup = (unsigned char *) calloc (82, sizeof (unsigned char)) ;	// Contains the group number associated with a given grid cell
			
			if (MessageBoxA (hDlg, "The default language is English. Change to Hungarian?", "Welcome to SuDoKu solver!", MB_YESNO | MB_ICONQUESTION | MB_APPLMODAL) == IDYES) {
				langCode = Magyar ;
			}
			else {
				langCode = English ;
			}

			enableLogging = true ;
			clearLog = false ;
			paintOrigNumbers  = false ;
			canClose = true ;								// Enables or disables the closure of the dialog when the user clicks on the X in the top-right corner

			mprintf (szLogHeader1[langCode]) ;				// Log header
			mprintf (szLogHeader2[langCode]) ;
			mprintf (szLogHeader3[langCode]) ;

			return FALSE ;									// Do not give focus to the default control, keep it where I focussed it!
		}
		break ;
		case WM_COMMAND:									// Button and menu messages
		{
			wmId = LOWORD (wParam) ;
			wmEvent = HIWORD (wParam) ;

			switch (wmId)
			{
				/*case IDC_EDIT_LOG:						// disable editing of the log window. Send focus to List view immediately as the log window gets it
				{
					switch (HIWORD (wParam))
					{
					case EN_SETFOCUS:
						SetFocus (hListViewStart) ;
						return 0 ;
					}
				}
				break ;*/
				case IDC_BUTTON_CLOSE:						// The button, the corresponding menu item and the toolbar button are all synchronized
				case IDC_TOOLBAR_EXIT:
				case ID_MENU_FILE_EXIT:
				{
					PostMessage (hDlg, WM_CLOSE, 0, 0) ;	// Close down everything gracefully
				}
				break ;
				case IDC_BUTTON_CLEAR:
				case IDC_TOOLBAR_CLEAR:
				{
					ZeroMemory (pgridArea, 81) ;
					resetGrid (hListViewStart) ;
					SetFocus (hListViewStart) ;
				}
				break ;
				case IDC_BUTTON_SOLVE:
				case IDC_TOOLBAR_SOLVE:
				{
					hThread = CreateThread (NULL, 0, (LPTHREAD_START_ROUTINE) SuDoKuEngine,	hDlg, CREATE_SUSPENDED, &ThreadId) ; // Create a thread
					if (ResumeThread (hThread) == -1) {
						wsprintf (buffer, szThreadFStart [langCode], ThreadId) ;
						mprintf (buffer) ;
						MessageBoxA (hDlg, szThreadFStartMsg [langCode], szError [langCode], MB_OK | MB_ICONEXCLAMATION | MB_APPLMODAL) ;
						return true ;
					}
					
					working = true ;						// Set to true while solving the grid
					canClose = false ;
					EnableWindow (GetDlgItem (hDlg, IDC_BUTTON_STOP), true) ;
					EnableWindow (GetDlgItem (hDlg, IDC_BUTTON_CLEAR), false) ;
					EnableWindow (GetDlgItem (hDlg, IDC_BUTTON_SOLVE), false) ;
					EnableWindow (GetDlgItem (hDlg, IDC_BUTTON_CLOSE), false) ;
					EnableWindow (GetDlgItem (hDlg, IDC_BUTTON_CLEAR_LOG), false) ;
					EnableWindow (GetDlgItem (hDlg, IDC_RADIO_MULTISOLVE), false) ;
					EnableWindow (GetDlgItem (hDlg, IDC_RADIO_SINGLESOLVE), false) ;
					EnableWindow (GetDlgItem (hDlg, IDC_RADIO_VARIATIONS), false) ;
					EnableMenuItem (hMenu, ID_MENU_FILE_LOADGRID, MF_BYCOMMAND | MF_DISABLED) ;
					EnableMenuItem (hMenu, ID_MENU_FILE_EXIT, MF_BYCOMMAND | MF_DISABLED) ;
					SendMessage (hToolbar, TB_ENABLEBUTTON, IDC_TOOLBAR_STOP, true) ;
					SendMessage (hToolbar, TB_ENABLEBUTTON, IDC_TOOLBAR_CLEAR, false) ;
					SendMessage (hToolbar, TB_ENABLEBUTTON, IDC_TOOLBAR_SOLVE, false) ;
					SendMessage (hToolbar, TB_ENABLEBUTTON, IDC_TOOLBAR_EXIT, false) ;

					SendMessage (hProgress, PBM_SETMARQUEE, (WPARAM) TRUE, 20) ; // Progres bar start 
					ShowWindow (hProgress, SW_SHOW) ;
					SetFocus (hListViewStart) ;
				}
				break ;
				case IDC_BUTTON_STOP:
				case IDC_TOOLBAR_STOP:
				{
					terminateThread = true ;				// User terminated the thread while it was running
					working = false ;
					canClose = true ;
					EnableWindow (GetDlgItem (hDlg, IDC_BUTTON_STOP), false) ;
					EnableWindow (GetDlgItem (hDlg, IDC_BUTTON_CLEAR), true) ;
					EnableWindow (GetDlgItem (hDlg, IDC_BUTTON_SOLVE), true) ;
					EnableWindow (GetDlgItem (hDlg, IDC_BUTTON_NEXT), false) ;
					EnableWindow (GetDlgItem (hDlg, IDC_BUTTON_CLOSE), true) ;
					EnableWindow (GetDlgItem (hDlg, IDC_BUTTON_CLEAR_LOG), true) ;
					EnableWindow (GetDlgItem (hDlg, IDC_RADIO_MULTISOLVE), true) ;
					EnableWindow (GetDlgItem (hDlg, IDC_RADIO_SINGLESOLVE), true) ;
					EnableWindow (GetDlgItem (hDlg, IDC_RADIO_VARIATIONS), true) ;
					EnableMenuItem (hMenu, ID_MENU_FILE_LOADGRID, MF_BYCOMMAND | MF_ENABLED) ;
					EnableMenuItem (hMenu, ID_MENU_FILE_EXIT, MF_BYCOMMAND | MF_ENABLED) ;
					SendMessage (hToolbar, TB_ENABLEBUTTON, IDC_TOOLBAR_STOP, false) ;
					SendMessage (hToolbar, TB_ENABLEBUTTON, IDC_TOOLBAR_CLEAR, true) ;
					SendMessage (hToolbar, TB_ENABLEBUTTON, IDC_TOOLBAR_SOLVE, true) ;
					SendMessage (hToolbar, TB_ENABLEBUTTON, IDC_TOOLBAR_NEXT, false) ;
					SendMessage (hToolbar, TB_ENABLEBUTTON, IDC_TOOLBAR_EXIT, true) ;

					ShowWindow (hProgress, SW_HIDE) ;		// Stop progres bar
					ResumeThread (hThread) ;
					SetFocus (hListViewStart) ;
				}
				break ;
				case IDC_BUTTON_NEXT:
				case IDC_TOOLBAR_NEXT:
				{
					getStartTime () ;						// User requests the next solution

					mprintf ("\r\n\r\n") ;
					wsprintf (buffer, szLogDateTime[langCode], currentDateTime ()) ;
					mprintf (buffer) ;
					mprintf ("\r\n") ;

					if (ResumeThread (hThread) == -1) {
						wsprintf (buffer, szThreadFResume [langCode], ThreadId) ;
						mprintf (buffer) ;
						MessageBoxA (hDlg, szThreadFResumeMsg [langCode], szError [langCode], MB_OK | MB_ICONEXCLAMATION | MB_APPLMODAL) ;
						return true ;
					}
					EnableWindow (GetDlgItem (hDlg, IDC_BUTTON_NEXT), false) ;
					EnableWindow (GetDlgItem (hDlg, IDC_BUTTON_CLOSE), false) ;
					EnableWindow (GetDlgItem (hDlg, IDC_BUTTON_CLEAR_LOG), false) ;
					SendMessage (hToolbar, TB_ENABLEBUTTON, IDC_TOOLBAR_NEXT, false) ;
					SendMessage (hToolbar, TB_ENABLEBUTTON, IDC_TOOLBAR_EXIT, false) ;
					ShowWindow (hProgress, SW_SHOW) ;
					SetFocus (hListViewStart) ;
				}
				break ;
				case IDC_BUTTON_CLEAR_LOG:
				{
					resetLog () ;							// Clear the log window
				}
				break ;
				case IDC_TOOLBAR_HUNFLAG:					// Change to Hungarian
				{
					langCode = Magyar ;
					changeLang () ;
					SendMessage (hToolbar, TB_ENABLEBUTTON, IDC_TOOLBAR_HUNFLAG, false) ;
					SendMessage (hToolbar, TB_ENABLEBUTTON, IDC_TOOLBAR_ENGFLAG, true) ;
					SendMessage (hDlg, WM_NCPAINT, 0, 0) ;
				}
				break ;
				case IDC_TOOLBAR_ENGFLAG:					// Change to English
				{
					langCode = English ;
					changeLang () ;
					SendMessage (hToolbar, TB_ENABLEBUTTON, IDC_TOOLBAR_HUNFLAG, true) ;
					SendMessage (hToolbar, TB_ENABLEBUTTON, IDC_TOOLBAR_ENGFLAG, false) ;
					SendMessage (hDlg, WM_NCPAINT, 0, 0) ;
				}
				break ;
				case IDC_RADIO_SINGLESOLVE:					// Single-solve mode
				{
					int ret = SendMessage (hRadioButtonSin, BM_GETCHECK, 0, 0) ;
					if (ret == BST_CHECKED) {
						solveMode = Single ;
						playingNumbers = 9 ;
						SendMessage (GetDlgItem (hDlg, IDC_RADIO_VARIATIONS), BM_SETCHECK, BST_UNCHECKED, 0) ;
						SendMessage (GetDlgItem (hDlg, IDC_RADIO_MULTISOLVE), BM_SETCHECK, BST_UNCHECKED, 0) ;
						EnableWindow (GetDlgItem (hDlg, IDC_EDIT_NUMS), false) ;
					}
					SetFocus (hListViewStart) ;
				}
				break ;
				case IDC_RADIO_MULTISOLVE:					// Multi-solve mode
				{
					int ret = SendMessage (hRadioButtonMul, BM_GETCHECK, 0, 0) ;
					if (ret == BST_CHECKED) {
							solveMode = Multi ;
							playingNumbers = 9 ;
							SendMessage (GetDlgItem (hDlg, IDC_RADIO_VARIATIONS), BM_SETCHECK, BST_UNCHECKED, 0) ;
							SendMessage (GetDlgItem (hDlg, IDC_RADIO_SINGLESOLVE), BM_SETCHECK, BST_UNCHECKED, 0) ;
							EnableWindow (GetDlgItem (hDlg, IDC_EDIT_NUMS), false) ;
					}
					SetFocus (hListViewStart) ;
				}
				break ;
				case IDC_RADIO_VARIATIONS:					// Variations only mode
				{
					int ret = SendMessage (hRadioButtonVar, BM_GETCHECK, 0, 0) ;
					switch (ret) {
						case BST_CHECKED:
						{
							solveMode = Variations ;
							EnableWindow (GetDlgItem (hDlg, IDC_EDIT_NUMS), true) ;
							SendMessage (GetDlgItem (hDlg, IDC_RADIO_MULTISOLVE), BM_SETCHECK, BST_UNCHECKED, 0) ;
							SendMessage (GetDlgItem (hDlg, IDC_RADIO_SINGLESOLVE), BM_SETCHECK, BST_UNCHECKED, 0) ;
						}
						break ;
						case BST_INDETERMINATE:
						{
							EnableWindow (GetDlgItem (hDlg, IDC_EDIT_NUMS), false) ;
						}
						break ;
						case BST_UNCHECKED:
						{
							EnableWindow (GetDlgItem (hDlg, IDC_EDIT_NUMS), false) ;
						}
						break ;
					}
					SetFocus (hListViewStart) ;
				}
				break ;
				case IDC_CHECK_LOG:							// Enable/disable logging
				{
					int ret = SendMessage (hCheckLog, BM_GETCHECK, 0, 0) ;
					switch (ret) {
						case BST_CHECKED:
						{
							enableLogging = true ;
						}
						break ;
						case BST_INDETERMINATE:
						{
							enableLogging = false ;
						}
						break ;
						case BST_UNCHECKED:
						{
							enableLogging = false ;
						}
						break ;
					}
					SetFocus (hListViewStart) ;
				}
				break ;
				case ID_MENU_FILE_SAVEGRID:					// Save the starting grid
				case IDC_TOOLBAR_SAVE:
				{
					OPENFILENAME ofn ;
					char szFileName[MAX_PATH] = "" ;

					ZeroMemory (&ofn, sizeof (ofn)) ;
					ofn.lStructSize = sizeof (OPENFILENAME) ;
					ofn.hwndOwner = hDlg ;
					ofn.lpstrFilter = "Text Files (*.txt)\0*.txt\0All Files (*.*)\0*.*\0" ;
					ofn.lpstrFile = szFileName ;
					ofn.nMaxFile = MAX_PATH ;
					ofn.lpstrDefExt = "txt" ;
					ofn.Flags = OFN_EXPLORER | OFN_PATHMUSTEXIST | OFN_HIDEREADONLY | OFN_OVERWRITEPROMPT ;	// Ask to overwrite if exists

					readGrid (hListViewStart) ;

					if (GetSaveFileName (&ofn)) {
						if (SaveTextFile (szFileName)) {
							MessageBoxA (hDlg, szGridSavedMsg [langCode], szSuccess [langCode], MB_OK | MB_ICONINFORMATION | MB_APPLMODAL) ;
						}
						else {
							MessageBoxA (hDlg, szGridFSavedMsg [langCode], szError [langCode], MB_OK | MB_ICONEXCLAMATION | MB_APPLMODAL) ;
							break ;
						}
					}
					SetFocus (hListViewStart) ;
				}
				break ;
				case ID_MENU_FILE_LOADGRID:					// Load the starting grid
				case IDC_TOOLBAR_LOAD:
				{
					OPENFILENAME ofn ;
					char szFileName[MAX_PATH] = "" ;		// Largest file name possible

					ZeroMemory (&ofn, sizeof(ofn)) ;

					ofn.lStructSize = sizeof (OPENFILENAME) ;
					ofn.hwndOwner = hDlg ;
					ofn.lpstrFilter = "Text Files (*.txt)\0*.txt\0All Files (*.*)\0*.*\0" ;
					ofn.lpstrFile = szFileName ;				// File name
					ofn.nMaxFile = MAX_PATH ;
					ofn.Flags = OFN_EXPLORER | OFN_FILEMUSTEXIST | OFN_HIDEREADONLY ;	// No read-only files, file must exist
					ofn.lpstrDefExt = "txt" ;				// Default extension

					if (GetOpenFileName (&ofn)) {
						if (LoadTextFile(szFileName)) {
							writeGrid (hListViewStart) ;
							MessageBoxA (hDlg, szGridLoadedMsg [langCode], szSuccess [langCode], MB_OK | MB_ICONINFORMATION | MB_APPLMODAL) ;
						}
						else {
							MessageBoxA (hDlg, szGridFLoadedMsg [langCode], szError [langCode], MB_OK | MB_ICONEXCLAMATION | MB_APPLMODAL) ;
							break ;
						}
					}
					SetFocus (hListViewStart) ;
				}
				break ;
				case ID_MENU_FILE_SAVELOG:					// Save the log window content
				case IDC_TOOLBAR_LOG:
				{
					OPENFILENAME ofn ;
					char szFileName[MAX_PATH] = "" ;

					ZeroMemory (&ofn, sizeof (ofn)) ;

					ofn.lStructSize = sizeof (OPENFILENAME) ;
					ofn.hwndOwner = hDlg ;
					ofn.lpstrFilter = "Log Files (*.log)\0*.log\0All Files (*.*)\0*.*\0" ;
					ofn.lpstrFile = szFileName ;
					ofn.nMaxFile = MAX_PATH ;
					ofn.lpstrDefExt = "log" ;
					ofn.Flags = OFN_EXPLORER | OFN_PATHMUSTEXIST | OFN_HIDEREADONLY | OFN_OVERWRITEPROMPT;	// Ask to overwrite if exists

					EnableWindow (GetDlgItem (hDlg, IDC_BUTTON_CLEAR_LOG), false) ;
					if (GetSaveFileName (&ofn))	{
						HWND hEditControl = GetDlgItem (hDlg, IDC_EDIT_LOG) ;
						if (SaveLogFile (hEditControl, szFileName)) {
							MessageBoxA (hDlg, szLogSavedMsg [langCode], szSuccess [langCode], MB_OK | MB_ICONINFORMATION | MB_APPLMODAL) ;
						}
						else {
							MessageBoxA (hDlg, szLogFSavedMsg [langCode], szError [langCode], MB_OK | MB_ICONEXCLAMATION | MB_APPLMODAL) ;
							break ;
						}
					}
					EnableWindow (GetDlgItem (hDlg, IDC_BUTTON_CLEAR_LOG), true) ;
					SetFocus (hListViewStart) ;
				}
				break ;
				case ID_MENU_HELP_ABOUT:					// display the "About" modal dialog
				{
					RECT rcP, rc ;							// Rectangle structure to store the coordinates

					GetWindowRect (hDlg, &rcP) ;			// Parent's position
					int widthP = (rcP.right - rcP.left) ;
					int heightP = (rcP.bottom - rcP.top) ;
					GetWindowRect (hAboutDlg, &rc) ;		// About dialog's position
					int width = (rc.right - rc.left) ;
					int height = (rc.bottom - rc.top) ;
					/*MoveWindow (hAboutDlg, rcP.left + (widthP - width) / 2, rcP.top + (heightP - height) / 2, width, height, TRUE) ;*/
					SetWindowPos (hAboutDlg, HWND_TOP, rcP.left + (widthP - width) / 2, rcP.top + (heightP - height) / 2, width, height, SWP_SHOWWINDOW) ;
				}
			}
		}
		break ;
		case WM_PAINT:
		{
			hDC = BeginPaint (hDlg, &ps) ;
			//SetBkMode(hDC, TRANSPARENT) ;
			//Rectangle (hDC, 150, 150, 300, 300) ;
			EndPaint (hDlg, &ps) ;
		}
		break ;
		case HDN_BEGINTRACK:
		{
			SetWindowLong (hDlg, DWL_MSGRESULT, TRUE) ;		// Prevent resizing of the list view (grid) columns

			return TRUE ;									// Message processed
		}
		case WM_NOTIFY:
		{
			NMHDR *nmhdr = (NMHDR *) lParam ;

			if (HDN_BEGINTRACKW == nmhdr->code || HDN_BEGINTRACKA == nmhdr->code || HDN_BEGINTRACK == nmhdr->code 
				|| nmhdr->code == HDN_DIVIDERDBLCLICKA || nmhdr->code == HDN_DIVIDERDBLCLICKW)
			{
				SetWindowLong (hDlg, DWL_MSGRESULT, TRUE) ;	// Prevent resizing

				return TRUE ;
			}

			if (nmhdr->code == TTN_GETDISPINFO) {			// Handle tooltip requests for the toolbar buttons
				lpttt = (LPTOOLTIPTEXT) lParam ;			// Structure to be used for sending info to the toolbar
				idButton = lpttt->hdr.idFrom ;
            
				switch (idButton) 
				{
					case IDC_TOOLBAR_SAVE:
					{
						lpttt->lpszText = szToolbarSave [langCode] ;
					}
					break ; 
					case IDC_TOOLBAR_LOAD: 
					{
						lpttt->lpszText = szToolbarLoad [langCode] ;
					}
					break ; 
					case IDC_TOOLBAR_LOG:
					{
						lpttt->lpszText = szToolbarLog [langCode] ; 
					}
					break ;
					case IDC_TOOLBAR_CLEAR:
					{
						lpttt->lpszText = szToolbarClear [langCode] ; 
					}
					break ;
					case IDC_TOOLBAR_SOLVE:
					{
						lpttt->lpszText = szToolbarSolve [langCode] ; 
					}
					break ;
					case IDC_TOOLBAR_STOP:
					{
						lpttt->lpszText = szToolbarStop [langCode] ; 
					}
					break ;
					case IDC_TOOLBAR_NEXT:
					{
						lpttt->lpszText = szToolbarNext [langCode] ; 
					}
					break ;
					case IDC_TOOLBAR_HUNFLAG:
					{
						lpttt->lpszText = szToolbarHunFlag [langCode] ; 
					}
					break ; 
					case IDC_TOOLBAR_ENGFLAG:
					{
						lpttt->lpszText = szToolbarEngFlag [langCode] ; 
					}
					break ; 
					case IDC_TOOLBAR_EXIT:
					{
						lpttt->lpszText = szToolbarExit [langCode] ;
					}
					break ; 
				}
            } 
			switch (LOWORD (wParam))						// The identifier of the common control sending the message
			{
				case IDC_LIST_START:
				{
					pnm = (LPNMLISTVIEW) lParam ; 

					if (pnm->hdr.hwndFrom == hListViewStart && pnm->hdr.code == NM_CUSTOMDRAW)
					{
						SetWindowLong (hDlg, DWL_MSGRESULT, (LONG) ProcessCustomDrawStartG (lParam)) ;

						return TRUE;
					}

					if (((LPNMHDR) lParam)->code == NM_CLICK || ((LPNMHDR) lParam)->code == NM_RCLICK || ((LPNMHDR) lParam)->code == NM_DBLCLK)
					{
						memset (&hti, 0, sizeof (LVHITTESTINFO)) ;
						memset (&LvItem, 0, sizeof (LVITEM)) ;
						ia = (NMITEMACTIVATE *) lParam ;

						if (working) {						// If solve is in progress, disable the editing of any grid cells
							return TRUE;
						}

						hti.pt.x = ia->ptAction.x ;			// Get the coordinates of the mouse click to identify the grid cell that is affected
						hti.pt.y = ia->ptAction.y ;
						SendMessage (hListViewStart, LVM_SUBITEMHITTEST, 0, (LPARAM) &hti) ;
						if (hti.iItem == -1 || hti.iSubItem == -1 || hti.iSubItem == 0) {
							break;
						}
						// iItem = row, iSubItem = col. Item is zero-based. The subitem is 1-based. Zero is the item itself
						// wParam = Index of the list-view item
						// lParam = Pointer to an LVITEM structure. To retrieve the item text, set iSubItem to zero. To retrieve the text of a subitem, set iSubItem to the subitem's index
						// The pszText member points to a buffer that receives the text. The cchTextMax member specifies the number of characters in the buffer.

						LvItem.mask = LVIF_TEXT ;			// Set of flags that specify which members of this structure contain data to be set or which members are being requested.
						LvItem.iItem = hti.iItem ;
						LvItem.iSubItem = hti.iSubItem ;
						char cellText[2] ;
						LvItem.pszText = cellText ;
						LvItem.cchTextMax = 2 ;
						SendMessage (hListViewStart, LVM_GETITEMTEXT, hti.iItem, (LPARAM) &LvItem) ;

						if (((LPNMHDR) lParam)->code == NM_CLICK) { // Left mouse click
							if (atoi (cellText) == 9) {
								_itoa_s (1, cellText, 10) ;
								SendMessage (hListViewStart, LVM_SETITEMTEXT, hti.iItem, (LPARAM) &LvItem) ;
							}
							else if (atoi (cellText) == 0) {
								_itoa_s (1, cellText, 10) ;	// Integer 1 converted to text in 10 radix
								SendMessage (hListViewStart, LVM_SETITEMTEXT, hti.iItem, (LPARAM) &LvItem) ;
							}
							else {
								cellText[0] ++ ;			// Increase the value in the grid cell
								SendMessage (hListViewStart, LVM_SETITEMTEXT, hti.iItem, (LPARAM) &LvItem) ;
							}
						}
						else if (((LPNMHDR) lParam)->code == NM_RCLICK) { // right mouse click
							if (atoi (cellText) == 0) {
								_itoa_s (9, cellText, 10) ;
								SendMessage (hListViewStart, LVM_SETITEMTEXT, hti.iItem, (LPARAM) &LvItem) ;
							}
							else if (atoi (cellText) == 1) {
								_itoa_s (9, cellText, 10) ;
								SendMessage (hListViewStart, LVM_SETITEMTEXT, hti.iItem, (LPARAM) &LvItem) ;
							}
							else {
								cellText[0] -- ;			// Decrease the value in the grid cell
								SendMessage (hListViewStart, LVM_SETITEMTEXT, hti.iItem, (LPARAM) &LvItem) ;
							}
						}
						else if (((LPNMHDR) lParam)->code == NM_DBLCLK) { // Double mouse click
							cellText[0] = 0 ;				// Erease the value in the grid cell
							SendMessage (hListViewStart, LVM_SETITEMTEXT, hti.iItem, (LPARAM) &LvItem) ;
						}
						SendMessage (hListViewStart, WM_PAINT, 0, 0) ;
					}
					break ;
				}
				case IDC_LIST_SOLVED:
				{
					LPNMLISTVIEW pnm = (LPNMLISTVIEW) lParam ; // NMLISTVIEW is a structure. The first member is NMHDR that has the notification code hwndFrom, idFrom, code

					if (pnm->hdr.hwndFrom == hListViewSolved &&pnm->hdr.code == NM_CUSTOMDRAW)
					{
						SetWindowLong (hDlg, DWL_MSGRESULT, (LONG) ProcessCustomDrawSolvedG (lParam)) ;

						return TRUE ;
					}
				}
			}
		}
		break ;
		case WM_CTLCOLORSTATIC:								// Read-only edit control's colour
		{
			HDC hdc = (HDC) wParam ;
			if (GetDlgItem (hDlg, IDC_EDIT_LOG) == (HWND) lParam || GetDlgItem (hDlg, IDC_EDIT_NUMS) == (HWND) lParam) {
				SetTextColor (hdc, logTxtFrgClr) ;
				SetBkColor (hdc, logTxtBckClr) ;
				
				return (INT_PTR) hLogBrush ;
				//return (LRESULT) ((HBRUSH) hLogBrush) ;	// If not a dialog but a window
			}
		}
		break;
		case WM_DESTROY:									// Called by WM_CLOSE
		{
			free (gridArea) ;								// Free malloc or calloc-ated memory
			free (prev_gridArea) ;
			free (numsDone) ;
			free (killerGroup) ;

			if (hThread != NULL)
				CloseHandle (hThread) ;
			if (hListViewStart != NULL)
				CloseHandle (hListViewStart) ;
			if (hListViewSolved != NULL)
				CloseHandle (hListViewSolved) ;
			if (hWndListView != NULL)
				CloseHandle (hWndListView) ;
			if (hProgress != NULL)
				CloseHandle (hProgress) ;
			if (hRadioButtonSin != NULL)
				CloseHandle (hRadioButtonSin) ;
			if (hRadioButtonMul != NULL)
				CloseHandle (hRadioButtonMul) ;
			if (hRadioButtonVar != NULL)
				CloseHandle (hRadioButtonVar) ;
			if (hStatusBar != NULL)
				CloseHandle (hStatusBar) ;
			if (hToolbar != NULL)
				CloseHandle (hToolbar) ;
			if (hOutput != NULL)
				CloseHandle (hOutput) ;
			if (hImgList != NULL)
			ImageList_Destroy (hImgList) ;
			DeleteObject (hFont) ;
			DeleteObject (hLogBrush) ;

			SetDoubleClickTime (0) ;						// Reset default, system double click time
			PostQuitMessage (0) ;							// Sends WM_QUIT
			
			return 0 ;
		}
		break ;
		case WM_CLOSE:										// On closure of the dialog
		{
			if (!canClose)
				return 0 ;
			if (MessageBoxA (hDlg, szQuitMsg [langCode], szQuitCMsg [langCode], MB_OKCANCEL | MB_ICONQUESTION) == IDOK) {
				DestroyWindow (hDlg) ;
			}
			SetFocus (hListViewStart) ;
		    return 0 ;
		}
		break ;
	}

	return 0 ;
}

// About dialog callback routine
BOOL CALLBACK AboutDlgProc (HWND hwnd, UINT Message, WPARAM wParam, LPARAM lParam)
{
	switch (Message)
	{
		case WM_INITDIALOG:
		{
			return TRUE ;								// After processed messages must return TRUE
		}
		break ;
		case WM_COMMAND:
		{
			switch (LOWORD (wParam))
			{
				case IDC_BUTTON_OK:
				{
					EndDialog (hwnd, IDC_BUTTON_OK) ;	// Modal dialog so has to call EndDialog
				}
				break;
			}
		}
		break ;
		case WM_PAINT:
		{
			// Drawing bitmaps
			// 0. Get the DC first
			PAINTSTRUCT pstruct;
			PAINTSTRUCT * ppstruct = &pstruct ;
			HDC hDC, MemDC ;

			hDC = BeginPaint (hwnd, ppstruct) ;
			// 1. Load the bitmap from the resource
			HBITMAP bmp = LoadBitmap (GetModuleHandle(NULL), MAKEINTRESOURCE (IDB_BITMAP_HEART)) ;
			// 2. Create a memory device compatible with the above DC variable
			MemDC = CreateCompatibleDC (hDC) ;
			// 3. Select the new bitmap into it
			HBITMAP oldBmp = (HBITMAP) SelectObject (MemDC, bmp);
			// 4. Copy the bits from the memory DC into the current DC to show the bitmap
			BitBlt (hDC, 257, 72, 275, 90, MemDC, 0, 0, SRCCOPY) ;

			SelectObject (MemDC, oldBmp) ;
			DeleteObject (bmp) ;
			DeleteDC (MemDC) ;
			EndPaint (hwnd, ppstruct) ;
		}
		break ;
		default:
			return FALSE ;									// Messages that not handled must return FALSE
	}

	return TRUE ;
}

// List view (starting grid) callback routine
LRESULT ListViewStartProc (HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam)
{
	HDC hDCst, hDCso ;
	int xStart = 20, xEnd = 208, yStart = 22, cube3X = 63, cube3Y = 52 ;
	static bool Tracking = false ;

	switch (msg)
	{
		case WM_MOUSEMOVE:									// Track the mouse if it enters the list view control client area
		{
			TRACKMOUSEEVENT tme ;
			tme.cbSize = sizeof (TRACKMOUSEEVENT) ;
			tme.dwFlags = TME_HOVER | TME_LEAVE ;			// Type of events to track & trigger
			tme.dwHoverTime = 1 ;							// How long the mouse has to be in the window to trigger a hover event
			tme.hwndTrack = hListViewStart ;
			TrackMouseEvent (&tme) ;
		}
		case WM_MOUSEHOVER:
		{
			SetDoubleClickTime (200) ;						// Decrease double click time for more convenience

			return true ;
		}
		break ;
		case WM_MOUSELEAVE:
		{
			SetDoubleClickTime (0) ;						// Restore system default mouse double click speed

			return true ;
		}
		break ;
		case WM_PAINT:
		{
			CallWindowProc (OrigListViewStartProc, hWnd, msg, wParam, lParam) ; // Send all other messages to the original WndProc
			CallWindowProc (OrigListViewSolvedProc, hWnd, msg, wParam, lParam) ; // First let the original control paint itself, then paint over it
			hDCst = GetDC (hListViewStart) ;
			hDCso = GetDC (hListViewSolved) ;

			// Starting grid
			MoveToEx (hDCst, xStart, yStart, NULL) ;		// Paint the group 3x3 rectangles over the List view control
			LineTo (hDCst, xEnd, yStart) ;
			MoveToEx (hDCst, xStart, yStart + cube3Y, NULL) ;
			LineTo (hDCst, xEnd, yStart + cube3Y);
			MoveToEx (hDCst, xStart, yStart + 2 * cube3Y, NULL) ;
			LineTo (hDCst, xEnd, yStart + 2 * cube3Y);
			MoveToEx (hDCst, xStart, yStart + 3 * cube3Y, NULL) ;
			LineTo (hDCst, xEnd, yStart + 3 * cube3Y) ;
			
			MoveToEx (hDCst, xStart, yStart, NULL) ;
			LineTo (hDCst, xStart, yStart + 3 * cube3Y) ;
			MoveToEx (hDCst, xEnd, yStart, NULL) ;
			LineTo (hDCst, xEnd, yStart + 3 * cube3Y) ;

			MoveToEx (hDCst, xStart + cube3X, yStart, NULL) ;
			LineTo (hDCst, xStart + cube3X, yStart + 3 * cube3Y) ;
			MoveToEx (hDCst, xStart + 2 * cube3X, yStart, NULL) ;
			LineTo (hDCst, xStart + 2 * cube3X, yStart + 3 * cube3Y) ;

			// Solved grid
			MoveToEx (hDCso, xStart, yStart, NULL) ;
			LineTo (hDCso, xEnd, yStart) ;
			MoveToEx (hDCso, xStart, yStart + cube3Y, NULL) ;
			LineTo (hDCso, xEnd, yStart + cube3Y);
			MoveToEx (hDCso, xStart, yStart + 2 * cube3Y, NULL) ;
			LineTo (hDCso, xEnd, yStart + 2 * cube3Y);
			MoveToEx (hDCso, xStart, yStart + 3 * cube3Y, NULL) ;
			LineTo (hDCso, xEnd, yStart + 3 * cube3Y) ;
			
			MoveToEx (hDCso, xStart, yStart, NULL) ;
			LineTo (hDCso, xStart, yStart + 3 * cube3Y) ;
			MoveToEx (hDCso, xEnd, yStart, NULL) ;
			LineTo (hDCso, xEnd, yStart + 3 * cube3Y) ;

			MoveToEx (hDCso, xStart + cube3X, yStart, NULL) ;
			LineTo (hDCso, xStart + cube3X, yStart + 3 * cube3Y) ;
			MoveToEx (hDCso, xStart + 2 * cube3X, yStart, NULL) ;
			LineTo (hDCso, xStart + 2 * cube3X, yStart + 3 * cube3Y) ;

			// Draw the original starting grid numbers in different colour
			if (paintOrigNumbers) {
				SetTextColor (hDCso, origCellClr) ;			// Colour the starting grid values
				SetBkMode (hDCso, TRANSPARENT) ;
				SetBkColor (hDCso, RGB (255, 255, 255)) ;

				hFont2 = CreateFont (14, 0, 0, 0, FW_BOLD, FALSE, FALSE, FALSE, ANSI_CHARSET, OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS, DEFAULT_QUALITY, DEFAULT_PITCH | FF_ROMAN, "Times New Roman") ;
				hOldFont2 = (HFONT) SelectObject (hDCso, hFont2) ;
				
				LVITEM LvItem ;
				LvItem.mask = LVIF_TEXT ;					// Changing the text only
				char cellTextStart[2] ;
				char cellTextSolved[2] ;
				LvItem.pszText = cellTextStart ;
				LvItem.cchTextMax = 2 ;						// Include a terminating zero
			
				int x = 27, y = 26, dx = 21, dy = 17 ;		// Upper-left cell is at 27, 26. Each cell is 21 pixels apart horizontally and 17 vertically

				for (char i = 1; i <= 9; i ++) {			// Populate cells with given values in the starting grid with a different colour
					for (char j = 1; j <= 9; j ++) {
						LvItem.iSubItem = j ;
						SendMessage (hListViewStart, LVM_GETITEMTEXT, i - 1, (LPARAM) &LvItem) ;
						if (cellTextStart[0] != 0) {
							TextOut (hDCso, x + (j - 1) * dx, y + (i - 1) * dy, cellTextStart, 2) ;
						}
					}
				}

				if (solvedNTimes > 1 && solveMode == Multi) {
					SetTextColor (hDCso, chgdCellClr) ;		// Colour the changed grid
					for (char i = 1; i <= 9; i ++) {		// During multi-solve mode, colour the changed cells differently
						for (char j = 1; j <= 9; j ++) {
							LvItem.iSubItem = j ;
							LvItem.pszText = cellTextStart ;
							SendMessage (hListViewStart, LVM_GETITEMTEXT, i - 1, (LPARAM) &LvItem) ;
							LvItem.pszText = cellTextSolved ;
							SendMessage (hListViewSolved, LVM_GETITEMTEXT, i - 1, (LPARAM) &LvItem) ;
							if (cellTextSolved[0] == 0 && cellTextStart[0] == 0) { // It is 0 (marked by changedGrid and it is not in the starting grid
								int val = * (pgridArea + ((i - 1) * 9) + (j - 1)) ;
								_itoa_s (val, cellTextSolved, 10) ;
								TextOut (hDCso, x + (j - 1) * dx, y + (i - 1) * dy, cellTextSolved, 2) ;
							}
						}					
					}
				}

				SelectObject (hDCso, hOldFont2) ;			// Restore font when done

				paintOrigNumbers = false ;
			}

			ReleaseDC (hListViewStart, hDCst) ;
			ReleaseDC (hListViewSolved, hDCso) ;

			return true ;
		}
	}

	return CallWindowProc (OrigListViewStartProc, hWnd, msg, wParam, lParam) ; // Send all other messages to the original WndProc
}

// List view (starting grid) header callback routine
LRESULT ListViewStartHeaderProc (HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam)
{
	switch (msg)
	{
		case WM_SETCURSOR:									// Stop the header from changing to the "change column width mouse cursor"
		{
			return TRUE ;
		}
		case WM_LBUTTONDBLCLK:								// Stop the user from resizing by double clicking on the header
		{
			return 0 ;
		}
	}

	return CallWindowProc (OrigListViewStartHeaderProc, hWnd, msg, wParam, lParam) ; // Send all other messages to the original WndProc
}

// List view (solved grid) callback routine
LRESULT ListViewSolvedHeaderProc (HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam)
{
	switch (msg)
	{
		case WM_SETCURSOR:
		{
			return TRUE ;
		}
		case WM_LBUTTONDBLCLK:
		{
			return 0 ;
		}
	}
	return CallWindowProc (OrigListViewSolvedHeaderProc, hWnd, msg, wParam, lParam) ;
}

// Custom draw of list view (grid) columns 
LRESULT ProcessCustomDrawStartG (LPARAM lParam)
{
	lplvcd = (LPNMLVCUSTOMDRAW) lParam ;

	switch (lplvcd->nmcd.dwDrawStage) {
	case CDDS_PREPAINT:
		return CDRF_NOTIFYITEMDRAW ;

	case CDDS_ITEMPREPAINT:
		return CDRF_NOTIFYSUBITEMDRAW ;

	case CDDS_SUBITEM | CDDS_ITEMPREPAINT:
		if (lplvcd->iSubItem == 0) {						// Can only colour a whole column
			lplvcd->clrText = gridCellTextClr ;
			lplvcd->clrTextBk = itemColClr ;
			return CDRF_NEWFONT ;
		}
		else if (lplvcd->iSubItem % 2 == 0) {				// Every even column
			lplvcd->clrText = gridCellTextClr ;
			lplvcd->clrTextBk = subitemEvenColClr ;
			return CDRF_NEWFONT ;
		}
		else {
			lplvcd->clrText = gridCellTextClr ;				// Every odd column
			lplvcd->clrTextBk = subitemOddColClr ;
			return CDRF_NEWFONT ;
		}
	}
	return CDRF_DODEFAULT ;
}

// Same as for the start grid list view custome draw function above
LRESULT ProcessCustomDrawSolvedG (LPARAM lParam)
{
	lplvcd = (LPNMLVCUSTOMDRAW) lParam ;

	switch (lplvcd->nmcd.dwDrawStage) {
	case CDDS_PREPAINT:
		return CDRF_NOTIFYITEMDRAW ;

	case CDDS_ITEMPREPAINT:
		return CDRF_NOTIFYSUBITEMDRAW ;

	case CDDS_SUBITEM | CDDS_ITEMPREPAINT:
		if (lplvcd->iSubItem == 0) {
			lplvcd->clrText = gridCellTextClr ;
			lplvcd->clrTextBk = itemColClr ;
			return CDRF_NEWFONT ;
		}
		else if (lplvcd->iSubItem % 2 == 0) {
			lplvcd->clrText = gridCellTextClr ;
			lplvcd->clrTextBk = subitemEvenColClr ;
			return CDRF_NEWFONT ;
		}
		else {
			lplvcd->clrText = gridCellTextClr ;
			lplvcd->clrTextBk = subitemOddColClr ;
			return CDRF_NEWFONT ;
		}
	}
	return CDRF_DODEFAULT ;
}

// Saves the starting grid content in a file selected by the user
BOOL SaveTextFile (char * szFileName)
{
	HANDLE hFile ;
	BOOL bSuccess = FALSE ;

	hFile = CreateFile (szFileName, GENERIC_WRITE, 0, NULL,	CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL) ;
	if (hFile != INVALID_HANDLE_VALUE)
	{
		long int written = NULL ;							// Number of bytes written
		for (int i = 0; i < 81; i ++) {
			*(pgridArea + i) += 48 ;						// 0 + 48 = '0'
		}
		if (WriteFile (hFile, pgridArea, 81, (LPDWORD) &written, NULL)) {
			if (written = 81) {
				bSuccess = TRUE ;
			}
		}
		CloseHandle (hFile) ;
	}
	return bSuccess ;
}

// Loads the starting grid cells from a file selected by the user
BOOL LoadTextFile (char * szFileName)
{
	HANDLE hFile ;
	BOOL bSuccess = FALSE ;

	hFile = CreateFile (szFileName, GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, 0, NULL); // For read even if shared
															// NULL = security attributes, 0 = flags and attributes, NULL = template file
	if (hFile != INVALID_HANDLE_VALUE)
	{
		long int read ;										// Number of bytes read
		if (ReadFile (hFile, pgridArea, 81, (LPDWORD) &read, NULL)) {
			if (read == 81) {
				bSuccess = TRUE ;
			}
		}
		CloseHandle (hFile) ;
		for (int i = 0; i < 81; i ++) {
			*(pgridArea + i) -= 48 ;						// '0' - 48 = 0
		}
	}

	return bSuccess ;
}

// Save the log window content in a file
BOOL SaveLogFile (HWND hEdit, LPCTSTR pszFileName)
{
	HANDLE hFile ;
	BOOL bSuccess = FALSE ;

	hFile = CreateFile (pszFileName, GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL) ;
	if (hFile != INVALID_HANDLE_VALUE)
	{
		long int TextLength ;
		TextLength = GetWindowTextLength (hEdit) ;			// Get the size of the text in the edit control
		if (TextLength > 0)
		{
			char * Text ;
			long int BufferSize = TextLength + 1 ;
			Text = (char *) GlobalAlloc (GPTR, BufferSize) ;
			if (Text != NULL)
			{
				if (GetWindowText (hEdit, Text, BufferSize))// GetWindowText does not yield the text as a return value but as an OUT parameter
				{											// That is why first we need to store it in an allocated memory area
					long int written ;						// Number of bytes written
					if (WriteFile (hFile, Text, TextLength, (LPDWORD) &written, NULL))
						if (TextLength == written) {
							bSuccess = TRUE ;
						}
				}
				GlobalFree (Text) ;
			}
		}
		CloseHandle (hFile) ;
	}

	return bSuccess ;
}

// End of source file - SuDoKuMain.cpp