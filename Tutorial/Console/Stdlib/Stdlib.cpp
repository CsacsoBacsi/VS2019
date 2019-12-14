// Stdlib.cpp : Defines the entry point for the console application.
//

#include <stdlib.h>
#include <time.h>
#include <iostream>

using namespace std ;

void fnExit (void) ;
int compareints (const void *, const void *) ;

int main ()
{
	// Conversions
	float myfl = (float) atof ("3.14565") ;						// String to float
	double mydb = atof ("3.14565") ;							// String to double
	int myin = atoi ("314") ;									// String to integer
	long int mylin = atol ("123456789") ;						// String to long
	long long int myllin = atoll ("1234567891011") ;			// String to long long
	char * end ;
	mydb = strtod ("1.2345xx", &end) ;							// String to double + the pointer points at the first non-numerical char
	myfl = strtof ("1.234567abc123", &end) ;					// String to float
	long long unsigned int lluint = strtoull ("1234567891011", &end, 10) ; // String to unsigned long long. Last param is radix (10-based)
	char buffer [256] ;
	errno_t errn = _itoa_s (123, buffer, 10) ;					// Integer to char
	
	// Random
	srand ((unsigned int) time (NULL)) ;
	int rnum = rand () % 100 + 1 ;								// In the range of 1 - 100. Returns a pseudo-random integral number in the range between 0 and RAND_MAX

	// Sort and search
	int values[] = { 50, 20, 60, 40, 10, 30 } ;
	int * pItem	;
	int key = 40 ;
	qsort (values, 6, sizeof (int), compareints) ;				// Needs a compare function reference
	pItem = (int *) bsearch (&key, values, 6, sizeof (int), compareints) ; // Searches for a match

	// Misc
	div_t divresult ;
	divresult = div (38,5) ;
	cout << "38 div 5: " << divresult.quot << ", remainder: " << divresult.rem << endl ;
	int absval = abs (-12) ;

	// Resource Acquisition Is Initialization or RAII, is a C++ programming technique[1][2] which binds the life cycle of a resource (allocated memory, thread of execution,
	// open socket, open file, locked mutex, database connection—anything that exists in limited supply) to the lifetime of an object
	// Vector and unique_ptr are examples of RAII objects. They do the cleanup in a destructor, they allocate in the constructor, they do not raise exceptions
	// The RAII object can be created/instantiated as an automatic storage class object (on the stack) so when it goes out of scope, its destructor is called automatically
	// which deallocates anything that had been allocated. No need to call delete or free explicitly.
	// Use any resource via the instance of the RAII class

	// Memory
	int * pint = (int *) calloc (10, sizeof(int)) ;				// Allocates 10 integers, inits them with zeros and creates a pointer that points at it. pint is created on the stack. The 10 integers are on the heap!
	char * pchar = (char *) malloc (10) ;						// Allocates 10 bytes and a pointer (pchar) pointeing at it
	pchar = (char *) realloc (pchar, 20) ;						// Reallocates the array. Previously 

	// Program termination
	/* All resources including file handles, open files, memory allocated get freed and reclaimed by the OS. So no need for calling destructors really, but it is not good practice
	   Resources allocated on the heap (dynamically allocated objects) should be freed by the programmer. The current, new OSes do this but noone should rely on that!
	*/
	atexit (fnExit) ;											// On exit, call this function
	
    /* Objects associated with the current thread with thread storage duration are destroyed (C++11 only).
       Objects with static storage duration are destroyed (C++) and functions registered with atexit are called.
       All C streams (open with functions in <cstdio>) are closed (and flushed, if buffered), and all files created with tmpfile are removed.
       Control is returned to the host environment.
	*/
	exit (EXIT_SUCCESS) ;										// EXIT_SUCCESS or EXIT_FAILURE the params
	
	/* No additional cleanup tasks are performed: No object destructors are called. Although whether C streams are closed and/or flushed, and files 
	   open with tmpfile are removed depends on the particular system or library implementation.
	*/
	quick_exit (EXIT_FAILURE) ;

	/* Terminates the process normally by returning control to the host environment, but without performing any of the regular cleanup tasks for terminating 
	   processes (as function exit does).
	*/
	_Exit (EXIT_SUCCESS) ;

	/* Aborts the current process, producing an abnormal program termination.
	   The function raises the SIGABRT signal (as if raise(SIGABRT) was called). This, if uncaught, causes the program to terminate returning a platform-dependent 
	   unsuccessful termination error code to the host environment.
	   The program is terminated without destroying any object and without calling any of the functions passed to atexit or at_quick_exit.
	*/
	abort () ;

	return 0 ;
}

void fnExit (void)
{
  cout << "Exit function called." << endl ;
  char * buffer = (char *) malloc (1000) ;
  size_t bcount = 999 ;
  errno_t errn =_dupenv_s (&buffer, &bcount, "ORACLE_HOME") ;	// Get any environmental variable value
  cout << "Oracle home dir: " << buffer << endl ;
  system ("dir") ;												// Executing a system command. Output goes to stdout

  return ;
}

int compareints (const void * a, const void * b)
{
	if (*(int *) a <  *(int *) b) return -1 ;
	if (*(int *) a == *(int *) b) return 0 ;
	if (*(int *) a >  *(int *) b) return 1 ;

	return 0 ;
}

