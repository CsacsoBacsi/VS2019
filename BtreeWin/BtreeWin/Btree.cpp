/* B-tree (Balanced tree) main 
   This tool creates and populates a B-tree structure. This enables fast retrieval of particular elements from a vast stored information.
   It also provides functionality to insert new values (keys) or delete them.
   Limitations: currently 38 keys can be inserted, the maximum number of keys is 4 which implies a tree order of 5. The minimum number of keys is 2
   within each node. The maximum is twice as much (4). The root node is an exception and can hold less than 2 keys. The keys can only be positive integers.
   There are 20 (NODES) nodes reserved, each could contain up to 4 keys. These are all alterable and extendable though in Btree.h
                                                  2016 (c) Csacso Software, All Rights reserved
*/

// B-tree (Balanced tree) handling functions

#include "Btree.h"

// Simulates a database table with 41 rows
dbtable mytbl [MAX_ELEMS] =  {{50,  "First"      },{51, "Second"       },{60, "Third"       },{25,  "Fourth"      },{30, "Fifth"      },
                              {92,  "Sixth"      },{15, "Seventh"      },{67, "Eighth"      },{100, "Ninth"       },{14, "Tenth"      },
                              {40,  "Eleventh"   },{16, "Twelfth"      },{77, "Thirteenth"  },{33,  "Fourteenth"  },{47, "Fifteenth"  },
						      {105, "Sixteenth"  },{8,  "Seventeenth"  },{56, "Eighteenth"  },{21,  "Nineteenth"  },{32, "Twentieth"  },
							  {44,  "Twentyfirst"},{58, "Twentysecond" },{87, "Twentythird" },{27,  "Twentyfourth"},{38, "Twentyfifth"},
						      {91,  "Twentysixth"},{69, "Twentyseventh"},{9,  "Twentyeighth"},{29,  "Twentyninth" },{80, "Thirtieth"  },
							  {52,  "Thirtyfirst"},{45, "Thirtysecond" },{53, "Thirtythird" },{54,  "Thirtyfourth"},{55, "Thirtyfifth"},
							  {62,  "Thirtysixth"},{64, "Thirtyseventh"},{41, "Thirtyninth" },{42,  "Fourtieth"   },{43, "Fortyfirst" }
                             } ;
// Program entry point
int main ()
{
	memset (tree, 0, sizeof (tree)) ;							// Set everything to zero
	memset (btree, false, sizeof (btree)) ;
	nodeHWM = 0 ;												// Initialize the key counters
	nodeCount = 0 ;
	rootNodeIndex = 0 ;

	PopulateTree () ;											// Populate the tree by a program

	return 0 ;

	//Delete (92) ;
	//Insert (28, 50) ;											// Reusing empty node slot

//	cout << endl << "Traversing b-tree before any operation in ascending order..." << endl ;
//	TraverseTree (tree, rootNodeIndex) ;						// Traverse the tree starting from the root node

	// Testing
	int delthese [29] = {8,9,14,16,21,27,29,30,32,38,40,42,43,45,47,51,52,54,55,58,60,62,64,69,77,87,91,100,105} ;
	int delthese2 [8] = {15,25,41,44,53,56,80,92} ;
	int delthese3 [3] = {33,50,67} ;

	// Deletes
	for (int i = 0 ; i < 29 ; i ++) {
		cout << "Deleting key " << delthese[i] << endl ;
		Delete (delthese[i]) ;
		CheckTree () ;
		Sleep (500) ;
	}
	
	cout << endl << "Traversing b-tree in ascending order..." << endl ;
	TraverseTree (tree, rootNodeIndex) ;

	for (int i = 0 ; i < 8 ; i ++) {
		cout << "Deleting key " << delthese2[i] << endl ;
		Delete (delthese2[i]) ;
		CheckTree () ;
		Sleep (500) ;
	}

	cout << endl << "Traversing b-tree in ascending order..." << endl ;
	TraverseTree (tree, rootNodeIndex) ;

	for (int i = 0 ; i < 3 ; i ++) {
		cout << "Deleting key " << delthese3[i] << endl ;
		Delete (delthese3[i]) ;
		CheckTree () ;
		Sleep (500) ;
	}

	cout << endl << "Traversing b-tree in ascending order..." << endl ;
	TraverseTree (tree, rootNodeIndex) ;

	// Inserts
	for (int i = 0 ; i < 29 ; i ++) {
		cout << "Inserting key " << delthese[i] << endl ;
		Insert (delthese[i], i + 1) ;
		CheckTree () ;
		Sleep (500) ;
	}

	cout << endl << "Traversing b-tree in ascending order..." << endl ;
	TraverseTree (tree, rootNodeIndex) ;

	for (int i = 0 ; i < 8 ; i ++) {
		cout << "Inserting key " << delthese2[i] << endl ;
		Insert (delthese2[i], i + 1) ;
		CheckTree () ;
		Sleep (500) ;
	}

	cout << endl << "Traversing b-tree in ascending order..." << endl ;
	TraverseTree (tree, rootNodeIndex) ;

	for (int i = 0 ; i < 3 ; i ++) {
		cout << "Inserting key " << delthese3[i] << endl ;
		Insert (delthese3[i], i + 1) ;
		CheckTree () ;
		Sleep (500) ;
	}

	cout << endl << "Traversing b-tree in ascending order..." << endl ;
	TraverseTree (tree, rootNodeIndex) ;

	return 0 ;
}

