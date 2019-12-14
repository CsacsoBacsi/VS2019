// SuDoKu.cpp : Defines the entry point for the console application.
//
/*SuDoKu solving using Backtracking or Trial and Error
  When all else fails, there is one technique that is guaranteed to always work, indeed you can solve any Sudoku puzzle just using just this one strategy alone.
  You just work logically through all the possible alternatives in every square in order until you find the allocations that work out. If you choose a wrong
  option at some stage later you will find a logical inconsistency and have to go back, undoing all allocations and then trying another option. Because there
  are so many alternatives (billions) you won't want to use it too often. You start with a square and choose one number from the available possibilities. This
  is a completely different type of strategy as it uses 'brute force' rather than 'logic'. It is a contentious Sudoku solving technique but computers have the
  power to do this in milliseconds.
*/
#include <stdlib.h>
//#include "stdafx.h"
#include<stdio.h>
#include <conio.h>
#include <time.h>
#include <windows.h>
#include <winnt.h>
#include <locale.h>

// Global variables
unsigned char * gridArea = (unsigned char *) calloc (82, sizeof (unsigned char)) ;	// Grid area. 81 numbers + first char (0) is not used
unsigned char * pgridArea ;
unsigned char * numsDone = (unsigned char *) malloc (10 * sizeof (unsigned char)) ;	// Registers how many of each number (1-9) are still available
unsigned char * pnumsDone ;
unsigned char * killerGroup = (unsigned char *) calloc (82, sizeof (unsigned char)) ;	// Contains the group number associated with a given grid cell
unsigned int killerGroupSum [82] ;							// Group number (array index), sum value of the cells in the group (first char not used)
bool gridSolved = false ;
unsigned long recursiveCalls = 0l ;							// Number of recursive calls
unsigned long variations = 0l ;								// Number of all variations
unsigned long goodVariations = 0l;							// Number of valid variations
bool onlyVariations = false ;								// Do not solve just calculate variations
char playingNumbers = 9 ;									// Number of playing numbers (starting with 1)
bool multiSolve = true ;									// Let the system try to find another solution
unsigned long solvedNTimes = 0 ;							// If multisolve = true then the number of possible solutions

// Function proto-types
unsigned char recursiveSolve (unsigned char &) ;
bool checkRow (unsigned char &, unsigned char, bool) ;
bool checkCol (unsigned char &, unsigned char, bool) ;
bool checkRegion (unsigned char &, unsigned char, bool) ;
bool checkGroup (unsigned char &, unsigned char) ;
char checkSingleChoice () ;
void printGrid () ;
bool verifyGrid1 () ;
bool verifyGrid2 () ;
bool verifyGrid3 () ;
bool verifyGrid4 () ;
bool verifyGrid5 () ;
bool nextSolution () ;
unsigned long long getSysTime () ;
void example1 () ;
void example2 () ;
void example3 () ;
void example4 () ;
void example5 () ;
void example6 () ;
void example7 () ;

