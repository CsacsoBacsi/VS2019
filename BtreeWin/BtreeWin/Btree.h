// B-tree (Balanced tree) header file

// Includes
#include <iostream>
#include <math.h>
#include <windows.h>
#include <string>

// Namespaces
using std::cout ;
using std::cin ;
using std::endl ;
using std::string ;

// Constants, parameters, B-tree core params
#define MAX_ELEMS 40											// The maximum number of keys this btree can store
#define TREE_ORDER 5											// The number of max pointers (to subtrees) the node can hold (one more than keys)
																// Also means that less than 2 keys can not be in any node at any time
#define MAX_KEYS 4												// Max number of keys (one less than the order of the tree
#define MIN_KEYS MAX_KEYS / 2									// Min number of keys
#define SPLIT_POINT TREE_ORDER / 2								// The place of the median value in the series of keys in a node

#define NODES 20												// Size of the tree array. Number of possible nodes to be allocated

// Windows
extern HWND	hDlg ;
extern HWND	hAboutDlg ;
extern HWND hHelpDlg ;
extern FILE * stream ;
extern HWND hTreeView ;
extern HWND hTreeViewP ;
extern char nullchar[3] ;

// Structures
struct dbtable {												// Simulate a database table with two columns: key + attribute
	int UID ;													// A unique identifier
	char Name [50] ;											// Arbitrary name
} ;

struct node	{													// Each node's structure. 
	int count ;													// Number of keys in a node
	int key[MAX_KEYS + 1] ;									// Keys' array. Temporarily we store the new key then split the node hence the + 1
	int rowNum[MAX_KEYS + 1] ;									// Row number (of a table row) where the key can be found
	int nodePointer[TREE_ORDER + 1] ;							// If a non-leaf node, pointers to children nodes
	int prntNodePointer ;										// Parent node's pointer to enable finding siblings (if any)
	char changeType[MAX_KEYS + 1][3] ;
} ;
extern node tree[NODES] ;
extern node stree[NODES] ;

struct insInfo {												// Insert information
	int key ;													// The key to be inserted
	int rowNum ;												// The row number the key could be found on
	int nodeIndex ;												// The index of the node in the tree where the new value should go
	int insertPos ;												// If action is 'I' then the insertion point. If 'E' then the position where the key has been found
    int rightOrigin ;											// The newly created right split node
	char action ;												// 'E'xists, 'A'ppend, 'I'nsert (unused really)
} ;

struct delInfo {												// Delete information
	int nodeIndex ;												// The index of the node in the tree where the deletion should occur
	int key ;													// The key to be deleted
	int position ;												// Deletion point
	int prntIndex ;												// Parent node index
	int prntKey ;												// Parent key
	int prntRowNum ;											// Parent row number
	int prntKeyPos ;											// Parent key position
	int leftSibling ;											// The left sibling's node index
	int rightSibling ;											// The right sibling's node index
	bool isLeafNode ;											// Boolean that indicates whether the node to delete the key from is a leaf or non-leaf node
	int leftChild ;												// If a key is deleted from a non-leaf node, this is the left child's index
	int rightChild ;											// If a key is deleted from a non-leaf node, this is the right child's index
	char delType[2] ;											// Deletion type. 1, 2a, 2b, 2c, 3a, 3b, 3c or 3d
} ;

struct Deltype {												// Deletion information to store history of how steps taken to delete a key
	char leafType ;												// 'L'-leaf, 'I'-intermediate, 'R'-root
	char deltype[2] ;											// Two-char identifier such as 2a, 3d, etc.
	int nodeIndex ;												// Holds the index of the node in the tree (physical memory) where a deletion is about to happen
	int key ;													// The key to be deleted
} ;
extern Deltype * dtype ;

struct Successor {												// Successor info
	int key ;
	int nodeIndex ;
	int position ;
	int leftSiblingCount ;
	int rightSiblingCount ;
} ;
extern Successor suc ;

struct Predecessor {											// Predecessor info
	int key ;
	int nodeIndex ;
	int position ;
	int leftSiblingCount ;
	int rightSiblingCount ;
} ;
extern Predecessor pred ;

// Globals
extern bool btree[NODES] ;										// Keeps record of free and occupied (allocated) nodes in tree[20]
extern bool sbtree[NODES] ;										// Keeps record of free and occupied (allocated) nodes in stree[20] (shadow tree)
extern int tblRowNum ;											// The virtual db table's row number
extern int nodeCount ;											// Keeps track of created node counts
extern int snodeCount ;											// Keeps track of created node counts in the shadow tree
extern int nodeHWM ;											// High Water Mark. Highest allocated node index
extern int snodeHWM ;											// High Water Mark. Highest allocated node index in the shadow tree
extern int rootNodeIndex ;										// Keeps track of which node is the root one
extern int srootNodeIndex;										// Keeps track of which node is the root one in the shadow tree
extern bool success ;											// Indicates whether the deletion was successful or not
extern int dtypeInd ;											// Pointer index to the deletion type history array
extern bool recur ;												// Recursive indicator

// Function prototypes
// Btree utils
extern int main () ;
extern void PopulateTree () ;									// Populates the tree with test data (for test purposes only)
extern int CreateNode (node *) ;								// Creates then initializes a new node
extern void InitNode (node *) ;									// During node creation initializes the structure's variables
extern insInfo Find (node *, int, int) ;						// Finds a key in the tree by traversing it
extern int GetRowNum (int, int) ;								// Given a key it finds its corresponding row number (enabling fast access)
extern void TraverseTree (node *, int) ;						// Traverses the b-tree in key value ascending order (prints result)
extern bool CheckTree () ;										// Health check of the tree

// Insert
extern bool Insert (int, int) ;									// Main key insertion routine
extern bool InsKey (insInfo) ;									// With more info on the key to be inserted
extern void Split (insInfo) ;									// Split a node if overflows
extern int GetInsertPos (node *, int) ;							// Get the exact position of the new key where it fits

// Delete
extern bool Delete (int) ;										// Main key deletion routine
extern bool DelKey (int, int, int) ;							// With more info on the key to be deleted
extern void GetDelType (delInfo *, int, int, int) ;				// Get the deletion type
extern void DelKey1 (int, int, int, char) ;						// 01
extern void DelKey2a (delInfo *, int) ;							// 2a
extern void DelKey2b (delInfo *, int) ;							// 2b
extern void DelKey2c (delInfo *, int) ;							// 2c
extern void DelKey3a (delInfo *, int) ;							// 3a
extern void DelKey3b (delInfo *, int) ;							// 3b
extern void DelKey3c (delInfo *, int) ;							// 3c
extern void DelKey3d (delInfo *, int) ;							// 3d
extern Successor  GetSucc (int, int) ;							// Get the successor (immediate greater value than this key)
extern Successor _GetSucc (int) ;								// Recursive pair of GetSucc
extern Predecessor  GetPred (int, int) ;						// Get the predecessor (immediate smaller value than this key)
extern Predecessor _GetPred (int, int) ;						// Recursive pair of GetPred

// Help texts
extern char * helpInsertGeneral ;
extern char * helpDeleteGeneral ;
extern char * helpDeleteType1 ;
extern char * helpDeleteType2a ;
extern char * helpDeleteType2b ;
extern char * helpDeleteType2c ;
extern char * helpDeleteType3a ;
extern char * helpDeleteType3b ;
extern char * helpDeleteType3c ;
extern char * helpDeleteType3d ;