int CreateNode (node * tree) {									// Creates a node and initializes it
	int i ;

	cout << endl << "<<< CreateNode start >>>" << endl ;
	for (i = 0 ; i < NODES ; i ++) {							// Look for the first available empty node
		if (!btree[i]) {
			break ;
		}
	}
	if (i == NODES) {											// No empty nodes in the pre-allocated array!
		cout << "Tree node size of " << NODES << " is too small. Allocate more!" << endl ;
		cout << "<<< CreateNode end >>>" << endl ;
		exit (-1) ;
	}
	if (i > nodeHWM - 1) {										// Adjust high water mark if the first available free node is beyond the current HWM
		nodeHWM ++ ;
	}
	InitNode (tree + i) ;										// Initialize the pointers to -1. Zero means the first node, that is why
	btree[i] = true ;											// Node is not free (not false), it has been taken
	nodeCount ++ ;
	cout << "New node created and initialized" << endl ;
	cout << "<<< CreateNode end >>>" << endl ;
	return i ;
}

void InitNode (node * node) {									// Initialize the node, set the pointers to -1 as 0 could be an index value to an array member
	cout << endl << "<<< InitNode start >>>" << endl ;
	cout << "Initializing node" << endl ;
	for (int j = 0 ; j <= TREE_ORDER ; j ++) {
		node->nodePointer[j] = -1 ;
		if (j < TREE_ORDER) {
			node->changeType[j][0] = 0 ;
			node->changeType[j][1] = 0 ;
		}
	}
	node->prntNodePointer = -1 ;								// Init parent node pointer
	cout << "<<< InitNode end >>>" << endl ;

}

insInfo Find (node * tree, int nodeIndex, int key) {			// Find where the key in the tree should be inserted
	int j ;
	insInfo findi ;
	node * thisNode ;

	cout << endl << "<<< Find start >>>" << endl ;
	if (tree[nodeIndex].key[0] == 0 && tree[nodeIndex].nodePointer[0] == 0) {// Empty node. Not initialized, stop searching
		findi.action = 'X' ;
		cout << "Node not initialized. Can not insert" << endl ;
		cout << "<<< Find end >>>" << endl ;
		return findi ;
	}

	thisNode = &tree[nodeIndex] ;

	findi.key = key ;
	for (j = 0 ; j < thisNode->count ; j ++) {					// Check only up to the count of existing keys and no further
		if (tree[nodeIndex].key[j] == key) {					// Key found as it exists already
			findi.action = 'E' ;
			findi.insertPos = j ;
			findi.nodeIndex = nodeIndex ;
			cout << "Key found" << endl ;
			cout << "<<< Find end >>>" << endl ;
			return findi ;
		}
		if (tree[nodeIndex].key[j] > key) {						// Key is less than the stored key
			if (thisNode->nodePointer[j] == -1) {				// If no subtree found then needs inserting here
				if (thisNode->count == MAX_KEYS) {
					cout << "Key will make node split" << endl ;
					findi.action = 'S';
				}
				else {
					cout << "Key will be inserted somewhere inside the node" << endl ;
					findi.action = 'I' ;
				}
				findi.insertPos = j ;
				findi.nodeIndex = nodeIndex ;
				cout << "<<< Find end >>>" << endl ;
				return findi ;
			}
			else {
				cout << "<<< Find end >>>" << endl ;
				return Find (tree, thisNode->nodePointer[j], key) ; // Subtree found so search for the key in that node in a recursive manner
			}
		}
		else {
			continue ;											// Carry on until a larger (than this key) is found
		}
	}
	// No larger key found
	if (thisNode->nodePointer[j] == -1) {						// Key is greater than any stored keys on this node and no subtree for greater values
		if (j == MAX_KEYS) {									// Key value should go after the last existing key but there is no room. Needs splitting
			findi.action = 'S' ;
			findi.insertPos = j ;
			findi.nodeIndex = nodeIndex ;
			cout << "Key will make node split" << endl ;
			cout << "<<< Find end >>>" << endl ;
			return findi ;
		}
		else {
			findi.action = 'A' ;								// Key value should go after the last existing key and there is still room for in in this node
			findi.insertPos = j ;
			findi.nodeIndex = nodeIndex ;
			cout << "Key will be appended (inserted as last key)" << endl ;
			cout << "<<< Find end >>>" << endl ;
			return findi ;
		}
	}

	cout << "<<< Find end >>>" << endl ;
	return Find (tree, thisNode->nodePointer[j], key) ;			// Subtree with greater values found so search that node for the key
}

