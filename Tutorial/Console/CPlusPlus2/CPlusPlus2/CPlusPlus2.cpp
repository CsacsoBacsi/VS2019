// CPlusPlus2.cpp : This file contains the 'main' function. Program execution begins and ends there.
//

#include <iostream>
#include <algorithm>
#define __STDC_WANT_LIB_EXT1__ 1
#include <cstring>
#include <cstddef>
#include <vector>

#include "Globals.h" // .h files. Declare function prototypes or classes. Use gards like #paragma once not to include the same definition twice

int g_file_global = 5 ; // Has program duration, only visible in this file. Internal linkage
static int g_file_global_here = 0 ; // Global but visible only in this source file
int incr = 0 ;

inline void incr_func() ; // Prototype needed for compiler. Forward declaration

// Classes
class Calc
{
private:
    int m_value ; // Only member functions can access it

public:
    Calc() { m_value = 0 ; } // Constructor

    void add (int value) { m_value += value ; } // Setters
    void sub (int value) { m_value -= value ; }
    void mult (int value) { m_value *= value ; }

    int getValue() { return m_value ; } // Accessor

    Calc & add2(int value) { // References must be initialized! Thus "this" will live outside the function as it gets initialized! Also, it has been passed in, so exists outside!
        (*this).m_value += value ;
        return *this; // Safe to return it because exists outside. The caller passed it in as &mycalc
    }
    Calc & sub2(int value) { m_value -= value; return *this; }
    Calc & mult2(int value) { m_value *= value; return *this; }

    Calc * add3(int value) {
        (*this).m_value += value;
        return this;
    }
    Calc * sub3(int value) { m_value -= value; return this; }
    Calc * mult3(int value) { m_value *= value; return this; }

    Calc sub5 (int value) { m_value -= value; return *this; }
    Calc mult5 (int value) { m_value *= value ; return *this ; }
    Calc add5 (int value) { m_value += value; return *this; }

} ;

