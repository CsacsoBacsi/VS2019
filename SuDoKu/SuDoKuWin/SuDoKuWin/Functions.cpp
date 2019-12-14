// Functions.cpp
/* Contains various helper functions
*/

#include "SuDoKuWin.h"

// Prints the list view grid on the log window
void printGrid ()
{
	unsigned char i, j ;

	mprintf ("   ") ;
	for (i = 1; i <= 9; i++) {
		wsprintf (buffer, "%c", i + 96) ;					// Lower-case letter columns
		mprintf (buffer) ;
	}
	mprintf ("\r\n") ;

	mprintf ("  ") ;
	for (i = 1; i <= 10; i++) {
		mprintf ("-") ;
	}
	mprintf ("\r\n") ;

	for (i = 0; i < 9; i ++) {
		wsprintf (buffer, " %c|", i + 65) ;					// Upper-case letter rows
		mprintf (buffer) ;
		for (j = 1; j <= 9; j ++) {
			wsprintf (buffer, "%d", *(gridArea + i * 9 + j)) ;
			mprintf (buffer) ;
		}
		mprintf ("\r\n") ;
	}
	mprintf("\r\n") ;
}

// Used in Variations only mode to display the first few (max 9) cells
bool printPartGrid ()
{
	memset (buffer3, 0, 10) ;
	for (char i = 1; i <= playingNumbers; i++) {
		if (*(gridArea + i) == 0) {
			return false ;									// Contains a zero so it is not a good (complete) variation
		}
		else {
			buffer3[i-1] = *(gridArea + i) + 48 ;			// Build a string buffer with the numbers that make the good (complete) variation
		}
	}

	//	wsprintf (buffer, "%d", *(gridArea + i)) ;
	mprintf (buffer3) ;										// Send it to the log
	mprintf ("\r\n") ;

	return true ;
}

// Checks if all numbers (from 1 to 9) had been used fully
bool verifyGrid1 ()
{
	for (unsigned char i = 1; i <= 9; i ++) {
		if (*(numsDone + i) != 0)
			return false ;
	}
	return true ;
}

// Checks if every row has unique numbers
bool verifyGrid2 ()
{
	unsigned char * numbers = (unsigned char *) calloc (9, sizeof(unsigned char)) ;	// Calloc initializes the array with zeros
	unsigned char i, k ;

	for (unsigned char j = 0; j < 9; j ++) {
		for (i = j * 9 + 1; i <= j * 9 + 9; i ++) {
			if (*(gridArea + i) != 0)
				numbers[*(gridArea + i) - 1] = 1 ;
		}
		for (k = 0; k < 9; k ++) {
			if (numbers[k] != 1) {
				free (numbers) ;
				return false ;
			}
		}
		for (k = 0; k < 9; k ++) {
			numbers[k] = 0 ;
		}
	}
	free (numbers) ;
	return true ;
}

// Checks if every column has unique numbers
bool verifyGrid3 ()
{
	unsigned char * numbers = (unsigned char *) calloc (9, sizeof(unsigned char)) ;	// Another difference to malloc () is that the first param is the number of elements
	unsigned char i, k ;

	for (unsigned char j = 0; j < 9; j ++) {
		for (i = 1; i <= 73; i +=9) {
			if (*(gridArea + i) != 0)
				numbers[*(gridArea + i + j) - 1] = 1 ;
		}
		for (k = 0; k < 9; k ++) {
			if (numbers[k] != 1) {
				free (numbers) ;
				return false ;
			}
		}
		for (k = 0; k < 9; k ++) {
			numbers[k] = 0 ;
		}
	}
	free (numbers) ;
	return true ;
}

// Checks if the sum of all grid cells is 405
bool verifyGrid4 ()
{
	unsigned  int sum ;

	sum = 0 ;
	for (unsigned char i = 1; i <= 81; i ++) {
		sum += *(gridArea + i) ;
	}
	if (sum == 405)											// sum (1-9) * 9 = 405
		return true ;
	else
		return false ;
}

// Checks if the initial state of the grid is valid
bool verifyGrid5 ()
{
	unsigned char * gridNums = (unsigned char *) calloc (82, sizeof (unsigned char)) ;

	for (unsigned char i = 1; i <= 81; i ++) {
		if (*(gridArea + i) != 0) {
			if (checkRow (i, *(gridArea + i), true)			// Check the row
				&& checkCol (i, *(gridArea + i), true)		// Check the column
				&& checkRegion (i, *(gridArea + i), true))	// Check the region
				continue ;
			else
				return false ;
		}
	}
	free (gridNums) ;
	return true ;
}

// Waits for the user to press Next or Stop to find the next solution or not
bool nextSolution ()
{
	getEndTime () ;											// Get elapsed secs and recursive call statistics
	wsprintf (buffer, szSolvedNTimes [langCode], solvedNTimes) ;
	mprintf (buffer) ;
	printGrid () ;
	printTime () ;
	wsprintf (buffer, szNoRecCalls3 [langCode], -- recursiveCalls) ;
	mprintf (buffer) ;
	sprintf_s (elapsedSecs, szElapsedSecs2 [langCode], (t_diff1 + t_diff2 + t_diff3) / 3) ;
	sprintf_s (recCalls, szNoRecCalls2 [langCode], recursiveCalls) ;

	SendMessage (hStatusBar, SB_SETTEXT, (WPARAM) 0, (LPARAM) elapsedSecs) ;
	SendMessage (hStatusBar, SB_SETTEXT, (WPARAM) 1, (LPARAM) recCalls) ;
	SendMessage (hStatusBar, SB_SETTEXT, (WPARAM) 2, (LPARAM) "") ;
	recursiveCalls = 0 ;

	resetGrid (hListViewSolved) ;
	writeGrid (hListViewSolved) ;							// Displays the internal memory (pgridArea) content in the solved grid (list view)
	inverseGrid () ;
	changedGrid () ;
	memcpy (prev_gridArea, gridArea, 82) ;					// This becomes the previous solved grid. Populate the previous grid area array
	paintOrigNumbers = true ;
	SendMessage (hListViewStart, WM_PAINT, (WPARAM) 0, (LPARAM) 0) ;
	ShowWindow (hProgress, SW_HIDE) ;
	UpdateWindow (hDlg) ;
	EnableWindow (GetDlgItem (hDlg, IDC_BUTTON_NEXT), true) ;
	SendMessage (hToolbar, TB_ENABLEBUTTON, IDC_TOOLBAR_NEXT, true) ;
	EnableWindow (GetDlgItem (hDlg, IDC_BUTTON_CLEAR_LOG), true) ;
	SuspendThread (GetCurrentThread ()) ;					// Suspends the engine thread and waits until the user continues or stops
	if (terminateThread)
		return false ;
	
	return true ;
}

