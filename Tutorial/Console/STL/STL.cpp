// STL.cpp : Defines the entry point for the console application.
//

#include <iostream>
#include <sstream>
#include <vector>
#include <iterator>
#include <algorithm>
#include <set>
#include <map>
#include <deque>
#include <stack>
#include <array>
#include <memory>
#include <bitset>

using namespace std ;

void insert_vector (vector <int>&, int, int, int) ;
unique_ptr <int> treble (int data) ;

int main ()
{
	// *** Vectors ***
	// Vectors are sequence containers representing arrays that can change in size. Just like arrays, vectors use contiguous storage locations for their elements, 
	// which means that their elements can also be accessed using offsets on regular pointers to its elements, and just as efficiently as in arrays. But unlike arrays,
	// their size can change dynamically, with their storage being handled automatically by the container.
	// Internally, vectors use a dynamically allocated array to store their elements. This array may need to be reallocated in order to grow in size when new elements
	// are inserted, which implies allocating a new array and moving all elements to it. This is a relatively expensive task in terms of processing time, and thus, 
	// vectors do not reallocate each time an element is added to the container.
	// Instead, vector containers may allocate some extra storage to accommodate for possible growth, and thus the container may have an actual capacity greater than 
	// the storage strictly needed to contain its elements (i.e., its size).

	bool dummy = false ;
	vector <int> v (10) ;
	vector <int> v2 ;

	bool is_empty = v2.empty () ;								// Check if it is empty

	for (int i = 0 ; i < 10 ; i ++) {
		v[i] = (i+1) * (i+1) ;
	}

	for (int i = 9 ; i > 0 ; i --) {
		v[i] -= v[i-1] ;
	}

	int elements_count = v.size () ;							// Check the size of the vector
	is_empty = v.empty () ;										// Check if it is empty

	v.resize (20) ;												// Resize (fills up with zeros). If shrinks, the last ones are deleted
	elements_count = v.size () ;
	for (int i = 10 ; i < 20 ; i ++) {
		v[i] = i*2 ;
	}

	v.push_back (100) ;											// Adds another element to the end of the vector
	elements_count = v.size () ;

	v2 = v ;													// Init new vectors. Copy content (elements) into new vector
	vector <int> v3 (v) ;										// These statements are identical

	vector <string> names (20, "Unknown") ;						// String vector with 20 elements initialized to "Unknown" each
	vector < vector <int> > Matrix (3, vector <int> (2, -1)) ;	// Two-dim 3x2 vector

	int data [] = {2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31} ; 
	vector<int> primes (data, data + (sizeof (data) / sizeof (data[0]))) ; // Initialize a vector using an ordinary array. Works as two iterators. One points at the first, the other one to the last element
	vector<int> primes2 (primes.begin (), primes.begin () + primes.size ()) ; // Same as the previous row. Iterators or pointers can be used interchangeably

	insert_vector (v, 111, 5, 3) ;								// Call function passing the reference so that the vector does not get copied!
	primes.emplace (primes.begin () + 3, 8) ;					// Inserts a new element. All the others are forwarded so not so efficient

	for (vector<int>::iterator it = v.begin () ; it != v.end () ; it ++) { // Begin returns a pointer to the first element, end does the same for the last one
		*it ++ ;												// Increment the value iterator is pointing to because iterator = pointer
	}

	bool found_11 = false ;
	if (find (primes.begin (), primes.end (), 11) != primes.end ()) { // The end iterator points beyond the last element so should not be dereferenced
		found_11 = true ;
		int position_11 = find (primes.begin (), primes.end (), 11) - primes.begin () ; // Find returns an iterator (a pointer) so we need to subtract the starting pointer
		position_11 = position_11 ;
	}

	int max_elem = *max_element (primes.begin (), primes.end ()) ; // Returns the max element value
	int max_elem_index = max_element (primes.begin (), primes.end ()) - primes.begin () ; // Returns the max element index (zero-based!)

	sort (primes.begin (), primes.end ()) ;						// Sort array in ascending order 
	sort (primes.rbegin (), primes.rend ()) ;					// Sort array in descending order

	swap (*(primes.begin () + 1), *(primes.begin () + 2)) ;		// Swaps two values. iterator must be dereferenced

	int prime23 = primes.at (1) ;								// At position (n). Same as [] but can not change value
	int *pprime = primes.data () ;								// Get the pointer internally used by vector. This points at the 1st element
	prime23 = *(pprime + 1) ;

	vector<int>::iterator it = primes.begin () ;
	it ++ ;
	primes.erase (it) ;											// Erase one element
	it = primes.begin () ;
	primes.erase (it + 2, it + 5) ;								// Erase a range of elements

	vector <int> v5 ;											// 3 numbers, get their permutations
	for (int i = 0 ; i < 3 ; i ++) { 
		v5.push_back (i) ;										// Allocate one element at a time appending it to the end of the vector
	} 

	do { 
		cout << v5[0] << ' ' << v5[1] << ' ' << v5[2] << endl ;
	} while (next_permutation (v5.begin (), v5.end ())) ;		// Creates the next permutation, then restores the original order after the loop

	cout << "Size: " << primes.size () << endl ;
	cout << "Capacity: " << primes.capacity () << endl ;		// Greater ir equal to the size. Contains extra space for future expansion
	cout << "Max size: " << primes.max_size () << endl ;
	primes.reserve (100) ;										// Requests that the capacity be at least this size
	cout << "New capacity: " << primes.capacity () << endl ;

	int myints [] = {1,2,3,4,5,6,8} ;
	vector <int> v4 ;
	v4.assign (myints, myints + 3) ;							// Assign from an array

	// *** Sets ***
	// Sets are containers that store unique elements following a specific order.
	// In a set, the value of an element also identifies it (the value is itself the key, of type T), and each value must be unique. The value of the elements in a 
	// set cannot be modified once in the container (the elements are always const), but they can be inserted or removed from the container.

	set <int> s ;												// Sorted, distinct list of objects

	for (int i = 1 ; i <= 100 ; i ++) {
		s.insert (i) ;											// Insert 100 elements, [1..100] 
	} 
	s.insert (42) ;												// Does nothing, 42 already exists in set

	if (s.find (42) != s.end ()) {								// Find the value 42
		dummy = true ;
	}
	else {
		dummy = false ;
	}

	for (int i = 2 ; i <= 100 ; i += 2) {
		s.erase (i) ;											// Erase even values 
	}
	int n = int (s.size ()) ;									// n will be 50 

	s.insert (8) ;
	int total = 0 ;
	for (set<int>::iterator its = s.begin () ; its != s.end () ; its ++) { 
		total += *its ;											// *its ++ does not work because the container is not linear. Pointer can not be used to access the values in order
	}

	// *** Pairs ***
	// This class couples together a pair of values, which may be of different types (T1 and T2). The individual values can be accessed through its public members first and second.

	pair <string, pair <int, int> > P ;
	P.first = "Csacsi" ;
	P.second.first = 5 ;
	P.second.second = 10 ;
	string str = P.first ;										// Extract string 
	int x = P.second.first ;									// Extract first int 
	int y = P.second.second ;									// Extract second int

	// *** Maps ***
	// Maps are associative containers that store elements formed by a combination of a key value and a mapped value, following a specific order.
	// In a map, the key values are generally used to sort and uniquely identify the elements, while the mapped values store the content associated to this key.

	map <string, int> M ;										// Key - value pair. Basically an array (set) of pairs. Unique in ascending order. Same as set...
	M["Key1"] = 1 ;												// Operator [] creates a new pair. Also, indexes the value by the key
	M["Key2"] = 2 ;
	M["Key5"] = 10 ;

	int x1 = M["Key1"] + M["Key2"] ;							// [] operator to get the value by the key

	if (M.find ("Key5") != M.end ()) {							// Find only finds the key but can not change the value or add a new pair
		M.erase ("Key5") ;										// Erase a value by its key
	}

	M["Key2"] = 5 ;
	total = 0 ;
	for (map <string,int>::iterator itm = M.begin () ; itm != M.end () ; itm ++) {
		total += (*itm).second ;								// Access the value as the second element of a pair
	}

	// *** Deques *** 
	// Double-ended queues are sequence containers with dynamic sizes that can be expanded or contracted on both ends (either its front or its back).
	// While vectors use a single array that needs to be occasionally reallocated for growth, the elements of a deque can be scattered in different 
	// chunks of storage, with the container keeping the necessary information internally to provide direct access to any of its elements in constant
	// time and with a uniform sequential interface.

	deque <int> d (5, 1) ;										// Five ints with the value of 1

	deque<int>::iterator itd = d.begin () ;
	++ itd ;
    itd = d.insert (itd, 10) ; 

	// *** Stacks ***
	// Stacks are a type of container adaptor, specifically designed to operate in a LIFO context (last-in first-out), where elements are inserted and extracted only
	// from one end of the container.
	// Stacks are implemented as containers adaptors, which are classes that use an encapsulated object of a specific container class as its underlying container, 
	// providing a specific set of member functions to access its elements. Elements are pushed/popped from the "back" of the specific container, which is known as the 
	// top of the stack.

	stack <int> stck ;
	stck.push (5) ;
	stck.push (7) ;
	stck.push (1) ;												// Last value is 1
	stck.pop () ;												// Delete (pop) last value

	int f = stck.top () ;										// The last value now is 7

	// *** Arrays ***
	// Arrays are fixed-size sequence containers: they hold a specific number of elements ordered in a strict linear sequence.
	// Internally, an array does not keep any data other than the elements it contains (not even its size, which is a template parameter, fixed on compile time). 
	// It is as efficient in terms of storage size as an ordinary array declared with the language's bracket syntax ([])

	array <long, 10> fibonacci = {1L, 1L} ;						// Fixed length. Can not be resized, reallocated
	for (unsigned int i = 2 ; i < fibonacci.size () ; ++ i) {
		fibonacci [i] = fibonacci [i-1] + fibonacci [i-2] ;
	}

	for (auto& value : fibonacci) {
		cout << value << endl ;
	}

	cout << endl ;
	array <long, 10> secondarr ;
	secondarr.fill (10) ;
	fibonacci.swap (secondarr) ;
	for (auto& value : fibonacci) {
		cout << value << endl ;
	}
	cout << "Element at position 8 (zero-based): " << secondarr[8] << endl ;

	// *** Bit sets ***
	bitset <4> mybs ;											// Number of bits 

	mybs [1] = 1 ;												// 0010
	mybs [2] = mybs [1] ;										// 0110

	cout << "Mybitset: " << mybs << endl ;
	cout << "Number of bits set: " << mybs.count () << endl ;	// Get count of set bits
	cout << "Testing bit 2: " << mybs.test (1) << endl ;
	cout << "Any bits set? " << mybs.any () << endl ;
	cout << "No bits set? " << mybs.none () << endl ;
	cout << "All bits set? " << mybs.all () << endl ;
	mybs.set () ;												// Set all bits to 1
	mybs.set (2, 0) ;											// Set bit 3 to zero
	cout << "Mybitset: " << mybs << endl ;
	mybs.reset () ;												// Set all bits to zero
	mybs.set () ;
	mybs.reset (1) ;											// Set bit 1 to zero
	cout << "Mybitset: " << mybs << endl ;
	mybs.flip () ;												// Flip (reverse) all bits
	mybs.flip (3) ;
	cout << "Mybitset: " << mybs << endl ;

	// *** Strings ***
	string mystr ("Test string") ;
	for (string::iterator strit = mystr.begin () ; strit != mystr.end () ; ++ strit) {
		cout << *strit ;										// Echo each char in the string using the iterator
	}
	cout << endl ;

	cout << "Size: " << mystr.size () << endl ;
	cout << "Length: " << mystr.length () << endl ;
	cout << "Capacity: " << mystr.capacity () << endl ;

	cout << "5th char: " << mystr [4] << endl ;					// [] operator
	cout << "6th char: " << mystr.at (5) << endl ;				// at ()
	cout << "Last char: " << mystr.back () << endl ;			// Last char

	mystr += " appended" ;										// Concat another string. + operator overloaded. Same as mystr.append ()
	cout << "After append: " << mystr << endl ;
	cout << "New size: " << mystr.size () << endl ;
	cout << "New length: " << mystr.length () << endl ;
	cout << "New capacity: " << mystr.capacity () << endl ;
	mystr.push_back ('!') ;										// Append one char at the end
	mystr.insert (4, " my") ;									// Insert anywhere
	cout << mystr << endl ;

	string mystr2 ;
	mystr2.assign (mystr) ;										// String1 = string2
	mystr2.erase (4, 3) ;										// Erase chars. From pos 4 3 chars
	mystr2.replace(8, 3, "***");
	cout << mystr2 << endl ;

	char * cstr ;
	cstr = (char *) mystr2.c_str () ;									// c_str () returns a pointer to a null terminated char array

	char buffer [20] ;
	size_t length = mystr2._Copy_s (buffer, 6, 5) ;						// Copies a substring into the target string
	buffer [length]='\0';												// Copy does not append null so the programmer has to do so
	cout << buffer << endl ;

	size_t found = mystr2.find ("**") ;									// Get the first occurance of a string in another one
    cout << "'**' found at: " << found << endl ;
	cout << "'**' Last occurance at: " << mystr2.find_last_of ("**") << endl ; // Last occurance of a string in another one
	cout << mystr2.substr (8, 2) << endl ;								// Get a substring at position 8 with a length of 2

	if (mystr2.compare (8, 2, "**") == 0) {								// Compare strings or substrings
		cout << "'**' found at position 8!" << endl ;
	}

	// *** Smart pointers ***
	// unique_ptr
	// Is a type that defines an object that stores a pointer of which there can be only one. Assigning or copying a unique_ptr<T> object is not possible.
	// The pointer stored by one unique_ptr<T> object can be moved to another using std::move(). After such an operation the original object will be invalid.

	int num = 5 ;
	int num2 = 8 ;
	class ptrclass {
	public:
		int memb1 = 1 ;
		int memb2 = 2 ; 
	} ;
	
	unique_ptr <int> ptr ;
	unique_ptr <ptrclass> ptr2 ;
	unique_ptr <ptrclass> ptr3 ;
	unique_ptr <ptrclass> ptr32 ;
	unique_ptr <ptrclass> ptr4 ;
	shared_ptr <ptrclass> ptr5 ;
	shared_ptr <ptrclass> ptr6 ;

	ptr = treble (num) ;
	cout << endl << "Three times num = " << 3 * num ;
	cout << endl << "Result = " << * ptr << endl ;
	
	ptr2 = (unique_ptr <ptrclass>) new ptrclass () ;			// Here, there is a class instance with two memebers, plus a pointer to that instance whose ownership is taken by the unique_ptr object
	ptr2 -> memb1 = 3 ;
	ptr2 -> memb2 = 5 ;

	ptrclass ptri1 ;											// This is created on the stack
	ptrclass * ptrc = &ptri1 ;									// Local pointer created on the stack
	ptrc -> memb2 = 6 ;
	
	ptrclass ptri2 ;
//	ptr3 = (unique_ptr <ptrclass>) &ptri2 ;						// Can not point at a stack variable or object
	ptrclass * pc = (ptrclass *) new ptrclass () ;				// Heap object, unique ptr can point at
	ptr3 = (unique_ptr <ptrclass>) pc ;
	ptrclass * rawptr = ptr3.get () ;							// Get the "raw" pointer the object (ptr3) owns
//	ptr32 = ptr3 ;												// Can not happen. Two unique ptrs can not point at the same object
	ptr4 = (unique_ptr <ptrclass>) pc ;							// Defies the concept of uniqueness! At the end of the program, ptr3 goes out of scope so pc is deleted
																// Then ptr4 follows but by then pc had been deleted!!!!!
	ptr3.release () ;											// Release ownership of the object pc so the destruction of ptr4 will not fail (pc will be destroyed only then!!!!!)
	ptr4.reset () ;												// Deletes managed object. pc has been destroyed

	{															 // A newly created ptrclass instance will get deleted when ptr7 goes out of scope
		unique_ptr <ptrclass> ptr7 = (unique_ptr <ptrclass>) new ptrclass () ;
	}															// No need to delete the ptrclass instance

	unique_ptr <ptrclass> p10 = make_unique <ptrclass> () ;		// Creates the class instance, the pointer to it and the p10 smart pointer to own the pointer and instance

	// shared_ptr
	// In contrast to unique_ptr, you can have multiple shared_ptr objects pointing to the same object.
	// The object pointed to will survive until the last shared_ptr object that points to it is destroyed,
	// then it too will be destroyed.
	{
		ptrclass * pc2 = (ptrclass *) new ptrclass () ;
		ptr5 = (shared_ptr <ptrclass>) pc2 ;
		ptr6 = ptr5 ;											// uses count = 2. Must be a copy otherwise the other shared pointer does not share it but owns it!
		ptr5.reset () ;											// Releases the object, uses count = 1
		ptr5 = ptr5 ;
	}															// pc2 gets destroyed here automatically as both ptr5 and ptr6 go out of scope

	// weak_ptr
	// When the last shared_ptr object that manages that resource is destroyed the resource will be freed, even if there are weak_ptr objects pointing to that resource. 
	// This is essential for avoiding cycles in data structures.

	// *** String streams ***
	// Stream class to operate on strings.
	// Objects of this class use a string buffer that contains a sequence of characters. This sequence of characters can be accessed directly as a string object, using member str.
	// Characters can be inserted and/or extracted from the stream using any operation allowed on both input and output streams.

	string s1 = "101\n102\n103" ;								// Read from a string as it was a console input stream
	istringstream is (s1) ;
 
	vector <int> v10 ;
	int tmp ;
	while (is >> tmp) {											// Store each integer in a temp variable
		v10.push_back (tmp) ;									// Add the integer to the vector
	}

	ostringstream os ;
	for (vector <int>::iterator it = v10.begin (); it != v10.end () ; it ++) { // Copy all elements from vector<int> to string stream as text 
		os << ' ' << *it ;
	}
	string s2 = os.str () ;										// Get string from string stream 

	return (0) ;
}

void insert_vector (vector <int>& vparam, int val, int index, int n) {
	vector<int>::iterator it ;
	it = vparam.begin () ;										// Set to the beginning. Use a pointer to point to the beginning
	it += index ;												// At position index,
	vparam.insert (it, n, val) ;								// n values inserted all initialized to val
}

unique_ptr <int> treble (int data)	{
	unique_ptr <int> result ;									// result will point at the newly created/allocated integer
	result = (unique_ptr <int>) new int (0) ;
	* result = 3 * data ;
	return result ;												// Allocated on the heap, so safe to return. This will then populate ptr (another pointer). 
}																// There is an implicit 'move' that moves the unique pointers from one to another