int main()
{
	int i1 = 5 ; // Copy initializer
	int i2 (5) ; // Direct initializer
    int * pi2 = &i2 ;
	int i3 {5} ; // Uniform initialization
	// int i3a { 5.1 } ; // Compiler error. Uniform init, checks if it is the correct type 
	int i4 {} ; // Zero initialization
    int i5 = 5, i6 = 5 ; // Multiple variables

    Calc mycalc, mycalc2, mycalc3, mycalc5, mycalc6 ;
    mycalc.add (6) ; // Compiler rewrites it: add (&mycalc, 6) passing in the "this" pointer so the function knows it has to add to this->m_value
    mycalc2.add2(5).mult2(2).sub2(1) ; // Chain of calls
    mycalc3.add3(5)->mult3(2)->sub3(1); // Chain of calls

    Calc mc = mycalc5.mult5 (3) ;
    Calc mc2 = mc.mult5(5) ;

    mycalc6.sub5 (5).mult5(2).add5(3) ;

    std::cout << "Hello World!\n" ; // Overloaded operator << 

std::cout << "bool:\t\t" << sizeof(bool) << " bytes" << std::endl;
std::cout << "char:\t\t" << sizeof(char) << " bytes" << std::endl;
std::cout << "wchar_t:\t" << sizeof(wchar_t) << " bytes" << std::endl;
std::cout << "char16_t:\t" << sizeof(char16_t) << " bytes" << std::endl; // C++11, may not be supported by your compiler
std::cout << "char32_t:\t" << sizeof(char32_t) << " bytes" << std::endl; // C++11, may not be supported by your compiler
std::cout << "short:\t\t" << sizeof(short) << " bytes" << std::endl;
std::cout << "int:\t\t" << sizeof(int) << " bytes" << std::endl;
std::cout << "long:\t\t" << sizeof(long) << " bytes" << std::endl;
std::cout << "long long:\t" << sizeof(long long) << " bytes" << std::endl; // C++11, may not be supported by your compiler
std::cout << "float:\t\t" << sizeof(float) << " bytes" << std::endl;
std::cout << "double:\t\t" << sizeof(double) << " bytes" << std::endl;
std::cout << "long double:\t" << sizeof(long double) << " bytes" << std::endl;

// Variables can now be declared anywhere in the code. This has lots of advantages. It does not affect anything above. Do not need to scroll to the top (declaration)
int g_file_global = -1 ;
// ::g_file_global means: global name space. Or used for namespace std::cout or for static class memebers: Myclass::Myfunc or MtClass::Mysubclass
::g_file_global ++ ;

// The size of int varies from machine to machine. However fixed ints do not!
/*
int8_t 1 byte signed - 128 to 127
uint8_t 1 byte unsigned 0 to 255
int16_t 2 byte signed - 32, 768 to 32, 767
uint16_t 2 byte unsigned 0 to 65, 535
int32_t 4 byte signed - 2, 147, 483, 648 to 2, 147, 483, 647
uint32_t 4 byte unsigned 0 to 4, 294, 967, 295
int64_t 8 byte signed - 9, 223, 372, 036, 854, 775, 808 to 9, 223, 372, 036, 854, 775, 807
uint64_t 8 byte unsigned 0 to 18, 446, 744, 073, 709, 551, 615
*/

//Fixed - width integers may not be supported on architectures where those types can’t be represented.They may also be less performant than the built - in types on some architectures.
//To help address the above downsides, C++11 also defines two alternative sets of fixed - width integers.
//The fast type(std::int_fast#_t) gives you an integer that’s the fastest type with a width of at least # bits(where #  = 8, 16, 32, or 64).For example, std::int_fast32_t will give you the fastest integer type that’s at least 32 bits.
//The least type(std::int_least#_t) gives you the smallest integer type with a width of at least # bits(where #  = 8, 16, 32, or 64).For example, std::int_least32_t will give you the smallest integer type that’s at least 32 bits.
double dbl = static_cast <double> (9) / 5 ; // Not an integer division anymore.
constexpr double pi(3.14159); // Compile time constant
const int myAge = 5 ; // Runtime because myAge is entered by the user
int x = 0;
int y = 2;
int z = (++x, ++y) ; // Evaluates to the rightmost value (3)
z = x, y ; // Evaluates to x. y is discarded

// Arrays
int prime [5] { 2, 3, 5, 7, 11 } ;
int prime2 [5] {} ;
int prime3 [] { 8, 1, 5, 7, 10, 9 } ;
std::cout << "Prime size: " << sizeof (prime) << " " << std::size (prime) << '\n' ; // 20 and 5

std::sort (prime3, prime3 + 6);

for (int i = 0; i < 6; ++ i)
    std::cout << prime3 [i] << ' ' ;
std::cout << '\n' ;

int array[][4] = { // Created on the stack! Limited!
{ 1, 2, 3, 4 },
{ 5, 6, 7, 8 }
} ;

std::vector<int> array_std{ 9, 7, 5, 3, 1 } ; // No need to delete (automatically freed when out of scope). Can be resized!
array_std.resize (15) ;
// Bool arrays are compacted into bytes, saving memory

// String
char myString[] = "string" ;
const size_t length = std::size (myString) ;
std::cout << myString << " has " << length << " characters.\n" ;
myString [1] = 'p' ;
char name[20] = "Csacsi" ;

char source [] = "Copy this!" ;
char dest [11] ; // Note that the length of dest is only 5 chars!
strcpy_s (dest, 11, source) ; // A runtime error will occur in debug mode
std::cout << dest << '\n' ;

// Pointers
char * chPtr ; // chars are 1 byte
int * iPtr ; // ints are usually 4 bytes
struct Something
{
    int nX, nY, nZ ;
};
Something * somethingPtr ; // Something is probably 12 bytes

std::cout << sizeof (chPtr) << '\n' ; // prints 8 for 64bit target
std::cout << sizeof (iPtr) << '\n' ; // prints 8
std::cout << sizeof (somethingPtr) << '\n'; // prints 8

int value5 = 5;
void *voidPtr = &value5;
//cout << *voidPtr << endl; // illegal: cannot dereference a void pointer
int *intPtr = static_cast<int*> (voidPtr) ; // At dereference time it has to be cast. The system then knows how many bytes from pointer[0]

/*
1) Arrays are implemented using pointers. Pointers can be used to iterate through an array (as an alternative to array indices) (covered in lesson 6.8).
2) They are the only way you can dynamically allocate memory in C++ (covered in lesson 6.9). This is by far the most common use case for pointers.
3) They can be used to pass a large amount of data to a function in a way that doesn’t involve copying the data, which is inefficient (covered in lesson 7.4)
4) They can be used to pass a function as a parameter to another function (covered in lesson 7.8).
5) They can be used to achieve polymorphism when dealing with inheritance (covered in lesson 12.1).
6) They can be used to have one struct/class point at another struct/class, to form a chain. This is useful in some more advanced data structures, such as linked lists and trees.
*/

int *ptr{ nullptr } ;

std::cout << "Array first value: " << * prime << '\n' ;
std::cout << &prime[1] << '\n'; // print memory address of array element 1
std::cout << prime + 1 << '\n'; // print memory address of array pointer + 1 

char myName1[] = "Csacsi"; // Fixed array
const char *myName2 = "Csacsi"; // pointer into read only memory. Can not be modified. Global scope!
std::cout << myName2 << '\n' ;

// Dynamic memory allocation
int * intptr = new int (5) ; // Created on the heap!
delete intptr;
intptr = nullptr ;

int *value = new (std::nothrow) int; // Ask for an integer's worth of memory
if (!value) // Handle case where new returned null
{
    std::cout << "Could not allocate memory";
}

int *array1 = new int[5] ; // Use array new.  Note that length does not need to be constant!
array1 [0] = 5; // set element 0 to value 5
delete[] array1;

int *array2 = new int[length] () ; // Initialize to zero

int **ptrptr ; // pointer to a pointer to an int, two asterisks
int value6 = 5;

int *ptr3 = &value6 ;
int **ptrptr2 = &ptr3 ;
std::cout << **ptrptr2 ;

int **array4 = new int * [10] ; // allocate an array of 10 int pointers
// int **array = new int[10][5]; // Does not work
int (*array5)[5] = new int[10][5]; // 10 pointers pointing at a 5 element array containing ints 
auto array6 = new int[10][5]; // so much simpler!

int **array7 = new int *[10] ; // allocate an array of 10 int pointers — these are our rows
for (int count = 0; count < 10; ++count)
    array7 [count] = new int [count + 1]; // these are our columns. New returns a pointer to count + 1 integer

for (int count = 0; count < 10; ++count)
    delete [] array [count] ;
delete [] array ;

// References
int value2 = 5; // normal integer
int &ref = value2 ; // reference to variable value
// Must be initialized. Can not be reassigned to reference an other variable
// Handy as function parameters
// References passed as params to function: void printElements(int (&arr)[4]) // They do not decay to pointers. They are copied

// For-each loop
int fibonacci[] = { 0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89 } ;
for (int number : fibonacci) // iterate over array fibonacci
std::cout << number << ' '; // we access the array element for this iteration through variable number

for (auto &element : fibonacci) // The ampersand makes element a reference to the actual array element, preventing a copy from being made. Faster
std::cout << element << ' ';

incr_func () ; // Function calls are expensive. With the inline keyword, the compiler copies here the seed of the function (useful when the seed is small). Results in more code though!
incr_func () ;

}

// **********************************************************************
// Functions section
// **********************************************************************

void doSomething (std::nullptr_t ptr) // std::nullptr_t is a type
{
    static int still_global = 0 ;
    std::cout << "in doSomething()\n" ;
    still_global ++ ; // Keeps value between function calls 
}

// If we know that a function should not change the value of an argument, but don’t want to pass by value, because we do not want it to be copied as it is huge,
// the best solution is to pass by const reference."

void myfunc2 (const int &whatever_var)
{
    int whatever_var2 = whatever_var;
}
// Possible to pass a pointer by reference as well *& both together!Pointer can be changed then e.g.to null pointer.
void myfunc3 (const int *&intptr)
{
    intptr = nullptr ;
}
static void myfunc4 (const int *&intptr) // Only visible in current source file
{
    intptr = nullptr ;
}
inline void incr_func () {
    incr ++ ;
}