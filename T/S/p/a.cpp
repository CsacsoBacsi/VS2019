#include <iostream>
#include <stdio.h>
#include <io.h>
#include <conio.h>
#include <stdlib.h>

using namespace std;

extern "C" int getValFromASM(int, int, int, int, int, int, int); // External function prototype. Does not apply name mengling -> "C"
extern "C" int getValFromASM2(int, int, int, int, int, int, int); // External function prototype. Does not apply name mengling -> "C"

int func (int a, int b, int c, int d, int e, int f) {
	int g = 255;
	int h = 254;
	int i = g + d ;
	int j = h + e ;
	return i + j ;
}

int main()
{
	int ch = 1 ;
	ch = func (1, 2, 3, 4, 5, 6) ; // First four params passed in RCX, RDX, R8, R9. The rest on the stack

	cout << "Retval from ASM:" << getValFromASM(9, 10, 11, 12, 13, 14, 15) << endl;
	cout << "Retval from ASM:" << getValFromASM2 (9, 10, 11, 12, 13, 14, 15) << endl;
	ch = _getch(); // Wait for a key to be pressed. Prevents the execution window from closing

	return 0;
}