int GetRowNum (int nodeIndex, int key)							// Find a given key in the tree and return its row number (to help finding it quick!)
{
	int j ;
	node * thisNode ;

	thisNode = &tree[nodeIndex] ;

	if (!recur) {												// To avoid this message appearing on the screen each time it is called recursively
		cout << endl << "<<< GetRowNum start >>>" << endl ;
		cout << "*** Searching for key " << key << " ***" << endl ;
		recur = true ;
	}
	else {
		cout << "<<< GetRowNum start (recursive) >>>" << endl ;
		cout << "Called again recursively to search for key " << key << endl ;
	}	
	cout << "Start searching left (smaller keys)" << endl ;
	cout << "Checking node " << nodeIndex << "..." << endl ;
	for (j = 0 ; j < thisNode->count ; j ++) {					// Check only up to the count of existing keys and no further
		cout << "Comparing search key to " << tree[nodeIndex].key[j] << endl ;
		if (thisNode->key[j] == key) {							// Key found as it exists already
			cout << "Key found!" << endl ;
			cout << "<<< GetRowNum end >>>" << endl ;
			recur = false ;
			return  thisNode->rowNum[j] ;
		}
		if (thisNode->key[j] > key) {							// Key is less than the stored key no point going any further!
			cout << "Search key is less than key" << endl ;
			if (thisNode->nodePointer[j] == -1) {				// If no subtree found then needs inserting here
				cout << "No further sub-trees to search..." << endl ;
				cout << "Key not found!" << endl ;
				cout << "<<< GetRowNum end >>>" << endl ;
				recur = false ;
				return -1 ;										// Not found
			}
			else {
				cout << "Searching sub-tree " << thisNode->nodePointer[j] << "..." << endl ;
				return GetRowNum (thisNode->nodePointer[j], key) ; // Subtree found so search for the key in that node in a recursive manner
			}
		}
		else {
			continue ;											// Continue in this node searching for a stored key greater than the searched one
		}
	}
	cout << "Reached the end of node " << nodeIndex << ". Checked all values" << endl ;

	// This node has no smaller keys, we reached the ned of the kwys, so try going right where bigger keys are stored
	cout << "Search right now (greater keys)" << endl ;
	if (thisNode->nodePointer[j] == -1) {						// Carry on until a larger (than this key) is found
		cout << "No further sub-trees to search..." << endl ;
		cout << "Key not found!" << endl ;
		cout << "<<< GetRowNum end >>>" << endl ;
		recur = false ;
		return -1 ;
	}
	else {
		return GetRowNum (thisNode->nodePointer[j], key) ;
	}
}

