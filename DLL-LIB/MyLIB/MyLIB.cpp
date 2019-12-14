// MyLIB.cpp : Defines the functions for the LIB application.
//

#include "MyLIB.h"
#include <stdexcept>
#include <iostream>


using namespace std;

namespace MyLIBFuncs
{
	double MyLIBFuncs::Add(double a, double b)
	{
		cout << "Called from a LIB. Returning " << a + b << endl;
		return a + b;
	}

	double MyLIBFuncs::Subtract(double a, double b)
	{
		cout << "Called from a LIB." << endl;
		return a - b;
	}

	double MyLIBFuncs::Multiply(double a, double b)
	{
		cout << "Called from a LIB." << endl;
		return a * b;
	}

	double MyLIBFuncs::Divide(double a, double b)
	{
		if (b == 0)
		{
			cout << "Called from a LIB." << endl;
			throw invalid_argument("b cannot be zero!");
		}
		cout << "Called from a LIB." << endl;
		return a / b;
	}
}



