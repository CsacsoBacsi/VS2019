/* BtreeWin.cpp
   Defines the entry point for the application.*/

#include "Btree.h"
#include "Resource.h"
#include <commctrl.h>
#include <stdio.h>
#include <io.h>
#include <Uxtheme.h>

#pragma comment (lib,"comctl32.lib")
#pragma comment (linker,"/manifestdependency:\"type='win32' name='Microsoft.Windows.Common-Controls' \
						version='6.0.0.0' processorArchitecture='*' publicKeyToken='6595b64144ccf1df' language='*'\"")

BOOL CALLBACK DialogProc (HWND, UINT, WPARAM, LPARAM) ;
BOOL CALLBACK AboutDlgProc (HWND, UINT, WPARAM, LPARAM) ;
BOOL CALLBACK HelpHlpProc (HWND, UINT, WPARAM, LPARAM) ;
BOOL WINAPI ConsoleHandlerRoutine (DWORD) ;
void PopulateTreeView (HWND) ;
void _PopulateTreeView (HWND, node *, int, HTREEITEM) ;
void TraverseTreeView () ;
void _TraverseTreeView (HTREEITEM) ;
bool FindTV (HWND, int) ;
bool _FindTV (HWND, HTREEITEM, int, int) ;
void EraseChangeTypes () ;
bool SaveTextFile (char *) ;
bool CheckLoadTextFile (char *) ;
bool CheckSTree () ;
bool ShadowToReal () ;

