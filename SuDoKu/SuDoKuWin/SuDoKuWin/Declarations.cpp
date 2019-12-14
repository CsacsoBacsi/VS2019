// Declarations.cpp
/* Contains all application-wide declarations of handles, callback procedures, global variables, function prototypes
   and multi-lingual string constants
*/

#include "SuDoKuWin.h"

// Handles
// A HANDLE is a handle to an object. HWND is a handle to a window. HWND is a HANDLE, but not all HANDLEs are HWNDs
HWND			hDlg = NULL ;						// Main dialog handle
HWND			hAboutDlg = NULL ;					// About dialog handle
HWND			hListViewStart = NULL ;				// Starting grid (list view) handle
HWND			hListViewSolved = NULL ;			// Solved grid (list view) handle
HWND			hProgress = NULL ;					// Progress bar handle
HWND			hRadioButtonSin = NULL ;			// Single-solve mode radio button handle
HWND			hRadioButtonMul = NULL ;			// Multi-solve mode radio button handle
HWND			hRadioButtonVar = NULL ;			// Variations only mode radio button handle
HWND			hCheckLog = NULL ;					// Logging enabling/disabling radio button handle
HWND			hWndListView = NULL ;				// Generic list view handle
HWND			hListViewStartHeader = NULL ;		// Starting grid (list view header) handle
HWND			hListViewSolvedHeader = NULL ;		// Solved grid (list view header) handle
HWND			hOutput = NULL ;					// Log edit control handle
HWND			hStatusBar = NULL ;					// Status bar handle
HWND			hToolbar = NULL ;					// Toolbar handle
HWND			hToolTipSG = NULL ;					// Starting grid tooltip handle
HWND			hToolTipSS = NULL ;					// Single-solve radio button tooltip handle
HWND			hToolTipMS = NULL ;					// Multi-solve radio button tooltip handle
HWND			hToolTipVR = NULL ;					// Variations only radio button tooltip handle
HWND			hToolTipLO = NULL ;					// Logging enabling/disabling radio button tooltip handle
HWND			hToolTipLW = NULL ;					// Logging (edit control) window tooltip handle
HIMAGELIST		hImgList = NULL ;					// Toolbar image list handle
HANDLE			hThread = NULL ;					// SuDoKu engine thread handle

// Colour references
COLORREF		logTxtFrgClr = RGB (0, 0, 0) ;		// Log window text foreground (text) colour
COLORREF		logTxtBckClr = RGB (204, 204, 255) ; // Log window text background colour
COLORREF		logBckClr = RGB (204, 204, 255) ;	// Log window background colour
HBRUSH			hLogBrush = NULL ;					// Log window background colour brush
COLORREF		origCellClr = RGB (0, 180, 0) ;		// Starting grid original filled in cells' colour
COLORREF		chgdCellClr = RGB (255, 0, 0) ;		// During multi-solve mode, the colour of the changed cells (compared to previous solution)
COLORREF		itemColClr = RGB (235, 235, 235) ;	// Grid item colour (first or 0th sub-item)
COLORREF		subitemEvenColClr = RGB (230, 230, 230) ;// Grid every even subitem (column) colour
COLORREF		subitemOddColClr = RGB (255, 255, 255) ;// Grid every odd subitem (column) colour
COLORREF		gridCellTextClr = RGB (0, 0, 0) ;	// Grid cell text (foreground) colour

// Tooltip supporting objects
LPTOOLTIPTEXT	lpttt ;								// Structure to be used for sending info to the toolbar
UINT_PTR		idButton ;							// The toolbar button that should display the tooltip

// Listview related objects
LPNMLISTVIEW	pnm ;								// NMLISTVIEW is a structure. The first member is NMHDR that has the notification code hwndFrom, idFrom, code
LVHITTESTINFO	hti ;								// Helps identify the cell in the list view (original grid) where the user clicked
NMITEMACTIVATE	* ia ;								// Holds coordinates of the mouse click
LVITEM			LvItem ;							// List view item structure to send and receive grid cell info
LPNMLVCUSTOMDRAW lplvcd ;							// Custome draw helper structure

// Callback function pointers
WNDPROC			OrigListViewStartHeaderProc ;
WNDPROC			OrigListViewSolvedHeaderProc ;
WNDPROC			OrigListViewStartProc ;
WNDPROC			OrigListViewSolvedProc ;

