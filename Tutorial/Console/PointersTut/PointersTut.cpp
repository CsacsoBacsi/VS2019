// PointersTut.cpp : Defines the entry point for the console application.
//
#include <stdlib.h>
#include <stdio.h>

int * pmyVar;													// Created on the heap, debugger shows real heap address
char * pmyVar2;
int myVar = 5 ;
int ** pvalue3 ;
void ** pvalue4 ;
int ** pvalue5 ;

void alterString (char *) ;
void alterString2 (char *) ;
void alterInt (int *) ;

int main()
{
	double * pvalue1 = NULL;									// Pointer initialized with null
	pvalue1 = new double;										// Allocates space for a pointer that points at a double

	int * intArray = new int[10];								// Pointer to a 10 member int array
    int intarray2 [5];                                          // Normal array
    int * prt2 = intarray2 ;                                    // intarray2 the name is the pointer itself

	double ** pvalue2 = NULL;									// Pointer pointing at another pointer. We do not know whether that pointer points at an array or just a single pointer.
																// Furthermore, we do not know that if it points at an array, then each array member points at a further array or not
	pvalue2 = new double * [5];									// Pointer array containing 5 pointers. Now we know, that the topmost pointer points at an array of 5 pointers which will point at double values 
	for (int i = 0; i < 5; ++i)									// but still do not know how many
		pvalue2 [i] = new double [10];							// Now we know, that each pointer in the 5 member array now points at an array of 10 doubles each

	*pvalue2[0] = 10;
	* (pvalue2[0] +2) = 15;

	for (int i = 0; i < 5; i++) {
		for (int j = 0; j < 10; j++) {
			printf("%f\n", pvalue2[i][j]);
		}
	}

	pvalue3 = new int * ;										// pvalue3 was created on the heap at address 1111. Points at address 2222 which points at nothing at the mo
	//* (pvalue3) = new void * ;
	* (pvalue3) = &myVar ;										// Now the pointer points at myVar's address which is 3333. the value to be found there is 5
	** pvalue3 = 10 ;											// Let's change that value to 10
	//(int*) (* pvalue3) = 10 ;

	printf ("Myvar before: %d\n", myVar) ;
	pvalue4 = new void * ;										// Can not be dereferenced because the compiler does not know of the size
	pvalue5 = (int **) pvalue4 ;
	* (pvalue5) = &myVar ;
	** pvalue5 = 15 ;

	printf ("Myvar is: %d now!\n", myVar) ;

	delete pvalue1;
	for (int i = 0; i < 5; ++i) {
		delete[] pvalue2[i];
	}
	delete pvalue2;

	// Use of malloc
	char ** a;
	a = (char **) malloc (10 * sizeof(char *));					// Allocate 10 char pointer. Allocates 40 bytes of space. 4 bytes each pointer

	for (int i = 0; i<10; i++)
		a[i] = (char *) malloc(20 * sizeof(char));				// For each pointer, allocate 20 chars

	for (int i = 0; i < 10; ++i) {
		free (a[i]);
	}
	free (a);

	int myVar;
	myVar = 5;
	// int * pmyVar;											// Created on the stack. Debugger does not show real address, only variable name
	pmyVar = &myVar;

	myVar = 10;
	*pmyVar = 11;

	printf ("\n") ;

	pmyVar2 = "This is a string";								// The string is created on the heap then the address is assigned to the pointer
	printf ("My string before call: %s\n", pmyVar2) ;
	printf ("Pointer: %d\n", (long)pmyVar2) ;
	// alterString (pmyVar2) ;
	printf ("My string after call: %s\n", pmyVar2) ;
	printf ("String is immutable!\n\n") ;						// The string is created in a read-only area and pmyVar2 just points at it!

	char pmyVar5 [17] ;
	pmyVar5[0] = '0' ;
	pmyVar5[1] = '1' ;
	pmyVar5[2] = 0 ;
	printf ("My string before call: %s\n", pmyVar5) ;
	alterString (pmyVar5) ;
	printf ("My string after call: %s\n", pmyVar5) ;
	printf ("String is mutable!\n\n") ;							// The array of chars is actually alterable (mutable)!

	//char pmyVar6[] = "Another string" ; // Same as pmyVar6 [] = {'A','n','o'}
	char pmyVar6 [] = {'A','n','o', 0} ;
	printf ("My string before call: %s\n", pmyVar6) ;
	alterString2 (pmyVar6) ;									// For chars, the pointer is the name of the array/string
	printf ("My string after call: %s\n", pmyVar6) ;
	printf ("String is mutable!\n\n") ;							// The array of chars is actually alterable (mutable)!

	// *************************************************
	// char * string and char string [] are not the same!!!
	// char * string = "Something" is allocated in read-only (heap, data segment), fixed memory. Not possible to change. Creates two objects: the string in fixed data segment + a pointer to it
	// char string [] = "Hi" is created in new memory and lives only in its scope (stack!). This array is changeable. It is an array: string[0] = 'H', striong[1] = 'i'
	// *************************************************

	int mynum = 1 ;
	printf ("My num before call: %d\n", mynum) ;
	alterInt (&mynum) ;											// The pointer is indicated by &
	printf ("My num after call: %d\n", mynum) ;

    return 0;
}

void alterString (char * str)
{
	printf ("My string received: %s\n", str) ;
	printf ("Pointer: %d\n", (long) str) ;
	str [0] = 'H' ;
	str [1] = 'i' ;
	printf ("My string after assign: %s\n", str) ;
}

void alterString2 (char * str)
{
	str [0] = 'P' ;
	str [1] = 'o' ;
	str [2] = 0 ;
}

void alterInt (int * num)
{
	* num = 101 ;
}

