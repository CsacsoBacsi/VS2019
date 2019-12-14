// B-tree (Balanced tree) insertion functions
#include "Btree.h"

// *** Insertion ***
bool Insert (int key, int rowNum) {								// The main insertion routine
	insInfo insi ;

	if (nodeCount == 0) {
		CreateNode (tree) ;										// Create the first, (root) node
	}

	insi = Find (tree, rootNodeIndex, key) ;					// Find where the key should go
	if (insi.action == 'E') {
		return false ;
	}
	insi.rowNum = rowNum ;
	insi.rightOrigin = -1 ;
	InsKey (insi) ;
	
	return true ;
}

bool InsKey (insInfo insi) {									// Inserts a new key into the tree
/*  Insertion only occurs on a leaf node. First we must find the insertion point where the new key can be inserted at. at any given time,
    there must at least be MIN_KEYS number of keys in each and every node (except the root node) and there can not be more than MAX_KEYS
	(TREE_ORDER - 1).

	Type 1 insertion occurs if the node we would like to insert the new key into has less than MAX_KEYS keys. In this case a simple insertion
	occurs at the correct insertion point.
	Type 2 insertion occurs if the node we would like to insert the new key into already has MAX_KEYS (i.e. it is full) and upon insertion of
	this additional key an overflow occurs. In such cases, the overflowed node must be split. Splitting means a creation of a new (rigth split node).
	The key to the left of the median value in the node to be split stay where they are. The median key is promoted to the parent (it becomes an 
	insert into the parent node). If a parent node does not exist, it must be created and initialized. This is how the tree expands with new levels.
	Upwards. If the parent node already exists, we must find where to insert this median key. This may boil down to a type 1 insert unless the parent
	node already has MAX_KEYS therefore overflows. This will trigger a parent node split, the median being promoted a level higher, etc. The initial
	insertion into a leaf node may trigger several splits on several levels in the whole tree until a node is found that has enough room to accommodate
	the median from below.
	During splits, if they occur on non-leaf nodes, we must ensure that the newly created node has the correct children and these children point at
	the correct parent node too. The new node's parent pointer must also be correctly set. Special care needed in situations when the right most child
	node splits. Node pointers  and parent pointers must be correctly set, whole sub-trees can move from one parent to another.
	the growth of the tree is only limited by the number of allocated nodes.
*/
	insInfo linsi ;												// Local insert info
	node * thisNode ;
	int j ;

	linsi.key = insi.key ;										// Populate the todo structure, key
	linsi.insertPos = insi.insertPos ;							// Inserting position within the node
	linsi.nodeIndex = insi.nodeIndex ;							// Node index (in the tree)
	linsi.rowNum = insi.rowNum ;								// Get and assign a row number
	linsi.action = insi.action ;								// Actions are: key 'E'xist, key to be 'I'nserted between keys or first, 
	linsi.rightOrigin = insi.rightOrigin ;						// 'A'ppend the key to an existing list of keys as there is space, 'S'plitting needed

	thisNode = &tree[linsi.nodeIndex] ;							// This node (easier to read)

	if (thisNode->count > 0 && linsi.insertPos < thisNode->count) {// Node already has keys and the insert position is somewhere between (insert), not at the end (append)
		for (j = thisNode->count ; j > linsi.insertPos ; j --) {
			thisNode->key[j] = thisNode->key[j - 1] ;			// Everthing is shifted to the right to make room for the new key
			thisNode->rowNum[j] = thisNode->rowNum[j - 1] ;
			thisNode->nodePointer[j + 1] = thisNode->nodePointer[j] ;
		}
	}

	thisNode->key[linsi.insertPos] = linsi.key ;				// Insert the key at its correct position
	thisNode->rowNum [insi.insertPos] = linsi.rowNum ;
	if (linsi.rightOrigin != -1)								// If the key originated from below (promotion) it needs to point back to the split right node
	{
		thisNode->nodePointer[linsi.insertPos + 1] = linsi.rightOrigin ; // Must be inserted at median + 1 
	}
	tree[linsi.nodeIndex].count ++ ;

	if (thisNode->count == TREE_ORDER) {						// Up to TREE_ORDER numbers are inserted then checked if node needs splitting
		Split (linsi) ;
	}

	return true ;
}

