// Cplusplus.cpp : Defines the entry point for the console application.
//

#include <iostream>
#include <iomanip>
#include <cstdarg>
#include <string>
#include <vector>
#include <thread>

// No need for namespace notation
using std::cout;
using std::cin;
using std::endl;
using std::setw;
using std::string;
using std::getline;
using std::vector;
using std::thread;

void * renew (void *, size_t, size_t) ;
int incr1 (int = 5) ;
int incr2 (int*) ;
double avg (double array[][3], int n) ;
int incr3 (int& num) ;
int incr4 (int&& num) ;
int incr5(int num);
int sum2(int, ...);
void thread_function ();
double & lowest(double a[], int len);
double something2 = 6.6;

template <typename T, typename S> // T and S could be of different types
S Twice(T data1, S data2)
{
	return (data1 + data2) * 2;
}

class CBox // C-prefix. For MFC, it is also an m_ - prefix
{
public:
	double m_Length;
	double m_Width;
	double m_Height;
	double m_something;
	static int objectCount;
	double Volume2 () ; // Declared outside of the class


	double Volume ()
	{
		return m_Length * m_Width * m_Height ;
	}

	// CBox () {} // Default constructor

	CBox (double lv = 1.0, double bv = 1.0, double hv = 1.0) // Default values
	{
		cout << endl << "Constructor called with default values." << endl ;
		m_Length = lv; // Set values of
		m_Width = bv; // data members
		m_Height = hv;
		objectCount ++ ;
	}

	// Constructor definition using an initialization list/*
/*	CBox (double lv = 1.0, double bv = 1.0, double hv = 1.0, double ss = 1.1) :
		m_Length(lv), m_Width(bv), m_Height(hv), m_something (ss)
	{
		cout << endl << "Constructor called.";
	} */

	// ~CBox() ; // Class destructor prototype

	~CBox() // Gets called automatically at the end of the program
	{
		cout << "Destructor called." << endl;
		// Should be used to delete anything allocated by the new operator
	}

	int getprivnum ()
	{
		return m_privnum ;
	}

	bool Compare (CBox& xBox)
	{
		return this->Volume() > xBox.Volume(); // 'this' points to the current object
	}

	static double statFunc(int mynum)
	{
		return mynum * objectCount; // Accesses static variables
	}

	bool CBox::operator<(CBox& aBox) // Overloaded 'less than'
	{
		return this->Volume() < aBox.Volume();
	}
	
	bool operator==(CBox& aBox) // Overloaded equality operator
	{
		return this->Volume() == aBox.Volume();
	}

	// Function to compare a CBox object with a constant
	bool CBox::operator<(double& value)
	{
		return this->Volume() < value ;
	}

private:
	int m_privnum = 500 ;

};

int CBox::objectCount (0) ; // Initialize static member of CBox class

class TheClass // 
{
public:
	int pub_member1 = 1;
	int pub_member2 = 2;

	int get_priv_m1(void) { return priv_member1; };
	int get_pub_members(void) { return get_pub_members1(); };
	virtual int get_pub_members1(void) { return pub_member1 * pub_member2; };

	static int stat_member1 ;

protected:
	int prot_member1 = 3;

private:
	int priv_member1 = 4;
	int priv_member2 = 5;
};

int TheClass::stat_member1 = -1;

class TC1: public TheClass { // Inherits members with the original access specifier. Protected: all become protected. Private is the default
public:
	int pub_member3 = 6;
	int pub_member4 = 7;
	int get_prot_m1(void) { return prot_member1; };

	virtual int get_pub_members1(void) { return pub_member1 * pub_member2 * 5; };
};

class FClass final // Can not be inherited
{
public:
	int pub_member1 = 5;
};

class absClass
{
public:
	double m_Length;
	double m_Width;
	double m_Height;

	// Function for calculating a volume - no content
	// This is defined as a 'pure' virtual function, signified by '= 0'
	virtual double Volume3() const = 0;
	virtual void ShowVolume() const = 0;
};

// Abstract class can not be instantiated. It must be derived
class myabsClass : public absClass // Derived class
{
public:
	// Function to calculate the volume of a CBox object
	virtual double Volume3() const override // you are not overriding, only the virtual function that must have the same signature
	{
		return m_Length*m_Width*m_Height;
	}

	// Function to show the volume of an object
	virtual void ShowVolume() const override
	{
		std::cout << std::endl << "My abstract class usable volume is " << Volume3();

	}
};