// Fetches the list view grid cell contents and store it in the internally allocated memory (gridArea)
void readGrid (HWND hWndListView)
{
	memset (&LvItem, 0, sizeof (LVITEM)) ;
	LvItem.mask = LVIF_TEXT ;								// Changing the text only
	char cellText[2] ;
	LvItem.pszText = cellText ;
	LvItem.cchTextMax = 2 ;									// Include a terminating zero

	for (char i = 1; i < 10; i ++) {
		for (char j = 1; j < 10; j ++) {
			LvItem.iSubItem = j ;
			SendMessage (hWndListView, LVM_GETITEMTEXT, i - 1, (LPARAM) &LvItem) ;
			if (cellText[0] != 0)
				* (pgridArea + ((i - 1) * 9) + (j - 1)) = atoi (cellText) ; // Convert text to number
			else
				* (pgridArea + ((i - 1) * 9) + (j - 1)) = 0 ;
		}
	}
}

// Writes the internally allocated memory's (gridArea) content into the list view control
void writeGrid (HWND hWndListView)
{
	memset (&LvItem, 0, sizeof (LVITEM)) ;
	LvItem.mask = LVIF_TEXT ;
	char cellText[2] ;
	cellText[1] = 0 ;
	LvItem.pszText = cellText ;
	LvItem.cchTextMax = 2 ;									// Include a terminating zero

	for (char i = 1; i < 10; i ++) {
		for (char j = 1; j < 10; j ++) {
			LvItem.iSubItem = j ;
			if (*(pgridArea + ((i - 1) * 9) + (j - 1)) != 0) {
				int val = * (pgridArea + ((i - 1) * 9) + (j - 1)) ;
				_itoa_s (val, cellText, 10) ;				// Convert the numerical value to a string
				SendMessage (hWndListView, LVM_SETITEMTEXT, i - 1, (LPARAM) &LvItem) ;
			}
		}
	}
}

// Clears all grid cells. fills them up with zero
void resetGrid (HWND hWndListView)
{	
	memset (&LvItem, 0, sizeof (LVITEM)) ;
	LvItem.mask = LVIF_TEXT ;
	char cellText[2] ;										// Size is 2 as it includes a terminating zero
	LvItem.pszText = cellText ;
	LvItem.cchTextMax = 2 ;

	for (char i = 1; i < 10; i++) {
		for (char j = 1; j < 10; j++) {
			LvItem.iSubItem = j ;
			cellText[0] = 0 ;
			cellText[1] = 0 ;
			SendMessage (hWndListView, LVM_SETITEMTEXT, i - 1, (LPARAM) &LvItem) ;
		}
	}
}

// Erases cells in the solved grid that were given by the user in the starting grid
void inverseGrid ()
{
	memset (&LvItem, 0, sizeof (LVITEM)) ;
	LvItem.mask = LVIF_TEXT ;								// Changing the text only
	char cellText[2] ;
	LvItem.pszText = cellText ;
	LvItem.cchTextMax = 2 ;									// Include a terminating zero

	for (char i = 1; i < 10; i ++) {
		for (char j = 1; j < 10; j ++) {
			LvItem.iSubItem = j ;
			SendMessage (hListViewStart, LVM_GETITEMTEXT, i - 1, (LPARAM) &LvItem) ;
			if (cellText[0] != 0) {
				cellText[0] = 0 ;
				cellText[1] = 0 ;
				SendMessage (hListViewSolved, LVM_SETITEMTEXT, i - 1, (LPARAM) &LvItem) ;
			}
		}
	}
}

// During multi-solve mode, detects the changed cells compared to previous solved grid
void changedGrid ()
{
	memset (&LvItem, 0, sizeof (LVITEM)) ;
	if (solvedNTimes <= 1)
		return ;

	LvItem.mask = LVIF_TEXT ;								// Changing the text only
	char cellText[2] ;
	LvItem.pszText = cellText ;
	LvItem.cchTextMax = 2 ;									// Include a terminating zero

	for (char i = 1; i < 10; i ++) {
		for (char j = 1; j < 10; j ++) {
			LvItem.iSubItem = j ;
			if (*(pgridArea + ((i - 1) * 9) + (j - 1)) != *(prev_pgridArea + ((i - 1) * 9) + (j - 1))) { // different from previous
				cellText[0] = 0 ;							// Mark them with a 0
				cellText[1] = 0 ;
				SendMessage (hListViewSolved, LVM_SETITEMTEXT, i - 1, (LPARAM) &LvItem) ;
			}
		}
	}
}

// "My" printf that echoes strings to the log window
void mprintf (char * string)
{
	if (enableLogging || clearLog) {						// Enable printing if the user clicked on the clear log button (display the log header)
		AppendText (string) ;
	}
}

