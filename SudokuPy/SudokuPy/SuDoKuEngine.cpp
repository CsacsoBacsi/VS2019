// SuDoKuEngine.cpp
//
/*SuDoKu solving using Backtracking or Trial and Error
  When all else fails, there is one technique that is guaranteed to always work, indeed you can solve any Sudoku puzzle just using just this one strategy alone.
  You just work logically through all the possible alternatives in every square in order until you find the allocations that work out. If you choose a wrong
  option at some stage later you will find a logical inconsistency and have to go back, undoing all allocations and then trying another option. Because there
  are so many alternatives (billions) you won't want to use it too often. You start with a square and choose one number from the available possibilities. This
  is a completely different type of strategy as it uses 'brute force' rather than 'logic'. It is a contentious Sudoku solving technique but computers have the
  power to do this in milliseconds.
*/

#include "SuDoKuWin.h"

// Entry point of the main SuDoKu solver engine. Calls the recursive engine and kicks off "brute force" and "backtracking"
int SuDoKuEngine (HWND hDlg)
{
	unsigned char i ;										// Loop variable
	unsigned char x ;										// Grid coordinate
	char retVal ;											// Return value from the recursive function

	// Initialization section
	terminateThread = false ;								// As a default, do not terminate the thread
	*gridArea = -1 ;										// Init unused first index value in the grid area
	*numsDone = 0 ;											// Init unused first array member
	x = 1;													// First grid cell
	for (i = 1; i < 10; i ++) {								// Set the count of unused numbers to an initial 9
		*(numsDone + i) = 9 ;
	}
	gridSolved = false ;									// The grid is not solved yet
	recursiveCalls = 0l ;									// Number of recursive calls going forward during "brute force"
	variations = 0l ;										// All variations tried
	goodVariations = 0l ;									// Only the possible variations
	
	int ret = SendMessage (hRadioButtonVar, BM_GETCHECK, 0, 0) ; // Check if variations only mode selected
	switch (ret) {
		case BST_CHECKED:
		{
			solveMode = Variations ;
			EnableWindow (GetDlgItem (hDlg, IDC_EDIT_NUMS), true) ; // Enable the number of cells edit box
			char buff[2] ;											// Buffer to accommodate the edit box text (plus a terminating zero)
			buff[1] = 0 ;
			SendMessage (GetDlgItem (hDlg, IDC_EDIT_NUMS), WM_GETTEXT, 2, (LPARAM) buff) ;
			playingNumbers = (char) atoi (buff) ;					// Set the number of cells (or playing numbers) that get involved in this solve
			if (playingNumbers > 9 || playingNumbers < 2) {
				EnableWindow (GetDlgItem (hDlg, IDC_BUTTON_CLEAR), true) ;
				EnableWindow (GetDlgItem (hDlg, IDC_BUTTON_SOLVE), true) ;
				EnableWindow (GetDlgItem (hDlg, IDC_BUTTON_STOP), false) ;
				EnableWindow (GetDlgItem (hDlg, IDC_BUTTON_CLEAR_LOG), true) ;
				ShowWindow (hProgress, SW_HIDE) ;
				EnableWindow (GetDlgItem (hDlg, IDC_RADIO_MULTISOLVE), true) ;
				EnableWindow (GetDlgItem (hDlg, IDC_RADIO_SINGLESOLVE), true) ;
				EnableWindow (GetDlgItem (hDlg, IDC_RADIO_VARIATIONS), true) ;
				EnableMenuItem (hMenu, ID_MENU_FILE_LOADGRID, MF_BYCOMMAND | MF_ENABLED) ;
				EnableMenuItem (hMenu, ID_MENU_FILE_EXIT, MF_BYCOMMAND | MF_ENABLED) ;
				SendMessage (hToolbar, TB_ENABLEBUTTON, IDC_TOOLBAR_CLEAR, true) ;
				SendMessage (hToolbar, TB_ENABLEBUTTON, IDC_TOOLBAR_SOLVE, true) ;
				SendMessage (hToolbar, TB_ENABLEBUTTON, IDC_TOOLBAR_STOP, false) ;

				MessageBoxA (hDlg, szCells2And9[langCode], szInvalidNoCells[langCode], MB_OK | MB_ICONEXCLAMATION | MB_APPLMODAL) ;
				return -1 ;
			}
		}
		break ;
		case BST_INDETERMINATE:
		{
			playingNumbers = 9 ;							// Default is all numbers from 1 to 9
			EnableWindow (GetDlgItem (hDlg, IDC_EDIT_NUMS), false) ;
		}
		break ;
		case BST_UNCHECKED:
		{
			playingNumbers = 9 ;
			EnableWindow (GetDlgItem (hDlg, IDC_EDIT_NUMS), false) ;
		}
	}
	solvedNTimes = 0 ;										// during multi-solve, it counts the number of solutions of the grid
	working = true ;
	canClose = false ;

	SendMessage (hStatusBar, SB_SETPARTS, (WPARAM) 3, (LPARAM) statwidths) ; // 3 = sizeof(statwidths) / sizeof(int)
	SendMessage (hStatusBar, SB_SETTEXT, (WPARAM) 0, (LPARAM) szElapsedSecs[langCode]) ;
	SendMessage (hStatusBar, SB_SETTEXT, (WPARAM) 1, (LPARAM) szRecursiveCalls[langCode]) ;
	SendMessage (hStatusBar, SB_SETTEXT, (WPARAM) 2, (LPARAM) "") ;

	mprintf ("\r\n\r\n") ;
	wsprintf (buffer, szLogDateTime[langCode], currentDateTime ()) ;
	mprintf (buffer) ;
	mprintf ("\r\n") ;

	if (solveMode != Variations) {
		hRadioButtonMul = GetDlgItem (hDlg, IDC_RADIO_MULTISOLVE) ; // Handle to the dialog box that contains the control, the identifier of the control
		ret = SendMessage (hRadioButtonMul, BM_GETCHECK, 0, 0) ;
		switch (ret)
		{
			case BST_CHECKED:
				mprintf (szMultiSolveMode[langCode]) ;
				solveMode = Multi ;
				break;
			case BST_INDETERMINATE:
				mprintf (szSingleSolveMode[langCode]) ;
				break;
			case BST_UNCHECKED:
				mprintf (szSingleSolveMode[langCode]) ;
				break ;
		}
	}
	else {
		mprintf (szVariationsOnlyMode[langCode]) ;
		wsprintf (buffer, szVariationsCells[langCode], (int) playingNumbers) ;
		mprintf (buffer) ;
		resetGrid (hListViewStart) ;
	}

	resetGrid (hListViewSolved) ;							// Initialize the resulting grid
	getStartTime () ;										// Stopper start!
	
	readGrid (hListViewStart) ;								// Read the initial (setup) grid and populate the internally allocated array pgridArea
	if (solveMode != Variations) {
		mprintf (szGridValidationCheck[langCode]) ;
		if (verifyGrid5 ()) {								// Verify the grid set up by the user
			mprintf (szGridIsValid[langCode]) ;
			mprintf (szSolvingGrid[langCode]) ;
		}
		else {												// Invalid grid! Reset everything
			ShowWindow (hProgress, SW_HIDE) ;
			EnableWindow (GetDlgItem (hDlg, IDC_BUTTON_CLEAR), true) ;
			EnableWindow (GetDlgItem (hDlg, IDC_BUTTON_SOLVE), true) ;
			EnableWindow (GetDlgItem (hDlg, IDC_BUTTON_STOP), false) ;
			EnableWindow (GetDlgItem (hDlg, IDC_BUTTON_CLOSE), true) ;
			EnableWindow (GetDlgItem (hDlg, IDC_BUTTON_CLEAR_LOG), true) ;
			EnableWindow (GetDlgItem (hDlg, IDC_RADIO_MULTISOLVE), true) ;
			EnableWindow (GetDlgItem (hDlg, IDC_RADIO_SINGLESOLVE), true) ;
			EnableWindow (GetDlgItem (hDlg, IDC_RADIO_VARIATIONS), true) ;
			EnableMenuItem (hMenu, ID_MENU_FILE_LOADGRID, MF_BYCOMMAND | MF_ENABLED) ;
			EnableMenuItem (hMenu, ID_MENU_FILE_EXIT, MF_BYCOMMAND | MF_ENABLED) ;
			SendMessage (hToolbar, TB_ENABLEBUTTON, IDC_TOOLBAR_CLEAR, true) ;
			SendMessage (hToolbar, TB_ENABLEBUTTON, IDC_TOOLBAR_SOLVE, true) ;
			SendMessage (hToolbar, TB_ENABLEBUTTON, IDC_TOOLBAR_STOP, false) ;
			SendMessage (hToolbar, TB_ENABLEBUTTON, IDC_TOOLBAR_EXIT, true) ;
			working = false ;
			canClose = true ;
			mprintf (szGridIsInvalid[langCode]) ;
			MessageBoxA (hDlg, szGridIsInvalidMsg[langCode], szGridIsInvalidSMsg[langCode], MB_OK | MB_ICONEXCLAMATION | MB_APPLMODAL) ;
			return -1 ;
		}
		mprintf (szStartingGrid[langCode]) ;
		printGrid () ;
	}
	
	for (i = 1; i < 10; i ++) {								// Set number of unused numbers based on the grid after set up
		for (unsigned char k = 1; k <= 81; k ++) {
			if (*(gridArea + k) == i) {
				(*(numsDone + i)) -- ;
			}
		}
	}

	// This is the core engine of the SuDoKu solver
	retVal = recursiveSolve (x) ;							// Call the main function

	if (retVal == -2) {										// Unknown outcome
		mprintf (szThreadTermin[langCode]) ;
		goto variationsOnly ;								// Cleanup only
	}

	if (solveMode == Variations) {							// Variations only mode
		printf ("") ;
		wsprintf (buffer, szNumVariations[langCode], variations) ;
		mprintf (buffer) ;
		wsprintf (buffer, szNumValidVariations[langCode], goodVariations) ;
		mprintf (buffer) ;
		goto variationsOnly ;
	}

	if (solveMode != Multi) {								// Anything other than multi-solve mode
		getEndTime () ;										// Stopper end!
		if (retVal == -1) {
			mprintf (szGridCantSolved[langCode]) ;
			wsprintf (buffer, szNoRecCalls[langCode], -- recursiveCalls) ;
			mprintf (buffer) ;
		}
		else if (retVal == 0) {
			mprintf (szSolvedGrid [langCode]) ;
			printGrid () ;
			writeGrid (hListViewSolved) ;
			inverseGrid () ;
			paintOrigNumbers = true ;
			SendMessage (hListViewStart, WM_PAINT, (WPARAM) 0, (LPARAM) 0) ;
			printTime () ;

			sprintf_s (elapsedSecs, szElapsedSecs2 [langCode], (t_diff1 + t_diff2 + t_diff3) / 3) ;
			sprintf_s (recCalls, szNoRecCalls2 [langCode], recursiveCalls) ;
			SendMessage (hStatusBar, SB_SETTEXT, (WPARAM) 0, (LPARAM) elapsedSecs) ;
			SendMessage (hStatusBar, SB_SETTEXT, (WPARAM) 1, (LPARAM) recCalls) ;
			SendMessage (hStatusBar, SB_SETTEXT, (WPARAM) 2, (LPARAM) "") ;
			UpdateWindow (hDlg) ;

			mprintf(szVerification1 [langCode]) ;			// Various solved grid verifications
			if (verifyGrid1 ())
				mprintf (szVerification1OK [langCode]) ;
			else
				mprintf (szVerification1FD [langCode]) ;
			mprintf (szVerification2 [langCode]) ;
			if (verifyGrid2 ())
				mprintf (szVerification2OK [langCode]) ;
			else
				mprintf (szVerification2FD [langCode]) ;
			mprintf (szVerification3 [langCode]) ;
			if (verifyGrid3 ())
				mprintf (szVerification3OK [langCode]) ;
			else
				mprintf (szVerification3FD [langCode]) ;
			mprintf (szVerification4 [langCode]) ;
			if (verifyGrid4 ())
				mprintf (szVerification4OK [langCode]) ;
			else
				mprintf (szVerification4FD [langCode]) ;
			}
			wsprintf (buffer, szNoRecCalls3 [langCode], -- recursiveCalls) ;
			mprintf (buffer) ;
	}
	else {
		if (retVal == -1)									// No more solutions found
			mprintf (szNoMoreSolution [langCode]) ;
		else if (retVal == 0)
			mprintf ("") ;
		else
			mprintf (szUnknownOutcome [langCode]) ;
	}		

variationsOnly:												// Variations only mode and cleanup section
	EnableWindow (GetDlgItem (hDlg, IDC_BUTTON_CLEAR), true) ;
	EnableWindow (GetDlgItem (hDlg, IDC_BUTTON_SOLVE), true) ;
	EnableWindow (GetDlgItem (hDlg, IDC_BUTTON_STOP), false) ;
	EnableWindow (GetDlgItem (hDlg, IDC_BUTTON_CLOSE), true) ;
	EnableWindow (GetDlgItem (hDlg, IDC_BUTTON_CLEAR_LOG), true) ;
	EnableWindow (GetDlgItem (hDlg, IDC_RADIO_MULTISOLVE), true) ;
	EnableWindow (GetDlgItem (hDlg, IDC_RADIO_SINGLESOLVE), true) ;
	EnableWindow (GetDlgItem (hDlg, IDC_RADIO_VARIATIONS), true) ;
	EnableMenuItem (hMenu, ID_MENU_FILE_LOADGRID, MF_BYCOMMAND | MF_ENABLED) ;
	EnableMenuItem (hMenu, ID_MENU_FILE_EXIT, MF_BYCOMMAND | MF_ENABLED) ;
	SendMessage (hToolbar, TB_ENABLEBUTTON, IDC_TOOLBAR_CLEAR, true) ;
	SendMessage (hToolbar, TB_ENABLEBUTTON, IDC_TOOLBAR_SOLVE, true) ;
	SendMessage (hToolbar, TB_ENABLEBUTTON, IDC_TOOLBAR_STOP, false) ;
	SendMessage (hToolbar, TB_ENABLEBUTTON, IDC_TOOLBAR_EXIT, true) ;
	hProgress = GetDlgItem (hDlg, IDC_PROGRESS_BAR) ;
	ShowWindow (hProgress, SW_HIDE) ;

	working = false ;
	canClose = true ;

	return 0 ;
}