// Namespaces
namespace myns {
	int myinteger = 10;
}

int get_bit (int num, int pos) {
    int mask = pow (pos,  2) ;
    return num & mask ? 1 : 0 ;
} ;

int main (int argc, char* argv[])
{
    printf("Bit is %d", get_bit (5, 2)) ;
    printf("Bit is %d", get_bit(16, 4)) ;
    printf("Bit is %d", get_bit(16, 3)) ;
    printf("Bit is %d", get_bit(129, 7)) ;
    printf("Bit is %d", get_bit(129, 1));
    printf("Bit is %d", get_bit(129, 2));

	// Command line arguments
	for (int i = 0; i <argc; i++)
		cout << "argument " << (i + 1) << ": " << argv[i] << endl ;

	// Variables
	double *HowMuch = new double(43.0);

	static int m = 1;
	const int arrsize = 20;
	char letter('R'); // Functional init
	short int byte4 = 5;
	long int byte8 = 12345678;
	bool thistrue = true; // Lowercase!
	typedef int myint; // Type definition
	myint myinteger = 25;
	int a, b = 5; //
	a = ++b; // 6
	int c, d = 5;
	c = d++; // 5

	// Pointers
	int i = 128;
	m = 2;
	int k = i;
	int *p = &i;
	p++;
	p--;
	*p = 129;
	int * nullp(nullptr);
	char * proverb("A miss is as good as a mile."); // Pointer being initialized
	const char* const pstring("Some text"); // Neither the pointer nor the content can be modified
	char buffer[6] = "12345";
	char * pbuffer = buffer; // Same
	cout << endl << "  " << *(pbuffer + 2) << endl;

	int beans[2][5];
	int * pbeans(&beans[0][0]);
	int * pbeans2(beans[2]);
	int (*pbeans3)[5] = beans;
	int k2 = 4;
	int * pbeans4 = &k2;
	int ** pbeans5 = &pbeans4 ;
	int pp = ** pbeans5;
	int *** ppp = &pbeans5 ; // ppp is a pointer to pointer that points at a pointer that points at 4
	int j = 3;
	i=1;
	int onebean = *(*(beans + i) + j);
	int ** ptrke = new int * [5];
	for (int i = 0; i<5; ++i)
		ptrke[i] = new int[19];


	// Streams
	int numb1 = 1234, numb2 = 5678;
	int height;
	cout << endl; // Start on a new line
	cout << numb1 << setw(6) << setiosflags(std::ios::left) << numb2; // Output two values. Formatted one
	cout << endl;

	cout << endl // Start a new line
		<< "Enter the height of the room in inches: ";
	cin >> height;

	// Casts
	double value2 = 15.5;
	int whole_number = static_cast<int>(value2);
	cout << endl << whole_number << endl;
	
	int another_int = (int) value2; // Old style cast
	auto integ = 10; // Must be initialized to have a type

	int x = 10;
	double y = 5.5;
	cout << "The type of x*y is " << typeid(x*y).name() << endl; // Type info object

	// Bit-wise operations
	char letter1 = 'A', letter2 = 'Z', result = 0;
	result = letter1 & letter2;
	cout << endl << result << endl;

	// Namespaces
	cout << endl << "Main:" << myinteger << "My nspace:" << myns::myinteger << endl;

	//Enums
	enum myenum {One, Two, Three, Four, Five}; //Just a set constants 
	cout << myenum::Four << endl; // Number 3 is output

	// Arrays
	int engine_size[5] = { 200, 250, 300, 350, 400 };
	int second = engine_size[2];
	long data[100] = { 0 }; // Init to zero the whole array

	int arrvalue []{ 2, 3, 4 }; // New init syntax

	double temperatures[] = { 65.5, 68.0, 75.0, 77.5, 76.4, 73.8,80.1 };
	double sum = 0.0;
	for (double t : temperatures) // Range based FOR loop
	   sum += t;
	cout << "Total temp:" << sum << endl;

	char movie_star[15] = "Cruise";
	cout << movie_star[4];

	char name[50]; // Array to store a string
	cin.getline(name, 50, '\n');

	char stars[][80] = { "Lilla", "Me" }; 
	char * pstr[] = { "Lilla", "Me" };
	cout << (sizeof temperatures) / (sizeof temperatures[0]) << endl; // Size of the wgole array divided by the furst element size. Gets the number of lements

	int vec[] = { 0,1,2,3,4,5,6,7,8,9 } ;
	for (auto x : vec) // For each x in vec. Loop over each member of the collection
		cout << x << '\n';
	for (auto x : { 10,21,32,43,54,65 })
		cout << x << '\n';

    // Pre-post increment
    int ic = 0 ;
    printf ("IC value: %d", ic ++) ; // Prints zero
    int ica [3] = {5,6,7} ;

    ic = 0 ;
    if (ic++ > 0 && ica[i] == 6) { // Not true as ic++ is zero at the time of the evaluation. ica[i] = 6 though
        printf ("True") ;
    }
    ic = 0;
    if (ic++ > 0 || ica[i] == 6) { // True as the second part ica[i] is true as it is 6
        printf("True");
    }

	// Allocating memory
	char *dynchar = new char [20];
	dynchar[0] = 'X';
	char * dynchar2 = (char *) renew (dynchar, 20, 30);
	cout << endl << "The char:" << dynchar2[0] << endl;

	// Reference
	long lnumber = 10L;
	long & rlnumber(lnumber); 
	rlnumber ++; // = * plnumber ++ 

	float FtoC = 9 / 5;
	for (auto& t : temperatures)
		t = (t - 32)*FtoC; // The array elements are modified. Without reference, a value is only copied into t

	int xx(5);
	int&& rExpr = 2 * xx + 3; // Rvalue reference
	int rExpr2 = 2 * xx + 3;
	
	// String functions
	// strcmp - compare strings
    // strcat - Concatenate
	// strcpy - string copy
	// strspn - search chars of a string in another
	// strstr - search string in another

	char dest[11] = "Dest" ;
	char * src = "Source" ;
	char * findme = "u" ;
	errno_t val = strcat_s (dest, sizeof (dest), src) ;
	strcpy_s (dest, sizeof (dest), src) ;
	char * found = strstr (dest, findme) ;
	//src [2] = 'i' ;												// String created on the heap, str just points at it. Not mutable!
	char pocsom [] = "Pocsom" ;
	pocsom[2] = 'a' ;
	dest[2] = 'i' ;
	char * dest2 = "Dest2" ;
	char * src2 = "Src2" ;
	//strcpy_s (dest2, sizeof (dest2), src2) ;						// Dest2 is immutable!

	// Functions
	int num1 = 8;
	int res1 = incr1(num1) ; // Pass by value
	int res11 = incr1(5 + 6);

	int num2 = 9;
	int res2 = incr2(&num2) ; // Pass by pointer
	cout << endl << num2 << endl << res2 ;

	double arr[2][3] = {{1.0, 2.0, 3.0},{5.0, 6.0, 7.0}} ; // Pass an array
	cout << endl << "Average = " << avg (arr, sizeof arr / sizeof arr[0]) << endl ;

	int num3 = 9 ;
	int res3 = incr3 (num3) ; // Pass by reference. Same as pass by value but no copy of the value is made therefore quicker.
	// Access it inside the function the same way as pass by value
	cout << endl << num3 << result ;
	//int res31 = incr3(5 + 6); // Does not compile

	int num4 (3) ;
	int value4 (6) ;
	result = incr4 (value4 + num4) ; // Increment a rvalue expression
	cout << endl << "incr(value+num) = " << result ;

	result = incr5 (value4 + num4); // Increment a rvalue expression 2
	cout << endl << "incr(value+num) = " << result;


	cout << sum2 (6, 2, 4, 6, 8, 10, 12) << endl; // Variable number of parameters
	cout << sum2 (9, 11, 22, 33, 44, 55, 66, 77, 66, 99) << endl;

	double data2[] = {3.0, 10.0, 1.5, 15.0, 2.7, 23.0, 4.5, 12.0, 6.8, 13.5, 2.1, 14.0 };
	int len = _countof(data2) ;
	lowest (data2, len) = 6.9 ; // Change lowest to 6.9. Returning a reference to an lvalue
	lowest (data2, len) = 7.9 ; // Sets the lowest value

	int (* pfun1)(int); // Pointer to a function
	double * pfun2 (char*, int); // A function that returns a pointer to a double
	pfun1 = incr1 ; // Just a function name
	int res5 = pfun1 (9) ;
	int res6 = incr1(); // Default value is 5
	double * retval5 = pfun2("Haliho", 10);

	// Function templates
	cout << Twice(10, 20) << endl; // Int and int
	cout << Twice(5, 3.14) << endl; // Int and float


	// Exceptions
	try { // Outer try}
		try
		{
			// int i = 0 ;
			int i = 101;

			if (i == 0) {
				throw "Division by zero";
			}
			if (i > 100) {
				throw i;
			}
		}
		catch (const char * ex)
		{
			cout << "Exception: " << ex << endl;
		}
		catch (const int& ex)
		{
			// Process the exception
			cout << "Integer inner exception: " << ex << endl;
			throw; // Rethrow the exception for processing by the caller
		}
	}
	catch (const int ex)
	{
		cout << "Integer outer exception: " << ex << endl;
	}

	// Decltype
	double val5 = 100.56;
	int val6 = 200;
	decltype(val5 * val6) sum5(0) ; // sum is defined as double
	cout << typeid (sum5).name() << endl ;

	// Structures
	struct RECTANGLE // Defines
	{
		int Left;
		int Top;
		int Right;
		int Bottom;
	} ;
	RECTANGLE rect1, rect2; // Allocates memory

	rect1.Left = 5 ;
	rect2.Top = 10 ;

	RECTANGLE * prect1 = &rect1 ;
	(*prect1).Right = 8 ;

	// Classes
	CBox bigBox; // Declare a variable which is a class
	bigBox.m_Height = 5;
	bigBox.m_Length = 3;
	bigBox.m_Width = 2;
	
	cout << endl
		<< "Volume of box1 = " << bigBox.Volume () << endl ;

	cout << endl
		<< "Volume2 of box1 = " << bigBox.Volume2() << endl;

	cout << endl
		<< "Private number = " << bigBox.getprivnum() << endl;

	CBox boxes[5] ; // Array of objects

	cout << endl
		<< "Object count = " << bigBox.objectCount << endl;

	CBox::statFunc (10) ; // Calling a static function

	CBox cigar;
	CBox* pcigar (&cigar) ; // Initialize pointer to cigar object address

	cout << endl
		<< "Volume2 of cigar box = " << pcigar->Volume2() << endl;

	CBox& rcigar (cigar); // Define reference to object cigar
	cout << endl
		<< "Volume2 of cigar box = " << rcigar.Volume2() << endl; // Reference is just an alias, so use it as a normal object

	union shareLD // Sharing memory between long and double
	{
		double dval;
		long lval;
	} myUnion ;

	// Or shareLD myUnion ;
	myUnion.lval = 100; // Using a member of a union

	union // Anonymous union
	{
		char* pval;
		double dval;
		long lval;
	};
	dval = 55.5; // Refer to a member without a union name

	// Operator overloading
	if (bigBox == cigar)
		cout << endl << "bigBox is equal to cigar";
	else
		cout << endl << "bigBox is not equal to cigar";

	// The string class
	string sentence = "This sentence is false.";
	cout << "The string is of length " << sentence.length() << endl;
	string sentence2 ;
	// getline(cin, sentence2, '*');

	string bees(7, 'b');
	string letters(bees); // Init with another string

	string combined;
	sentence2 = sentence2 + "\n"; // Append string containing newline
	combined = sentence + sentence2; // Concatenate
	cout << combined << endl;

	if (combined.empty())
	{
		cout << "Combined is empty" << endl;
	}

	string sentence3("Too many cooks spoil the broth.");
	for (size_t i = 0; i < sentence3.length(); i++)
	{
		if (' ' == sentence3[i])
			sentence3[i] = '*';
	}
	string sentence4("Too many cooks spoil the broth.");
	for (auto & ch : sentence4)
	{
		if (' ' == ch)
			ch = '*';
	}
	cout << "Sentence4: " << sentence4 << endl;

	string query("Any"); // Append
	string phrase("phrase12345");
	query.append(phrase, 3, 5).append(1, '?'); // From position 3 five chars

	string saying = "This is a saying."; // Insert
	saying.insert(16, " ").insert(17, "that is insertedxxxx", 0, 16);
	cout << "Saying: " << saying << endl;

	string proverb2 = "A nod is as good as a wink to a blind horse"; // Replace
	string sentence7("It's bath time!");
	proverb2.replace(38, 5, sentence7, 5, 3);

	string dog1("Lucy"); // Compare
	string dog2("Daisy");
	if (dog1 < dog2)
		cout << "Dog2 comes first!" << endl;
	else if (dog1 > dog2)
		cout << "Dog1 comes first!" << endl;
	
	dog1.swap(dog2); // Swap

	string phrase2("So near and yet so far"); // Search
	string str2("So near");
	cout << phrase2.find(str2) << endl; // Outputs 0
	cout << phrase2.find("so far") << endl; // Outputs 16

	string str10 = "123456789012345"; // Last occurence
	cout << "Last occurence of 1 is: " << str10.find_last_of("123", 14, 2) << endl;

	cout << "substring of 123456789012345: " << str10.substr (3, 5) << endl; // Substring

	// Class inheritence
	TC1 myTC1; // Create derived class instance
	
	cout << myTC1.get_priv_m1 () << endl;
	// cout << myTC1.priv_member1 << endl; // Inaccessible
	// cout << TheClass::prot_member1 << endl; // Inaccessible. Must be static or an instance is needed
	cout << myTC1.get_prot_m1 () << endl; // Accessible by derived class functions
	cout << TheClass::stat_member1 << endl; // Only static member via the base class otherwise an object (instance) is needed

	cout << myTC1.get_pub_members() << endl; // Early binding. Static binding. Calls the get_members1 function of the base class not the derived class!
	// Virtual function. Late binding. Dynamic binding. Calls the function of the right object
	
	// Pointers to classes

	CBox * pBox (nullptr); // Pointer to base class objects only
	CBox myBox; // Creates the object instance
	pBox = &myBox; // Set pointer to address of instance
	pBox-> Volume(); // Display volume of base box
	pBox = &cigar; // Set pointer to derived class object
	pBox->Volume(); // Display volume of derived box

	CBox * pBox2 = new CBox ; // Does 3 things: declares pointer to a CBox, creates a new CBox, sets pointer to new object
	pBox2->Volume() ;

	// Class cast
	TheClass * pContainer = new TC1 ;
	TheClass * pBox5 = dynamic_cast<TheClass*> (pContainer); // Upcast
	TC1 * pBox6 = dynamic_cast<TC1*>(pContainer); // Cast to the correct type. Dynamic means check at runtime. Otherwise static_cast

	// Standard Template Library
	// Containers

	auto data21 = new vector <CBox> () ;
	
	// Threads
	int yn = int (5) ;
	thread t1 = thread  (&thread_function) ; // t1 starts running
	cout << "Main thread\n" ;
	t1.join () ;   // main thread waits for the thread t to finish

	// Exit
	return 0 ; // 0 = false, no error
}