// Appends text to the log window text
void AppendText (TCHAR * newText)
{
	logLength = GetWindowTextLength (hOutput) ;				// Get the current log window text size
	appendTxtLength = strlen (newText) ;					// Length of string to be appended to the log. Without the terminating zero char
	
	if ((logLength + appendTxtLength) > MAXLOGTEXTSIZE) {	// If log window text size exceeded the MAXLOGTEXTSIZE
		SendMessage (hOutput, EM_SETSEL, 0, ((logLength + appendTxtLength) - (MAXLOGTEXTSIZE)) + 1024) ; // Erase plus 1K worth of text on top of the size of the new text
		SendMessage (hOutput, EM_REPLACESEL, FALSE, (LPARAM) "") ; // Delete (replace with an empty string) from the first char (0) at least 1K chars
		logLength = GetWindowTextLength (hOutput) ;			// Get the new length after erasing
	}

	SendMessage (hOutput, EM_SETSEL, (WPARAM) logLength, (LPARAM) logLength) ; // Move the caret to the end of the text
	SendMessage (hOutput, EM_REPLACESEL, FALSE, (LPARAM) newText) ; // Insert the text at the new caret position (which is the very end)
}

// Gets the start time when the solver engine kicks off
void getStartTime ()
{
	st_time1 = GetTickCount () ;
	st_time2 = clock () ;
	st_time3 = getSysTime () ;
}

// Gets the end time when the solver engine completed the solve
void getEndTime ()
{
	et_time1 = GetTickCount () ;
	et_time2 = clock () ;
	et_time3 = getSysTime () ;
}

// Prints the elapsed time between the solver engine start and end time
void printTime ()
{
	t_diff1 = et_time1 - st_time1 ;
	t_diff1 = t_diff1 / 1000. ;								// Calculate the difference
	sprintf_s (buffer, szTimeTicks [langCode], t_diff1) ;
	mprintf (buffer) ;

	t_diff2 = (double) (et_time2 - st_time2) / CLOCKS_PER_SEC;
	sprintf_s (buffer, szTimeClocks [langCode], t_diff2) ;
	mprintf (buffer) ;

	t_diff3 = (double) (et_time3 - st_time3) / 10000 / 1000 ;
	sprintf_s (buffer, szTimeSystem [langCode], t_diff3) ;
	mprintf (buffer) ;
	sprintf_s (buffer, szTimeAverage [langCode], (t_diff1 + t_diff2 + t_diff3) / 3) ;
	mprintf (buffer) ;
}

// Echoes the current date and time. Used for logging
char * currentDateTime ()
{
	SYSTEMTIME st = { 0 } ;
	GetLocalTime (&st) ;									// Local time
	wsprintf (buffer2, "%02d/%02d/%04d %02d:%02d:%02d", st.wDay, st.wMonth, st.wYear, st.wHour, st.wMinute, st.wSecond) ;

	return buffer2 ;
}

// Gets the system time
unsigned long long getSysTime ()
{
	SYSTEMTIME systime ;
	FILETIME filetime ;
	unsigned long long ns_since_1601 ;
	ULARGE_INTEGER * ptr ;

	GetSystemTime (&systime) ;
	if (!SystemTimeToFileTime (&systime, &filetime))
		return 0 ;

	ptr = (ULARGE_INTEGER *) &ns_since_1601 ;

	ptr->u.LowPart = filetime.dwLowDateTime ;
	ptr->u.HighPart = filetime.dwHighDateTime ;

	return ns_since_1601 ;
}