void Split (insInfo insi) {										// Splits a node if it is full (> TREE_ORDER)
	int i, j ;
	int median ;
	int splitLeftNodeIndex, splitRightNodeIndex, propagateNodeIndex ;
	int retval = -1 ;
	node * splitLeftNode, * splitRightNode, * propagateNode ;

	median = tree[insi.nodeIndex].key[SPLIT_POINT] ;			// Get the median value (at index floor ((TREE_ORDER + 1) / 2))

	int newNode = CreateNode (tree) ;							// Allocate new node, new right node to split left node into
	splitLeftNodeIndex = insi.nodeIndex ;						// Left split node
	splitRightNodeIndex = newNode ;								// Right split node
	propagateNodeIndex = tree[insi.nodeIndex].prntNodePointer ;	// Node to propagate the median to. -1 if does not exist
	splitLeftNode = &tree[splitLeftNodeIndex] ;
	splitRightNode = &tree[splitRightNodeIndex] ;
	propagateNode = &tree [propagateNodeIndex] ;

	for (i = SPLIT_POINT + 1, j = 0 ; i < TREE_ORDER ; i ++, j ++) { // Popualate new, right split node
		splitRightNode->key[j] = splitLeftNode->key[i] ;		// Copy the keys beyond the median into a new node
		splitRightNode->nodePointer[j] = splitLeftNode->nodePointer[i] ;
		
		if (splitLeftNode->nodePointer[i] != -1) {				// The new parent node is set here. Those nodes whose parent keys copied to new split right node
			tree[splitLeftNode->nodePointer[i]].prntNodePointer = splitRightNodeIndex ; // must have their parent node pointer readjusted
		}
		splitRightNode->rowNum[j] = splitLeftNode->rowNum[i] ;
	}
	splitRightNode->nodePointer[j] = splitLeftNode->nodePointer[i] ; // The rightmost pointer needs copying too!
	if (splitLeftNode->nodePointer[i] != -1) {
		tree[splitLeftNode->nodePointer[i]].prntNodePointer = splitRightNodeIndex ; // The rightmost node needs to have a new parent too!
	}
	splitRightNode->count = (int) floor ((TREE_ORDER) / 2) ;	// Node has been halved, new count is half too

	// If no parent node to propagate the median to then create and populate one
	if (propagateNodeIndex == -1) {								// If there was no parent for this node i.e. this is the root node
		newNode = CreateNode (tree) ;
		propagateNodeIndex = newNode ;							// Node where the median goes
		propagateNode = &tree [propagateNodeIndex] ;
		propagateNode->key[0] = median ;						// It is going to be the first key in the node
		propagateNode->rowNum[0] = splitLeftNode->rowNum[SPLIT_POINT] ; // The correct rownum is surely here :-)
		propagateNode->nodePointer[0] = splitLeftNodeIndex ;	// Every new parent node with the first key has two pointers. To the two nodes it originated from
		propagateNode->nodePointer[1] = splitRightNodeIndex ;
		propagateNode->prntNodePointer = -1 ;					// No parent, he is the top (root)
		propagateNode->count = 1 ;
		rootNodeIndex = propagateNodeIndex ;					// Save the new root node's index
	}
	else {														// There is a node above this where we can insert the median into
		insInfo linsi ;											// Local insert info
		
		linsi.action = 'I' ; // Not used
		linsi.key = median ;
		linsi.rowNum = splitLeftNode->rowNum[(int)floor((TREE_ORDER) / 2)] ;
		linsi.nodeIndex = tree[insi.nodeIndex].prntNodePointer ;
		linsi.insertPos = GetInsertPos(tree + linsi.nodeIndex, median) ; // Where should it go?
		linsi.rightOrigin = splitRightNodeIndex ;				// This is the new node (split right node). Must be linked to a parent (the parent needs to point at it)
		InsKey (linsi) ;										// Insert median into parent node
	}

	// Manage the left split node
	for (i = SPLIT_POINT ; i < TREE_ORDER ; i ++) {				// Erase values 
		splitLeftNode->key[i] = 0 ;
		splitLeftNode->nodePointer[i + 1] = -1 ;				// Node pointers are one ahead and go one further
		splitLeftNode->rowNum[i] = 0 ;
	}

	splitLeftNode->count = (int) floor ((TREE_ORDER) / 2) ;

	if (splitLeftNode->prntNodePointer == -1) {					// During the split, nodes with their parent keys moved must have their parent node pointer adjusted
		splitLeftNode->prntNodePointer = propagateNodeIndex ;	// New parent was created as a result of the split. This left split node needs to wired to it
	}															// Except, if it has already been rewired during a split (copy) operation
	if (splitRightNode->prntNodePointer == -1) {					// During the split, during the copy to the right split (new) node, the parent node pointers are adjusted!
		splitRightNode->prntNodePointer = propagateNodeIndex ;	// Except for the last right split node whose parent must be set explicitly here!
	}
}

int GetInsertPos (node * node, int val) {						// Search for the place the key can go toin
	int i ;

	for (i = 0 ; i < node->count ; i ++) {
		if (node->key[i] > val)
			return i ;
	}
	return i ;													// Must be inserted as the rightmost key
}
