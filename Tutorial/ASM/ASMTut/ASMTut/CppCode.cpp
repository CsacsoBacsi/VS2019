#include <iostream>
#include <conio.h>
#include <ctime>

using namespace std ;

/*int MyASMFunc ()
{
	_asm { // Inline assembly
		mov eax, 100 // 32 bit Assembly only!
	}
}*/

extern "C" long long ASMFunc (long long, long long, long long, long long, long long, long long) ; // No name mangling just an underscore
extern "C" long long CalledFromCpp (long long, long long, long long, long long, long long, long long) ;
extern "C" long long CalledFromASM (long long, long long, long long, long long, long long, long long) ;


int main()
{
	long long p1 = 1l, p2 = 2l, p3 = 3l, p4 = 4l, p5 = 5l, p6 = 6l ;
	long long ap1 = 11l, ap2 = 12l, ap3 = 13l, ap4 = 14l, ap5 = 15l, ap6 = 16l ; // 81
	
	long long retvalC ;
	long long retvalASM ;

	// Calling C++ from C++
	retvalC = CalledFromCpp (p1, p2, p3, p4, p5, p6) ; // 42			
	cout << "Returning value from C++ function: " << retvalC << endl ;

	// Calling ASM from C++ (which in turn calls C++)
	retvalASM = ASMFunc (ap1, ap2, ap3, ap4, ap5, ap6) ; // 81 (params to ASM) + 96 (ASM local vars) + 21 (ASM params for C++) + 4 (C++ local vars) = 202
	cout << "Returning value from ASM function: " << retvalASM << endl ;
	
	_getch() ; // Press any key
	return 0 ;
}

long long CalledFromCpp (long long rp1, long long rp2, long long rp3, long long rp4, long long rp5, long long rp6)
{
	long long lv1 = 10 ;
	long long lv2 = 11 ;
	
	return rp1 + rp2 + rp3 + rp4 + rp5 + rp6 + lv1 + lv2 ; // 42
}

long long CalledFromASM (long long rp1, long long rp2, long long rp3, long long rp4, long long rp5, long long rp6)
{
	long long lv1 = 1;
	long long lv2 = 3;

	return rp1 + rp2 + rp3 + rp4 + rp5 + rp6 + lv1 + lv2 ; // 21 (ASM params for C++) + 4 (local vars) = 25
}