// Changes the language
void changeLang ()
{
	MENUITEMINFOA menuitem ;

	// Dialog window
	SetWindowText (hDlg, szDialogCaption [langCode]) ;		// Dialog window's caption

	HBITMAP hBitmapSave = (HBITMAP) LoadImage (GetModuleHandle (NULL), MAKEINTRESOURCE (IDB_BITMAP_SAVE), IMAGE_BITMAP, 16, 16, 0) ; // Load the bitmaps (saved by Paint using the .ico file)
	HBITMAP hBitmapLoad = (HBITMAP) LoadImage (GetModuleHandle (NULL), MAKEINTRESOURCE (IDB_BITMAP_LOAD), IMAGE_BITMAP, 16, 16, 0) ;
	HBITMAP hBitmapLog = (HBITMAP) LoadImage (GetModuleHandle (NULL), MAKEINTRESOURCE (IDB_BITMAP_LOG), IMAGE_BITMAP, 16, 16, 0);
	HBITMAP hBitmapExit = (HBITMAP) LoadImage (GetModuleHandle (NULL), MAKEINTRESOURCE (IDB_BITMAP_EXIT), IMAGE_BITMAP, 16, 16, 0);
	HBITMAP hBitmapSuDoKu = (HBITMAP) LoadImage (GetModuleHandle (NULL), MAKEINTRESOURCE (IDB_BITMAP_SUDOKU), IMAGE_BITMAP, 16, 16, 0);

	// Menu structure
	hMenu = GetMenu (hDlg) ;
	menuitem = {sizeof (MENUITEMINFOA)} ;
	menuitem.fMask = MIIM_FTYPE | MIIM_STRING | MIIM_SUBMENU ; // File sub-menu
	hSubMenu = GetSubMenu (hMenu, 0) ;
	menuitem.hSubMenu = hSubMenu ;
	GetMenuItemInfoA (hMenu, 0, true, &menuitem) ;
	if (langCode == Magyar)
		menuitem.dwTypeData = "&Fájl" ;
	else
		menuitem.dwTypeData = "&File" ;
	SetMenuItemInfoA (hMenu, 0, true, &menuitem) ;
	menuitem.fMask = MIIM_STRING | MIIM_BITMAP ;			// File sub-menu items
	menuitem.hSubMenu = NULL ;
	menuitem.hbmpItem = hBitmapSave ;
	//GetMenuItemInfoA (hMenu, ID_MENU_FILE_SAVEGRID, false, &menuitem) ;
	if (langCode == Magyar)
		menuitem.dwTypeData = "Rács &mentése" ;
	else
		menuitem.dwTypeData = "&Save grid" ;
	SetMenuItemInfoA (hMenu, ID_MENU_FILE_SAVEGRID, false, &menuitem) ;
	menuitem.hbmpItem = hBitmapLoad;
	if (langCode == Magyar)
		menuitem.dwTypeData = "Rács &betöltése" ;
	else
		menuitem.dwTypeData = "&Load grid" ;
	SetMenuItemInfoA (hMenu, ID_MENU_FILE_LOADGRID, false, &menuitem) ;
	menuitem.hbmpItem = hBitmapLog ;
	if (langCode == Magyar)
		menuitem.dwTypeData = "&Napló mentése" ;
	else
		menuitem.dwTypeData = "Sa&ve log" ;
	SetMenuItemInfoA (hMenu, ID_MENU_FILE_SAVELOG, false, &menuitem) ;
	menuitem.hbmpItem = hBitmapExit ;
	if (langCode == Magyar)
		menuitem.dwTypeData = "&Kilépés" ;
	else
		menuitem.dwTypeData = "&Exit" ;
	SetMenuItemInfoA (hMenu, ID_MENU_FILE_EXIT, false, &menuitem) ;

	menuitem.fMask = MIIM_FTYPE | MIIM_STRING | MIIM_SUBMENU ; // Help sub-menu
	hSubMenu = GetSubMenu (hMenu, 1) ;
	menuitem.hSubMenu = hSubMenu ;
	if (langCode == Magyar)
		menuitem.dwTypeData = "&Súgó" ;
	else
		menuitem.dwTypeData = "&Help" ;
	SetMenuItemInfoA (hMenu, 1, true, &menuitem) ;
	menuitem.fMask = MIIM_STRING | MIIM_BITMAP;				// Help sub-menu items
	menuitem.hSubMenu = NULL ;
	menuitem.hbmpItem = hBitmapSuDoKu;
	if (langCode == Magyar)
		menuitem.dwTypeData = "&A SuDoKu megoldó programról" ;
	else
		menuitem.dwTypeData = "&About SuDoKu solver" ;
	SetMenuItemInfoA (hMenu, ID_MENU_HELP_ABOUT, false, &menuitem) ;

	// Push buttons
	SendMessage (GetDlgItem (hDlg, IDC_BUTTON_CLEAR), WM_SETTEXT, 0, (LPARAM) szClearButton [langCode]) ; // WM_SETTEXT sets the text on the controo
	SendMessage (GetDlgItem (hDlg, IDC_BUTTON_SOLVE), WM_SETTEXT, 0, (LPARAM) szSolveButton [langCode]) ;
	SendMessage (GetDlgItem (hDlg, IDC_BUTTON_STOP), WM_SETTEXT, 0, (LPARAM) szStopButton [langCode]) ;
	SendMessage (GetDlgItem (hDlg, IDC_BUTTON_NEXT), WM_SETTEXT, 0, (LPARAM) szNextButton [langCode]) ;
	SendMessage (GetDlgItem (hDlg, IDC_BUTTON_CLOSE), WM_SETTEXT, 0, (LPARAM) szCloseButton [langCode]) ;
	SendMessage (GetDlgItem (hDlg, IDC_BUTTON_CLEAR_LOG), WM_SETTEXT, 0, (LPARAM) szClearLogButton [langCode]) ;

	// Radio buttons
	SendMessage (GetDlgItem (hDlg, IDC_RADIO_SINGLESOLVE), WM_SETTEXT, 0, (LPARAM) szSingleSolveButton [langCode]) ;
	SendMessage (GetDlgItem (hDlg, IDC_RADIO_MULTISOLVE), WM_SETTEXT, 0, (LPARAM) szMultiSolveButton [langCode]) ;
	SendMessage (GetDlgItem (hDlg, IDC_RADIO_VARIATIONS), WM_SETTEXT, 0, (LPARAM) szVariationsButton [langCode]) ;

	// Check buttons
	SendMessage (GetDlgItem (hDlg, IDC_CHECK_LOG), WM_SETTEXT, 0, (LPARAM) szEnableLogging [langCode]) ;

	// Static texts
	SendMessage (GetDlgItem (hDlg, IDC_STATIC_START), WM_SETTEXT, 0, (LPARAM) szStaticStart [langCode]) ; // Label texts
	SendMessage (GetDlgItem (hDlg, IDC_STATIC_SOLVED), WM_SETTEXT, 0, (LPARAM) szStaticSolved [langCode]) ;
	SendMessage (GetDlgItem (hDlg, IDC_STATIC_OPTIONS), WM_SETTEXT, 0, (LPARAM) szStaticOptions [langCode]) ;
	SendMessage (GetDlgItem (hDlg, IDC_STATIC_CELLS), WM_SETTEXT, 0, (LPARAM) szStaticCells [langCode]) ;
	SendMessage (GetDlgItem (hDlg, IDC_STATIC_LOG), WM_SETTEXT, 0, (LPARAM) szStaticLog [langCode]) ;

	// Tooltips
	TOOLINFO toolinfo ;										// Tool Tip Info structure
	memset (&toolinfo, 0, sizeof (TOOLINFO)) ;
	toolinfo.cbSize = sizeof (TOOLINFO) ;
	toolinfo.hwnd = hDlg ;									// The parent window
	toolinfo.uFlags = TTF_SUBCLASS | TTF_IDISHWND ;			// IDISHWND = the next ID is a window (control) handle not a resource ID
	toolinfo.uId = (UINT_PTR) GetDlgItem (hDlg, IDC_LIST_START) ; // Starting grid list view
	toolinfo.hinst = NULL ;									// If a string resource is used, handle to the instance that contains it
	toolinfo.lpszText = szSGTooltip [langCode] ;

	SendMessage (hToolTipSG, TTM_ADDTOOL, 0, (LPARAM) &toolinfo) ; // Add the tool all the info it needs
	SendMessage (hToolTipSG, TTM_SETMAXTIPWIDTH, 0, 120) ;	// Set the width of the balloon tooltip so that lines will wrap
	//SendMessage (hToolTip, WM_SETTEXT, 0, (LPARAM) szLWTooltip [langCode]) ; // This did not work

	memset (&toolinfo, 0, sizeof (TOOLINFO)) ;
	toolinfo.cbSize = sizeof (TOOLINFO) ;
	toolinfo.hwnd = hDlg ;									// The parent window
	toolinfo.uFlags = TTF_SUBCLASS | TTF_IDISHWND ;			// IDISHWND = the next ID is a window (control) handle not a resource ID
	toolinfo.uId = (UINT_PTR) GetDlgItem (hDlg, IDC_RADIO_SINGLESOLVE) ; // Single-solve radio button
	toolinfo.hinst = NULL ;									// If a string resource is used, handle to the instance that contains it
	toolinfo.lpszText = szSSTooltip [langCode] ;

	SendMessage (hToolTipSS, TTM_ADDTOOL, 0, (LPARAM) &toolinfo) ; // Add the tool all the info it needs

	memset (&toolinfo, 0, sizeof (TOOLINFO)) ;
	toolinfo.cbSize = sizeof (TOOLINFO) ;
	toolinfo.hwnd = hDlg ;									// The parent window
	toolinfo.uFlags = TTF_SUBCLASS | TTF_IDISHWND ;			// IDISHWND = the next ID is a window (control) handle not a resource ID
	toolinfo.uId = (UINT_PTR) GetDlgItem (hDlg, IDC_RADIO_MULTISOLVE) ; // Multi-solve radio button
	toolinfo.hinst = NULL ;									// If a string resource is used, handle to the instance that contains it
	toolinfo.lpszText = szMSTooltip [langCode] ;

	SendMessage (hToolTipMS, TTM_ADDTOOL, 0, (LPARAM) &toolinfo) ; // Add the tool all the info it needs

	memset (&toolinfo, 0, sizeof (TOOLINFO)) ;
	toolinfo.cbSize = sizeof (TOOLINFO) ;
	toolinfo.hwnd = hDlg ;									// The parent window
	toolinfo.uFlags = TTF_SUBCLASS | TTF_IDISHWND ;			// IDISHWND = the next ID is a window (control) handle not a resource ID
	toolinfo.uId = (UINT_PTR) GetDlgItem (hDlg, IDC_RADIO_VARIATIONS) ; // Variations only radio button
	toolinfo.hinst = NULL ;									// If a string resource is used, handle to the instance that contains it
	toolinfo.lpszText = szVRTooltip [langCode] ;

	SendMessage (hToolTipVR, TTM_ADDTOOL, 0, (LPARAM) &toolinfo) ; // Add the tool all the info it needs
	
	memset (&toolinfo, 0, sizeof (TOOLINFO)) ;
	toolinfo.cbSize = sizeof (TOOLINFO) ;
	toolinfo.hwnd = hDlg ;									// The parent window
	toolinfo.uFlags = TTF_SUBCLASS | TTF_IDISHWND ;			// IDISHWND = the next ID is a window (control) handle not a resource ID
	toolinfo.uId = (UINT_PTR) GetDlgItem (hDlg, IDC_CHECK_LOG) ; // Enable/disable logging checkbox button
	toolinfo.hinst = NULL ;									// If a string resource is used, handle to the instance that contains it
	toolinfo.lpszText = szLOTooltip [langCode] ;

	SendMessage (hToolTipLO, TTM_ADDTOOL, 0, (LPARAM) &toolinfo) ; // Add the tool all the info it needs

	memset (&toolinfo, 0, sizeof (TOOLINFO)) ;
	toolinfo.cbSize = sizeof (TOOLINFO) ;
	toolinfo.hwnd = hDlg ;									// The parent window
	toolinfo.uFlags = TTF_SUBCLASS | TTF_IDISHWND ;			// IDISHWND = the next ID is a window (control) handle not a resource ID
	toolinfo.uId = (UINT_PTR) GetDlgItem (hDlg, IDC_EDIT_LOG) ; // Log (edit control) window
	toolinfo.hinst = NULL ;									// If a string resource is used, handle to the instance that contains it
	toolinfo.lpszText = szLWTooltip [langCode] ;

	SendMessage (hToolTipLW, TTM_ADDTOOL, 0, (LPARAM) &toolinfo) ; // Add the tool all the info it needs

	mprintf (szLanguage[langCode]) ;
}