int main()
{
	unsigned char i ;										// Loop variable
	unsigned char x ;										// Grid coordinate
	char retVal ;									// Return value from the recursive function
	long st_time1, et_time1 ;								// 3 different times to calc elapsed time
	clock_t st_time2, et_time2 ;
	unsigned long long st_time3, et_time3 ;
	double t_diff1, t_diff2, t_diff3 ;						// Time difference

	printf ("*** SuDoKu solving utility using brute force and backtracking ***\n") ;
	printf ("**** Copyright (c) 2016 Csacso software All rights reserved  ****\n\n") ;

	// Initialize variables
	pgridArea = gridArea + 1 ;								// For a better debugger view of the grid area (starts at index 1)
	pnumsDone = numsDone + 1 ;								// Same for the finsihed numbers
	*gridArea = -1 ;										// Init unused first index value in the grid area
	*numsDone = 0 ;
	x = 1;													// First grid cell

	for (i = 1; i < 10; i ++) {								// Set the count of unused numbers to an initial 9
		*(numsDone + i) = 9 ;
	}

	// Test values in various grid cells
	example1 () ; // 3 values only
	//example2 () ; // Website example. Medium level
	//example3 () ; // Eight 5s to test single choice
	//example4 () ; // Advanced level (3) SuDoKu
	//example5 () ; // Impossible to solve
	//example6 () ; // Killer SuDoKu
	//example7 () ; // All cells in 1 group. Sum must be 405

	for (i = 1; i < 10; i ++) {								// Set number of unused numbers based on the grid after set up
		for (unsigned char k = 1; k <= 81; k ++) {
			if (*(gridArea + k) == i) {
				(*(numsDone + i)) -- ;
			}
		}
	}

	printf ("Starting grid:\n\n") ;
	printGrid ();

	printf ("Checking grid validity...\n") ;
	if (verifyGrid5 ())
		printf ("The grid is valid.\n") ;
	else {
		printf ("The grid is invalid, please check the initial values.\n") ;
		return -1 ;
	}

	if (onlyVariations)
		printf ("Press any key to get the number of requested variations...\n") ;
	else
		printf ("Press any key to solve the grid...\n") ;
	_getch () ;
	if (onlyVariations)
		printf ("Getting the variations for %d cells...\n", (int) playingNumbers) ;
	else
		printf ("Solving the grid...\n") ;

	if (!multiSolve) {
		st_time1 = GetTickCount () ;						// Get the start time
		st_time2 = clock () ;
		st_time3 = getSysTime () ;
	}

	retVal = recursiveSolve (x) ;							// Call the main function
	if (onlyVariations) {
		printf ("") ;
	}
	else if (retVal == -1 && (!multiSolve))
		printf ("Grid could not be solved.\n") ;
	else if (retVal == -1 && (multiSolve))
		printf ("No more possible solutions found.\n") ;
	else if (retVal == 0 && (!multiSolve)) {
		printf ("\nSolved grid:\n\n") ;
		printGrid ();
	}
	else if (retVal == 0 && (multiSolve))
		printf ("") ;
	else
		printf ("Unknown outcome.\n") ;

	if (onlyVariations) {
		printf("Number of variations to resolve the grid : %ld\n", variations);
		printf("Valid variations                         : %ld\n", goodVariations);
	}
	else if (!multiSolve)
		printf("Number of recursive calls to resolve grid: %ld\n", -- recursiveCalls);

	if (!multiSolve) {
		et_time1 = GetTickCount ();							// Get the end time
		et_time2 = clock ();
		et_time3 = getSysTime ();

		t_diff1 = et_time1 - st_time1 ;
		t_diff1 = t_diff1 / 1000. ;							// Calculate the difference
		printf ("Time (ticks) taken to resolve in seconds : %0.6f\n", t_diff1) ;

		t_diff2 = (double) (et_time2 - st_time2) / CLOCKS_PER_SEC ;
		printf ("Time (clock) taken to resolve in seconds : %0.6f\n", t_diff2) ;

		t_diff3 = (double) (et_time3 - st_time3) / 10000 / 1000 ;
		printf ("Time (systm) taken to resolve in seconds : %0.6f\n", t_diff3) ;
		printf ("Time (avrge) taken to resolve in seconds : %0.6f\n\n", (t_diff1 + t_diff2 + t_diff3) / 3) ;
	}

	if (onlyVariations)
		goto variationsOnly ;

	if (!multiSolve) {
		printf("Grid verification 1: ") ;
		if (verifyGrid1 ())
			printf ("OK. All numbers (from 1 to 9) used.\n") ;
		else
			printf ("FAILED. Not all numbers (from 1 to 9) used.\n") ;

		printf ("Grid verification 2: ") ;
		if (verifyGrid2 ())
			printf ("OK. All rows have unique numbers.\n") ;
		else
			printf ("FAILED. Not all rows contain unique numbers.\n") ;

		printf ("Grid verification 3: ") ;
		if (verifyGrid3 ())
			printf ("OK. All columns have unique numbers.\n") ;
		else
			printf ("FAILED. Not all columns contain unique numbers.\n") ;

		printf ("Grid verification 4: ") ;
		if (verifyGrid4 ())
			printf ("OK. The sum of all grid cell values is 405.\n\n") ;
		else
			printf ("FAILED. The sum of all grid cell values is not 405.\n\n") ;
	}

variationsOnly:
	free (gridArea) ;
	free (numsDone) ;
	free (killerGroup) ;

	printf ("*** End of program ***\n") ;
	_getch () ;

	return 0;
}

