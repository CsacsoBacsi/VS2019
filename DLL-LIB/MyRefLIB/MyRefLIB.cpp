// MyRefLIB.cpp : Defines the entry point for the console application.
//
// Project type: Static Library
// Creates MyLIB.lib
// Static linking at compile time
// Additional include dir: ../MyLIB/ to fetch MyLIB.h
// Project dependencies: MyLIB

#include "stdafx.h"
#include <iostream>
#include "MyLIB.h"

using namespace std;

int main()
{
	double a = 7;
	double b = 99;

	cout << "a + b = " <<
		MyLIBFuncs::MyLIBFuncs::Add(a, b) << endl;
	cout << "a - b = " <<
		MyLIBFuncs::MyLIBFuncs::Subtract(a, b) << endl;
	cout << "a * b = " <<
		MyLIBFuncs::MyLIBFuncs::Multiply(a, b) << endl;
	cout << "a / b = " <<
		MyLIBFuncs::MyLIBFuncs::Divide(a, b) << endl;

	return 0;
}