// Misc
FILE *			stream ;							// Handle used for saving/loading the grid and saving the log
unsigned long	ThreadId ;							// The internal ID of the sudoku solver thread
HMENU			hMenu = NULL, hSubMenu = NULL ;		// Menu handles
HFONT			hFont = NULL ;						// Font handle used in the log window
HFONT			hFont2 = NULL, hOldFont2 = NULL ;	// Font handle used to mark the original numbers in the solved grid

// Global variables
unsigned char * gridArea ;							// Grid area. 81 numbers + first char (0) is not used
unsigned char * prev_gridArea ;						// The previous grid area. Used in multi-solve mode to detect what has changed
unsigned char * pgridArea ;							// Pointer that points at the first grid cell (for easier debugging)
unsigned char * prev_pgridArea ;					// Pointer that points at the first grid cell (for easier debugging)
unsigned char * numsDone ;							// Registers how many of each number (1-9) are still available
unsigned char * pnumsDone ;							// Pointer that points at the first used number array (for easier debugging)
unsigned char * killerGroup ;						// Array of killer groups
unsigned int	killerGroupSum [82] ;				// Group number (array index), sum value of the cells in the group (first char not used)
bool			terminateThread ;					// True indicates that the user pressed the Stop button to interrupt the engine thread
bool			working ;							// Indicates that the engine is busy. Used to disable editing of the starting grid while running
long			st_time1, et_time1 ;				// Three different times to calc elapsed time (start and end times). Ticks
clock_t			st_time2, et_time2 ;				// Clock time
unsigned long long st_time3, et_time3 ;				// Sys time
double			t_diff1, t_diff2, t_diff3 ;			// Three different time differences (end time - start time)
bool			gridSolved ;						// Set to true if the grid is solved
unsigned long	recursiveCalls ;					// Number of recursive calls to solve the grid
unsigned long	variations ;						// Number of all variations
unsigned long	goodVariations ;					// Number of valid variations
solvemode_t		solveMode = Single ;				// Solve mode: Single, Multi or Variations
char			playingNumbers ;					// Number of playing numbers (starting with 1 up to 81)
unsigned long	solvedNTimes ;						// If multisolve set to true then the number of possible solutions so far
char			elapsedSecs[100] ;					// Helper char array to populate the status bar's elapsed seconds
char			recCalls[100] ;						// Helper char array to populate the status bar's number of recursive calls
char			buffer[200] ;						// Helper char array to support wsprintf string operation
char			buffer2[200] ;						// Helper char array to support wsprintf string operation with current date and time
char			buffer3[10] ;						// Helper char array to display variations in variations only mode
unsigned int	logLength ;							// Stores thee current length of the log window text
unsigned int	appendTxtLength ;					// Length of the string to be appended to the log window text
int				statwidths [] = {150, 320, -1} ;	// Cummulative widths! Not individual! The second status bar section is 170 pixel wide. -1 means take the rest
TBBUTTON		tbb [13] ;							// Array of toolbar buttons
bool			canClose ;							// Indicates whether the dialog can close by clicking on the "X" in the top right corner
bool			enableLogging ;						// Logging enabled/disabled flag
bool			clearLog ;							// Indicates that the user clicked on the clear log button
bool			paintOrigNumbers ;					// Tells the WM_PAINT message handler when the original grid numbers should be painted over the solution grid