// The main SuDoKu solver engine. Called recursively during "brute force"
unsigned char recursiveSolve (unsigned char &x) {
	unsigned char i ;
	unsigned char retVal ;
	bool retval ;
	unsigned char saveX ;
	unsigned char saveFix = 0 ;
	bool success = false ;

	if (terminateThread) {									// The user stopped the engine
		return -2 ;
	}

	if (solveMode == Variations && (x == playingNumbers + 1))
		return -1 ;

	recursiveCalls ++ ;										// Stores the number of recursive forward steps
	if ((recursiveCalls / 100000000) * 100000000 == recursiveCalls) {
		wsprintf (buffer, szNoRecCalls4 [langCode], currentDateTime (), recursiveCalls) ;
		mprintf (buffer) ;
	}

	if (*(gridArea + x) != 0) {								// If the grid cell already contains a non-zero value go as far as it is zero
		i = x ;
		while (i <= 81) {
			if (*(gridArea + i) == 0)
				break ;
			i ++ ;
		}
		x = i ;
	}

	saveX = x ;												// Save the coordinate so that the function after a backtrack can pick up from where it left off

	for (i = 1; i <= playingNumbers; i ++) {				// Try each number (from 1 to 9)
		variations ++ ;
		if (terminateThread) {								// If the user terminated this engine thread forcefully
			return -2 ;
		}
		//Sleep (1) ;
		if ((*(numsDone + i)) == 0)							// If this number has already been exhausted then skip it
				continue ;
		if (*(gridArea + x) == 0							// Check if this number (i) is a valid number for this (x) cell 
				&& checkRow (x, i, false) 
				&& checkCol (x, i, false) 
				&& checkRegion (x, i, false)
				&& checkGroup (x, i)) {						// Number to be placed in a cell must satisfy all these criteria
			
			*(gridArea + x) = i ;							// Populate cell
			if (solveMode == Variations) {
				if (printPartGrid ()) {
					goodVariations ++ ;
				}
			}
			(*(numsDone + i)) -- ;							// Register that another instance of this number (i) has been taken
			success = true ;

			char fix = checkSingleChoice () ;				// Check if there are any apparent choices available
			if (fix != -1)
				saveFix = fix ;
			else
				saveFix = 0;

			if (terminateThread) {
				return -2 ;
			}
			
			retval = verifyGrid1 () ;						// Check if all numbers have been used (basically the grid is fully filled)

			if (retval) {
				gridSolved = true ;
				if (solveMode == Multi) {
					solvedNTimes ++ ;						// In multi-solve mode, count the successful solutions
					if (nextSolution ()) {					// The user wants the next solution to be found
						gridSolved = false ;
						goto failed ;						// Simulate that it failed to find a valid cell value to make it stay in the loop
					}
				}
				else
					break ;
			}

			x ++ ;											// Otherwise take a step forward
			retVal = recursiveSolve (x) ;					// Call the function recursively passing it the next grid cell to try to fill in
			if (retVal == 0) {								// The grid is solved
				break ;
			}

failed:
			success = false ;								// Backtrack here
			x = saveX ;										// Restore grid cell position
			*(gridArea + saveX) = 0 ;						// Set cell to zero
			(*(numsDone + i)) ++ ;							// Adjust unused number count

			if (saveFix != 0) {								// If this recursive call also found a fix value then get rid of that too as things changed
				(*(numsDone + *(gridArea + saveFix))) ++ ;
				*(gridArea + saveFix) = 0 ;
				saveFix = 0 ;
			}
		}
	}

	if (gridSolved) {										// The grid is solved, return from the recursive call (go up and up the stack)
		return 0 ;
	}

	return -1 ;												// Failed to find a valid cell
}