// Creates the application's toolbar
void createToolbar ()
{
	hToolbar = CreateWindowEx (0, TOOLBARCLASSNAME, NULL, WS_CHILD | WS_VISIBLE | TBSTYLE_TOOLTIPS | TBSTYLE_FLAT | TBSTYLE_TRANSPARENT,
		                       0, 0, 0, 0, hDlg, NULL, GetModuleHandle (NULL), NULL) ;
	//(HMENU) IDR_TOOLBAR - could mean the ID of the toolbar so when messages are handled, we know it has come from this control

	if (hToolbar != NULL)
		SendMessage (hToolbar, TB_BUTTONSTRUCTSIZE, (WPARAM) sizeof (TBBUTTON), 0) ; // for backward compatibility

		HICON hIconSave = (HICON) LoadIcon (GetModuleHandle (NULL), MAKEINTRESOURCE (IDC_SAVE_ICON)) ; // Load the icons
		HICON hIconLoad = (HICON) LoadIcon (GetModuleHandle (NULL), MAKEINTRESOURCE (IDC_LOAD_ICON)) ;
		HICON hIconLog = (HICON) LoadIcon (GetModuleHandle (NULL), MAKEINTRESOURCE (IDC_LOG_ICON)) ;
		HICON hIconExit = (HICON) LoadIcon (GetModuleHandle (NULL), MAKEINTRESOURCE (IDC_EXIT_ICON)) ;
		HICON hIconClear = (HICON) LoadIcon (GetModuleHandle (NULL), MAKEINTRESOURCE (IDC_CLEAR_ICON)) ;
		HICON hIconSolve = (HICON) LoadIcon (GetModuleHandle (NULL), MAKEINTRESOURCE (IDC_SOLVE_ICON)) ;
		HICON hIconStop = (HICON) LoadIcon (GetModuleHandle (NULL), MAKEINTRESOURCE (IDC_STOP_ICON)) ;
		HICON hIconNext = (HICON) LoadIcon (GetModuleHandle (NULL), MAKEINTRESOURCE (IDC_NEXT_ICON)) ;
		HICON hIconHunFlag = (HICON) LoadIcon (GetModuleHandle (NULL), MAKEINTRESOURCE (IDC_HUNFLAG_ICON)) ;
		HICON hIconEngFlag = (HICON) LoadIcon (GetModuleHandle (NULL), MAKEINTRESOURCE (IDC_ENGFLAG_ICON)) ;

		hImgList = ImageList_Create (16, 16, ILC_COLOR16 | ILC_MASK, 6, 1) ; // ILC_MASK needed for transparent icons
		ImageList_AddIcon (hImgList, hIconSave) ;			// Add icons to the image list. Toolbar needs an image list
		ImageList_AddIcon (hImgList, hIconLoad) ;
		ImageList_AddIcon (hImgList, hIconLog) ;

		ImageList_AddIcon (hImgList, hIconClear) ;
		ImageList_AddIcon (hImgList, hIconSolve) ;
		ImageList_AddIcon (hImgList, hIconStop) ;
		ImageList_AddIcon (hImgList, hIconNext) ;

		ImageList_AddIcon (hImgList, hIconHunFlag) ;
		ImageList_AddIcon (hImgList, hIconEngFlag) ;
		ImageList_AddIcon (hImgList, hIconExit) ;

		SendMessage (hToolbar, TB_SETIMAGELIST, 0, (LPARAM) hImgList) ; // Sets the image list of the toolbar
		SendMessage (hToolbar, TB_SETMAXTEXTROWS, 0, 0) ;	// Do not show text underneath the icon just as a tooltip

		ZeroMemory (tbb, sizeof (tbb)) ;
		tbb[0].iBitmap = 0 ;								// The icon index is zero-based
		tbb[0].fsState = TBSTATE_ENABLED ;
		tbb[0].fsStyle = TBSTYLE_BUTTON ;
//		tbb[0].iString = SendMessage (hToolbar, TB_ADDSTRING, 0 , (LPARAM) TEXT ("Save grid")) ; // It did not work for some reason
		tbb[0].idCommand = IDC_TOOLBAR_SAVE ;

		tbb[1].iBitmap = 1 ;
		tbb[1].fsState = TBSTATE_ENABLED ;
		tbb[1].fsStyle = TBSTYLE_BUTTON ;
		tbb[1].idCommand = IDC_TOOLBAR_LOAD ;

		tbb[2].iBitmap = 2 ;
		tbb[2].fsState = TBSTATE_ENABLED ;
		tbb[2].fsStyle = TBSTYLE_BUTTON ;
		tbb[2].idCommand = IDC_TOOLBAR_LOG ;

		tbb[3].fsState = TBSTATE_ENABLED ;					// Toolbar button separator
		tbb[3].fsStyle = TBSTYLE_SEP ;

		tbb[4].iBitmap = 3 ;
		tbb[4].fsState = TBSTATE_ENABLED ;
		tbb[4].fsStyle = TBSTYLE_BUTTON ;
		tbb[4].idCommand = IDC_TOOLBAR_CLEAR ;

		tbb[5].iBitmap = 4 ;
		tbb[5].fsState = TBSTATE_ENABLED ;
		tbb[5].fsStyle = TBSTYLE_BUTTON ;
		tbb[5].idCommand = IDC_TOOLBAR_SOLVE ;

		tbb[6].iBitmap = 5 ;
		tbb[6].fsState = TBSTATE_ENABLED ;
		tbb[6].fsStyle = TBSTYLE_BUTTON ;
		tbb[6].idCommand = IDC_TOOLBAR_STOP ;

		tbb[7].iBitmap = 6 ;
		tbb[7].fsState = TBSTATE_ENABLED ;
		tbb[7].fsStyle = TBSTYLE_BUTTON ;
		tbb[7].idCommand = IDC_TOOLBAR_NEXT ;

		tbb[8].fsState = TBSTATE_ENABLED ;
		tbb[8].fsStyle = TBSTYLE_SEP ;

		tbb[9].iBitmap = 7 ;
		tbb[9].fsState = TBSTATE_ENABLED ;
		tbb[9].fsStyle = TBSTYLE_BUTTON ;
		tbb[9].idCommand = IDC_TOOLBAR_HUNFLAG ;

		tbb[10].iBitmap = 8 ;
		tbb[10].fsState = TBSTATE_ENABLED ;
		tbb[10].fsStyle = TBSTYLE_BUTTON ;
		tbb[10].idCommand = IDC_TOOLBAR_ENGFLAG ;

		tbb[11].fsState = TBSTATE_ENABLED ;
		tbb[11].fsStyle = TBSTYLE_SEP ;

		tbb[12].iBitmap = 9 ;
		tbb[12].fsState = TBSTATE_ENABLED ;
		tbb[12].fsStyle = TBSTYLE_BUTTON ;
		tbb[12].idCommand = IDC_TOOLBAR_EXIT ;

		SendMessage (hToolbar, TB_ADDBUTTONS, sizeof (tbb) / sizeof (TBBUTTON), (LPARAM) &tbb) ;
		SendMessage (hToolbar, TB_ENABLEBUTTON, IDC_TOOLBAR_STOP, false) ; // Enable/disable toolbar buttons
		SendMessage (hToolbar, TB_ENABLEBUTTON, IDC_TOOLBAR_NEXT, false) ;
		ShowWindow (hToolbar, true) ;

		DestroyIcon (hIconSave) ;							// The icons are embedded into the image list so no need for them
		DestroyIcon (hIconLoad) ;
		DestroyIcon (hIconLog) ;
		DestroyIcon (hIconClear) ;
		DestroyIcon (hIconSolve) ;
		DestroyIcon (hIconStop) ;
		DestroyIcon (hIconNext) ;
		DestroyIcon (hIconHunFlag) ;
		DestroyIcon (hIconEngFlag) ;
		DestroyIcon (hIconExit) ;
}