// Function prototypes
BOOL CALLBACK	DialogProc (HWND, UINT, WPARAM, LPARAM) ;
BOOL CALLBACK	AboutDlgProc (HWND, UINT, WPARAM, LPARAM) ;
int				SuDoKuEngine (HWND) ;
unsigned char	recursiveSolve (unsigned char &) ;
HWND			CreateListView (HWND, HINSTANCE, int) ;
LRESULT			ProcessCustomDrawStartG (LPARAM) ;
LRESULT			ProcessCustomDrawSolvedG (LPARAM) ;
BOOL			SaveTextFile (char *) ;
BOOL			LoadTextFile (char *) ;
BOOL			SaveLogFile (HWND, LPCTSTR) ;
LRESULT			ListViewStartHeaderProc (HWND, UINT, WPARAM, LPARAM) ;
LRESULT			ListViewSolvedHeaderProc (HWND, UINT, WPARAM, LPARAM) ;
LRESULT			ListViewStartProc (HWND, UINT, WPARAM, LPARAM) ;
unsigned long long getSysTime () ;
void			getStartTime () ;
void			getEndTime () ;
void			printTime () ;
void			resetGrid (HWND) ;
void			readGrid (HWND) ;
void			writeGrid (HWND) ;
void			inverseGrid () ;
void			changedGrid () ;
char *			currentDateTime () ;
bool			checkRow (unsigned char &, unsigned char, bool) ;
bool			checkCol (unsigned char &, unsigned char, bool) ;
bool			checkRegion (unsigned char &, unsigned char, bool) ;
bool			checkGroup (unsigned char &, unsigned char) ;
char			checkSingleChoice () ;
void			printGrid () ;
bool			printPartGrid () ;
bool			verifyGrid1 () ;
bool			verifyGrid2 () ;
bool			verifyGrid3 () ;
bool			verifyGrid4 () ;
bool			verifyGrid5 () ;
bool			nextSolution () ;
unsigned long long getSysTime () ;
void			AppendText (TCHAR *) ;
void			mprintf (char *) ;
char *			currentDateTime () ;
void			createToolbar () ;
void			createStartingGridTooltip () ;
void			createSingleSolveTooltip () ;
void			createMultiSolveTooltip () ;
void			createVariationsTooltip () ;
void			createLoggingTooltip () ;
void			createLogWinTooltip () ;
void			resetLog () ;

// Multi-lingual strings
language_t		langCode = English ;				// Language code (enum type) (English or Magyar)
char *			szDialogCaption [] {"SuDoKu solver", "SuDoKu megoldó"} ;
char *			szLogHeader1 [] {"******************** SuDoKu Solver log ************************\r\n",
                                 "******************* SuDoKu megoldó napló **********************\r\n"} ;
char *			szLogHeader2 [] {"******* Application using brute force and backtracking ********\r\n",
                                 "******* A program próbálgatást és visszalépést használ ********\r\n"} ;
char *			szLogHeader3 [] {"*** Copyright (c) 2016 Csacso software, All rights reserved ***\r\n",
                                 "** Copyright (c) 2016 Csacsó szoftver, Minden jog fenntartva **\r\n"} ;
char *			szLanguage [] {"\r\nLanguage: English", "\r\nNyelv: Magyar"} ;
char *			szLogDateTime [] {"Log date & time: %s\r\n", "Log dátum és idö: %s\r\n"} ;
char *			szSingleSolveMode [] {"Single-solve mode.\r\n", "Egy megoldású mód.\r\n"} ;
char *			szMultiSolveMode [] {"Multi-solve mode.\r\n", "Több megoldású mód.\r\n"} ;
char *			szVariationsOnlyMode [] {"Variations only mode.\r\n", "Csak variációk mód\r\n"} ;
char *			szVariationsCells [] {"Getting the variations for %d cells...\r\n", "Variációk keresése %d cellára...\r\n"} ;
char *			szEnableLogging [] {"Enable logging", "Napló engedélyezése"} ;
char *			szGridValidationCheck [] {"Checking grid validity...\r\n", "A rács ellenörzése...\r\n"} ;
char *			szCells2And9[] {"The number of cells must be between 2 and 9!", "A cellaszámnak 2 és 9 között kell lennie!"} ;
char *			szInvalidNoCells[] {"Invalid number of cells", "Hibás megadott cellaszám"} ;
char *			szGridIsValid[] {"The grid is valid.\r\n", "A rács rendben.\r\n"} ;
char *			szSolvingGrid[] {"Solving the grid...\r\n", "Dolgozom a rácson...\r\n"} ;
char *			szGridIsInvalid[] {"The grid is invalid, please check the initial values!\r\n", "A rács hibás, ellenörizze a beírt számokat!"} ;
char *			szGridIsInvalidMsg[] {"The grid is invalid, please check the initial values!\r\n", "A rács hibás, ellenörizze a beírt számokat!"} ;
char *			szGridIsInvalidSMsg[] {"Invalid grid", "Hibás rács"} ;
char *			szStartingGrid[] {"Starting grid:\r\n\r\n", "Kezdö rács:\r\n\r\n"} ;
char *			szThreadTermin[] {"User terminated the solver thread.\r\n", "A felhasználó megszakította a megoldó rutint.\r\n"} ;
char *			szNumVariations [] {"Number of variations to solve the grid: %d\r\n", "A variációk száma a rács megoldásához: %d\r\n"} ;
char *			szNumValidVariations [] {"Valid variations                      : %d\r\n", "Helyes variációk                     : %d\r\n"} ;
char *			szElapsedSecs [] {"       Elapsed secs:",
                                  "       Eltelt msp:  "} ;