inline double CBox::Volume2() // Because it is declared outside the class, use ::
{
	return m_Length*m_Width*m_Height;
}

void * renew (void * ptr, size_t origsize, size_t newsize) {
	// no error checking here - it should be done.
	void *p = new char[newsize] ;
	memcpy (p, ptr, origsize) ;
	return p ;
}

// Functions
void thread_function ()
{
	cout << "Thread function called\n";
	std::this_thread::sleep_for (std::chrono::seconds (10)) ;
	cout << "Woke up\n";
}

int incr1 (int num)
{
	num++;
	return num;
}

int incr2 (int * num)
{
	(*num) ++ ; // Modify caller's variable via pointer
	return 0;
}

double avg (double arr[][3], int count)
{
	double sum (0.0) ;

	for (int i = 0; i < count; i++)
		for (int j = 0; j < 3; j++)
			sum += arr[i][j];
	return sum;
}

int incr3 (int& number)
// int incr3(const int& number)
{
	cout << endl << "Value received = " << number;
	number ++; // Increment caller's variable via reference 
	return 0;
}

int incr4(int&& num)
{
	cout << endl << "Value received = " << num;
	num++;
	return 0;
}

int incr5(int num)
{
	cout << endl << "Value received = " << num;
	num++;
	return 0;
}

int sum2(int count, ...)
{
	if (count <= 0)
		return 0 ;
	va_list arg_ptr; // Declare argument list pointer
	va_start (arg_ptr, count); // Set arg_ptr to 1st optional argument
	int sum (0);
	for (int i = 0; i<count; i++)
		sum += va_arg(arg_ptr, int); // Add int value from arg_ptr and increment
	va_end(arg_ptr); // Reset the pointer to null
	return sum;
}

// Never, ever, return the address of a local automatic variable from a function.
// Only a pointer created by New

double & lowest (double a[], const int len)
{
	int j = 0 ; // Index of lowest element
	for (int i = 1; i < len; i++)
		if (a[j] > a[i]) // Test for a lower value...
			j = i; // ...if so update j
	return a[j]; // Return reference to lowest element
}

double * pfun2(char * thisstring, int intnum)
{
	something2 *= intnum ;
	return &something2 ;
}