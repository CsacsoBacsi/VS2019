// Btree.cpp : Defines the entry point for the console application.
//
#include <iostream>
//#include <iomanip>

#define MAX_ELEMS 10

using std::cout;
using std::cin;
using std::endl;

struct bst														// Each node's structure. 
{
	int key ;													// Key value from the table. Serves a base for sorting
	int rownum ;												// Pointer to the row number holding this key
	int lindex ;												// Pointer to a node with a key value that is less than this node's key value
	int rindex ;												// Pointer to a node with a key value that is greater than this node's key value
} ;

struct dbtable													// Simulate a database table with two columns: key + attribute
{
	int UID ;													// A unique identifier
	char Name [50] ;											// Arbitrary name
} ;

int treeIndex ;
int steps = 0 ;													// Counts the number of recursive steps to locate a given key and return the row number

void Insert (struct bst *, int, dbtable) ;
void MakeNode (struct bst *, dbtable) ;
void Intrav (struct bst *, int) ;
void Pretrav (struct bst *, int) ;
int  FindRow (struct bst * tree, int index, int uid) ;
int  BinSearch (struct bst * tree, int index, int uid) ;

int main ()
{
	struct bst tree [MAX_ELEMS] ;								// The Binary tree
	struct dbtable mytbl [MAX_ELEMS] = {{50,  "First"  },		// Table with 10 rows
	                                    {10,  "Second" },
										{60,  "Third"  },
										{25,  "Fourth" },
										{30,  "Fifth"  },
										{92,  "Sixth"  },
										{15,  "Seventh"},
										{67,  "Eighth" },
										{100, "Ninth"  },
										{5,   "Tenth"  }} ;
	memset (tree, 0, sizeof (tree)) ;							// Set all values to zero
	
	for (treeIndex = 0 ; treeIndex < MAX_ELEMS ; treeIndex ++)	// For each table row
	{
		if (treeIndex == 0)
			MakeNode (&tree [treeIndex], mytbl [treeIndex]) ;	// Create the first node
		else
			Insert (tree, treeIndex, mytbl [treeIndex]) ;		// Add the subsequent nodes and link them up too to each other
	}
	
	int rownum = FindRow (tree, 0, 67) ;						// Full traverse from left to right
	cout << "Steps taken: " << steps << endl ;
	steps = 0 ;
	rownum = BinSearch (tree, 0, 67) ;							// Traverse in order
	cout << "Steps taken: " << steps << endl ;

	// Intrav (tree, 0) ;
	// Pretrav (tree,0) ;

	return 0 ;
}

void Insert (struct bst * tree, int treeIndex, dbtable mytbl)
{
	int baseIndex = 0 ;
	
	while (baseIndex <= treeIndex)								// Check every existing node where to link the new node
	{
		if (mytbl.UID <= tree[baseIndex].key)					// Inserted key is less than this node's key value
		{
			if (tree[baseIndex].lindex == -1)					// If leaf node, then make it a parent node
			{
				tree[baseIndex].lindex = treeIndex ;			// Create the link to the left
				MakeNode (&tree[treeIndex], mytbl) ;			// Init new node
				return ;
			}
			else
			{
				baseIndex = tree[baseIndex].lindex ;			// Take the next node to the left
				continue ;
			}

		}
		else // data is > tree[baseIndex].data
		{
			if (tree[baseIndex].rindex == -1)
			{
				tree[baseIndex].rindex = treeIndex ;			// Create the link to the right
				MakeNode (&tree[treeIndex], mytbl) ;			// Init new node
				return ;
			}
			else
			{
				baseIndex = tree[baseIndex].rindex ;			// Take the next node to the right
				continue ;
			}
		}
	}
}

void MakeNode (struct bst * tree, dbtable mytbl)
{
	tree->key = mytbl.UID ;
	tree->rownum = treeIndex + 1 ;								// Store the row number of the row in the table
	tree->lindex = tree->rindex = -1 ;							// New node, not linked to any other node just yet
}

void Intrav (struct bst * tree, int index)
{
	if (tree[index].lindex != -1)
		Intrav (tree, tree[index].lindex) ;
	cout << "DataIn =" << tree[index].key <<endl ;
	if (tree[index].rindex != -1)
		Intrav (tree, tree[index].rindex) ;
}

void Pretrav (struct bst * tree, int index)
{
	cout << "DataPre =" << tree[index].key << endl ;
	if (tree[index].lindex != -1)
		Pretrav (tree, tree[index].lindex) ;
	if (tree[index].rindex != -1)
		Pretrav (tree, tree[index].rindex) ;
}

int FindRow (struct bst * tree, int index, int uid)				// Traverse from left to right and stop when found
{
	static bool found = false ;
	static int rn = -1 ;										// Returns -1 if not found

	steps ++ ;													// Count the number of recursive calls

	if (tree[index].key == uid) {								// If the searched value is found
		rn = tree[index].rownum ;								// Get the row number
		found = true ;											// Set the found flag
		return rn ;
	}
	if (tree[index].lindex != -1)								// Go left if possible
		FindRow (tree, tree[index].lindex, uid) ;
	if (found)
		return rn ;

	if (tree[index].rindex != -1)								// Go right if possible
		FindRow (tree, tree[index].rindex, uid) ;
	if (found)
		return rn ;

	return rn ;
}

int BinSearch (struct bst * tree, int index, int uid)			// Traverse based on comparison result
{
	static bool found = false ;
	static int rn = -1 ;										// Returns -1 if not found

	steps ++ ;													// Count the number of recursive calls

	if (tree[index].key == uid) {								// If the searched value is found
		rn = tree[index].rownum ;								// Get the row number
		found = true ;											// Set the found flag
		return rn ;
	}
	if (tree[index].key > uid && tree[index].lindex != -1)		// Go left if possible and if the searched value is less than this node's value
		BinSearch (tree, tree[index].lindex, uid) ;
	if (found)
		return rn ;

	if (tree[index].key < uid && tree[index].rindex != -1)		// Go right if possible and if the searched value is greater than this node's value
		BinSearch (tree, tree[index].rindex, uid) ;
	if (found)
		return rn ;

	return rn ;
}