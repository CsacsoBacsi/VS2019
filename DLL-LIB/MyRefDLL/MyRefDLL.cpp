// MyRefDLL.cpp : Defines the entry point for the console application.
//
// Project type: Dynamic Link Library
// Creates MyDLL.dll
// Dynamic linking at Load time or Run time
// Linking with additional dependency/reference (MyDLL.lib - import library) does Load time or compile time linking
// Not linking with the import library and using LoadLibrary with GetProcAddress does Run time linking
// Additional include dir: ../MyDLL/ to fetch MyDLL.h
// Project dependencies: MyDLL

#include "stdafx.h"
#include <iostream>
#include "MyDLL.h"
#include <windows.h>
#include <tchar.h>

using namespace std;

typedef double (__cdecl *MyProc) (double, double);

int main()
{
	double a = 7;
	double b = 99;
	double returnval;
	HINSTANCE LibHandle ;
	MyProc ProcAdd ;
	BOOL Result;

	cout << "EXE running..." << endl;

	SetDllDirectory(_T ("D:\\VS2015Projects\\DLL - LIB\\Debug"));
	LibHandle = LoadLibrary(_T("MyDLL.dll"));

	if (LibHandle != NULL)
	{
		ProcAdd = (MyProc) GetProcAddress (LibHandle, "?Add@MyDLLFuncs@1@SANNN@Z");
		// If the function address is valid, call the function.
		if (NULL != ProcAdd)
		{
			returnval = (ProcAdd)(a, b);
			cout << "a + b = " << returnval << endl ;
		}
		// Free the DLL module.

		Result = FreeLibrary (LibHandle);
	}

	/*cout << "a + b = " <<
		MyDLLFuncs::MyDLLFuncs::Add(a, b) << endl;
	cout << "a - b = " <<
		MyDLLFuncs::MyDLLFuncs::Subtract(a, b) << endl;
	cout << "a * b = " <<
		MyDLLFuncs::MyDLLFuncs::Multiply(a, b) << endl;
	cout << "a / b = " <<
		MyDLLFuncs::MyDLLFuncs::Divide(a, b) << endl;
		*/
	try
	{
		//cout << "a / 0 = " << "";
			//MyDLLFuncs::MyDLLFuncs::Divide(a, 0) << endl;
	}
	catch (const invalid_argument &e)
	{
		cout << "Caught exception: " << e.what() << endl;
	}

	return 0;
}