char *			szRecursiveCalls [] {"Recursive calls:",
                                     "Rekurzív hívasok:"} ;
char *			szGridCantSolved [] {"Grid could not be solved.\r\n", "A rácsnak nincs megoldása.\r\n"} ;
char *			szNoRecCalls [] {"Number of recursive calls tried to solve the grid: %ld", "A rács megoldásához használt rekurzív hívások: %ld"} ;
char *			szSolvedGrid [] {"\nSolved grid:\r\n\r\n", "\nMegoldott rács:\r\n\r\n"} ;
char *			szElapsedSecs2 [] {"       Elapsed secs: %.6f",
                                   "       Eltelt msp: %.6f  "} ;
char *			szNoRecCalls2 [] {"Recursive calls: %d",
                                  "Rekurzív hívások: %d"} ;
char *			szNoRecCalls3 [] {"Number of recursive calls to solve the grid: %ld", "A rács megoldásához használt rekurzív hívások: %ld"} ;
char *			szNoRecCalls4 [] {"%s: Recursive call #%d...\r\n", "%s: Rekurzív hívások %d...\r\n"} ;
char *			szVerification1 [] {"Grid verification 1: ", "Rács ellenörzés 1: "} ;
char *			szVerification2 [] {"Grid verification 2: ", "Rács ellenörzés 2: "} ;
char *			szVerification3 [] {"Grid verification 3: ", "Rács ellenörzés 3: "} ;
char *			szVerification4 [] {"Grid verification 4: ", "Rács ellenörzés 4: "} ;
char *			szVerification1OK [] {"OK. All numbers (from 1 to 9) used\r\n", "OK. Az összes szám (1-töl 9-ig) szerepel\r\n"} ;
char *			szVerification1FD [] {"FAILED. Not all numbers (from 1 to 9) used.\r\n", "HIBA. Nem szerepel az összes szám (1-töl 9-ig).\r\n"} ;
char *			szVerification2OK [] {"OK. All rows have unique numbers\r\n", "OK. Minden sorban a számok csak egyszer szerepelnek\r\n"} ;
char *			szVerification2FD [] {"FAILED. Not all rows contain unique numbers.\r\n", "HIBA. Nem minden sorban szerepelnek a számok csak egyszer\r\n"} ;
char *			szVerification3OK [] {"OK. All columns have unique numbers\r\n", "OK. Minden oszlopan a számok csak egyszer szerepelnek.\r\n"} ;
char *			szVerification3FD [] {"FAILED. Not all columns contain unique numbers\r\n", "HIBA. Nem minden oszlopban szerepelnek a számok csak egyszer\r\n"} ;
char *			szVerification4OK [] {"OK. The sum of all grid cell values is 405\r\n\n", "OK. Az összes cellában lévö számok összege 405\r\n\n"} ;
char *			szVerification4FD [] {"FAILED. The sum of all grid cell values is not 405\r\n\n", "HIBA. Az összes cellában lévö számok összege nem 405\r\n\n"} ;
char *			szNoMoreSolution [] {"No more possible solutions found.\r\n", "Több megoldás nem található.\r\n"} ;
char *			szUnknownOutcome [] {"Unknown outcome.\r\n", "Nem értelmezhetö kimenetel."} ;
char *			szClearButton [] {"Clear","Töröl"} ;
char *			szSolveButton [] {"Solve","Megold"} ;
char *			szStopButton [] {"Stop","Leállít"} ;
char *			szNextButton [] {"Next","Következö"} ;
char *			szCloseButton [] {"Close","Bezár"} ;
char *			szClearLogButton [] {"Clear log","Napló törlése"} ;
char *			szSingleSolveButton [] {"Single-solve mode","Egy megoldású mód"} ;
char *			szMultiSolveButton [] {"Multi-solve mode","Több megoldású mód"} ;
char *			szVariationsButton [] {"Variations mode","Variációk mód"} ;
char *			szStaticSolved [] {"Solved grid", "Megoldott rács"} ;
char *			szStaticStart [] {"Starting grid", "Kezdö rács"} ;
char *			szStaticOptions [] {"Options", "Opciók"} ;
char *			szStaticCells [] {"cells", "cella"} ;
char *			szStaticLog [] {"Application log", "Napló"} ;
char *			szThreadFStart [] {"SuDoKu engine thread %d failed to start!\r\n", "A SuDoKu megoldó motor %d nem tudott elindulni!\r\n"} ;
char *			szThreadFStartMsg [] {"SuDoKu engine thread failed to start!", "A SuDoKu megoldó motor nem tudott elindulni!"} ;
char *			szError [] {"Error", "Hiba"} ;
char *			szSuccess [] {"Success", "Siker"} ;
char *			szThreadFResume [] {"The SuDoKu engine thread %d failed to resume!\r\n", "A SuDoKu megoldó motor %d nem tudott ujraindulni!\r\n"} ;
char *			szThreadFResumeMsg [] {"The SuDoKu engine thread failed to resume!", "A SuDoKu megoldó motor nem tudott ujraindulni!"} ;
char *			szGridSavedMsg [] {"Grid saved successfully!", "A rács sikeresen el lett mentve!"} ;
char *			szGridFSavedMsg [] {"Grid could not be saved!", "A rácsot nem sikerült elmenteni!"} ;
char *			szGridLoadedMsg [] {"Grid loaded successfully!", "A rács sikeresen be lett töltve!"} ;
char *			szGridFLoadedMsg [] {"Grid could not be loaded!", "A rácsot nem sikerült be tölteni!"} ;
char *			szLogSavedMsg [] {"Log saved successfully!", "A napló sikeresen el lett mentve!"} ;
char *			szLogFSavedMsg [] {"Log could not be saved!", "A naplót nem sikerült elmenteni!"} ;
char *			szQuitMsg [] {"Are you sure you want to quit?", "Biztos hogy ki szeretne lépni?"} ;
char *			szQuitCMsg [] {"Exit application", "Kilépés a programból"} ;
char *			szSolvedNTimes [] {"Solved grid #%d:\r\n\n", "A rács %d. megoldása:\r\n\n"} ;
char *			szTimeTicks [] {"Time (ticks) taken to resolve in seconds : %0.6f\r\n",
                                "A megoldáshoz eltelt idö (ütem) msp-ben  : %0.6f\r\n"} ;
