// Clib.cpp : Defines the entry point for the console application.
//

/* *** Libraries *** 
libucrt.lib      - The Universal CRT (UCRT) contains the functions and globals exported by the standard C99 CRT library. The UCRT is now a Windows component, 
                   and ships as part of Windows 10.
libvcruntime.lib - The vcruntime library contains Visual C++ CRT implementation-specific code, such as exception handling and debugging support, runtime 
                   checks and type information, implementation details and certain extended library functions.

libcmt.lib       - The code that initializes the CRT is in one of several libraries, based on whether the CRT library is statically or dynamically linked, or native, managed,
                   or mixed code. This code handles CRT startup, internal per-thread data initialization, and termination
msvcrt.lib       - Static library for the native CRT startup for use with DLL UCRT and vcruntime

libcpmt.lib      - Standard C++ Library, multithreaded, static link
msvcprt.lib      - Multithreaded, dynamic link (import library for MSVCP<version>.dll)
*/

#include <iostream>
#include <assert.h>
#include <ctype.h>
#include <errno.h>
#include <math.h>
#include <signal.h>
#include <stdarg.h>

using namespace std ;
int signaled = 0 ;												// Indicates that a signal has been handled
void my_handler (int param) ;
void varargs (int n, ...) ;

int main ()
{
	// Assert
	int p = NULL ;
	// assert (p != NULL) ;										// Aborts the program, sends line number that failed to stderr

	// Char type
	isalnum ('d')  ? cout << "True" << endl : cout << "False" << endl ;
	isalpha ('d')  ? cout << "True" << endl : cout << "False" << endl ;
	isblank ('\t') ? cout << "True" << endl : cout << "False" << endl ;
	iscntrl (14)   ? cout << "True" << endl : cout << "False" << endl ;
	isdigit ('1')  ? cout << "True" << endl : cout << "False" << endl ;
	islower ('d')  ? cout << "True" << endl : cout << "False" << endl ;
	ispunct (';')  ? cout << "True" << endl : cout << "False" << endl ;
	isspace (' ')  ? cout << "True" << endl : cout << "False" << endl ;
	isupper ('d')  ? cout << "True" << endl : cout << "False" << endl ;
	isxdigit ('G') ? cout << "True" << endl : cout << "False" << endl ;

	// Errno
	cout << errno << endl ;

	// Limits
	/* CHAR_BIT	Number of bits in a char object (byte)	8 or greater
	SCHAR_MIN	Minimum value for an object of type signed char	-127 (-27+1) or less
	SCHAR_MAX	Maximum value for an object of type signed char	127 (27-1) or greater
	UCHAR_MAX	Maximum value for an object of type unsigned char	255 (28-1) or greater
	CHAR_MIN	Minimum value for an object of type char	either SCHAR_MIN or 0
	CHAR_MAX	Maximum value for an object of type char	either SCHAR_MAX or UCHAR_MAX
	MB_LEN_MAX	Maximum number of bytes in a multibyte character, for any locale	1 or greater
	SHRT_MIN	Minimum value for an object of type short int	-32767 (-215+1) or less
	SHRT_MAX	Maximum value for an object of type short int	32767 (215-1) or greater
	USHRT_MAX	Maximum value for an object of type unsigned short int	65535 (216-1) or greater
	INT_MIN		Minimum value for an object of type int	-32767 (-215+1) or less
	INT_MAX		Maximum value for an object of type int	32767 (215-1) or greater
	UINT_MAX	Maximum value for an object of type unsigned int	65535 (216-1) or greater
	LONG_MIN	Minimum value for an object of type long int	-2147483647 (-231+1) or less
	LONG_MAX	Maximum value for an object of type long int	2147483647 (231-1) or greater
	ULONG_MAX	Maximum value for an object of type unsigned long int	4294967295 (232-1) or greater
	LLONG_MIN	Minimum value for an object of type long long int	-9223372036854775807 (-263+1) or less
	LLONG_MAX	Maximum value for an object of type long long int	9223372036854775807 (263-1) or greater
	ULLONG_MAX	Maximum value for an object of type unsigned long long int	18446744073709551615 (264-1) or greater
	*/

	// Math
	double param, result ;
	param = 60.0 ;
	result = cos (param) ;										// cosine of param
	param = 3 ;
	result = exp (param);										// e on the power of 3
	int n ;
	param = 8.0 ;
	result = frexp (param , &n) ;								// Breaks the floating point number x into its binary significand (a floating point with an absolute value between 0.5(included) and 1.0(excluded)) and an integral exponent for 2
	double fractpart, intpart ;
	param = 3.14159265 ;
	fractpart = modf (param , &intpart) ;						// Breaks param into an integral and a fractional part
	param = 7.0 ;
	int power = 3 ;
	result = pow (param, power) ;								// param on the power of power
	param = 1024.0 ;
	result = sqrt (param) ;										// Square root
	param = 27.0 ;
	result = cbrt (param) ;										// Cubic root
	param = 2.3 ;
	result = ceil (param) ;										// Rounds x upward, returning the smallest integral value that is not less than param
	param = -2.3 ;
	result = ceil (param) ;
	param = 2.3 ;
	result = floor (param) ;									// Rounds x downward, returning the largest integral value that is not greater than param
	param = -2.3 ;
	result = ceil (param) ;
	param = 5.3 ;
	result = fmod (param, 2) ;									// Calculates the remainder after division
	result = remainder (param, 2) ;								// remainder = 5.3 - (round (5.3 / 2)) * 2 = -0.7
	result = trunc (param) ;									// Rounds param toward zero, returning the nearest integral value that is not larger in magnitude than param
	param = 2.3 ;
	result = round (param) ;									// Returns the integral value that is nearest to x, with halfway cases rounded away from zero
	result = round (5.5) ;										// 6
	result = round (-5.5) ;										// -6

	// Signal
	/*	SIGABRT	(Signal Abort) Abnormal termination, such as is initiated by the abort function.
		SIGFPE	(Signal Floating-Point Exception) Erroneous arithmetic operation, such as zero divide or an operation resulting in overflow (not necessarily with a floating-point operation).
		SIGILL	(Signal Illegal Instruction) Invalid function image, such as an illegal instruction. This is generally due to a corruption in the code or to an attempt to execute data.
		SIGINT	(Signal Interrupt) Interactive attention signal. Generally generated by the application user.
		SIGSEGV	(Signal Segmentation Violation) Invalid access to storage: When a program tries to read or write outside the memory it has allocated.
		SIGTERM	(Signal Terminate) Termination request sent to program.
	*/
	void (* prev_handler) (int) ;

	prev_handler = signal (SIGINT, my_handler) ;
	raise (SIGINT) ;
	cout << "Signaled: " << signaled << endl ;

	// Variable argument list
	varargs (4, 3.14159, 2.71828, 5.9, 1.41421) ;

	// Strings (char arrays)
	char * c_from = "Csacsika" ;
	char c_to [50] ;
	memcpy (c_to, c_from, strlen (c_from) + 1) ;				// Destination, source, number of chars to copy. Just bytes, from one memory location to another
	char mmove [] = "memmove can be very useful......" ;
	memmove (mmove + 20, mmove + 15, 11) ;						// It is a copy, not a move!
	memset (c_to, 0, 50) ;
	strcpy_s (c_to, c_from) ;									// Copies the source up to the terminating null char. String aware!
	memset (c_to, 0, 50) ;
	strncpy_s (c_to, c_from, 6) ;								// Copies only n chars
	memcpy (c_to, c_from, strlen (c_from) + 1) ;
	strcat_s (c_to, 50, " and Zsurni") ;						// Destination, buffr size, source
	strncat_s (c_to, " and who?", 9) ;							// Number of chars (9) to append (concat)

	char * str1 = "String1" ;
	char * str2 = "String2" ;
	int res = memcmp (str1, str2, 7) ;							// Compare two blocks of memory. Last param is the number of bytes to compare. Zero if equal
	res = strcmp (str1, str2) ;									// Same as memcmp but the comparison goes as far as the null char (string aware function)
	res = strncmp (str1, str2, 6) ;								// Compares the given number of chars only

	char * pch = (char*) memchr (c_from, 'i', strlen (c_from)) ; // Returns a pointer that points at the char the function searched for
	pch = strchr (c_from, 'i') ;								// Searches until the null char. Returns a pointer to the char searched (if found)
	pch = strchr (c_from, 'x') ;								// Or returns a NULL string if not found
	char alphanums [] = "fcba73xy" ;
	char nums [] = "1234567890" ;
	int first_occur = strcspn (alphanums, nums) ;				// Returns the first occurrance of any char of the second string in the first string
	pch = strpbrk (alphanums, nums) ;							// Same as before, just a pointer is returned rather than the position
	int span = strspn (alphanums, "abcdefghijklmnopqrstuvwxyz") ; // Returns the initial span of chars that match
	pch = strrchr (c_from, 's') ;								// Returns the last occurrance of the char searched
	pch = strstr (c_from, "cs") ;								// Returns a pointer to the first occurrance of the second string in the first string
	char * delimiters = ".;," ;
	char delimstr [] = "First sentence. Then semi-colon; Finally a comma,Then nothing." ;
	char * next_token = NULL ;
	pch = strtok_s (delimstr, delimiters, &next_token) ;		// Tokenizes a string
	while (pch != NULL) {
		cout << pch << endl ;
		pch = strtok_s (NULL, delimiters, &next_token) ;		// NULL means search from where the previous function left off
	}

	return 0 ;
}


void my_handler (int param) {
	signaled = 1 ;
}

void varargs (int n, ...) {
	int i ;
	double val ;
	va_list vl ;

	cout << "Printing floats:" << endl ;
	va_start (vl, n) ;											// From the last named parameter which is n in this case, build a list of arguments
	for (i = 0 ; i < n ; i ++) {
		val = va_arg (vl, double) ;								// Takes the next argument. Arguments must be the same size otherwise it fails! Like a pointer that gets advanced
		cout << val << endl ;
	}
	va_end (vl) ;
}