// Checks if a given number can go in that row or not
bool checkRow (unsigned char &x, unsigned char numVal, bool preCheck) {
	unsigned char rowNum = (x - 1) / 9 + 1 ;

	for (unsigned char i = rowNum * 9 - 8; i <= rowNum * 9; i ++) {
		if (preCheck) {
			if (*(gridArea + i) == numVal && x != i)
				return false ;
		}
		else {
			if (*(gridArea + i) == numVal)
				return false ;
		}
	}
	return true ;
}

// Checks if a given number can go in that column or not
bool checkCol (unsigned char &x, unsigned char numVal, bool preCheck) {
	unsigned char colNum = x % 9 ;

	for (unsigned char i = colNum; i <= 73; i += 9) {
		if (preCheck) {
			if (*(gridArea + i) == numVal && x != i)
				return false ;
		}
		else {
			if (*(gridArea + i) == numVal)
				return false ;
		}
	}
	return true;
}

// Checks if a given number can go in that region (3 x 3) or not
bool checkRegion (unsigned char &x, unsigned char numVal, bool preCheck) {
	unsigned char lx ;
	unsigned char upperLeft ;								// Upper-left corner of a given region

	lx = x ;
	lx = lx - ((x - 1) / 9) * 9 ;
	upperLeft = ((lx - 1) / 3) * 3 + 1 ;

	if (x > 54)												// 3rd region
		upperLeft += 54 ;
	else if (x > 27)										// 2nd region
		upperLeft += 27 ;

	// Region upper-left corners
	// 1,2,3,10,11,12,19,20,21 = 1 // 4,5,6,13,14,15,22,23,24 = 4 // 7,8,9,16,17,18,25,26,27 = 7
	// 28,29,30,37,38,39,46,47,48 = 28 // 31,32,33,40,41,42,49,50,51 = 31 // 34,35,36,43,44,45,52,53,54 = 34
	// 55,56,57,64,65,66,73,74,75 = 55 // 58,59,60,67,68,69,76,77,78 = 58 // 61,62,63,70,71,72,79,80,81 = 61
	if (preCheck) {
		if ((*(gridArea + upperLeft) == numVal && upperLeft != x) || (*(gridArea + upperLeft + 1) == numVal  && upperLeft + 1 != x) ||
			(*(gridArea + upperLeft + 2) == numVal  && upperLeft + 2 != x) || (*(gridArea + upperLeft + 9) == numVal  && upperLeft + 9 != x) ||
			(*(gridArea + upperLeft + 10) == numVal  && upperLeft + 10 != x) || (*(gridArea + upperLeft + 11) == numVal  && upperLeft + 11 != x) ||
			(*(gridArea + upperLeft + 18) == numVal  && upperLeft + 18 != x) || (*(gridArea + upperLeft + 19) == numVal  && upperLeft + 19 != x) || 
			(*(gridArea + upperLeft + 20) == numVal  && upperLeft + 20 != x))
			return false ;
	}
	else {
		if (*(gridArea + upperLeft) == numVal || *(gridArea + upperLeft + 1) == numVal || *(gridArea + upperLeft + 2) == numVal ||
			*(gridArea + upperLeft + 9) == numVal || *(gridArea + upperLeft + 10) == numVal || *(gridArea + upperLeft + 11) == numVal ||
			*(gridArea + upperLeft + 18) == numVal || *(gridArea + upperLeft + 19) == numVal || *(gridArea + upperLeft + 20) == numVal)
			return false ;
	}

	return true ;
}