char *			szTimeClocks [] {"Time (clock) taken to resolve in seconds : %0.6f\r\n",
                                 "A megoldáshoz eltelt idö (óra) msp-ben   : %0.6f\r\n"} ;
char *			szTimeSystem [] {"Time (systm) taken to resolve in seconds : %0.6f\r\n",
                                 "A megoldáshoz eltelt idö (rendsz) msp-ben: %0.6f\r\n"} ;
char *			szTimeAverage [] {"Time (avrge) taken to resolve in seconds : %0.6f\r\n\n",
                                  "A megoldáshoz eltelt idö (átlag) msp-ben : %0.6f\r\n"} ;
char *			szToolbarSave [] {"Save grid", "Rács mentése"} ;
char *			szToolbarLoad [] {"Load grid", "Rács betöltése"} ;
char *			szToolbarLog [] {"Save log", "Napló mentése"} ;
char *			szToolbarExit [] {"Exit", "Kilépés"} ;
char *			szToolbarHunFlag [] {"Hungarian", "Magyar"} ;
char *			szToolbarEngFlag [] {"English", "Angol"} ;
char *			szToolbarClear [] {"Clear","Töröl"} ;
char *			szToolbarSolve [] {"Solve","Megold"} ;
char *			szToolbarStop [] {"Stop","Megállít"} ;
char *			szToolbarNext [] {"Next","Következö"} ;
char *			szSGTooltip [] {"Left click - Up\r\nRight click - Down\r\nDouble click - Clear",
                                "Bal gomb - Növel\r\nJobb gomb - Csökkent\r\nDupla katt - Töröl"} ;
char *			szSSTooltip [] {"Solve the grid once", "A rács egyszeri megoldása"} ;
char *			szMSTooltip [] {"Try solving the grid multiple times in multiple steps", "A rács többszöri megoldásának megpróbálása lépésenként"} ;
char *			szVRTooltip [] {"List the possible variations for a given number of cells", "A lehetséges variációk listája adott cella számra"} ;
char *			szLOTooltip [] {"Enable/disable sending messages to the log window","Engedélyezi/tiltja a napló üzeneteket"} ;
char *			szLWTooltip [] {"Max. 10M chars. If exceeded, first 1K gets erased","Max. 10M karakter. Túllépés esetén az elsö 1K törlödik"} ;

// End of source file - Declarations.cpp