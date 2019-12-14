// Stdio.cpp : Defines the entry point for the console application.
//

#include <stdio.h>
#include <iostream>
#include <conio.h>

using namespace std ;

int main ()
{
	// *** Input-output streams/files ***

	FILE * pFile ;
	char buffer [2048] ;
	char oldname [] = "c:\\temp\\myfile.txt";
	char newname[] = "c:\\temp\\myfile2.txt";

	/* "r"	read: Open file for input operations. The file must exist.
	   "w"  write: Create an empty file for output operations. If a file with the same name already exists, its contents are discarded and the file is treated as a new empty file.
	   "a"  append: Open file for output at the end of a file. Output operations always write data at the end of the file, expanding it. Repositioning operations (fseek, fsetpos, rewind) are ignored. The file is created if it does not exist.
	   "r+" read/update: Open a file for update (both for input and output). The file must exist.
	   "w+" write/update: Create an empty file and open it for update (both for input and output). If a file with the same name already exists its contents are discarded and the file is treated as a new empty file.
	   "a+" append/update: Open a file for update (both for input and output) with all output operations writing data at the end of the file. Repositioning operations (fseek, fsetpos, rewind) affects the next input operations, but output operations move the position back to the end of file. The file is created if it does not exist.
	*/

	/* Streams can be either fully buffered, line buffered or unbuffered. 
	   On fully buffered streams, data is read/written when the buffer is filled, (_IOFBF)
	   on line buffered streams this happens when a new-line character is encountered, (_IOLBF)
	   and on unbuffered streams characters are intended to be read/written as soon as possible (_IONBF)
	*/

	fopen_s (&pFile, oldname, "w") ;
	if (pFile != NULL)
	{
		fputs ("fopen_s example", pFile) ;
		setvbuf (pFile, buffer, _IOFBF, sizeof (buffer)) ;		// Sets the buffer size. If NULL, the stream is unbuffered. Must be the first operation after open. Fully buffered
		fflush (pFile) ;										// Flushes the buffer
		fclose (pFile) ;										// This one does a flush as well
	}

	int result = rename (oldname , newname);
	if (result == 0)
		cout << "File successfully renamed" << endl ;
	else
		cout << "Error renaming file" << endl ;

	if (remove (newname) != 0)									// Delete file
		cout << "Error deleting file" << endl ;
	else
		cout << "File successfully deleted" << endl ;

	tmpfile_s (&pFile) ;										// Creates a temporary file with a unique name
	int c ;
	fputs ("tmpfile example", pFile) ;							// Puts a whole string in the file
	fputc ('!', pFile) ;										// Puts a siongle char in the file
	rewind (pFile) ;
	do {
		c = fgetc (pFile) ;										// Get one char at a time
		cout << char (c) ;
	} while (c != EOF) ;										// EOF = -1
	cout << endl ;

	rewind (pFile) ;
	char input [100] ;
	if (fgets (input, 100, pFile) != NULL)						// Get a whole string until CRLF or EOF or max size (saecond param)
		cout << input << endl ;

	rewind (pFile) ;
	result = fread (buffer, 1 , 10, pFile) ;					// Reads a block of n bytes from the file
	fpos_t pos ;
	fgetpos (pFile, &pos) ;										// Gets the current position in the stream/file
	/* SEEK_SET	Beginning of file
	   SEEK_CUR	Current position of the file pointer
	   SEEK_END	End of file
	*/
	fseek (pFile, 1, SEEK_CUR) ;								// 1 char away from the current position
	char singlebuff [1] ;
	result = fread (singlebuff, 1, 1, pFile) ;

	fseek (pFile, 0, SEEK_END) ;								// Take position at the end
	fwrite (" Zsurni**", 1, 7, pFile) ;							// Write from a buffer (each element being 1 char wide), 7 chars
	rewind (pFile) ;
	fgets (buffer, 30, pFile) ;
	fclose (pFile) ;											// Temp file gets discarded

	// char got = _getch () ;										// Fetch a char from stdin not waiting for ENTER

	// *** Formatted input/output ***
	/* d or i	Signed decimal integer								392
	   u		Unsigned decimal integer							7235
	   o		Unsigned octal										610
	   x		Unsigned hexadecimal integer						7fa
	   X		Unsigned hexadecimal integer (uppercase)			7FA
	   f		Decimal floating point, lowercase					392.65
	   F		Decimal floating point, uppercase					392.65
	   e		Scientific notation (mantissa/exponent), lowercase	3.9265e+2
	   E		Scientific notation (mantissa/exponent), uppercase	3.9265E+2
	   g		Use the shortest representation: %e or %f			392.65
	   G		Use the shortest representation: %E or %F			392.65
	   a		Hexadecimal floating point, lowercase				-0xc.90fep-2
	   A		Hexadecimal floating point, uppercase				-0XC.90FEP-2
	   c		Character											a
	   s		String of characters								sample
	   p		Pointer address										b8000000
	   n		Nothing printed
	   %		A % followed by another % character will write a single % to the stream	%
	*/

	fopen_s (&pFile, oldname, "w") ;
	fprintf (pFile, "%s", "%s string\n") ;
	fprintf (pFile, "%s%d", "%d integer ", 255) ;
	snprintf (buffer, 100, "%.2f", 12.345) ;
	sprintf_s (buffer, "%d", 250) ;								// Same as snprintf but no size is specified

	char str1 [80] ;
	int i ;
	scanf_s ("%s", str1, 79) ;									// Formatted input. Last param is the number of chars to read
	scanf_s ("%d", &i) ;

	fclose (pFile) ;

    return 0 ;													// Temp file gets automatically deleted upon normal program termination
}

