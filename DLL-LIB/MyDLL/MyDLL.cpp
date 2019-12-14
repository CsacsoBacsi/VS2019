// MyDLL.cpp : Defines the exported functions for the DLL application.
//

#include "stdafx.h"
#include "MyDLL.h"
#include <stdexcept>
#include <iostream>


using namespace std;

namespace MyDLLFuncs
{
	double MyDLLFuncs::Add(double a, double b)
	{
		cout << "Called from a DLL. Returning " << a + b << endl;
		return a + b;
	}

	double MyDLLFuncs::Subtract(double a, double b)
	{
		cout << "Called from a DLL." << endl;
		return a - b;
	}

	double MyDLLFuncs::Multiply(double a, double b)
	{
		cout << "Called from a DLL." << endl;
		return a * b;
	}

	double MyDLLFuncs::Divide(double a, double b)
	{
		if (b == 0)
		{
			cout << "Called from a DLL." << endl;
			throw invalid_argument("b cannot be zero!");
		}
		cout << "Called from a DLL." << endl;
		return a / b;
	}
}