// Clears the log window completely
void resetLog ()
{
	SetDlgItemText (hDlg, IDC_EDIT_LOG, "") ;

	clearLog = true ;
	mprintf (szLogHeader1[langCode]) ;						// Log header
	mprintf (szLogHeader2[langCode]) ;
	mprintf (szLogHeader3[langCode]) ;

	mprintf (szLanguage[langCode]) ;						// Display selected language
	clearLog = false ;
}

// Tooltip for the starting grid
void createStartingGridTooltip ()
{
	hToolTipSG = CreateWindow (TOOLTIPS_CLASS, NULL, WS_POPUP | TTS_BALLOON, 0,0,0,0, hDlg, NULL, GetModuleHandle (NULL), 0) ; // Creates a tooltip control

	if (hToolTipSG != NULL) {
		SendMessage (hToolTipSG, TTM_ACTIVATE, TRUE, 0) ;	// Send this message to Activate ToolTips for the window. FALSE to deactivate the tool tip

		TOOLINFO toolinfo ;									// Tool Tip Info structure
		memset (&toolinfo, 0, sizeof (TOOLINFO)) ;
		toolinfo.cbSize = sizeof (TOOLINFO) ;
		toolinfo.hwnd = hDlg ;								// The parent window
		toolinfo.uFlags = TTF_SUBCLASS | TTF_IDISHWND ;		// IDISHWND = the next ID is a window (control) handle not a resource ID
		toolinfo.uId = (UINT_PTR) GetDlgItem (hDlg, IDC_LIST_START) ; // Starting grid list view
		toolinfo.hinst = NULL ;								// If a string resource is used, handle to the instance that contains it
		toolinfo.lpszText = szSGTooltip [langCode] ;

		SendMessage (hToolTipSG, TTM_ADDTOOL, 0, (LPARAM) &toolinfo) ; // Add the tool all the info it needs
		SendMessage (hToolTipSG, TTM_SETMAXTIPWIDTH, 0, 120) ; // Set the width of the balloon tooltip so that lines will wrap
	}
}