// The sum of the cells in the group must be correct
bool checkGroup (unsigned char &x, unsigned char numVal) {
	unsigned int sum, currSum ;
	unsigned char stillZero ;
	unsigned char members ;
	unsigned int minVal ;
	
	if (solveMode == Variations)
		return true ;

	if (killerGroup[x] != 0) {
		sum = killerGroupSum [killerGroup[x]] ;
		currSum = 0 ; stillZero = 0 ; members = 0 ;
		for (int i = 1; i <= 81; i++) {
			if (killerGroup[i] == killerGroup[x]) {			// Grid cells in the same group
				currSum += gridArea [i] ;					// Get the current sum of the cells in the same group
				members ++ ;								// Number of member cells in the group
				if (gridArea[i] == 0) {
					stillZero ++ ;
				}
			}
		}
		if (currSum + numVal > sum)							// Can not add the current number to the current grid cell as that would exceed the allowed sum
			return false ;
		
		minVal = 0 ; // 2-> 1, 3-> 1+2, 4-> 1+2+3, 9-> 1+2+3+4+5+6+7+8, 10-> 1+2+3+4+5+6+7+8+9, 11-> 1+2+3+4+5+6+7+8+9+1, 81->396
		int i = 2, j = 2 ;
		while (i <= stillZero) {
			minVal += (j - 1) ;
			j ++, i ++ ;
			if (j == 11)
				j = 2 ;
		}
		if (stillZero == 1 && (sum - (currSum + numVal)) == 0)	// Last number to be added to the group must match the sum!
			return true ;									// Perfect figure! Adding the last cell value = the predefined sum
		else if (stillZero == 1 && (sum - (currSum + numVal)) != 0)
			return false ;
		if ((sum - (currSum + numVal)) < minVal)
			return false ;
	}

	return true ;
}

// Check if any of the numbers (from 1 to 9) only one left because that has a fix place
char checkSingleChoice () {
	bool retVal ;
	char index ;
	unsigned char i, j, k ;

	if (solveMode == Variations)
		return -1 ;

	index = 0 ;
	for (i = 1; i <= 9; i ++) {								// FOR all the numbers (from 1 to 9)
		index = 0 ;
		if (numsDone[i] == 1) {
			for (k = 1; k <= 73; k += 9) {
				retVal = checkRow (k, i, false) ;
				if (retVal) {
					index = k ;
					break ;
				}
			}
			if (index != 0) {
				for (j = index; j <= index + 9; j ++) {
					retVal = checkCol (j, i, false) ;
					if (retVal) {
						index = j ;
						break ;
					}
				}
			}
		}
		if (index != 0 && *(gridArea + index) == 0) {		// Only if the grid cell is not occupied
			*(gridArea + index) = i ;
			(*(numsDone + i)) -- ;
			return index ;
		}
	}

	return -1 ;												// No single choice this time
}

// End of source file - SuDoKuEngine.cpp