void TraverseTree (node * tree, int startNodeIndex) {			// Traverse the tree starting from the root
	int j ;

	cout << endl << "<<< TraverseTree start >>>" << endl ;
	cout << "*** Traversing the internal btree in ascending order ***" << endl ;
	for (j = 0 ; j <= tree[startNodeIndex].count ; j ++) {		// There are one more pointers (node indices) than keys so equality must be allowed
		if (tree[startNodeIndex].nodePointer[j] != -1) {
			TraverseTree (tree, tree[startNodeIndex].nodePointer[j]) ;
		}
		if (j < tree[startNodeIndex].count) {					// There are more pointers (node indices) than keys so we do not want to echo the key value beyond the last one
			cout << "Row number: " << tree[startNodeIndex].rowNum[j] << " - Key value: " << tree[startNodeIndex].key[j] << endl ;
		}
	}
	cout << "<<< TraverseTree end >>>" << endl ;
}

void PopulateTree () {											// Populates a tree "manually" for test purposes

	cout << endl << "<<< PopulateTree start >>>" << endl ;
	cout << "*** Populating the internal btree with demo key-rownum values ***" << endl ;
	goto next1 ;
	memset (tree, 0, sizeof (tree)) ;
	tree[0].key[0] = 30 ; tree[0].key[1] = 60 ;
	tree[0].rowNum[0] = 1 ; tree[0].rowNum[1] = 2 ;
	tree[0].nodePointer[0] = 1 ; tree[0].nodePointer[1] = 2 ; tree[0].nodePointer[2] = 3 ; tree[0].nodePointer[3] = -1 ; tree[0].nodePointer[4] = -1 ;
	tree[0].prntNodePointer = -1 ;
	tree[0].count = 2 ;
	tree[1].key[0] = 10 ; tree[1].key[1] = 20 ;
	tree[1].rowNum[0] = 3 ; tree[1].rowNum[1] = 4 ;
	tree[1].nodePointer[0] = -1 ; tree[1].nodePointer[1] = -1 ; tree[1].nodePointer[2] = -1 ; tree[1].nodePointer[3] = -1 ; tree[1].nodePointer[4] = -1 ;
	tree[1].prntNodePointer = 0 ;
	tree[1].count = 2 ;
	tree[2].key[0] = 40 ; tree[2].key[1] = 50 ;
	tree[2].rowNum[0] = 5 ; tree[2].rowNum[1] = 6 ;
	tree[2].nodePointer[0] = -1 ; tree[2].nodePointer[1] = -1 ; tree[2].nodePointer[2] = -1 ; tree[2].nodePointer[3] = -1 ; tree[2].nodePointer[4] = -1 ;
	tree[2].prntNodePointer = 0 ;
	tree[2].count = 2 ;
	tree[3].key[0] = 70 ; tree[3].key[1] = 80 ;
	tree[3].rowNum[0] = 7 ; tree[3].rowNum[1] = 8 ;
	tree[3].nodePointer[0] = -1 ; tree[3].nodePointer[1] = -1 ; tree[3].nodePointer[2] = -1 ; tree[3].nodePointer[3] = -1 ; tree[3].nodePointer[4] = -1 ;
	tree[3].prntNodePointer = 0 ;
	tree[3].count = 2 ;
	rootNodeIndex = 0 ;

next1:
	goto next2 ;
	memset (tree, 0, sizeof (tree)) ;
	tree[0].key[0] = 30 ;
	tree[0].rowNum[0] = 1 ;
	tree[0].nodePointer[0] = 1 ; tree[0].nodePointer[1] = 2 ; tree[0].nodePointer[2] = -1 ; tree[0].nodePointer[3] = -1 ; tree[0].nodePointer[4] = -1 ;
	tree[0].prntNodePointer = -1 ;
	tree[0].count = 1 ;
	tree[1].key[0] = 10 ; tree[1].key[1] = 20 ;
	tree[1].rowNum[0] = 3 ; tree[1].rowNum[1] = 4 ;
	tree[1].nodePointer[0] = -1 ; tree[1].nodePointer[1] = -1 ; tree[1].nodePointer[2] = -1 ; tree[1].nodePointer[3] = -1 ; tree[1].nodePointer[4] = -1 ;
	tree[1].prntNodePointer = 0 ;
	tree[1].count = 2 ;
	tree[2].key[0] = 40 ; tree[2].key[1] = 50 ;
	tree[2].rowNum[0] = 5 ; tree[2].rowNum[1] = 6 ;
	tree[2].nodePointer[0] = -1 ; tree[2].nodePointer[1] = -1 ; tree[2].nodePointer[2] = -1 ; tree[2].nodePointer[3] = -1 ; tree[2].nodePointer[4] = -1 ;
	tree[2].prntNodePointer = 0 ;
	tree[2].count = 2 ;
	rootNodeIndex = 0 ;

next2:
	for (tblRowNum = 0; tblRowNum < MAX_ELEMS; tblRowNum++)		// For each table row
	{
		success = Insert (mytbl[tblRowNum].UID, tblRowNum + 1) ;
	}
	cout << "<<< PopulateTree end >>>" << endl ;
}