// Tooltip for single-solve mode
void createSingleSolveTooltip ()
{
	hToolTipSS = CreateWindow (TOOLTIPS_CLASS, NULL, WS_POPUP | TTS_BALLOON, 0,0,0,0, hDlg, NULL, GetModuleHandle (NULL), 0) ; // Creates a tooltip control

	if (hToolTipSS != NULL) {
		SendMessage (hToolTipSS, TTM_ACTIVATE, TRUE, 0) ;	// Send this message to Activate ToolTips for the window. FALSE to deactivate the tool tip

		TOOLINFO toolinfo ;									// Tool Tip Info structure
		memset (&toolinfo, 0, sizeof (TOOLINFO)) ;
		toolinfo.cbSize = sizeof (TOOLINFO) ;
		toolinfo.hwnd = hDlg ;								// The parent window
		toolinfo.uFlags = TTF_SUBCLASS | TTF_IDISHWND ;		// IDISHWND = the next ID is a window (control) handle not a resource ID
		toolinfo.uId = (UINT_PTR) GetDlgItem (hDlg, IDC_RADIO_SINGLESOLVE) ; // Single-solve radio button
		toolinfo.hinst = NULL ;								// If a string resource is used, handle to the instance that contains it
		toolinfo.lpszText = szSSTooltip [langCode] ;

		SendMessage (hToolTipSS, TTM_ADDTOOL, 0, (LPARAM) &toolinfo) ; // Add the tool all the info it needs
		SendMessage (hToolTipSS, TTM_SETMAXTIPWIDTH, 0, 120) ; // Set the width of the balloon tooltip so that lines will wrap
	}
}

