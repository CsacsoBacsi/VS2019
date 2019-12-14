// SuDoKuWin.h
/* Contains all application-wide extern declarations of handles, callback procedures, global variables, function prototypes
   and multi-lingual string constants. This is the main header file
*/

#include <windows.h>
#include <commctrl.h>
#include <stdio.h>
#include <time.h>
#include <Uxtheme.h>
#include "Resource.h"

// Constants
#define MAXLOGTEXTSIZE 1024 * 1024 * 10						// 10M bytes

// Handles
extern HWND			hDlg ;
extern HWND			hAboutDlg ;
extern HWND			hListViewStart ;
extern HWND			hListViewSolved ;
extern HWND			hProgress ;
extern HWND			hRadioButtonSin ;
extern HWND			hRadioButtonMul ;
extern HWND			hRadioButtonVar ;
extern HWND			hCheckLog ;
extern HWND			hStatusBar ;
extern HWND			hOutput ;
extern HWND			hWndListView ;
extern HWND			hListViewStartHeader ;
extern HWND			hListViewSolvedHeader ;
extern HWND			hOutput ;
extern HWND			hStatusBar ;
extern HWND			hToolbar ;
extern HWND			hToolTipSG ;
extern HWND			hToolTipSS ;
extern HWND			hToolTipMS ;
extern HWND			hToolTipVR ;
extern HWND			hToolTipLO ;
extern HWND			hToolTipLW ;
extern HIMAGELIST	hImgList ;
extern HANDLE		hThread ;

// Colour references
extern COLORREF		logTxtFrgClr ;
extern COLORREF		logTxtBckClr ;
extern COLORREF		logBckClr ;
extern HBRUSH		hLogBrush ;
extern COLORREF		origCellClr ;
extern COLORREF		chgdCellClr ;
extern COLORREF		itemColClr ;
extern COLORREF		subitemEvenColClr ;
extern COLORREF		subitemOddColClr ;
extern COLORREF		gridCellTextClr ;

// Tooltip supporting objects
extern LPTOOLTIPTEXT lpttt ;
extern UINT_PTR		idButton ;

// Listview related objects
extern LPNMLISTVIEW	pnm ;
extern LVHITTESTINFO hti ;
extern NMITEMACTIVATE * ia ;
extern LVITEM		LvItem ;
extern LPNMLVCUSTOMDRAW	lplvcd ;

// Callback function pointers
extern WNDPROC		OrigListViewStartHeaderProc ;
extern WNDPROC		OrigListViewSolvedHeaderProc ;
extern WNDPROC		OrigListViewStartProc ;
extern WNDPROC		OrigListViewSolvedProc ;

// Misc
extern FILE *		stream ;
extern unsigned long ThreadId ;
extern HMENU		hMenu, hSubMenu ;
extern HFONT		hFont, hFont2, hOldFont2 ;

// Global variables
extern unsigned char * gridArea ;
extern unsigned char * prev_gridArea ;
extern unsigned char * pgridArea ;
extern unsigned char * prev_pgridArea ;
extern unsigned char * numsDone ;
extern unsigned char * pnumsDone ;
extern unsigned char * killerGroup ;
extern bool			terminateThread ;
extern bool			working ;
extern long			st_time1, et_time1 ;
extern clock_t		st_time2, et_time2 ;
extern unsigned long long st_time3, et_time3 ;
extern double		t_diff1, t_diff2, t_diff3 ;
extern char			playingNumbers ;
extern unsigned int	killerGroupSum [82] ;
extern bool			gridSolved ;
extern unsigned long recursiveCalls ;
extern unsigned long variations ;
extern unsigned long goodVariations ;
extern unsigned long solvedNTimes ;
extern bool			terminateThread ;
extern char			elapsedSecs[100] ;
extern char			recCalls[100] ;
extern char			buffer[200] ;
extern char			buffer2[200] ;
extern char			buffer3[10] ;
extern unsigned int	logLength ;
extern unsigned int	appendTxtLength ;
extern int			statwidths [] ;
extern TBBUTTON		tbb [13] ;
extern bool			canClose ;
extern bool			enableLogging ;
extern bool			clearLog ;
extern bool			paintOrigNumbers ;
#ifndef _SOLVEMODE_											// ENUMs can only be defined once across all programming units. Use a guard here
#define _SOLVEMODE_
	enum solvemode_t {Single = 0, Multi = 1, Variations = 2} ;
#endif
extern solvemode_t	solveMode ;

// Function prototypes
extern BOOL CALLBACK DialogProc (HWND, UINT, WPARAM, LPARAM) ;
extern BOOL CALLBACK AboutDlgProc (HWND, UINT, WPARAM, LPARAM) ;
extern int			SuDoKuEngine (HWND) ;
unsigned char		recursiveSolve (unsigned char &) ;
extern HWND			CreateListView (HWND, HINSTANCE, int) ;
extern LRESULT		ProcessCustomDrawStartG (LPARAM) ;
extern LRESULT		ProcessCustomDrawSolvedG (LPARAM) ;
extern BOOL			SaveTextFile (char *) ;
extern BOOL			LoadTextFile (char *) ;
extern BOOL			SaveLogFile (HWND, LPCTSTR) ;
extern LRESULT		ListViewStartHeaderProc (HWND, UINT, WPARAM, LPARAM) ;
extern LRESULT		ListViewSolvedHeaderProc (HWND, UINT, WPARAM, LPARAM) ;
extern LRESULT		ListViewStartProc (HWND, UINT, WPARAM, LPARAM) ;
extern unsigned long long getSysTime () ;
extern void			getStartTime () ;
extern void			getEndTime () ;
extern void			printTime () ;
extern void			resetGrid (HWND) ;
extern void			readGrid (HWND) ;
extern void			writeGrid (HWND) ;
extern void			inverseGrid () ;
extern void			changedGrid () ;
extern char *		currentDateTime () ;
extern bool			checkRow (unsigned char &, unsigned char, bool) ;
extern bool			checkCol (unsigned char &, unsigned char, bool) ;
extern bool			checkRegion (unsigned char &, unsigned char, bool) ;
extern bool			checkGroup (unsigned char &, unsigned char) ;
extern char			checkSingleChoice () ;
extern void			printGrid () ;
extern bool			printPartGrid () ;
extern bool			verifyGrid1 () ;
extern bool			verifyGrid2 () ;
extern bool			verifyGrid3 () ;
extern bool			verifyGrid4 () ;
extern bool			verifyGrid5 () ;
extern bool			nextSolution () ;
extern unsigned long long getSysTime () ;
extern void			AppendText (TCHAR *) ;
extern void			mprintf (char *) ;
extern char *		currentDateTime () ;
extern void			changeLang () ;
extern void			createToolbar () ;
extern void			createStartingGridTooltip () ;
extern void			createSingleSolveTooltip () ;
extern void			createMultiSolveTooltip () ;
extern void			createVariationsTooltip () ;
extern void			createLoggingTooltip () ;
extern void			createLogWinTooltip () ;
extern void			resetLog () ;