unsigned char recursiveSolve(unsigned char &x) {
	unsigned char i, k ;
	unsigned char retVal ;
	bool retval ;
	unsigned char saveX ;
	unsigned char saveFix = 0 ;
	bool success = false ;

	if (onlyVariations && (x == playingNumbers + 1))
		return false ;

	recursiveCalls ++ ;										// Stores the number of recursive steps
	if ((recursiveCalls / 100000000) * 100000000 == recursiveCalls) {
		printf ("Recursive call %d ...\n", recursiveCalls) ;
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
		for (k = 1; k <= 9; k++)							// If this number has already been exhausted then skip it
			if ((*(numsDone + k)) == 9)
				continue ;
		variations ++ ;
		if (*(gridArea + x) == 0 
				&& checkRow (x, i, false) 
				&& checkCol (x, i, false) 
				&& checkRegion (x, i, false)
				&& checkGroup (x, i)) {						// Number ot be placed in a cell must satisfy all these criteria
			
			*(gridArea + x) = i ;							// Populate cell
			goodVariations ++ ;
			(*(numsDone + i)) -- ;
			success = true ;
			/*if (x == 81) {								// The last grid cell is filled. We are done
				gridSolved = true ;
				break ;
			}*/

			char fix = checkSingleChoice () ;				// Check if there are any apparent choices available
			if (fix != -1)
				saveFix = fix ;
			else
				saveFix = 0;
			
			retval = verifyGrid1 () ;
			if (retval) {
				gridSolved = true ;
				if (multiSolve) {
					solvedNTimes ++ ;
					if (nextSolution ()) {
						gridSolved = false ;
						goto failed ;						// Simulate that it failed to find a valid cell value to make it stay in the loop
					}
				}
				else
					break ;
			}

			x ++ ;											// Otherwise take a step forward
			retVal = recursiveSolve (x) ;					// Call the function recursively passing it the next grid cell to try to fill in
			if (retVal == 0) {
				break;
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

	if (gridSolved) {
		/*if (multiSolve)
			gridSolved = false ;
		else */
		return 0 ;
	}

	return -1 ;												// Failed to find a valid cell
}

bool checkRow (unsigned char &x, unsigned char numVal, bool preCheck) {	// Checks if a given number can go in that row or not
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

bool checkCol (unsigned char &x, unsigned char numVal, bool preCheck) {	// Checks if a given number can go in that column or not
	unsigned char colNum = x % 9 ;

	for (unsigned char i = colNum; i <= 82; i += 9) {
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

bool checkRegion (unsigned char &x, unsigned char numVal, bool preCheck) {	// Checks if a given number can go in that region (3 x 3) or not
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

bool checkGroup (unsigned char &x, unsigned char numVal) {
	unsigned int sum, currSum ;
	unsigned char stillZero ;
	unsigned char members ;
	unsigned int minVal ;
	
	if (onlyVariations)
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

char checkSingleChoice () {
	bool retVal ;
	char index ;
	unsigned char i, j, k ;

	if (onlyVariations)
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

	return -1 ;
}

void printGrid() {
	unsigned char i, j ;

	printf ("   ") ;
	for (i = 1; i <= 9; i++) {
		printf ("%d", i) ;
	}
	printf ("\n") ;

	printf ("   ") ;
	for (i = 1; i <= 9; i++) {
		printf ("_") ;
	}
	printf ("\n") ;

	for (i = 0; i < 9; i ++) {
		printf ("%c |", 65 + i) ;
		for (j = 1; j <= 9; j ++) {
			printf ("%d", *(gridArea + i * 9 + j)) ;
		}
		printf ("\n") ;
	}
	printf("\n") ;
}

bool verifyGrid1 () {										// Checks if all numbers (from 1 to 9) had been used fully
	for (unsigned char i = 1; i <= 9; i ++) {
		if (*(numsDone + i) != 0)
			return false ;
	}
	return true;
}

bool verifyGrid2 () {										// Checks if every row has unique numbers
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

bool verifyGrid3 () {										// Checks if every column has unique numbers
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
				return false;
			}
		}
		for (k = 0; k < 9; k ++) {
			numbers[k] = 0 ;
		}
	}
	free (numbers) ;
	return true ;
}

bool verifyGrid4 () {										// Checks if the sum of all grid cells is 405
	unsigned  int sum ;

	sum = 0 ;
	for (unsigned char i = 1; i <= 81; i ++) {
		sum += *(gridArea + i) ;
	}
	if (sum == 405)
		return true ;
	else
		return false ;
}

bool verifyGrid5 () {										// Checks if the initial state of the grid is valid
	unsigned char * gridNums = (unsigned char *) calloc (82, sizeof (unsigned char)) ;

	for (unsigned char i = 1; i <= 81; i ++) {
		if (*(gridArea + i) != 0) {
			if (checkRow (i, *(gridArea + i), true) 
				&& checkCol (i, *(gridArea + i), true) 
				&& checkRegion (i, *(gridArea + i), true))
				continue ;
			else
				return false ;
		}
	}
	free (gridNums) ;
	return true ;
}


bool nextSolution() {
	int charRead ;
	
	printf ("\nSolved grid #%d:\n\n", solvedNTimes) ;
	printGrid () ;
	printf("Number of recursive calls to resolve grid: %ld\n", -- recursiveCalls);
	recursiveCalls = 0 ;
	printf ("Press ENTER to continue, ESC to stop.\n") ;
readAgain:
	charRead = _getch () ;									// ENTER = 13, ESCAPE = 27
	if (charRead == 13)
		return true ;
	else if (charRead == 27)
		return false ;
	else
		goto readAgain ;
}
unsigned long long getSysTime () {
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

void example1 () {
	gridArea[25] = 5 ; 	gridArea[26] = 7 ; gridArea[27] = 9 ;
}
void example2 () {
	// Example taken form website: http://www.websudoku.com/images/example-steps.html
	gridArea[7] = 6 ; gridArea[8] = 8 ; gridArea[14] = 7 ; gridArea[15] = 3 ; gridArea[18] = 9 ;	gridArea[19] = 3 ; gridArea[21] = 9 ; gridArea[14] = 7 ; gridArea[26] = 4 ; gridArea[27] = 5 ;
	gridArea[28] = 4 ; gridArea[29] = 9 ; gridArea[37] = 8 ; gridArea[39] = 3 ; gridArea[41] = 5 ; gridArea[43] = 9 ; gridArea[45] = 2 ; gridArea[53] = 3 ; gridArea[54] = 6 ; 
	gridArea[55] = 9 ; gridArea[56] = 6 ; gridArea[61] = 3 ; gridArea[63] = 8 ; gridArea[64] = 7 ; gridArea[67] = 6 ; gridArea[68] = 8 ; gridArea[74] = 2 ; gridArea[75] = 8 ;
	//gridArea[80] = 6; gridArea[81] = 7;
}

void example3 () {
	gridArea[1] = 5 ; gridArea[13] = 5 ; gridArea[25] = 5 ; gridArea[29] = 5 ; gridArea[41] = 5 ; gridArea[53] = 5 ; gridArea[69] = 5 ; gridArea[81] = 5 ;
}

void example4 () {
	// Example taken from website: http://www.websudoku.com/?level=3
	gridArea[1] = 7 ; gridArea[5] = 5 ; gridArea[6] = 1 ; gridArea[10] = 5 ; gridArea[12] = 9 ;	gridArea[14] = 4 ; gridArea[17] = 6 ; gridArea[20] = 4 ; gridArea[24] = 8 ; gridArea[26] = 3 ;
	gridArea[28] = 6 ; gridArea[30] = 2 ; gridArea[32] = 3 ; gridArea[40] = 8 ; gridArea[42] = 6 ; gridArea[50] = 1 ; gridArea[52] = 9 ; gridArea[54] = 6 ; gridArea[56] = 5 ; 
	gridArea[58] = 6 ; gridArea[62] = 7 ; gridArea[65] = 7 ; gridArea[68] = 8 ; gridArea[70] = 6 ; gridArea[72] = 2 ; gridArea[76] = 3 ; gridArea[77] = 7 ; gridArea[81] = 9 ;
}

void example5 () {											// Can not be solved, runs for a long long time!
	gridArea[1] = 1 ; gridArea[2] = 1 ;
}

void example6 () {											// Killer SuDoKu
	//gridArea[1] = 4 ;
	killerGroup[1] = 1 ; killerGroup[2] = 1 ; killerGroup[3] = 1 ; killerGroup[10] = 1 ;
	killerGroupSum [1] = 11 ;								// Can not be solved. 4 + 3,2,1 or 5,2,1 will never be 11
	//killerGroupSum [1] = 12 ;
}

void example7 () {											// All the cells are in 1 group. Sum must be 405
	for (char i = 1; i <= 81; i ++)
		killerGroup[i] = 1 ;
	killerGroupSum [1] = 405 ;
}

// End of source file - SuDoKu solver utility

