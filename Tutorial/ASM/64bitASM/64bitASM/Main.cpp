#include <iostream>
#include <stdio.h>
#include <io.h>
#include <conio.h>
#include <stdlib.h>

using namespace std ;

extern "C" int getValFromASM () ; // External function prototype. Does not apply name mengling -> "C"

int main ()
{
	int ch ;

	cout << "Retval from ASM:" << getValFromASM() << endl ;
	ch = _getch () ; // Wait for a key to be pressed. Prevents the execution window from closing
	return 0 ;

}