// Multi-lingual strings
#ifndef _LANGUAGE_
#define _LANGUAGE_
	enum language_t {English = 0, Magyar = 1} ;
#endif
extern language_t	langCode ;
extern char *		szDialogCaption [] ;
extern char *		szLogHeader1 [] ;
extern char *		szLogHeader2 [] ;
extern char *		szLogHeader3 [] ;
extern char *		szLanguage [] ;
extern char *		szLogDateTime [] ;
extern char *		szSingleSolveMode [] ;
extern char *		szMultiSolveMode [] ;
extern char *		szVariationsOnlyMode [] ;
extern char *		szVariationsCells [] ;
extern char *		szEnableLogging [] ;
extern char *		szGridValidationCheck [] ;
extern char *		szCells2And9[] ;
extern char *		szInvalidNoCells[] ;
extern char *		szGridIsValid[] ;
extern char *		szSolvingGrid[] ;
extern char *		szGridIsInvalid[] ;
extern char *		szGridIsInvalidMsg[] ;
extern char *		szGridIsInvalidSMsg[] ;
extern char *		szStartingGrid[] ;
extern char *		szThreadTermin[] ;
extern char *		szNumVariations [] ;
extern char *		szNumValidVariations [] ;
extern char *		szElapsedSecs [] ;
extern char *		szRecursiveCalls [] ;
extern char *		szGridCantSolved [] ;
extern char *		szNoRecCalls [] ;
extern char *		szSolvedGrid [] ;
extern char *		szElapsedSecs2 [] ;
extern char *		szNoRecCalls2 [] ;
extern char *		szNoRecCalls3 [] ;
extern char *		szNoRecCalls4 [] ;
extern char *		szVerification1 [] ;
extern char *		szVerification2 [] ;
extern char *		szVerification3 [] ;
extern char *		szVerification4 [] ;
extern char *		szVerification1OK [] ;
extern char *		szVerification1FD [] ;
extern char *		szVerification2OK [] ;
extern char *		szVerification2FD [] ;
extern char *		szVerification3OK [] ;
extern char *		szVerification3FD [] ;
extern char *		szVerification4OK [] ;
extern char *		szVerification4FD [] ;
extern char *		szNoMoreSolution [] ;
extern char *		szUnknownOutcome [] ;
extern char *		szClearButton [] ;
extern char *		szSolveButton [] ;
extern char *		szStopButton [] ;
extern char *		szNextButton [] ;
extern char *		szCloseButton [] ;
extern char *		szClearLogButton [] ;
extern char *		szSingleSolveButton [] ;
extern char *		szMultiSolveButton [] ;
extern char *		szVariationsButton [] ;
extern char *		szStaticSolved [] ;
extern char *		szStaticStart [] ;
extern char *		szStaticOptions [] ;
extern char *		szStaticCells [] ;
extern char *		szStaticLog [] ;
extern char *		szThreadFStart [] ;
extern char *		szThreadFStartMsg [] ;
extern char *		szError [] ;
extern char *		szSuccess [] ;
extern char *		szThreadFResume [] ;
extern char *		szThreadFResumeMsg [] ;
extern char *		szGridSavedMsg [] ;
extern char *		szGridFSavedMsg [] ;
extern char *		szGridLoadedMsg [] ;
extern char *		szGridFLoadedMsg [] ;
extern char *		szLogSavedMsg [] ;
extern char *		szLogFSavedMsg [] ;
extern char *		szQuitMsg [] ;
extern char *		szQuitCMsg [] ;
extern char *		szSolvedNTimes [] ;
extern char *		szTimeTicks [] ;
extern char *		szTimeClocks [] ;
extern char *		szTimeSystem [] ;
extern char *		szTimeAverage [] ;
extern char *		szToolbarSave [] ;
extern char *		szToolbarLoad [] ;
extern char *		szToolbarLog [] ;
extern char *		szToolbarClear [] ;
extern char *		szToolbarSolve [] ;
extern char *		szToolbarStop [] ;
extern char *		szToolbarNext [] ;
extern char *		szToolbarHunFlag [] ;
extern char *		szToolbarEngFlag [] ;
extern char *		szToolbarExit [] ;
extern char *		szSGTooltip [] ;
extern char *		szSSTooltip [] ;
extern char *		szMSTooltip [] ;
extern char *		szVRTooltip [] ;
extern char *		szLOTooltip [] ;
extern char *		szLWTooltip [] ;

// End of source file - SuDoKuwin.h