// Main application entry point
int WINAPI WinMain (HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow)
{
	MSG msg ;
	BOOL ret ;

	InitCommonControls () ;
	hDlg = CreateDialogParam (hInstance, MAKEINTRESOURCE (IDD_DIALOG_MAIN), 0, DialogProc, 0) ; // Create the dialog window (main window)
	hAboutDlg = CreateDialogParam (GetModuleHandle(NULL), MAKEINTRESOURCE (IDD_DIALOG_ABOUT), hDlg, AboutDlgProc, 0) ; // Creates a modal dialog. Blocks until closed
	hHelpDlg = CreateDialogParam (GetModuleHandle(NULL), MAKEINTRESOURCE (IDD_DIALOG_HELP), hDlg, HelpHlpProc, 0) ; // Creates a modal dialog. Blocks until closed
	
	ShowWindow (hDlg, nCmdShow) ;

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

	switch (message) {
		case WM_INITDIALOG:									// Most of the initialization occurs here
		{
			TV_INSERTSTRUCT tvinsert ;
			HICON hIconDash, hIconAdded, hIconShuffled ;
			HIMAGELIST hImgList ;

			AllocConsole () ;								// Defines a console window (mainly for debug purposes if needed
			AttachConsole (GetCurrentProcessId ()) ;
			freopen_s (&stream, "CON", "w", stdout) ;
			SetConsoleTitle ("Console for the Balanced-tree") ;
			SetConsoleCtrlHandler (ConsoleHandlerRoutine, true) ;

			HWND hConsole = GetConsoleWindow () ;
			if (hConsole != NULL) {
				HMENU hMenu = GetSystemMenu (hConsole, FALSE) ;
				if (hMenu != NULL) DeleteMenu (hMenu, SC_CLOSE, MF_BYCOMMAND) ;
			}

			
			hTreeView = GetDlgItem (hDlg, IDC_TREEVIEW1) ;		// Tree view handle. This is the tree view where insertions and deletions will show
			hTreeViewP = GetDlgItem (hDlg, IDC_TREEVIEW2) ;		// Previous state tree view. Holds the keys as they were prior to the most recent insertion or deletion

			hIconDash = (HICON)LoadIcon (GetModuleHandle(NULL), MAKEINTRESOURCE(IDI_ICON_DASH)) ; // Tree item icons that appear in fornt of the label but after the +- sign
			hIconAdded = (HICON)LoadIcon (GetModuleHandle(NULL), MAKEINTRESOURCE(IDI_ICON_ADDED)) ;
			hIconShuffled = (HICON)LoadIcon (GetModuleHandle(NULL), MAKEINTRESOURCE(IDI_ICON_SHUFFLED)) ;
			
			hImgList = ImageList_Create(16, 16, ILC_COLOR16 | ILC_MASK, 3, 1); // ILC_MASK needed for transparent icons. Add 3 icons to the set
			ImageList_AddIcon(hImgList, hIconDash) ;			// Add icons to the image list
			ImageList_AddIcon (hImgList, hIconAdded) ;
			ImageList_AddIcon (hImgList, hIconShuffled) ;

			SendMessage (hTreeView, TVM_SETIMAGELIST, (WPARAM)TVSIL_NORMAL, (LPARAM)hImgList) ; // Add the imagelist ot the treeview
			SendMessage (hTreeViewP, TVM_SETIMAGELIST, (WPARAM)TVSIL_NORMAL, (LPARAM)hImgList) ;

			tvinsert.item.mask = TVIF_TEXT | TVIF_PARAM ;		// Add the technical Btree root to the tree
			tvinsert.hInsertAfter = TVI_ROOT ;
			tvinsert.hParent = TVI_ROOT ;
			tvinsert.item.pszText = "Btree" ;					// Artificial root to have a single root of this tree
			tvinsert.item.iImage = 0 ;
			tvinsert.item.iSelectedImage = 0 ;
			tvinsert.item.lParam = (LPARAM) nullchar ;			// No tooltip for this technical node

			SendMessage (hTreeView, TVM_INSERTITEM, 0, (LPARAM)&tvinsert) ; // Insert the initial 'Btree' node to have a single root node in the tree
			SendMessage (hTreeViewP, TVM_INSERTITEM, 0, (LPARAM)&tvinsert) ;

			return FALSE ;
		}
		break ;
		case WM_COMMAND:										// Button and menu messages
		{
			wmId = LOWORD (wParam) ;
			wmEvent = HIWORD (wParam) ;

			switch (wmId)
			{
				case ID_BUTTON_POPULATE:						// Populates the tree with about 40 node items (random numbers)
				{
					SendMessage (hTreeView, TVM_DELETEITEM, 0, (LPARAM)TVI_ROOT) ; // Delete everything from the tree
					
					memset (tree, 0, sizeof(tree)) ;			// Set everything to zero
					memset (btree, false, sizeof(btree)) ;
					nodeHWM = 0 ;								// Initialize the key counters
					nodeCount = 0 ;
					rootNodeIndex = 0 ;
					
					PopulateTree () ;							// Populate the back-end structure
					EraseChangeTypes () ;
					PopulateTreeView (hTreeView) ;				// Populate the front-end control
				}
				break ;
				case ID_BUTTON_INSERT:							// Insert a new key
				{
					char buff[5] ;
					int key ;
					int rownum ;
					insInfo insi ;

					SendMessage (GetDlgItem (hDlg, IDC_EDIT_KEY), WM_GETTEXT, 5, (LPARAM)buff) ; // Get the user input from the edit controls
					key = atoi (buff) ;							// And convert them to integer
					SendMessage (GetDlgItem (hDlg, IDC_EDIT_ROWNUM), WM_GETTEXT, 5, (LPARAM)buff) ;
					rownum = atoi (buff) ;
								
					insi = Find (tree, rootNodeIndex, key) ;	// Find where the key should go
					if (insi.action == 'E') {
						MessageBoxA (hDlg, "This key already exists!", "Error", MB_OK | MB_ICONEXCLAMATION) ;
						SetFocus (hTreeView) ;
						FindTV (hTreeView, key) ;

						return 0 ;
					}

					EraseChangeTypes () ;						// Get rid of the traces of the previous change (insert or deletion)
					SendMessage (hTreeViewP, TVM_DELETEITEM, 0, (LPARAM)TVI_ROOT) ; // Populate the Previous state tree view
					PopulateTreeView (hTreeViewP) ;				// Populate the other (Previous) tree view to preserve pre-deletion state
					
					bool success = Insert (key, rownum) ;

					CheckTree () ;								// Check the validity of the tree
					SendMessage (hTreeView, TVM_DELETEITEM, 0, (LPARAM)TVI_ROOT) ; // Re-populate the tree view
					PopulateTreeView (hTreeView) ;
					SetFocus(hTreeView) ;
					FindTV (hTreeView, key) ;					// Highlight (select) the newly inserted key (node, tree item)
				}
				break ;
				case ID_BUTTON_DELETE:							// Delete a key
				{
					TCHAR buffer[10] ;
					TVITEM item ;
					int key ;

					HTREEITEM hSelectedItem = (HTREEITEM) SendMessage (hTreeView, TVM_GETNEXTITEM, TVGN_CARET, NULL) ; // TVGN_CARET = selected item
					if (hSelectedItem == NULL)					// Nothing selected
						return 0 ;

					item.hItem = hSelectedItem ;				// It is the handle of the selected item tree node
					item.mask = TVIF_TEXT | TVIF_CHILDREN | TVIF_PARAM ; // Get these three components. These are valid
					item.cchTextMax = 10 ;						// Size of buffer
					item.pszText = buffer ;						// Buffer that receives the node's text (description)
					BOOL success = (BOOL) SendMessage (hTreeView, TVM_GETITEM, 0, (LPARAM)&item) ; // Get info about this tree item (the selected one)

					if (item.pszText[0] == '<') {				// It is a technical value, can not be deleted
						return 0 ;
					}

					key = atoi (item.pszText) ;
					EraseChangeTypes () ;
					SendMessage (hTreeViewP, TVM_DELETEITEM, 0, (LPARAM)TVI_ROOT) ; // Populate the Previous state tree view
					PopulateTreeView (hTreeViewP) ;				// Populate the other (Previous) tree view to preserve pre-deletion state

					Delete (atoi (item.pszText)) ;				// Delete the key

					CheckTree () ;								// Check if the tree is still healthy
					SendMessage (hTreeView, TVM_DELETEITEM, 0, (LPARAM)TVI_ROOT) ; // Clear the tree view (delete all items)
					PopulateTreeView (hTreeView) ;				// Re-populate the whole tree
					FindTV (hTreeViewP, key) ;					// Select the item that was deleted in the Previous state tree
					SetFocus (hTreeViewP) ;						// Give it the focus otherwise the selection is not visible
				}
				break ;
				case ID_BUTTON_FIND:
				{
					char buff[5] ;
					int key ;
					
					SendMessage (GetDlgItem (hDlg, IDC_EDIT_KEY), WM_GETTEXT, 5, (LPARAM)buff) ; // Get the user-typed key
					key = atoi (buff) ;
					bool success = FindTV (hTreeView, key) ;	// Find it and highlight it if exists
					if (success)
						SetFocus (hTreeView) ;					// by having clicked on the Find button, the focus is lost, so give it back so that the selection is visible
				}
				break ;
				case ID_BUTTON_CLOSE:
				{
					PostMessage (hDlg, WM_CLOSE, 0, 0) ;		// Close down everytging gracefully
				}
				break ;
				case ID_BUTTON_DELETEALL:
				{
					HTREEITEM Root ;
					TV_INSERTSTRUCT tvinsert ;

					memset (tree, 0, sizeof (tree)) ;			// Set everything to zero
					memset (btree, false, sizeof (btree)) ;		// Init the node free list array
					nodeHWM = 0 ;								// Initialize the key counters
					nodeCount = 0 ;
					rootNodeIndex = 0 ;

					SendMessage (hTreeView, TVM_DELETEITEM, 0, (LPARAM)TVI_ROOT) ;

					tvinsert.item.mask = TVIF_TEXT | TVIF_PARAM ;
					tvinsert.hInsertAfter = TVI_ROOT ;
					tvinsert.hParent = TVI_ROOT ;
					tvinsert.item.pszText = "Btree" ;			// Artificial root to have a single root of this tree

					Root = (HTREEITEM)SendMessage (hTreeView, TVM_INSERTITEM, 0, (LPARAM)&tvinsert) ;

					SendMessage (hTreeView, TVM_EXPAND, TVE_EXPAND, (LPARAM)(HTREEITEM)Root) ; // Expand this node (the root node in this case)
				}
				break ;
				case ID_FILE_SAVETREE:							// Saves the internal b-tree structure content in a text file
				{
					OPENFILENAME ofn ;
					char szFileName[MAX_PATH] = "" ;

					ZeroMemory (&ofn, sizeof (ofn)) ;			// Populate the parameters of the file to be opened
					ofn.lStructSize = sizeof (OPENFILENAME) ;
					ofn.hwndOwner = hDlg ;
					ofn.lpstrFilter = "Text Files (*.txt)\0*.txt\0All Files (*.*)\0*.*\0" ;
					ofn.lpstrFile = szFileName ;
					ofn.nMaxFile = MAX_PATH ;
					ofn.lpstrDefExt = "txt" ;
					ofn.Flags = OFN_EXPLORER | OFN_PATHMUSTEXIST | OFN_HIDEREADONLY | OFN_OVERWRITEPROMPT ;	// Ask to overwrite if exists

					if (GetSaveFileName (&ofn)) {				// Opens a standard windows dialog to specify the directory and file name 
						if (SaveTextFile (szFileName)) {
							MessageBoxA (hDlg, "File saved successfully!", "Success", MB_OK | MB_ICONINFORMATION | MB_APPLMODAL) ;
						}
						else {
							MessageBoxA (hDlg, "Error saving file!", "Error", MB_OK | MB_ICONEXCLAMATION | MB_APPLMODAL) ;
							break ;
						}
					}
					SetFocus (hTreeView) ;
				}
				break ;
				case ID_FILE_LOADTREE:							// Loads the file selected into a shadow area (shadow tree), checks the data and only then updates the tree
				{
					TV_INSERTSTRUCT tvinsert ;
					OPENFILENAME ofn ;
					char szFileName[MAX_PATH] = "" ;			// Largest file name possible

					ZeroMemory (&ofn, sizeof(ofn)) ;

					ofn.lStructSize = sizeof (OPENFILENAME) ;	// Populate the parameters of the file to be read
					ofn.hwndOwner = hDlg ;
					ofn.lpstrFilter = "Text Files (*.txt)\0*.txt\0All Files (*.*)\0*.*\0" ;
					ofn.lpstrFile = szFileName ;				// File name
					ofn.nMaxFile = MAX_PATH ;
					ofn.Flags = OFN_EXPLORER | OFN_FILEMUSTEXIST | OFN_HIDEREADONLY ;	// No read-only files, file must exist
					ofn.lpstrDefExt = "txt" ;					// Default extension

					if (GetOpenFileName (&ofn)) {				// Opens a standard windows dialog to specify the directory and file name to read from
						if (CheckLoadTextFile (szFileName)) {	// Check the loaded data first (checkSTree)
							SendMessage (hTreeView, TVM_DELETEITEM, 0, (LPARAM)TVI_ROOT) ; // Delete everything from the tree
							SendMessage(hTreeViewP, TVM_DELETEITEM, 0, (LPARAM)TVI_ROOT) ; // Delete everything from the tree
							PopulateTreeView (hTreeView) ;				// Populate the front-end control

							tvinsert.item.mask = TVIF_TEXT | TVIF_PARAM;// Add the technical Btree root to the tree
							tvinsert.hInsertAfter = TVI_ROOT;
							tvinsert.hParent = TVI_ROOT;
							tvinsert.item.pszText = "Btree";		// Artificial root to have a single root of this tree
							tvinsert.item.iImage = 0;
							tvinsert.item.iSelectedImage = 0;
							tvinsert.item.lParam = (LPARAM)nullchar;// No tooltip for this technical node
							SendMessage (hTreeViewP, TVM_INSERTITEM, 0, (LPARAM)&tvinsert) ; // Insert the initial 'Btree' node to have a single root node in the tree
							SetFocus (hTreeView) ;

							MessageBoxA (hDlg, "File successfully loaded!", "Success", MB_OK | MB_ICONINFORMATION | MB_APPLMODAL) ;
						}
						else {
							MessageBoxA (hDlg, "Error loading file. File may be corrupt!", "Error", MB_OK | MB_ICONEXCLAMATION | MB_APPLMODAL) ;
							break ;
						}
					}
				}
				break ;
				case ID_HELP_ABOUT:								// Display the "About" modal dialog
				{
					RECT rcP, rc ;								// Rectangle structure to store the coordinates

					GetWindowRect (hDlg, &rcP) ;				// Parent's position
					int widthP = (rcP.right - rcP.left) ;
					int heightP = (rcP.bottom - rcP.top) ;
					GetWindowRect (hAboutDlg, &rc) ;			// About dialog's position
					int width = (rc.right - rc.left) ;
					int height = (rc.bottom - rc.top) ;
					/*MoveWindow (hAboutDlg, rcP.left + (widthP - width) / 2, rcP.top + (heightP - height) / 2, width, height, TRUE) ;*/
					SetWindowPos (hAboutDlg, HWND_TOP, rcP.left + (widthP - width) / 2, rcP.top + (heightP - height) / 2, width, height, SWP_SHOWWINDOW) ; // Sets the window's position as well as displays (shows) it
				}
				break ;
				case ID_HELP_HELP:								// Display the "Help" modal dialog
				{
					RECT rcP, rc ;								// Rectangle structure to store the coordinates

					GetWindowRect (hDlg, &rcP) ;				// Parent's position
					int widthP = (rcP.right - rcP.left) ;
					int heightP = (rcP.bottom - rcP.top) ;
					GetWindowRect (hHelpDlg, &rc) ;				// About dialog's position
					int width = (rc.right - rc.left) ;
					int height = (rc.bottom - rc.top) ;
					/*MoveWindow (hAboutDlg, rcP.left + (widthP - width) / 2, rcP.top + (heightP - height) / 2, width, height, TRUE) ;*/
					SetWindowPos (hHelpDlg, HWND_TOP, rcP.left + (widthP - width) / 2, rcP.top + (heightP - height) / 2, width, height, SWP_SHOWWINDOW) ; // Sets the window's position as well as displays (shows) it
				}
				break ;
				case ID_FILE_EXIT:
				{
					PostMessage (hDlg, WM_CLOSE, 0, 0) ;		// Close down everything gracefully
				}
				break ;
			}
		}
		break ;
		case WM_PAINT:
		{
			hDC = BeginPaint (hDlg, &ps) ;						// Not used, redundant
			//SetBkMode(hDC, TRANSPARENT) ;
			//Rectangle (hDC, 150, 150, 300, 300) ;
			EndPaint (hDlg, &ps) ;
		}
		break ;
		case WM_NOTIFY:											// The parent window (dialog) gets notified if something happens to the tree view (or anything else)
		{
			LPNMHDR  pnmh = (LPNMHDR)lParam ;
			switch (pnmh->code)
			{
				case TVN_SELCHANGED:							// This notification is sent when the user selects a tree item
				{
					LPNMTREEVIEW pnmtv = (LPNMTREEVIEW)lParam ;
					TVITEM item ;
					TCHAR buffer[10] ;
					char labelbuff[30] ;
					int rownum ;

					if (pnmtv->hdr.hwndFrom == hTreeViewP) {	// Do not handle the selection change from the Previous state tree view
						return 0 ;
					}

					item.hItem = pnmtv->itemNew.hItem ;			// The handle of the tree item selected
					item.mask = TVIF_TEXT | TVIF_CHILDREN | TVIF_PARAM ; // Get these three components. These are valid
					item.cchTextMax = 10 ;						// Size of bufferto store node label text
					item.pszText = buffer ;						// Buffer that receives the node's text (description)
					BOOL success = (BOOL)SendMessage(hTreeView, TVM_GETITEM, 0, (LPARAM)&item) ;

					if (item.pszText[0] == 'B' || item.pszText[0] == '<') { // These ones can be ignored as these are technical nodes
						return 0 ;
					}
					else {
						rownum = GetRowNum (rootNodeIndex, atoi(item.pszText)) ; // Get the row number associated with this key
						sprintf_s (labelbuff, "%s", item.pszText) ;
						SendMessage(GetDlgItem(hDlg, IDC_EDIT_KEY), WM_SETTEXT, 0, (LPARAM)labelbuff) ;
						sprintf_s (labelbuff, "%d", rownum) ;
						SendMessage(GetDlgItem(hDlg, IDC_EDIT_ROWNUM), WM_SETTEXT, 0, (LPARAM)labelbuff) ;
						SetFocus(hTreeView);						// Without the focus it does not show
					}
				}
				break ;
				case TVN_GETINFOTIP:							// The tree view must be created with (TVS_INFOTIP) Info Tip = true then this notification is sent
				{
					LPNMTVGETINFOTIP pTip = (LPNMTVGETINFOTIP)lParam ;
					HTREEITEM item = pTip->hItem ;
					TCHAR buffer[10] ;
					char deltype [17] = {'D','e','l','e','t','i','o','n',' ','t','y','p','e',' '} ;

					// Get the text for the item.
					TVITEM tvitem ;
					tvitem.mask = TVIF_PARAM | TVIF_TEXT ;		// what happened to the node during an insert or deletion is stored in lParam of the tree item
					tvitem.hItem = item ;
					tvitem.pszText = buffer ;
					tvitem.cchTextMax = 10 ;	
					TreeView_GetItem (hTreeView, &tvitem) ;

					if (buffer[0] == 'B') {						// For the root node, there is no lParam set so treat it differently
						pTip->pszText = "Root of the b-tree" ;
					}
					else if (*(char *)(tvitem.lParam) == 'I') { // Translate each and every lParam code into human digestable form
						pTip->pszText = "Newly inserted key" ;
					}
					else if (*(char *)(tvitem.lParam) == 'S' && *(char *)(tvitem.lParam + 1) == 'R') {
						pTip->pszText = "Insert, shifted right key";
					}
					else if (*(char *)(tvitem.lParam) == 'S' && *(char *)(tvitem.lParam + 1) == 'P') {
						pTip->pszText = "Overflow, split key" ;
					}
					else if (*(char *)(tvitem.lParam) == 'P' && *(char *)(tvitem.lParam + 1) == 'R') {
						pTip->pszText = "Overflow, propagated key";
					}
					else if (*(char *)(tvitem.lParam) == '0' && *(char *)(tvitem.lParam + 1) == '1') {
						pTip->pszText = "Deltype 1, shifted left key";
					}
					else if (*(char *)(tvitem.lParam) == 'D' && *(char *)(tvitem.lParam + 1) == 'a') {
						pTip->pszText = "Deltype 2a, descended key";
					}
					else if (*(char *)(tvitem.lParam) == 'D' && *(char *)(tvitem.lParam + 1) == 'b') {
						pTip->pszText = "Deltype 2b, descended key";
					}
					else if (*(char *)(tvitem.lParam) == 'D' && *(char *)(tvitem.lParam + 1) == 'c') {
						pTip->pszText = "Deltype 2c, descended key";
					}
					else if (*(char *)(tvitem.lParam) == '2' && *(char *)(tvitem.lParam + 1) == 'g') {
						pTip->pszText = "Deltype 2a, given up key";
					}
					else if (*(char *)(tvitem.lParam) == '2' && *(char *)(tvitem.lParam + 1) == 'i') {
						pTip->pszText = "Deltype 2a, shifted right key";
					}
					else if (*(char *)(tvitem.lParam) == '2' && *(char *)(tvitem.lParam + 1) == 'u') {
						pTip->pszText = "Deltype 2b, given up key";
					}
					else if (*(char *)(tvitem.lParam) == '2' && *(char *)(tvitem.lParam + 1) == 'e') {
						pTip->pszText = "Deltype 2b, shifted left key";
					}
					else if (*(char *)(tvitem.lParam) == '2' && *(char *)(tvitem.lParam + 1) == 'l') {
						pTip->pszText = "Deltype 2c, shifted left key";
					}
					else if (*(char *)(tvitem.lParam) == '2' && *(char *)(tvitem.lParam + 1) == 'r') {
						pTip->pszText = "Deltype 2c, shifted right key";
					}
					else if (*(char *)(tvitem.lParam) == '2' && *(char *)(tvitem.lParam + 1) == 'm') {
						pTip->pszText = "Deltype 2c, merged key";
					}
					else if (*(char *)(tvitem.lParam) == '3' && *(char *)(tvitem.lParam + 1) == 'a') {
						pTip->pszText = "Deltype 3a, predecessor key";
					}
					else if (*(char *)(tvitem.lParam) == '3' && *(char *)(tvitem.lParam + 1) == 'b') {
						pTip->pszText = "Deltype 3b, successor key";
					}
					else if (*(char *)(tvitem.lParam) == '3' && *(char *)(tvitem.lParam + 1) == 'c') {
						pTip->pszText = "Deltype 3c, underflow, predecessor key";
					}
					else if (*(char *)(tvitem.lParam) == '3' && *(char *)(tvitem.lParam + 1) == 'd') {
						pTip->pszText = "Deltype 3d, underflow, successor key";
					}
					else
						pTip->pszText = nullchar ;				// Point the tooltip at "nothing"
					break;
				}
			return TRUE ;
			}
		}
		break;
		case WM_DESTROY:										// Called by WM_CLOSE
		{
			PostQuitMessage (0) ;								// Sends WM_QUIT
			
			return 0 ;
		}
		break ;
		case WM_CLOSE:											// On closure of the dialog
		{
			if (MessageBoxA (hDlg, "Are you sure you want to quit?", "Exit application", MB_OKCANCEL | MB_ICONQUESTION) == IDOK) {
				DestroyWindow (hDlg) ;
			}
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
			return TRUE ;										// After processed messages must return TRUE
		}
		break ;
		case WM_COMMAND:
		{
			switch (LOWORD (wParam))
			{
				case IDC_BUTTON_OK:
				{
					EndDialog (hwnd, IDC_BUTTON_OK) ;			// Modal dialog so has to call EndDialog
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
			HBITMAP bmp = LoadBitmap (GetModuleHandle(NULL), MAKEINTRESOURCE(IDB_BITMAP_HEART)) ; // displays a heart next to Zsurni's name
			// 2. Create a memory device compatible with the above DC variable
			MemDC = CreateCompatibleDC (hDC) ;
			// 3. Select the new bitmap into it
			HBITMAP oldBmp = (HBITMAP)SelectObject (MemDC, bmp) ;
			// 4. Copy the bits from the memory DC into the current DC to show the bitmap
			BitBlt (hDC, 257, 72, 275, 90, MemDC, 0, 0, SRCCOPY) ;

			SelectObject (MemDC, oldBmp) ;
			DeleteObject (bmp) ;
			DeleteDC (MemDC) ;
			EndPaint (hwnd, ppstruct) ;
		}
		break ;
		default:
			return FALSE ;										// Messages that not handled must return FALSE
	}

	return TRUE ;
}

// About dialog callback routine
BOOL CALLBACK HelpHlpProc (HWND hwnd, UINT Message, WPARAM wParam, LPARAM lParam)
{
	switch (Message)
	{
		case WM_INITDIALOG:
		{
			return TRUE ;										// After processed messages must return TRUE
		}
		break ;
		case WM_COMMAND:
		{
			switch (LOWORD (wParam))
			{
				case ID_BUTTON_HELP_CLOSE:
				{
					EndDialog (hwnd, ID_BUTTON_HELP_CLOSE) ;			// Modal dialog so has to call EndDialog
				}
				break;
				case IDC_BUTTON_HELP_INSGEN:
				{
					SendMessage (GetDlgItem (hHelpDlg, IDC_EDIT_HELP), WM_SETTEXT, 0, (LPARAM)helpInsertGeneral) ;
				}
				break ;
				case IDC_BUTTON_HELP_DELGEN:
				{
					SendMessage (GetDlgItem (hHelpDlg, IDC_EDIT_HELP), WM_SETTEXT, 0, (LPARAM)helpDeleteGeneral) ;
				}
				break ;
				case IDC_BUTTON_HELP_DEL1:
				{
					SendMessage (GetDlgItem (hHelpDlg, IDC_EDIT_HELP), WM_SETTEXT, 0, (LPARAM)helpDeleteType1) ;
				}
				break ;
				case IDC_BUTTON_HELP_DEL2A:
				{
					SendMessage (GetDlgItem (hHelpDlg, IDC_EDIT_HELP), WM_SETTEXT, 0, (LPARAM)helpDeleteType2a) ;
				}
				break ;
				case IDC_BUTTON_HELP_DEL2B:
				{
					SendMessage (GetDlgItem (hHelpDlg, IDC_EDIT_HELP), WM_SETTEXT, 0, (LPARAM)helpDeleteType2b) ;
				}
				break ;
				case IDC_BUTTON_HELP_DEL2C:
				{
					SendMessage (GetDlgItem (hHelpDlg, IDC_EDIT_HELP), WM_SETTEXT, 0, (LPARAM)helpDeleteType2c) ;
				}
				break ;
				case IDC_BUTTON_HELP_DEL3A:
				{
					SendMessage (GetDlgItem (hHelpDlg, IDC_EDIT_HELP), WM_SETTEXT, 0, (LPARAM)helpDeleteType3a) ;
				}
				break ;
				case IDC_BUTTON_HELP_DEL3B:
				{
					SendMessage (GetDlgItem (hHelpDlg, IDC_EDIT_HELP), WM_SETTEXT, 0, (LPARAM)helpDeleteType3b) ;
				}
				break ;
				case IDC_BUTTON_HELP_DEL3C:
				{
					SendMessage (GetDlgItem (hHelpDlg, IDC_EDIT_HELP), WM_SETTEXT, 0, (LPARAM)helpDeleteType3c) ;
				}
				break ;
				case IDC_BUTTON_HELP_DEL3D:
				{
					SendMessage (GetDlgItem (hHelpDlg, IDC_EDIT_HELP), WM_SETTEXT, 0, (LPARAM)helpDeleteType3d) ;
				}
				break ;
			}
		}
		break ;
		case WM_PAINT:
		{
			PAINTSTRUCT pstruct;
			PAINTSTRUCT * ppstruct = &pstruct ;
			HDC hDC ;

			hDC = BeginPaint (hwnd, ppstruct) ;

			EndPaint (hwnd, ppstruct) ;
		}
		break ;
		default:
			return FALSE ;										// Messages that not handled must return FALSE
	}

	return TRUE ;
}

BOOL WINAPI ConsoleHandlerRoutine (DWORD dwCtrlType) {			// unfortunately, this does not prevent the whole app from terminating
	if (dwCtrlType == CTRL_CLOSE_EVENT) {
		FreeConsole () ;
		return TRUE ;
	}
	else {
		return FALSE ;
	}
}

void PopulateTreeView (HWND htv) {
	HTREEITEM Root ;
	TV_INSERTSTRUCT tvinsert ;

	cout << endl << "<<< PopulateTreeView start >>>" << endl ;
	cout << "Populating the tree view from the internal btree" << endl ;
	tvinsert.item.mask = TVIF_TEXT | TVIF_PARAM | TVIF_IMAGE | TVIF_SELECTEDIMAGE ; //; We deal with these params, these are set (it is a mask)
	tvinsert.hInsertAfter = TVI_ROOT ;
	tvinsert.hParent = TVI_ROOT ;
	tvinsert.item.pszText = "Btree" ;							// Artificial root to have a single root of this tree
	tvinsert.item.iImage = 0 ;
	tvinsert.item.iSelectedImage = 0 ;
	tvinsert.item.lParam = (LPARAM) nullchar ;

	Root = (HTREEITEM)SendMessage (htv, TVM_INSERTITEM, 0, (LPARAM)&tvinsert) ;
	cout << "Starting with the root node" << endl ;
	cout << "Node " << rootNodeIndex << endl ;
	_PopulateTreeView (htv, tree, rootNodeIndex, Root) ;		// Populate the whole tree recursively

	SendMessage (htv, TVM_EXPAND, TVE_EXPAND, (LPARAM)(HTREEITEM)Root) ; // Expand this node (the root node in this case)
	cout << "<<< PopulateTreeView end >>>" << endl ;
}

void _PopulateTreeView (HWND htv, node * tree, int startNodeIndex, HTREEITEM Parent) {// Traverse the tree starting from the root
	int i, j ;
	TV_INSERTSTRUCT tvinsert ;
	HTREEITEM _Parent ;
	char label [10] ;

	cout << "<<< PopulateTreeView start (recursive) >>>" << endl ;
	cout << "Node " << startNodeIndex << endl ;
	if (tree[startNodeIndex].key[0] == 0 && tree[startNodeIndex].nodePointer[0] == 0) {// Empty node. Not initialized, stop searching
		return  ;
	}
	tvinsert.item.mask = TVIF_TEXT | TVIF_PARAM | TVIF_IMAGE | TVIF_SELECTEDIMAGE ;
	tvinsert.hInsertAfter = TVI_LAST ;
	tvinsert.item.iImage = 0 ;
	tvinsert.item.iSelectedImage = 0 ;

	i = 0 ;
	for (j = 0 ; j <= tree[startNodeIndex].count ; j ++) {		// There are one more pointers (node indices) than keys so equality must be allowed
		tvinsert.hParent = Parent ;

		if (j == 0 && tree[startNodeIndex].nodePointer[j] != -1) { // For each key in the node
			sprintf_s(label, "<%d", tree[startNodeIndex].key[i]) ;
			tvinsert.item.pszText = (LPSTR)label ;
			tvinsert.item.lParam = (LPARAM) nullchar ;
		}
		else if (tree[startNodeIndex].key[i] == 0 && tree[startNodeIndex].nodePointer[j] != -1) {
			i ++ ;
		}
		else {
			sprintf_s(label, "%d", tree[startNodeIndex].key[i]) ;
			tvinsert.item.pszText = (LPSTR)label ;
			tvinsert.item.lParam = (LPARAM) &(tree[startNodeIndex].changeType[i][0]) ; // Pass the change type as lparam
			if (tree[startNodeIndex].changeType[i][0] != NULL) {
				if (tree[startNodeIndex].changeType[i][0] == 'I') {
					tvinsert.item.iImage = 1 ;
					tvinsert.item.iSelectedImage = 1 ;
				}
				else {
					tvinsert.item.iImage = 2 ;
					tvinsert.item.iSelectedImage = 2 ;
				}
			}
			else {
				tvinsert.item.iImage = 0 ;
				tvinsert.item.iSelectedImage = 0 ;
			}
			i ++ ;
		}
		
		if (j < tree[startNodeIndex].count || (j == tree[startNodeIndex].count && tree[startNodeIndex].nodePointer[j] != -1)) { // For all non-zero keys or the last node pointer
			_Parent = (HTREEITEM)SendMessage(htv, TVM_INSERTITEM, 0, (LPARAM)&tvinsert);
			SendMessage (htv, TVM_EXPAND, TVE_EXPAND, (LPARAM)(HTREEITEM)Parent) ;
			_PopulateTreeView(htv, tree, tree[startNodeIndex].nodePointer[j], _Parent);
		}

		//if (tree[startNodeIndex].nodePointer[j] != -1) {
			//_Parent = (HTREEITEM)SendMessage(htv, TVM_INSERTITEM, 0, (LPARAM)&tvinsert);
		//	_PopulateTreeView (htv, tree, tree[startNodeIndex].nodePointer[j], _Parent) ;
		//}
	}
}

void TraverseTreeView () {
	TCHAR buffer[10] ;
	HTREEITEM Root ;
	HTREEITEM firstChild = NULL, nextSibling = NULL, lfirstChild = NULL ;
	TVITEM item ;
	BOOL success ;

	cout << endl << "<<< TraverseTreeView start >>>" << endl ;
	cout << "Traverse and display the keys of the tree view ***" << endl ;
	Root = (HTREEITEM) SendMessage (hTreeView, TVM_GETNEXTITEM, TVGN_ROOT, NULL) ; // TVGN_ROOT = Root node's handle
	item.hItem = Root ;
	item.mask = TVIF_TEXT | TVIF_CHILDREN | TVIF_PARAM ;		// Get these three components. These are valid
	item.cchTextMax = 10 ;										// Size of bufferto store node label text
	item.pszText = buffer ;										// Buffer that receives the node's text (description)
	success = (BOOL) SendMessage (hTreeView, TVM_GETITEM, 0, (LPARAM)&item) ; // Get info about this tree item

	cout << "Node: " << item.pszText << endl ;

	/* Since we can not retrieve all children using the same method, right at the very beginning, there are two routes available:
	1. If the root has children
	2. Has no children but has siblings
	In either case, the whole tree is fully traversed recursively
	*/
	if (item.cChildren) {										// Does the root have any children?
		cout << "Item has children" << endl ;
		firstChild = (HTREEITEM) SendMessage (hTreeView, TVM_GETNEXTITEM, TVGN_CHILD, (LPARAM)Root) ; // Get its first child
		item.hItem = firstChild ;
		success = (BOOL) SendMessage (hTreeView, TVM_GETITEM, 0, (LPARAM)&item) ;
		_TraverseTreeView (firstChild) ;						// Check out the first child
	}
	else {														// No children but may have siblings
		nextSibling = (HTREEITEM) SendMessage (hTreeView, TVM_GETNEXTITEM, TVGN_NEXT, (LPARAM)firstChild) ; // Get next sibling
		while (nextSibling != NULL) {							// Loop over each sibling
			cout << "Trying the next sibling" << endl ;
			item.hItem = nextSibling ;
			success = (BOOL) SendMessage (hTreeView, TVM_GETITEM, 0, (LPARAM)&item) ; 
			if (item.cChildren) {								// Check if this sibling node has a child or not
				lfirstChild = (HTREEITEM) SendMessage (hTreeView, TVM_GETNEXTITEM, TVGN_CHILD, (LPARAM)nextSibling) ; // If so, get its first child
				_TraverseTreeView (lfirstChild) ;				// Check out this child recursively
			}
			cout << "Node: " << item.pszText << endl ;
			nextSibling = (HTREEITEM) SendMessage (hTreeView, TVM_GETNEXTITEM, TVGN_NEXT, (LPARAM)nextSibling) ; // Try to fetch the next sibling
		}
	}
	cout << "<<< TraverseTreeView end >>>" << endl ;
	return ;
}

void _TraverseTreeView (HTREEITEM firstChild) {
	TVITEM item ;
	TCHAR buffer[10] ;
	BOOL success ;
	HTREEITEM lfirstChild, nextSibling ;
	
	cout << "<<< TraverseTreeView start (recursive) >>>" << endl ;
	item.hItem = firstChild ;
	item.mask = TVIF_TEXT | TVIF_CHILDREN | TVIF_PARAM ;		// Get these three components. These are valid
	item.cchTextMax = 10 ;										// Size of bufferto store node label text
	item.pszText = buffer ;										// Buffer that receives the node's text (description)
	success = (BOOL) SendMessage (hTreeView, TVM_GETITEM, 0, (LPARAM)&item) ; 
	cout << "Node: " << item.pszText << endl ;

	if (item.cChildren) {										// Traverses the whole sub-tree down to the last child
		cout << "Item has children" << endl ;
		lfirstChild = (HTREEITEM) SendMessage (hTreeView, TVM_GETNEXTITEM, TVGN_CHILD, (LPARAM)firstChild) ;
		item.hItem = lfirstChild ;
		success = (BOOL) SendMessage (hTreeView, TVM_GETITEM, 0, (LPARAM)&item) ;
		_TraverseTreeView (lfirstChild) ;
	}

	// If the whole sub-tree via the "has child" route is traversed (got to the very bottom), then go horizontal and try the next sibling
	nextSibling = (HTREEITEM) SendMessage (hTreeView, TVM_GETNEXTITEM, TVGN_NEXT, (LPARAM)firstChild) ;
	while (nextSibling != NULL) {								// While there are siblings
		cout << "Trying the next sibling" << endl ;
		item.hItem = nextSibling ;
		success = (BOOL) SendMessage (hTreeView, TVM_GETITEM, 0, (LPARAM)&item) ; 
		cout << "Node: " << item.pszText << endl ;
		if (item.cChildren) {									// Do the "has child" traverse
			lfirstChild = (HTREEITEM) SendMessage (hTreeView, TVM_GETNEXTITEM, TVGN_CHILD, (LPARAM)nextSibling) ;
			_TraverseTreeView (lfirstChild) ;
		}
		nextSibling = (HTREEITEM) SendMessage (hTreeView, TVM_GETNEXTITEM, TVGN_NEXT, (LPARAM)nextSibling) ;
	}

	return ;
}

bool FindTV (HWND htv, int key) {
	TCHAR buffer[10] ;
	HTREEITEM Root ;
	HTREEITEM firstChild = NULL, nextSibling = NULL, lfirstChild = NULL ;
	TVITEM item ;
	BOOL success ;
	int level = -1 ;

	cout << endl << "<<< FindTV start >>>" << endl ;
	cout << "*** Searching for a key in the tree view ***" << endl ; 
	Root = (HTREEITEM)SendMessage(htv, TVM_GETNEXTITEM, TVGN_ROOT, NULL) ; // TVGN_ROOT = Root node's handle
	item.hItem = Root ;
	item.mask = TVIF_TEXT | TVIF_CHILDREN | TVIF_PARAM  ;		// Get or set these components. These are valid
	item.cchTextMax = 10 ;										// Size of bufferto store node label text
	item.pszText = buffer ;										// Buffer that receives the node's text (description)
	success = (BOOL)SendMessage (htv, TVM_GETITEM, 0, (LPARAM)&item) ; // Get info about this tree item

	if (item.cChildren) {										// Does the root have any children?
		cout << "Item has children" << endl ;
		firstChild = (HTREEITEM)SendMessage (htv, TVM_GETNEXTITEM, TVGN_CHILD, (LPARAM)Root) ; // Get its first child
		item.hItem = firstChild ;
		success = (BOOL)SendMessage (htv, TVM_GETITEM, 0, (LPARAM)&item) ;
		if (atoi (item.pszText) == key) {
			success = (BOOL)SendMessage (htv, TVM_SELECTITEM, TVGN_CARET, (LPARAM)firstChild) ;
			cout << "<<< FindTV end >>>" << endl ;
			return true ;
		}
		if (_FindTV (htv, firstChild, key, level))
			cout << "<<< FindTV end >>>" << endl ;
			return true ;
	}
	else {														// No children but may have siblings
		nextSibling = (HTREEITEM)SendMessage (htv, TVM_GETNEXTITEM, TVGN_NEXT, (LPARAM)firstChild) ; // Get next sibling
		while (nextSibling != NULL) {							// Loop over each sibling
			cout << "Trying the next sibling..." << endl ;
			item.hItem = nextSibling ;
			success = (BOOL)SendMessage (htv, TVM_GETITEM, 0, (LPARAM)&item) ;
			if (atoi(item.pszText) == key) {
				success = (BOOL)SendMessage (htv, TVM_SELECTITEM, TVGN_CARET, (LPARAM)nextSibling) ;
				cout << "Key found!" << endl ;
				cout << "<<< FindTV end >>>" << endl ;
				return true ;
			}
			if (item.cChildren) {								// Check if this sibling node has a child or no
				cout << "Item has children" << endl ;
				lfirstChild = (HTREEITEM)SendMessage (htv, TVM_GETNEXTITEM, TVGN_CHILD, (LPARAM)nextSibling) ; // If so, get its first child
				if (_FindTV (htv, lfirstChild, key, level)) 	// Check out this child recursively
					cout << "Key found!" << endl ;
					cout << "<<< FindTV end >>>" << endl ;
					return true ;
			}
			nextSibling = (HTREEITEM)SendMessage(htv, TVM_GETNEXTITEM, TVGN_NEXT, (LPARAM)nextSibling); // Try to fetch the next sibling
		}
	}

	cout << "Key not found!" << endl ;
	cout << "<<< FindTV end >>>" << endl ;
	return false ;
}

bool _FindTV (HWND htv, HTREEITEM hitem, int key, int level) {
	TVITEM item ;
	TCHAR buffer[10] ;
	BOOL success ;
	HTREEITEM lfirstChild, nextSibling ;
	string indent = "   " ;
	string indent2 = "   " ;
	
	level ++ ;
	for (int l = 0 ; l < level ; l ++) {
		indent += indent2 ;
	}

	cout << indent << "<<< _FindTV start (recursive) >>>" << endl ;
	item.hItem = hitem ;
	item.mask = TVIF_TEXT | TVIF_CHILDREN | TVIF_PARAM ;		// Get these three components. These are valid
	item.cchTextMax = 10 ;										// Size of bufferto store node label text
	item.pszText = buffer ;										// Buffer that receives the node's text (description)
	success = (BOOL)SendMessage (htv, TVM_GETITEM, 0, (LPARAM)&item) ;
	if (atoi(item.pszText) == key) {
		success = (BOOL)SendMessage(htv, TVM_SELECTITEM, TVGN_CARET, (LPARAM)hitem) ;
		cout << indent << "<<< _FindTV end (recursive) >>>" << endl ;
		return true ;
	}

	if (item.cChildren) {										// Traverses the whole sub-tree down to the last child
		cout << indent << "Item has children" << endl ;
		lfirstChild = (HTREEITEM)SendMessage (htv, TVM_GETNEXTITEM, TVGN_CHILD, (LPARAM)hitem)  ;
		item.hItem = lfirstChild;
		success = (BOOL)SendMessage (htv, TVM_GETITEM, 0, (LPARAM)&item) ;
		if (atoi (item.pszText) == key) {
			success = (BOOL)SendMessage (htv, TVM_SELECTITEM, TVGN_CARET, (LPARAM)lfirstChild) ;
			cout << indent << "<<< _FindTV end (recursive) >>>" << endl;
			return true ;
		}
		if (_FindTV (htv, lfirstChild, key, level)) {
			cout << indent << "<<< _FindTV end (recursive) >>>" << endl ;
			return true ;
		}
	}

	// If the whole sub-tree via the "has child" route is traversed (got to the very bottom), then go horizontal and try the next sibling
	nextSibling = (HTREEITEM)SendMessage (htv, TVM_GETNEXTITEM, TVGN_NEXT, (LPARAM)hitem) ;
	while (nextSibling != NULL) {								// While there are siblings
		cout << indent << "Trying the next sibling..." << endl ;
		item.hItem = nextSibling ;
		success = (BOOL)SendMessage (htv, TVM_GETITEM, 0, (LPARAM)&item) ;
		if (atoi(item.pszText) == key) {
			success = (BOOL)SendMessage (htv, TVM_SELECTITEM, TVGN_CARET, (LPARAM)nextSibling) ;
			cout << indent << "<<< _FindTV end (recursive) >>>" << endl;
			return true ;
		}
		if (item.cChildren) {									// Do the "has child" traverse
			cout << indent << "Item has children" << endl ;
			lfirstChild = (HTREEITEM)SendMessage (htv, TVM_GETNEXTITEM, TVGN_CHILD, (LPARAM)nextSibling) ;
			if (_FindTV (htv, lfirstChild, key, level)) {
				cout << indent << "<<< _FindTV end (recursive) >>>" << endl;
				return true ;
			}
		}
		nextSibling = (HTREEITEM)SendMessage (htv, TVM_GETNEXTITEM, TVGN_NEXT, (LPARAM)nextSibling );
	}

	cout << indent << "<<< _FindTV end (recursive) >>>" << endl  ;
	return false ;
}

void EraseChangeTypes () {										// Each time it is a new insertion or deletion, we must delete the previously registered changes
	cout << endl << "<<< EraseChangeTypes start >>>" << endl ;
	cout << "*** Erasing previous change records ***" << endl ;
	for (int i = 0 ; i < nodeHWM ; i ++) {
		for (int j = 0 ; j < TREE_ORDER ; j ++) {
			tree[i].changeType[j][0] = 0 ;
			tree[i].changeType[j][1] = 0 ;
		}
	}
	cout << "<<< EraseChangeTypes end >>>" << endl ;
}

// Saves the current Btree view content in a file selected by the user
bool SaveTextFile (char * szFileName)
{
/* File record structure:
   First row:
   Root  Ncnt  PrntN
   00000,00000,00000,
   Subsequent rows:
   Taken NodeI Cnt   PrntI Key1  Key2  Key3  Key4  Rn1   Rn2   Rn3   Rn4   Np1   Np2   Np3   Np4   Np5   CRLF
   00000,00000,00000,00000,00000,00000,00000,00000,00000,00000,00000,00000,00000,00000,00000,00000,00000,CRLF
*/
	HANDLE hFile ;
	BOOL bSuccess = false ;
	long int written = NULL ;							// Number of bytes written
	char buffer[105] ;

	cout << "<<< SaveTextFile start >>>" << endl ;
	cout << "*** Saving internal btree to a text file ***" << endl ;
	hFile = CreateFile (szFileName, GENERIC_WRITE, 0, NULL,	CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL) ;
	if (hFile != INVALID_HANDLE_VALUE) {
		cout << "File opened successfully, writing header row..." << endl ;
		sprintf_s (buffer, 21, "%5d,%5d,%5d,%c%c", rootNodeIndex, nodeCount, nodeHWM, 13, 10) ;
		if (WriteFile (hFile, buffer, 20, (LPDWORD)&written, NULL)) {
			if (written != 20) {
				CloseHandle (hFile) ;
				cout << "Error writing header row" << endl ; 
				cout << "<<< SaveTextFile end >>>" << endl ;
				return false ;
			}
		}

		cout << "Writing nodes..." << endl ;
		for (int i = 0 ; i < nodeHWM ; i ++) {
			sprintf_s (buffer, 105, "%5d,%5d,%5d,%5d,%5d,%5d,%5d,%5d,%5d,%5d,%5d,%5d,%5d,%5d,%5d,%5d,%5d,%c%c", 
				       btree[i],i,tree[i].count, tree[i].prntNodePointer, tree[i].key[0], tree[i].key[1], tree[i].key[2], tree[i].key[3],
				       tree[i].rowNum[0], tree[i].rowNum[1], tree[i].rowNum[2], tree[i].rowNum[3],
				       tree[i].nodePointer[0],tree[i].nodePointer[1], tree[i].nodePointer[2], tree[i].nodePointer[3], tree[i].nodePointer[4],
				       13, 10) ;

			if (WriteFile (hFile, buffer, 104, (LPDWORD) &written, NULL)) {
				if (written != 104) {
					CloseHandle (hFile) ;
					cout << "Error writing node " << i << endl ; 
					cout << "<<< SaveTextFile end >>>" << endl ;
					return false ;
				}
			}
		}
		CloseHandle (hFile) ;
	}

	cout << "Internal btree saved successfully" << endl ;
	cout << "<<< SaveTextFile end >>>" << endl ;
	return true ;
}

bool CheckLoadTextFile (char * szFileName) // Loads then checks the previously saved tree from a file selected by the user
{
/* File record structure:
   First row:
   Root  Ncnt  PrntN
   00000,00000,00000,
   Subsequent rows:
   Taken NodeI Cnt   PrntI Key1  Key2  Key3  Key4  Rn1   Rn2   Rn3   Rn4   Np1   Np2   Np3   Np4   Np5   CRLF
   00000,00000,00000,00000,00000,00000,00000,00000,00000,00000,00000,00000,00000,00000,00000,00000,00000,CRLF
*/
	HANDLE hFile ;
	struct inS {												// Record structure
		char taken[5] ;
		char comma0[1] ;
		char node[5] ;
		char comma1[1] ;
		char count[5] ;
		char comma2[1] ;
		char prntNodePointer[5] ;
		char comma3[1] ;
		char key1 [5] ;
		char comma4[1] ;
		char key2[5] ;
		char comma5[1] ;
		char key3[5] ;
		char comma6[1] ;
		char key4[5] ;
		char comma7[1] ;
		char rn1[5] ;
		char comma8[1] ;
		char rn2[5] ;
		char comma9[1] ;
		char rn3[5] ;
		char comma10[1] ;
		char rn4[5] ;
		char comma11[1] ;
		char np1[5] ;
		char comma12[1] ;
		char np2[5] ;
		char comma13[1] ;
		char np3[5] ;
		char comma14[1] ;
		char np4[5] ;
		char comma15[1] ;
		char np5[5] ;
		char comma16[1] ;
	};
	union inU {													// UNIONed. The record is loaded into the buffer but accessed via the structure
		char buffer[105] ;
		inS inputS;
	};
	inU inLine ;

	cout << endl << "<<< CheckLoadTextFile start >>>" << endl ;
	cout << "*** Loading and checking textfile containing a previously saved internal btree ***" << endl ;
	hFile = CreateFile (szFileName, GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, 0, NULL); // For read even if shared
																// NULL = security attributes, 0 = flags and attributes, NULL = template file
	if (hFile != INVALID_HANDLE_VALUE)
	{
		long int read ;											// Number of bytes read
		cout << "File opened successfully, reading header row..." << endl ;
		if (ReadFile (hFile, inLine.buffer, 20, (LPDWORD) &read, NULL)) { // Read the first record that holds key tree info
			if (read != 20) {
				CloseHandle (hFile) ;
				cout << "Error reading header row" << endl ;
				cout << "<<< CheckLoadTextFile end >>>" << endl ;
				return false ;
			}
		}
		for (int i = 5 ; i < 18 ; i += 6) {
			inLine.buffer[i] = '\0' ;
		}

		srootNodeIndex = atoi (inLine.buffer) ;					// Populate the shadow variables
		snodeCount = atoi (inLine.buffer + 6) ;
		snodeHWM = atoi (inLine.buffer + 12) ;

		if (snodeCount == 0 || snodeHWM == 0 || (snodeCount > snodeHWM)) { // Do some sanity checks
			CloseHandle (hFile) ;
			cout << "Header row invalid" << endl ;
			cout << "<<< CheckLoadTextFile end >>>" << endl ;
			return false ;										// Invalid values
		}

		cout << "Header row OK, loading nodes..." << endl ;
		for (int i = 1 ; i <= snodeHWM ; i ++) {				// For each node stored in the file LOOP
			if (ReadFile (hFile, inLine.buffer, 104, (LPDWORD)&read, NULL)) { // Read one line (record) at a time
				if (read != 104) {
					CloseHandle (hFile) ;
					cout << "Error reading row " << i << endl ;
					cout << "<<< CheckLoadTextFile end >>>" << endl ;
					return false ;
				}
			}
			for (int i = 5 ; i < 104 ; i += 6) {				// Replace commas with a string terminator (zero)
				inLine.buffer[i] = '\0' ;
			}

			if (atoi (inLine.inputS.taken) == 0) {				// The free-list boolean array
				sbtree[atoi (inLine.inputS.node)] = false ;
			}
			else {
				sbtree[atoi (inLine.inputS.node)] = true ;
			}
			stree[atoi (inLine.inputS.node)].count = atoi (inLine.inputS.count) ;	// Count
			stree[atoi(inLine.inputS.node)].prntNodePointer = atoi (inLine.inputS.prntNodePointer) ; // Parent node pointer
			stree[atoi(inLine.inputS.node)].key[0] = atoi (inLine.inputS.key1) ;	// Keys
			stree[atoi(inLine.inputS.node)].key[1] = atoi (inLine.inputS.key2) ;
			stree[atoi(inLine.inputS.node)].key[2] = atoi (inLine.inputS.key3) ;
			stree[atoi(inLine.inputS.node)].key[3] = atoi (inLine.inputS.key4) ;
			stree[atoi(inLine.inputS.node)].rowNum[0] = atoi (inLine.inputS.rn1) ;	// Row numbers
			stree[atoi(inLine.inputS.node)].rowNum[1] = atoi (inLine.inputS.rn2) ;
			stree[atoi(inLine.inputS.node)].rowNum[2] = atoi (inLine.inputS.rn3) ;
			stree[atoi(inLine.inputS.node)].rowNum[3] = atoi (inLine.inputS.rn4) ;
			stree[atoi(inLine.inputS.node)].nodePointer[0] = atoi (inLine.inputS.np1) ;	// Node pointers (pointing at children)
			stree[atoi(inLine.inputS.node)].nodePointer[1] = atoi (inLine.inputS.np2) ;
			stree[atoi(inLine.inputS.node)].nodePointer[2] = atoi (inLine.inputS.np3) ;
			stree[atoi(inLine.inputS.node)].nodePointer[3] = atoi (inLine.inputS.np4) ;
			stree[atoi(inLine.inputS.node)].nodePointer[4] = atoi (inLine.inputS.np5) ;

			if (stree[atoi(inLine.inputS.node)].key[3] != 0 && stree[atoi(inLine.inputS.node)].rowNum[0] == 0) { // Check the row numbers whether they are missing or not
				CloseHandle (hFile) ;
				cout << "Missing row number!" << endl ;
				cout << "<<< CheckLoadTextFile end >>>" << endl ;
				return false ;
			}
			if (stree[atoi(inLine.inputS.node)].key[3] != 0 && stree[atoi(inLine.inputS.node)].rowNum[1] == 0) {
				CloseHandle (hFile) ;
				cout << "Missing row number!" << endl ;
				cout << "<<< CheckLoadTextFile end >>>" << endl ;
				return false ;
			}
			if (stree[atoi(inLine.inputS.node)].key[3] != 0 && stree[atoi(inLine.inputS.node)].rowNum[2] == 0) {
				CloseHandle (hFile) ;
				cout << "Missing row number!" << endl ;
				cout << "<<< CheckLoadTextFile end >>>" << endl ;
				return false ;
			}
			if (stree[atoi(inLine.inputS.node)].key[3] != 0 && stree[atoi(inLine.inputS.node)].rowNum[3] == 0) {
				CloseHandle (hFile) ;
				cout << "Missing row number!" << endl ;
				cout << "<<< CheckLoadTextFile end >>>" << endl ;
				return false ;
			}
		}
		CloseHandle (hFile) ;
		cout << "Shadow tree populated successfully" << endl ;
	}

	if (!CheckSTree ()) {										// Check the shadow tree's consistency
		if (ShadowToReal ()) {
			cout << "<<< CheckLoadTextFile end >>>" << endl ;
			return true ;
		}
		else {
			cout << "<<< CheckLoadTextFile end >>>" << endl ;
			return false ;
		}
	}
	else {
		cout << "<<< CheckLoadTextFile end >>>" << endl ;
		return false ;
	}
}

bool ShadowToReal() {											// Copy everything from the shadow structure over to the real one
	int i, j ;

	cout << endl << "<<< ShadowToReal start >>>" << endl ;
	cout << "*** Copying shadow tree into the real, internal one following load from file ***" << endl ;
	memset (tree, 0, sizeof (tree))	;							// Set everything to zero
	memset (btree, false, sizeof (btree)) ;
	EraseChangeTypes () ;

	rootNodeIndex = srootNodeIndex ;							// Key info first
	nodeCount = snodeCount ;
	nodeHWM = snodeHWM ;

	for (i = 0 ; i < NODES ; i ++) {
		for (j = 0 ; j < MAX_KEYS ; j ++) {
			tree[i].key[j] = stree[i].key[j] ;					// Keys
			tree[i].rowNum[j] = stree[i].rowNum[j] ;			// row numbers
			tree[i].nodePointer[j] = stree[i].nodePointer[j] ;	// Node pointers
		}
		tree[i].nodePointer[j] = stree[i].nodePointer[j] ;		// Last node pointer
		tree[i].count = stree[i].count ;						// Count
		tree[i].prntNodePointer = stree[i].prntNodePointer ;	// Parent node pointer
		btree[i] = sbtree[i] ;									// Free list tracker
	}

	cout << "<<< ShadowToReal end >>>" << endl ;
	return true ;
}

bool CheckSTree () {											// Checks if the internal node structure of the shadow tree is consistent (healthy). Returns true if not
	int  i, j, k ;

	cout << endl << "<<< CheckSTree start >>>" << endl ;
	cout << "*** Checking the consistency of the shadow btree ***" << endl ;

	for (i = 0 ; i < nodeHWM ; i ++) {							// For each node
		if (stree[i].key[0] == 0) {
			continue ;											// This node is empty, skip it. Probably it has become empty during a merge
		}
		for (j = 0 ; j < stree[i].count ; j ++) {				// For each key in the node
			if (stree[i].key[j] >= stree[i].key[j + 1] && j < stree[i].count - 1) { // Each key within a node must be less than the subsequent one
				cout << "Node " << i << " key " << j << " (" << stree[i].key[j] << ") is greater than next key (" << stree[i].key[j + 1] << ")" << endl ;
				cout << "<<< CheckSTree end >>>" << endl ;
				return true ;
			}
			else {
				if (stree[i].nodePointer[j] != -1) {			// Check if all children keys are less than this key
					for (k = 0 ; k < stree[stree[i].nodePointer[j]].count ; k ++) {
						if (stree[stree[i].nodePointer[j]].key[k] >= stree[i].key[j]) {
							cout << "Node " << i << " key " << k << " (" << stree[stree[i].nodePointer[j]].key[k] << ") is greater than the parent key (" << tree[i].key[j] << ")" << endl ;
							cout << "<<< CheckSTree end >>>" << endl ;
							return true ;
						}
					}
					if (stree[stree[i].nodePointer[j]].prntNodePointer != i) { // Check if the parent of this child node is truly the parent node
						cout << "Node " << i << " is not the parent of the child node " << stree[i].nodePointer[j] << endl;
						cout << "<<< CheckSTree end >>>" << endl ;
						return true ;
					}
				}
			}
		}

		if (stree[i].nodePointer[j] != -1) {					// Check if all children of the last key are greater than the parent key
			for (k = 0 ; k < stree[stree[i].nodePointer[j]].count ; k ++) {
				if (stree[stree[i].nodePointer[j]].key[k] <= stree[i].key[j - 1]) {
					cout << "Node " << stree[i].nodePointer[j] << " key " << stree[stree[i].nodePointer[j]].key[k] << " is less than the parent key (" << tree[i].key[j - 1] << ")" << endl ;
					cout << "<<< CheckSTree end >>>" << endl ;
					return true ;
				}
			}
			if (stree[stree[i].nodePointer[j]].prntNodePointer != i) { // Check if the parent of this last child node is truly the parent node
				cout << "Node " << i << " is not the parent of child node " << stree[i].nodePointer[j] << ". Parent node index: " << tree[tree[i].nodePointer[j]].prntNodePointer << endl ;
				cout << "<<< CheckSTree end >>>" << endl ;
				return true ;
			}
		}

		int cnt = 0 ;
		for (k = 0 ; k < TREE_ORDER - 1 ; k ++) {				// Check if the count is correct. Equals to the actual number of keys
			if (stree[i].key[k] > 0) {
				cnt ++ ;
			}
			else {												// If key is zero, we are done
				break ;
			}
		}
		if (stree[i].count != cnt) {							// Compare node count and actual count
			cout << "Key count mismatch in node " << i << ". Count: " << stree[i].count << ", actual count of non-zero keys: " << cnt << endl ;
			cout << "<<< CheckSTree end >>>" << endl ;
			return true ;
		}
	}
	
	cout << "The shadow b-tree is healthy!" << endl ;
	cout << "<<< CheckSTree end >>>" << endl ;
	return false ;												// The shadow tree is healthy!
}

// End of source file - BtreeWin.cpp