// Tooltip for multi-solve mode
void createMultiSolveTooltip ()
{
	hToolTipMS = CreateWindow (TOOLTIPS_CLASS, NULL, WS_POPUP | TTS_BALLOON, 0,0,0,0, hDlg, NULL, GetModuleHandle (NULL), 0) ; // Creates a tooltip control

	if (hToolTipMS != NULL) {
		SendMessage (hToolTipMS, TTM_ACTIVATE, TRUE, 0) ;	// Send this message to Activate ToolTips for the window. FALSE to deactivate the tool tip

		TOOLINFO toolinfo ;									// Tool Tip Info structure
		memset (&toolinfo, 0, sizeof (TOOLINFO)) ;
		toolinfo.cbSize = sizeof (TOOLINFO) ;
		toolinfo.hwnd = hDlg ;								// The parent window
		toolinfo.uFlags = TTF_SUBCLASS | TTF_IDISHWND ;		// IDISHWND = the next ID is a window (control) handle not a resource ID
		toolinfo.uId = (UINT_PTR) GetDlgItem (hDlg, IDC_RADIO_MULTISOLVE) ; // Multi-solve radio button
		toolinfo.hinst = NULL ;								// If a string resource is used, handle to the instance that contains it
		toolinfo.lpszText = szMSTooltip [langCode] ;

		SendMessage (hToolTipMS, TTM_ADDTOOL, 0, (LPARAM) &toolinfo) ; // Add the tool all the info it needs
		SendMessage (hToolTipMS, TTM_SETMAXTIPWIDTH, 0, 120) ; // Set the width of the balloon tooltip so that lines will wrap
	}
}

// Tooltip for variations only mode
void createVariationsTooltip ()
{
	hToolTipVR = CreateWindow (TOOLTIPS_CLASS, NULL, WS_POPUP | TTS_BALLOON, 0,0,0,0, hDlg, NULL, GetModuleHandle (NULL), 0) ; // Creates a tooltip control

	if (hToolTipVR != NULL) {
		SendMessage (hToolTipMS, TTM_ACTIVATE, TRUE, 0) ;	// Send this message to Activate ToolTips for the window. FALSE to deactivate the tool tip

		TOOLINFO toolinfo ;									// Tool Tip Info structure
		memset (&toolinfo, 0, sizeof (TOOLINFO)) ;
		toolinfo.cbSize = sizeof (TOOLINFO) ;
		toolinfo.hwnd = hDlg ;								// The parent window
		toolinfo.uFlags = TTF_SUBCLASS | TTF_IDISHWND ;		// IDISHWND = the next ID is a window (control) handle not a resource ID
		toolinfo.uId = (UINT_PTR) GetDlgItem (hDlg, IDC_RADIO_VARIATIONS) ; // Variations only radio button
		toolinfo.hinst = NULL ;								// If a string resource is used, handle to the instance that contains it
		toolinfo.lpszText = szVRTooltip [langCode] ;

		SendMessage (hToolTipVR, TTM_ADDTOOL, 0, (LPARAM) &toolinfo) ; // Add the tool all the info it needs
		SendMessage (hToolTipVR, TTM_SETMAXTIPWIDTH, 0, 120) ; // Set the width of the balloon tooltip so that lines will wrap
	}
}

// Tooltip for variations only mode
void createLoggingTooltip ()
{
	hToolTipLO = CreateWindow (TOOLTIPS_CLASS, NULL, WS_POPUP | TTS_BALLOON, 0,0,0,0, hDlg, NULL, GetModuleHandle (NULL), 0) ; // Creates a tooltip control

	if (hToolTipLO != NULL) {
		SendMessage (hToolTipLO, TTM_ACTIVATE, TRUE, 0) ;	// Send this message to Activate ToolTips for the window. FALSE to deactivate the tool tip

		TOOLINFO toolinfo ;									// Tool Tip Info structure
		memset (&toolinfo, 0, sizeof (TOOLINFO)) ;
		toolinfo.cbSize = sizeof (TOOLINFO) ;
		toolinfo.hwnd = hDlg ;								// The parent window
		toolinfo.uFlags = TTF_SUBCLASS | TTF_IDISHWND ;		// IDISHWND = the next ID is a window (control) handle not a resource ID
		toolinfo.uId = (UINT_PTR) GetDlgItem (hDlg, IDC_CHECK_LOG) ; // Enable/disable logging checkbox button
		toolinfo.hinst = NULL ;								// If a string resource is used, handle to the instance that contains it
		toolinfo.lpszText = szLOTooltip [langCode] ;

		SendMessage (hToolTipLO, TTM_ADDTOOL, 0, (LPARAM) &toolinfo) ; // Add the tool all the info it needs
		SendMessage (hToolTipLO, TTM_SETMAXTIPWIDTH, 0, 120) ; // Set the width of the balloon tooltip so that lines will wrap
	}
}

// Tooltip for the log window
void createLogWinTooltip ()
{
	hToolTipLW = CreateWindow (TOOLTIPS_CLASS, NULL, WS_POPUP | TTS_BALLOON, 0,0,0,0, hDlg, NULL, GetModuleHandle (NULL), 0) ; // Creates a tooltip control

	if (hToolTipLW != NULL) {
		SendMessage (hToolTipLW, TTM_ACTIVATE, TRUE, 0) ;	// Send this message to Activate ToolTips for the window. FALSE to deactivate the tool tip

		TOOLINFO toolinfo ;									// Tool Tip Info structure
		memset (&toolinfo, 0, sizeof (TOOLINFO)) ;
		toolinfo.cbSize = sizeof (TOOLINFO) ;
		toolinfo.hwnd = hDlg ;								// The parent window
		toolinfo.uFlags = TTF_SUBCLASS | TTF_IDISHWND ;		// IDISHWND = the next ID is a window (control) handle not a resource ID
		toolinfo.uId = (UINT_PTR) GetDlgItem (hDlg, IDC_EDIT_LOG) ; // Log (edit control) window
		toolinfo.hinst = NULL ;								// If a string resource is used, handle to the instance that contains it
		toolinfo.lpszText = szLWTooltip [langCode] ;

		SendMessage (hToolTipLW, TTM_ADDTOOL, 0, (LPARAM) &toolinfo) ; // Add the tool all the info it needs
		SendMessage (hToolTipLW, TTM_SETMAXTIPWIDTH, 0, 120) ; // Set the width of the balloon tooltip so that lines will wrap
	}
}

// End of source file - Functions.cpp