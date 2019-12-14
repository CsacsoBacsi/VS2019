#pragma once
namespace MyDLLFuncs
{
	// This class is exported from the MyDll.dll
	class MyDLLFuncs
	{
	public:
		// Returns a + b
		static __declspec (dllexport) double Add (double a, double b);

		// Returns a - b
		static __declspec (dllexport) double Subtract (double a, double b);

		// Returns a * b
		static __declspec (dllexport) double Multiply (double a, double b);

		// Returns a / b
		// Throws const std::invalid_argument& if b is 0
		static __declspec (dllexport) double Divide (double a, double b);
	};
}
