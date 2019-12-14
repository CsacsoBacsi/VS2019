// SuDoKuGrid.cpp
/* Contains a function that creates both the starting and the solved grid
*/

#include "SuDoKuWin.h"

#pragma comment (lib, "ComCtl32.lib")
#pragma comment (linker,"/manifestdependency:\"type='win32' name='Microsoft.Windows.Common-Controls' \
						version='6.0.0.0' processorArchitecture='*' publicKeyToken='6595b64144ccf1df' language='*'\"")

HWND CreateListView (HWND hwndParent, HINSTANCE hInstance, int ListViewID)
{
	LVCOLUMN LvCol ;										// Column struct for ListView
	LVITEM LvItem ;											// ListView Item struct

	INITCOMMONCONTROLSEX icex ;								// Structure for control initialization
	icex.dwICC = ICC_LISTVIEW_CLASSES ;
	InitCommonControlsEx (&icex) ;

	// If no resource editor was used, the list view control could be created like this
	//hWndListView = CreateWindowEx (0L, WC_LISTVIEW, "", LVS_REPORT | WS_CHILD | WS_VISIBLE | WS_BORDER | WS_TABSTOP | WS_EX_CLIENTEDGE,
	//								x, y, w, h, hwndParent, NULL, hInstance, NULL) ;

	hWndListView = GetDlgItem (hwndParent, ListViewID) ;	// Get handle of the control based on the resource ID

	memset (&LvCol, 0, sizeof (LvCol)) ;					// Reset column
	LvCol.mask = LVCF_TEXT | LVCF_WIDTH | LVCF_SUBITEM ;	// Type of mask. The info that we fill in or expect the control to return values in
	LvCol.cx = 0x15 ;

	char ** cols ;
	cols = (char **) malloc (9 * sizeof (char *)) ;
	for (char i = 0; i < 9; i ++) {
		cols[i] = (char *) malloc (2 * sizeof (char)) ;		// For each pointer, allocate 2 chars (the value and the terminating zero)
		cols[i][0] = 97 + i; cols[i][1] = 0 ;
	}

	LvCol.pszText = "";
	SendMessage (hWndListView, LVM_INSERTCOLUMN, 0, (LPARAM) &LvCol) ; // Insert/Show the first column
	for (char i = 1; i <= 9; i ++) {
		LvCol.pszText = cols[i - 1] ;
		SendMessage (hWndListView, LVM_INSERTCOLUMN, i, (LPARAM) &LvCol) ; // Inserting columns
	}

	char ** rows ;
	rows = (char **) malloc (9 * sizeof(char *)) ;
	for (char i = 0; i < 9; i ++) {
		rows[i] = (char *) malloc (2 * sizeof(char)) ;		// For each pointer, allocate 2 chars
		rows[i][0] = 65 + i ; rows[i][1] = 0 ;
	}

	memset (&LvItem, 0, sizeof (LvItem)) ;
	LvItem.mask = LVIF_TEXT ;								// Text Style
	LvItem.cchTextMax = 1 ;									// Max size of text

	for (char i = 0; i < 9; i++) {
		LvItem.iItem = i ;									// Choose the item  
		LvItem.iSubItem = 0 ;								// Put in first column
		LvItem.pszText = rows[i] ;
		SendMessage (hWndListView, LVM_INSERTITEM, 0, (LPARAM) &LvItem) ; // Inserting rows
	}
	
	for (int i = 0; i < 9; i ++) {
		free (rows[i]) ;
		free (cols[i]) ;
	}
	free (rows) ;
	free (cols) ;

	SendMessage (hWndListView, LVM_SETEXTENDEDLISTVIEWSTYLE, LVS_EX_GRIDLINES | LVS_EX_INFOTIP | LVS_EX_LABELTIP,
		                       LVS_EX_GRIDLINES | LVS_EX_INFOTIP | LVS_EX_LABELTIP) ;	// Sets the extended styles via a message
	//SetWindowTheme (hWndListView, L"Explorer", NULL) ;
	return (hWndListView) ;
}

// End of source file - SuDoKuGrid.cpp