bool CheckTree () {												// Checks if the internal node structure is consistent (healthy). Returns true if not
	int  i, j, k ;

	cout << endl << "<<< CheckTree start >>>" << endl ;
	cout << "*** Checking the consistency of the internal btree ***" << endl ;

	for (i = 0 ; i < nodeHWM ; i ++) {							// For each node
		if (tree[i].key[0] == 0) {
			continue ;											// This node is empty, skip it. Probably it has become empty during a merge
		}
		for (j = 0 ; j < tree[i].count ; j ++) {				// For each key in the node
			if (tree[i].key[j] >= tree[i].key[j + 1] && j < tree[i].count - 1) { // Each key within a node must be less than the subsequent one
				cout << "Node " << i << " key " << j << " (" << tree[i].key[j] << ") is greater than next key (" << tree[i].key[j + 1] << ")" << endl ;
				cout << "<<< CheckTree end >>>" << endl ;
				return true ;
			}
			else {
				if (tree[i].nodePointer[j] != -1) {				// Check if all children keys are less than this key
					for (k = 0 ; k < tree[tree[i].nodePointer[j]].count ; k ++) {
						if (tree[tree[i].nodePointer[j]].key[k] >= tree[i].key[j]) {
							cout << "Node " << i << " key " << k << " (" << tree[tree[i].nodePointer[j]].key[k] << ") is greater than the parent key (" << tree[i].key[j] << ")" << endl ;
							cout << "<<< CheckTree end >>>" << endl ;
							return true ;
						}
					}
					if (tree[tree[i].nodePointer[j]].prntNodePointer != i) { // Check if the parent of this child node is truly the parent node
						cout << "Node " << i << " is not the parent of the child node " << tree[i].nodePointer[j] << endl;
						cout << "<<< CheckTree end >>>" << endl ;
						return true ;
					}
				}
			}
		}

		if (tree[i].nodePointer[j] != -1) {						// Check if all children of the last key are greater than the parent key
			for (k = 0 ; k < tree[tree[i].nodePointer[j]].count ; k ++) {
				if (tree[tree[i].nodePointer[j]].key[k] <= tree[i].key[j - 1]) {
					cout << "Node " << tree[i].nodePointer[j] << " key " << tree[tree[i].nodePointer[j]].key[k] << " is less than the parent key (" << tree[i].key[j - 1] << ")" << endl ;
					cout << "<<< CheckTree end >>>" << endl ;
					return true ;
				}
			}
			if (tree[tree[i].nodePointer[j]].prntNodePointer != i) { // Check if the parent of this last child node is truly the parent node
				cout << "Node " << i << " is not the parent of child node " << tree[i].nodePointer[j] << ". Parent node index: " << tree[tree[i].nodePointer[j]].prntNodePointer << endl ;
				cout << "<<< CheckTree end >>>" << endl ;
				return true ;
			}
		}

		int cnt = 0 ;
		for (k = 0 ; k < TREE_ORDER - 1 ; k ++) {				// Check if the count is correct. Equals to the actual number of keys
			if (tree[i].key[k] > 0) {
				cnt ++ ;
			}
			else {												// If key is zero, we are done
				break ;
			}
		}
		if (tree[i].count != cnt) {								// Compare node count and actual count
			cout << "Key count mismatch in node " << i << ". Count: " << tree[i].count << ", actual count of non-zero keys: " << cnt << endl ;
			cout << "<<< CheckTree end >>>" << endl ;
			return true ;
		}
	}
	cout << "The b-tree is healthy!" << endl ;
	cout << "<<< CheckTree end >>>" << endl ;

	return false ;											// The tree is healthy!
}