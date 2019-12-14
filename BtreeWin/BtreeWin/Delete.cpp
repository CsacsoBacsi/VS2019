// B-tree (Balanced tree) deletion functions

#include "Btree.h"

bool Delete (int key) {											// The main deletion routine
	insInfo findi ;
	bool retval ;

	cout << endl << "<<< Delete start >>>" << endl ;
	dtype = (Deltype *) calloc (100, sizeof (Deltype)) ;		// Allocate a 100 slots to store deletion history
	dtypeInd = 0 ;
	findi = Find (tree, rootNodeIndex, key) ;					// Get node index, position by key
	if (findi.action != 'E') {									// Key does not exist so it can not be deleted either
		return false ;
	}
	
	retval = DelKey (findi.nodeIndex, key, findi.insertPos) ;

	free (dtype) ;

	cout << "<<< Delete end >>>" << endl ;
	return retval ;
}

bool DelKey (int nodeIndex, int key, int pos) {					// Called to delete a key
	delInfo deli ;

	cout << endl << "<<< DelKey start >>>" << endl ;
	deli.isLeafNode = false ;									// Init deletion info structure
	deli.key = -1 ;
	deli.leftChild = -1 ;
	deli.rightChild = -1 ;
	deli.leftSibling = -1 ;
	deli.rightSibling = -1 ;
	deli.nodeIndex = -1 ;
	deli.position = -1 ;
	deli.prntIndex = -1 ;
	deli.prntKey = -1 ;
	deli.prntKeyPos = -1 ;
	deli.prntRowNum = -1 ;

	GetDelType (&deli, nodeIndex, key, pos) ;					// Get the type of the deletion first

	cout << "Deletion type: " << deli.delType[0] << deli.delType[1] << endl ;
	switch (deli.delType[0]) {
		case '0':												// Simnple deletion from a leaf node
			if (deli.delType[1] == '1') {
				DelKey1 (deli.nodeIndex, deli.key, deli.position, '1') ;
			}
			break ;

		case '2':												// "Rotational" deletion on a leaf (or non-leaf node, if this is not the first deletion action)
			if (deli.delType[1] == 'a') {
				DelKey2a (&deli, key) ;
			}
			else if (deli.delType[1] == 'b') {
				DelKey2b (&deli, key) ;
			}
			else {
				DelKey2c (&deli, key) ;
			}
			break;

		case '3':												// Initiated on a non-leaf node
			if (deli.delType[1] == 'a') {
				DelKey3a (&deli, key) ;
			}
			else if (deli.delType[1] == 'b') {
				DelKey3b (&deli, key) ;
			}
			else if (deli.delType[1] == 'c') {
				DelKey3c (&deli, key) ;
			}
			else {
				DelKey3d (&deli, key) ;
			}
			break;

		default:
			break ;
	}

	cout << "<<< DelKey end >>>" << endl ;
	return true ;
}

void GetDelType (delInfo * deli, int nodeIndex, int key, int pos) { // Establish the deletion type
/* If the initial deletion (when the DelKey function is called via Delete the first time) occurs on a leaf node, the deletion type can
   only either be type 1 or type 2 (and its variants).
   
   Type 1 is a simple deletion from the node when there will be enough keys remaining in the node after the deletion (number of keys
   greater than MIN_KEYS which is half of TREE_ORDER - 1). In other words, there is no underflow in the node as a result of the key deletion.
   
   Type 2 deletion occurs when an underflow happens in the node where a key is about to be deleted from.
   Type 2a handles cases when the left sibling can help out as it has more than MIN_KEYS keys and can hand over its rigthmost key.
   Type 2b is similar to type 2a however in this case it is the right sibling that hands its first key (leftmost) over.
   
   In both cases the handover occurs via the parent key. The relinquished key replaces the parent key which in turn replaces the deleted 
   key in the underflowed node. This is also called "rotation" as the keys move around from left to right or right to left via the parent node.
   Please note that if non-leaf keys are involved in this, the node pointer of the key is also moving together with the relinquished key but
   does not stop at the parent but makes it over to the underflowed node.
   
   Type 2c is a special case when no sibling can help out and the node the key is deleted from underflows. In this keys the opposite of an insert
   must happen (when no more key fits in the node as it is full) i.e. the parent key must descend and the two children nodes must be merged.
   There are two cases: when the right child's keys merge into the left child node and vice versa when the left child's keys merge into the
   right child node. In both cases the parent key descends in the middle (median) then the original key marked for deletion can be deleted.
   Since one of the children (the one that merges into the other one) ceases to exist, the parent's node pointers must be adjusted accordingly.

   In such cases when nodes need merging and the parent key must descend (meaning it is deleted from the parent node) it can happen that the 
   parent node underflows as a result triggering another 2a, 2b or even another 2c deletion. This can spiral up to as far as the root node.
   Code-wise it is a recursive call to the DelKey functions.
   The only exception to the rule is the root key that can hold less than MIN_KEYS keys. When the last key from the root node is deleted 
   (e.g. as part of the children's merge) the tree collapses. It becomes flatter by one level. The node the other node was merged into becomes
   the new root node. This goes on until all keys from the last (root) node is deleted in which case the root node pointer is reset to zero.

   Type 3 deletions can only occur if the initial deletion happens to a non-leaf node. In these cases either the predecessor or the successor key can
   replace the deleted key. This key comes from a leaf node possibly several levels below the parent node.
   If the node holding the predecessor has enough keys (does not underflow due to the predecessor key's deletion) than the deletion is of type 3a.
   Type 3b handles the case when the node that holds the successor has enough keys to promote it.
   Type 3a is chosen also if although the predecessor's node underflows, one of its siblings (it may have two or just one) is rich (has enough keys)
   therefore can help out.
   Likewise, type 3b is chosen also if although the successor's node underflows, one of its siblings (it may have two or just one) is rich (has enough
   keys) therefore can help out.
   Type 3c and type 3d occur when neither node holding the predecessor and the successor respectively has enough keys remaining after the deletion
   (key promotion) and neither of their siblings are rich to help out with a spare key. We must decide though which key (predecessor or successor) to
   promote. In this decision the only decisive factor is the number of keys in the direct children. If the left child has more keys than MIN_KEYS, then
   the predecessor is chosen otherwise the right child's route down to the successor irrespective to whether the right child has more keys than MIN_KEYS
   or not. This might save us eventually an extra 2c type deletion. On the leaf level, the promotion of either the predecessor or the successor will always
   kick off a type 2 deletion that in turn can trigger further deletions in the sub-tree going higher and higher towards the root.
*/
	int j ;

	cout << endl << "<<< GetDelType start >>>" << endl ;
	cout << "Establishing the deletion type for node " << nodeIndex << ", key: " << key << endl ;
	// Get all necessary info on the node the key is about to be deleted from
	deli->nodeIndex = nodeIndex ;
	deli->key = key ;
	deli->position = pos ;
	deli->prntIndex = tree[deli->nodeIndex].prntNodePointer ;

	if (deli->prntIndex != -1) {								// Has a parent node
		for (j = 0 ; j <= tree[deli->prntIndex].count ; j ++) {	// Get the position (index) of the given key in the key set in the node
			if (tree[deli->prntIndex].nodePointer[j] == deli->nodeIndex)
				break ;
		}
		deli->prntKeyPos = j ;

		// Get siblings if any
		if (tree[deli->prntIndex].key[deli->prntKeyPos] == 0) {	// This can be 0 if this node is rightmost child
			deli->prntKey = tree[deli->prntIndex].key[deli->prntKeyPos - 1] ; // Get the parent key
			deli->prntRowNum = tree[deli->prntIndex].rowNum[deli->prntKeyPos - 1] ; // Get the parent key's row number
		}
		else {
			deli->prntKey = tree[deli->prntIndex].key[deli->prntKeyPos] ; // Get the parent key
			deli->prntRowNum = tree[deli->prntIndex].rowNum[deli->prntKeyPos]; // Get the parent key
		}

		if (deli->prntKeyPos > 0) {								// Find the left and right siblings
			deli->leftSibling = tree[deli->prntIndex].nodePointer[deli->prntKeyPos - 1] ;
		}
		else {
			deli->leftSibling = -1 ;
		}

		if (deli->prntKeyPos == tree[deli->prntIndex].count) {	// This is the rightmost sub-tree
			deli->rightSibling = -1 ;
		}
		else if (deli->prntKeyPos == TREE_ORDER) {				// Absolute rightmost sub-tree
			deli->rightSibling = -1 ;
		}
		else {
			deli->rightSibling = tree[deli->prntIndex].nodePointer[deli->prntKeyPos + 1] ;
		}
	}
	else {
		deli->leftSibling = -1 ;
		deli->rightSibling = -1 ;
	}

	if (tree[deli->nodeIndex].nodePointer[0] == -1) {			// Leaf node?
		deli->isLeafNode = true;
	}
	else {
		deli->isLeafNode = false;
	}

	if (!deli->isLeafNode) {									// Get children if any
		deli->leftChild = tree[deli->nodeIndex].nodePointer[deli->position] ;
		deli->rightChild = tree[deli->nodeIndex].nodePointer[deli->position + 1] ;
	}

	// Register this deletion in history (testing purposes only)
	dtypeInd ++ ;
	dtype[dtypeInd].key = deli->key ;
	dtype[dtypeInd].nodeIndex = deli->nodeIndex ;
	if (deli->isLeafNode) {
		dtype[dtypeInd].leafType = 'L' ;						// Leaf node
	}
	else if (deli->nodeIndex == rootNodeIndex) {
		dtype[dtypeInd].leafType = 'R' ;						// Root node
	}
	else {
		dtype[dtypeInd].leafType = 'I' ;						// Intermediate node
	}

	// Establish the type of the deletion
	if (deli->isLeafNode || dtype[dtypeInd - 1].deltype[1] == 'c') { // Is it a leaf node? Or the previous deletion involved merging
		if (tree[deli->nodeIndex].count > MIN_KEYS) {			// Will node have enough keys remaining after the deletion
			deli->delType [0] = '0' ;							// Type 1: leaf node, enough values after deletion
			deli->delType [1] = '1' ;
		}
		else if (tree[deli->nodeIndex].count == MIN_KEYS) {		// Type 2: has already the minimum number of keys, can not simply delete key
			if (deli->leftSibling == -1 && deli->rightSibling == -1) { // Root node
				deli->delType [0] = '0' ;						// Type 1: Root node this time
				deli->delType [1] = '1' ;
			}
			else if (deli->leftSibling != -1 && tree[deli->leftSibling].count > MIN_KEYS) {// Any siblings have more than min amount of keys?
				deli->delType [0] = '2' ;						// Type 2a: leaf node, with not enough values, left sibling can help out
				deli->delType [1] = 'a' ;
			}
			else if (deli->rightSibling != -1 && tree[deli->rightSibling].count > MIN_KEYS) {
				deli->delType [0] = '2' ;						// Type 2a: leaf node, with not enough values, right sibling can help out
				deli->delType [1] = 'b' ;
			}
			else {
				deli->delType [0] = '2' ;						// Type 2b: leaf node, with not enough values, neither sibling can help out (needs merging)
				deli->delType [1] = 'c' ;
			}
		}
		else {													// It can only be a root node (less than MIN_KEYS)
			deli->delType [0] = '0' ;							// Type 1: Root node this time
			deli->delType [1] = '1' ;
		}
	}
	else {														// Not a leaf node
		pred = GetPred (deli->nodeIndex, deli->position) ;		// Get the predecessor
		suc = GetSucc (deli->nodeIndex, deli->position) ;		// Get the successor
		
		if (tree[pred.nodeIndex].count  > MIN_KEYS) {			// Node holding the predecessor has enough keys
			deli->delType [0] = '3' ;							// Type 3a: non-leaf node, predecessor's node has enough keys
			deli->delType [1] = 'a' ;
		}
		else if (tree[suc.nodeIndex].count  > MIN_KEYS) {		// Node holding the successor has enough keys
			deli->delType [0] = '3' ;							// Type 3b: non-leaf node, successor's node has enough keys
			deli->delType [1] = 'b' ;
		}
		else if (pred.leftSiblingCount > MIN_KEYS || pred.rightSiblingCount > MIN_KEYS) {
			deli->delType [0] = '3' ;							// Type 3a: non-leaf node, predecessor node underflows but at least one of its siblings is rich (has enough keys)
			deli->delType [1] = 'a' ;
		}
		else if (suc.leftSiblingCount > MIN_KEYS || suc.rightSiblingCount > MIN_KEYS) {
			deli->delType [0] = '3' ;							// Type 3b: non-leaf node, succcessor node underflows but at least one of its siblings is rich (has enough keys)
			deli->delType [1] = 'b' ;
		}
		else {													// Neither the predecessor nor the successor or their siblings have enough keys
			if (tree[deli->leftChild].count > MIN_KEYS) {
				deli->delType[0] = '3';							// Type 3c: non-leaf node, left child has enough keys but neither the predecessor nor the successor or their siblings have enough keys
				deli->delType[1] = 'c';
			}
			else {
				deli->delType[0] = '3' ;						// Type 3d: non-leaf node, right child has enough keys or not and neither the predecessor nor the successor have enough keys
				deli->delType[1] = 'd' ;
			}
		}
	}

	dtype[dtypeInd].deltype[0] = deli->delType [0] ;			// Register deletion type as well in the history array
	dtype[dtypeInd].deltype[1] = deli->delType [1] ;

	cout << "Node: " << deli->nodeIndex << endl ;
	cout << "Position: " << deli->position << endl ;
	cout << "Parent node: " << deli->prntIndex << endl ;
	cout << "Parent key: " << deli->prntKey << endl ;
	cout << "Parent key position: " << deli->prntKeyPos << endl ;
	cout << "Is it a leaf node: " << deli->isLeafNode << endl ;
	cout << "Left child node: " << deli->leftChild << endl ;
	cout << "Right child node: " << deli->rightChild << endl ;
	cout << "right sibling node: " << deli->rightSibling << endl ;
	cout << "Left sibling node: " << deli->leftSibling << endl ;

	cout << "<<< GetDelType end >>>" << endl ;
}

// Type 1
void DelKey1 (int nodeIndex, int key, int pos, char type) {		// Delete a single key from a node with enough keys still left
/* Delete a key from a node (usually from a leaf but maybe from the root). 
   From the deletion point on, shift everything left (just deleting what needs to be). Sometimes during merges there are 5 keys temporarily
   so delete anything beyond the last key manually
   
   Type 1 is the simplest form or when the rightmost key from a non-leaf node is deleted, the code must chose which of the two node pointers
   needs deleting. In type 1 it is the one below the key. In type 2 it is the rightmost node pointer (beyond the last key)
   Finally, adjust the count after the deletion
*/
	int i ;
	node * thisNode ;

	cout << endl << "<<< DelKey1 start >>>" << endl ;
	thisNode = &tree[nodeIndex] ;

	if (thisNode->count == 1 && nodeIndex == rootNodeIndex && thisNode->nodePointer[0] == -1) {// Very last key is about to be deleted from the root node and this was also the last node
		btree[nodeIndex] = false ;								// This last node is now free too!
		rootNodeIndex = 0 ;										// Reset it to square one. We can safely do this earlier than the actual deletion below
		nodeCount -- ;
	}

	switch (type) {
		case '1':												// Simple delete, rich leaf or rightmost value in a non-leaf node is deleted
			for (i = pos; i < thisNode->count; i ++) {			// From the deletion point on, shift everything left
				thisNode->key[i] = thisNode->key[i + 1] ;
				thisNode->rowNum[i] = thisNode->rowNum[i + 1] ;
				thisNode->nodePointer[i] = thisNode->nodePointer[i + 1] ;
				thisNode->changeType[i][0] = '0' ;
				thisNode->changeType[i][1] = '1' ;
			}

			thisNode->key[i] = 0 ;								// Remove any left over (usually the 5th key)
			thisNode->rowNum[i] = 0 ;
			thisNode->nodePointer[i] = -1 ;						// The node pointer underneath the key needs deleting
			thisNode->changeType[i][0] = 0 ;
			thisNode->changeType[i][1] = 0 ;

			if (i == 1) {										// Last key from the root node is deleted, so remove last node pointer manually
				thisNode->nodePointer[0] = -1 ;
				thisNode->changeType[0][0] = 0 ;
				thisNode->changeType[0][1] = 0 ;
			}

			break ;
		case '2':												// The last key (rightmost) is to be deleted. Right child is merged into left
			thisNode->key[pos] = 0 ;
			thisNode->rowNum[pos] = 0 ;
			thisNode->nodePointer[pos + 1] = -1 ;				// The rightmost node pointer needs deleting
			thisNode->changeType[pos][0] = 0 ;
			thisNode->changeType[pos][1] = 0 ;

			break ;
		default:

			break ;
	}
	thisNode->count -- ;										// Finally, adjust the key count in the node

	cout << "<<< DelKey1 end >>>" << endl ;
}

// Type 2a
void DelKey2a (delInfo * deli, int key) {						// Delete key from a node. Underflow. Left sibling is rich
/* Delete from a leaf node where the node has underflowed due to a deletion and the left sibling node (being rich) then offers its rightmost
   key that goes up to replace the parent key in the parent node. That parent key in turn will descend and replace the deleted key in the 
   underflowed node restoring the required minimum key count. This is also called "rotation" as the keys move around through the parent node.
   The same is happening for non-leaf nodes when the initial deletion occurred on a leaf node (originated from there).
   
   First, save the left sibling's rightmost key as it will go up to replace the parent key, then delete it.
   Move this key up to replcae the parent key. In the underflowed node, move everything right to make space for the parent key
   that comes down if the key to be deleted is not the first one. Otherwise the parent key simply goes in the first position replacing
   the deleted key. If the left sibling is a non-leaf node, its node pointer and row number must travel over to the other sibling it helped out
*/
	int lkey, lRowNum, lNodePointer ;
	int prntKey, prntRowNum ;
	node * thisNode, * prntNode, * leftSibling ;

	cout << endl << "<<< DelKey2a start >>>" << endl ;
	thisNode = &tree[deli->nodeIndex] ;
	prntNode = &tree[deli->prntIndex] ;
	leftSibling = &tree[deli->leftSibling] ;

	lkey = leftSibling->key[leftSibling->count - 1] ;			// Left sibling's rightmost key
	lRowNum = leftSibling->rowNum[leftSibling->count - 1] ;		// Left sibling's rightmost key's row number
	lNodePointer = leftSibling->nodePointer[leftSibling->count] ; // Left sibling's rightmost key's sub-tree pointer
	
	DelKey1 (deli->leftSibling, lkey, leftSibling->count - 1, '2') ;

	prntKey = prntNode->key[deli->prntKeyPos - 1] ;				// Get the parent's key. That later needs coming down to underflowed node
	prntRowNum = prntNode->rowNum[deli->prntKeyPos - 1] ;
	prntNode->changeType[deli->prntKeyPos - 1][0] = '2' ;
	prntNode->changeType[deli->prntKeyPos - 1][1] = 'g' ;

	if (deli->position > 0) {									// If the key to be deleted is not the leftmost one
		for (int j = deli->position ; j > 0 ; j --) {			// Move everything right to make space for the parent key
			thisNode->key[j] = thisNode->key[j - 1] ;
			thisNode->rowNum[j] = thisNode->rowNum[j - 1] ;
			thisNode->nodePointer[j] = thisNode->nodePointer[j - 1] ;
			thisNode->changeType[j][0] = '2' ;
			thisNode->changeType[j][1] = 'i' ;
		}
	}

	if (deli->position == 0) {									// If the leftmost value is being deleted (replace by parent)
		thisNode->key[deli->position] = prntKey ;				// Prevents insertion into position -1
		thisNode->rowNum[deli->position] = prntRowNum ;
		thisNode->nodePointer[deli->position] = lNodePointer ;
		thisNode->changeType[deli->position][0] = 'D' ;
		thisNode->changeType[deli->position][1] = 'a' ;
	}
	else {
		thisNode->key[deli->position - 1] = prntKey ;			// Otherwise the parent key is inserted before the key to be deleted
		thisNode->rowNum[deli->position - 1] = prntRowNum ;
		thisNode->nodePointer[deli->position - 1] = lNodePointer ;
		thisNode->changeType[deli->position - 1][0] = 'D' ;
		thisNode->changeType[deli->position - 1][1] = 'a' ;
	}

	if (lNodePointer != -1) {
		tree[lNodePointer].prntNodePointer = deli->nodeIndex ;	// Adjust the parent node pointer as this node has been reattached to a new parent node
	}
	prntNode->key[deli->prntKeyPos - 1] = lkey ;				// The left sibling's rightmost key makes it up to the parent
	prntNode->rowNum[deli->prntKeyPos - 1] = lRowNum ;

	cout << "<<< DelKey2a end >>>" << endl ;
}

// Type 2b
void DelKey2b (delInfo * deli, int key) {						// Delete key from a node. Underflow. Right sibling is rich
/* Delete from a leaf node where the node has underflowed due to a deletion and the right sibling node then offers its leftmost key
   that goes up to replace the parent key in the parent node. That parent key in turn will replace the deleted key in the underflowed
   node restoring the right key count. This is also called as "rotation" as the keys move around through the parent node.
   The same is happening for non-leaf nodes when the initial deletion occurred on a leaf node (it started there).
   
   First, save the right sibling's (first) leftmost key as it will go up to replace the parent key, then delete it.
   Move this key up to replcae the parent key. In the underflowed node, move everything left as the parent key will be the rightmost key
   that comes down if the key to be deleted is not the rightmost one. Otherwise the parent key simply goes in the last position replacing
   the deleted key. If the right sibling is a non-leaf node, its node pointer and row number must travel over to the other sibling it helped out
*/
	int j ;
	int rkey, rRowNum, rNodePointer ;
	int prntKey, prntRowNum ;
	node * thisNode, * prntNode, * rightSibling ;

	cout << endl << "<<< DelKey2b start >>>" << endl ;
	thisNode = &tree[deli->nodeIndex] ;
	prntNode = &tree[deli->prntIndex] ;
	rightSibling = &tree[deli->rightSibling] ;

	rkey = rightSibling->key[0] ;								// Right sibling's leftmost key
	rRowNum = rightSibling->rowNum[0] ;
	rNodePointer = rightSibling->nodePointer[0] ;

	DelKey1 (deli->rightSibling, rkey, 0, '1') ;

	prntKey = prntNode->key[deli->prntKeyPos] ;
	prntRowNum = prntNode->rowNum[deli->prntKeyPos] ;
	prntNode->changeType[deli->prntKeyPos][0] = '2';
	prntNode->changeType[deli->prntKeyPos][1] = 'u';

	if (deli->position != thisNode->count - 1) {				// If not the rightmost key is deleted
		for (j = deli->position ; j < thisNode->count -1 ; j ++) {// Move everything left as the parent key comes as the rightmost key (largest)
			thisNode->key[j] = thisNode->key[j + 1] ;
			thisNode->rowNum[j] = thisNode->rowNum[j + 1] ;
			thisNode->nodePointer[j] = thisNode->nodePointer[j + 1] ;
			thisNode->changeType[j][0] = '2';
			thisNode->changeType[j][1] = 'e';
		}
		thisNode->nodePointer[j] = thisNode->nodePointer[j + 1] ;// Rightmost node pointer needs moving manually
	}

	thisNode->key[thisNode->count - 1] = prntKey ;				// The parent key replaces the rightmost key
	thisNode->rowNum[thisNode->count - 1] = prntRowNum ;
	thisNode->nodePointer[thisNode->count] = rNodePointer ;
	thisNode->changeType[thisNode->count - 1][0] = 'D' ;
	thisNode->changeType[thisNode->count - 1][1] = 'b' ;

	if (rNodePointer != -1) {
		tree[rNodePointer].prntNodePointer = deli->nodeIndex ;	// Adjust the parent node pointer as this node has been reattached to a new parent node
	}
	prntNode->key[deli->prntKeyPos] = rkey ;					// The right sibling's leftmost key makes it up to the parent
	prntNode->rowNum[deli->prntKeyPos] = rRowNum ;

	cout << "<<< DelKey2b end >>>" << endl ;
}

// Type 2c
void DelKey2c (delInfo * deli, int key) {						// Delete key from node with not enough keys remaining and neither sibling can help out either
/* Delete a key from a node that underflows but none of its siblings (can be just one) is rich and can't help out. In this case the node must
   merge its keys with the keys of either its siblings. The merge also involves a parent key coming down in the middle. (The opposite of insert where
   the key (median) was promoted to the parent). The key is then gets deleted.
   The same is happening for non-leaf nodes when the initial deletion occurred on a leaf node (it originated from there).
   First, save the parent key and its row number as it gets deleted (when it comes down as the median).
   
   If the right sibling is available, shift everything left in the node from the point of the deletion thus deleting the key and moving 
   the remaining keys to the left. Insert the parent key then (in the middle) and copy everything from the right sibling into this node.
   While copying, erase the keys, row numbers and node pointers from the right sibling. The rightmost node pointer value in the right sibling
   must be copied and erased "manually" (outside the loop). The node count is set to zero, the parent index to -1 actually giving the node
   back to the free list. Since a node ceases to exist, the parent's node pointer must be adjusted accordingly. This adjustment is a bit tricky
   as it must be carried out differently if the node that ceases to exist is a left or right sibling (or rigthmost node in the sub-tree).

   If the left sibling is available, copy everything excluding the key to be deleted to the right hand side of the median to make space for
   the keys of the left sibling (these keys are lower). Insert the parent key then (in the middle) and copy everything from the left sibling into
   the node to the left side of the parent key. While copying, erase the keys, row numbers and node pointers from the left sibling.
   The node count is set to zero, the parent index to -1 actually giving the node back to the free list.

   The parent key that has come down in both cases is then deleted (which can kick of a set of recursive calls if underflows).
   If the parent (root) no longer has any keys (count = 0) then the root node index global pointer is updated. The new root will be
   the node we merged the other node into.
*/
	int prntKey, prntRowNum ;
	int j ;
	node * thisNode, * prntNode, * leftSibling, * rightSibling ;

	cout << endl << "<<< DelKey2c start >>>" << endl ;
	thisNode = &tree[deli->nodeIndex] ;
	prntNode = &tree[deli->prntIndex] ;
	leftSibling = &tree[deli->leftSibling] ;
	rightSibling = &tree[deli->rightSibling] ;

	prntKey = deli->prntKey ;									// This parent key will move down
	prntRowNum = deli->prntRowNum ;

	if (deli->rightSibling != -1) {								// We merge the right sibling into this node
		for (j = deli->position ; j < SPLIT_POINT ; j ++) {		// Shift everything left
			thisNode->key[j] = thisNode->key[j + 1] ;
			thisNode->rowNum[j] = thisNode->rowNum[j + 1] ;
			thisNode->nodePointer[j] = thisNode->nodePointer[j + 1] ;
			thisNode->changeType[j][0] = '2';
			thisNode->changeType[j][1] = 'l';
		}

		thisNode->key[SPLIT_POINT - 1]  = prntKey ;				// Insert the key from the parent in the middle
		thisNode->rowNum[SPLIT_POINT - 1]  = prntRowNum ;
		thisNode->changeType[SPLIT_POINT - 1][0] = 'D';
		thisNode->changeType[SPLIT_POINT - 1][1] = 'c';

		for (j = 0 ; j < rightSibling->count ; j ++){			// Copy everything from the right sibling
			
			thisNode->key[j + SPLIT_POINT] = rightSibling->key[j] ;
			thisNode->rowNum[j + SPLIT_POINT] = rightSibling->rowNum[j] ;
			thisNode->nodePointer[j + SPLIT_POINT] = rightSibling->nodePointer[j] ;
			thisNode->changeType[j + SPLIT_POINT][0] = '2';
			thisNode->changeType[j + SPLIT_POINT][1] = 'm';

			rightSibling->key[j] = 0 ;							// Delete right sibling's data
			rightSibling->rowNum[j] = 0 ;
			if (rightSibling->nodePointer[j] != -1) {
				tree[rightSibling->nodePointer[j]].prntNodePointer = deli->nodeIndex ; // The children of the right sibling must be relocated to a new parent
			}
			rightSibling->nodePointer[j] = -1 ;
			rightSibling->changeType[j][0] = 0 ;
			rightSibling->changeType[j][1] = 0;
		}

		thisNode->nodePointer[j + SPLIT_POINT] = rightSibling->nodePointer[j] ; // The rightmost node pointer needs copying "manually"
		if (rightSibling->nodePointer[j] != -1) {
			tree[rightSibling->nodePointer[j]].prntNodePointer = deli->nodeIndex ; // The rightmost child of the right sibling must be relocated to a new parent "manually"
		}
		rightSibling->nodePointer[j] = -1 ;						// The rightmost node pointer needs deleting "manually"
		thisNode->count += rightSibling->count ;
		rightSibling->count = 0 ;
		rightSibling->prntNodePointer = -1 ;

		btree[deli->rightSibling] = false ;						// Set this node free
		nodeCount -- ;

		prntNode->nodePointer[deli->prntKeyPos + 1] = deli->nodeIndex ; // Right sibling is now empty, so no pointer should point at it. Fix parent's node pointers
	}
	else {														// We merge the left sibling into this node (as there is no right one)
		int i = SPLIT_POINT + 1 ;
		for (j = 0 ; j <= thisNode->count ; j ++) {				// Copy everything not including the delkey. Includes rightmost (median) node pointer too!
			if (thisNode->key[j] != deli->key) {
				thisNode->key[i] = thisNode->key[j] ;
				thisNode->rowNum[i] = thisNode->rowNum[j] ;
				thisNode->nodePointer[i] = thisNode->nodePointer[j] ;
				i ++ ;
				thisNode->changeType[j][0] = '2';
				thisNode->changeType[j][1] = 'r';
			}
		}
		thisNode->key [SPLIT_POINT] = prntKey ;
		thisNode->rowNum [SPLIT_POINT] = prntRowNum ;
		thisNode->changeType[SPLIT_POINT][0] = 'D';
		thisNode->changeType[SPLIT_POINT][1] = 'c';

		for (j = 0 ; j < leftSibling->count ; j ++) {
			
			thisNode->key[j] = leftSibling->key[j] ;
			thisNode->rowNum[j] = leftSibling->rowNum[j] ;
			thisNode->nodePointer[j] = leftSibling->nodePointer[j] ;
			thisNode->changeType[j][0] = '2';
			thisNode->changeType[j][1] = 'm';

			leftSibling->key[j] = 0 ;
			leftSibling->rowNum[j] = 0 ;
			if (leftSibling->nodePointer[j] != -1) {
				tree[leftSibling->nodePointer[j]].prntNodePointer = deli->nodeIndex ; // The children of the left sibling must be relocated to a new parent
			}
			leftSibling->nodePointer[j] = -1 ;
			leftSibling->changeType[j][0] = 0 ;
			leftSibling->changeType[j][1] = 0 ;
		}

		thisNode->nodePointer[j] = leftSibling->nodePointer[j] ;// Left sibling's rightmost pointer needs copying "manually"
		if (leftSibling->nodePointer[j] != -1) {
			tree[leftSibling->nodePointer[j]].prntNodePointer = deli->nodeIndex ; // The rightmost child of the left sibling must be relocated to a new parent "manually"
		}
		leftSibling->nodePointer[j] = -1;						// The rightmost node pointer needs deleting "manually"
		thisNode->count += leftSibling->count ;
		leftSibling->count = 0 ;
		leftSibling->prntNodePointer = -1 ;

		btree[deli->leftSibling] = false ;						// Set this node free
		nodeCount -- ;

		prntNode->nodePointer[deli->prntKeyPos -1] = deli->nodeIndex; // Left sibling is now empty, so no pointer should point at it. Fix parent's node pointers

	}
	if (prntNode->key[deli->prntKeyPos] == 0) {					// The rightmost key has two pointers. If the position is beyond the last key, adjust it
		deli->prntKeyPos = deli->prntKeyPos - 1 ;
	}

	DelKey (deli->prntIndex, prntKey, deli->prntKeyPos) ;

	if (prntNode->count == 0 && deli->prntIndex == rootNodeIndex) { // We deleted a key from the root node and no key is left
		rootNodeIndex = deli->nodeIndex ;						// This is the new root node then!
		btree[deli->prntIndex] = false ;						// This node is now free
		nodeCount -- ;
	}
	cout << "<<< DelKey2c start >>>" << endl ;
}

// Type 3a
void DelKey3a (delInfo * deli, int key) {						// Delete key from parent (non-leaf) node. Predecessor replaces deleted key
/*  Delete a key from a parent node. This eventually boils down to a type 1 deletion because the first thing to do is to find either a predecessor
    or a successor to the key value to be deleted. They are always found at the very bottom of the sub-tree in a leaf node either as the first key
	(successor) or the rightmost (last) one (predecessor).

	In this function, first the predecessor's key value and row number replace the key and row number of the parent node key to be deleted.
	The last step is to try deleting the predecessor from the leaf node. The simplest case is a type 1 deletion which happens if the leaf node holding
	the predecessor key does not underflow upon its key being deleted. In this function this is the case.
*/
	node * thisNode ;

	cout << endl << "<<< DelKey3a start >>>" << endl ;

	thisNode = &tree[deli->nodeIndex] ;

	thisNode->key[deli->position] = pred.key ;					// Predecessor key replaces deleted non-leaf node key
	thisNode->rowNum[deli->position] = tree[pred.nodeIndex].rowNum[pred.position] ;
	thisNode->changeType[deli->position][0] = '3';
	thisNode->changeType[deli->position][1] = 'a';

	DelKey (pred.nodeIndex, pred.key, pred.position) ;			// Delete the predecessor

	cout << "<<< DelKey3a end >>>" << endl ;
}

// Type 3b
void DelKey3b (delInfo * deli, int key) {						// Delete key from parent node. Succcessor replaces deleted key
/*  Delete a key from a parent node. This eventually boils down to a type 1 deletion because the first thing to do is to find either a predecessor
    or a successor to the key value to be deleted. They are always found at the very bottom of the sub-tree in a leaf node either as the first key
	(successor) or the rightmost (last) one (predecessor).

	In this function, first the successor's key value and row number replace the key and row number of the parent node key to be deleted.
	The last step is to try deleting the successor from the leaf node. The simplest case is a type 1 deletion which happens if the leaf node holding
	the successor does not underflow upon its key being deleted. In this function this is the case.
*/
	node * thisNode ;

	cout << endl << "<<< DelKey3b start >>>" << endl ;
	thisNode = &tree[deli->nodeIndex] ;

	thisNode->key[deli->position] = suc.key ;					// Successor key replaces deleted non-leaf node key
	thisNode->rowNum[deli->position] = tree[suc.nodeIndex].rowNum[suc.position] ;
	thisNode->changeType[deli->position][0] = '3';
	thisNode->changeType[deli->position][1] = 'b';

	DelKey (suc.nodeIndex, suc.key, suc.position) ;				// Delete the successor

	cout << "<<< DelKey3b end >>>" << endl ;
}

// Type 3c
void DelKey3c (delInfo * deli, int key) {						// Delete key from non-leaf node where neither the predecessor's node nor the successor's node has enough keys
																// The predecessor node was picked to supply the key to the non-leaf node
/* Delete a key from a parent node. This eventually boils down to a type 1 deletion because the first thing to do is to find either a predecessor
   or a successor to the key value to be deleted. They are always found at the very bottom of the sub-tree in a leaf node either as the first key
   (successor) or the rightmost (last) one (predecessor).

   In this function, the predecessor was chosen to replace the parent node key to be deleted. The left child has enough keys so going for the 
   predecessor saves us at least one DelKey2c call in the end. Hence the decision to go for the predecessor. An even more compelling reason to pick
   the predecessor is if the node holding the predecessor key has a sibling (left or right or both) that is rich, i.e. has at least one key that it
   can offer to replace the predecessor key and repair the underflow.
   The predecessor key value and row number replace the key and row number of the parent node key to be deleted. The last step is to try deleting the predecessor
   from the leaf node. This will however create a spiral upstream and trigger a series of type 2 deletions (DelKey2c) if any node in the sub-tree underflows. 
   The simplest case is a type 1 deletion which happens if the leaf node holding the predecessor does not underflow upon the predecessor key deletion.
   Please note that any further deletions triggered by underflows can only use type 1 or type 2 deletions. Type 3 deletions can only occur if the
   initial key deletion occurs on a non-leaf node!
*/
	node * thisNode ;

	cout << endl << "<<< DelKey3c start >>>" << endl ;
	thisNode = &tree[deli->nodeIndex] ;

	thisNode->key[deli->position] = pred.key ;					// Replace parent key with this nominated (predecessor) key
	thisNode->rowNum[deli->position] = tree[pred.nodeIndex].rowNum[pred.position] ;
	thisNode->changeType[deli->position][0] = '3';
	thisNode->changeType[deli->position][1] = 'c';
	
	DelKey (pred.nodeIndex, pred.key, pred.position) ;			// Delete this nominated key from the leaf with DelKey2c

	cout << "<<< DelKey3c end >>>" << endl ;
}

// Type 3d
void DelKey3d (delInfo * deli, int key) {						// Delete key from non-leaf node where neither the predecessor's node nor the successor's node has enough keys
																// The succcessor node was picked to supply the key to the non-leaf node
/* Delete a key from a parent node. This eventually boils down to a type 1 deletion because the first thing to do is to find either a predecessor
   or a successor to the key value to be deleted. They are always found at the very bottom of the sub-tree in a leaf node either as the first key
   (successor) or the rightmost (last) one (predecessor).
   
   In this function, the successor was chosen to replace the parent node key to be deleted. The right child has enough keys so going for the 
   successor saves us at least one DelKey2c call in the end. Hence the decision to go for the succcessor. An even more compelling reason to pick
   the successor is if the node holding the successor key has a sibling (left or right or both) that is rich, i.e. has at least one key that it
   can offer to replace the successor key and repair the underflow.
   The successor key value and row number replace the key and row number of the parent node key to be deleted. The last step is to try deleting the successor
   from the leaf node. This will however create a spiral upstream and trigger a series of type 2 deletions (DelKey2c) if any node in the sub-tree underflows. 
   The simplest case is a type 1 deletion which happens if the leaf node holding the successor does not underflow upon the successor key deletion.
   Please note that any further deletions triggered by underflows can only use type 1 or type 2 deletions. Type 3 deletions can only occur if the
   initial key deletion occurs on a non-leaf node!
*/
	node * thisNode ;

	cout << endl << "<<< DelKey3d start >>>" << endl ;
	thisNode = &tree[deli->nodeIndex] ;

	thisNode->key[deli->position] = suc.key ;					// Replace parent key with this (successor) nominated key
	thisNode->rowNum[deli->position] = tree[suc.nodeIndex].rowNum[suc.position] ;
	thisNode->changeType[deli->position][0] = '3';
	thisNode->changeType[deli->position][1] = 'd';

	DelKey (suc.nodeIndex, suc.key, suc.position) ;				// Delete this nominated key from the leaf with DelKey2c

	cout << "<<< DelKey3d end >>>" << endl ;
}

Successor GetSucc (int nodeIndex, int pos) {					// Get the successor key
	return _GetSucc (tree[nodeIndex].nodePointer[pos + 1]) ;
}

Successor _GetSucc (int nodeIndex) {							// Recursive pair of GetSucc
	int j ;
	int prntKeyPos ;
	int leftSibling, rightSibling ;
	node * thisNode ;

	thisNode = &tree[nodeIndex] ;

	if (thisNode->nodePointer[0] == -1) {						// Reached a leaf
		suc.key = thisNode->key[0] ;							// Always the first key in the node
		suc.nodeIndex = nodeIndex ;
		suc.position = 0 ;

		if (thisNode->prntNodePointer != -1) {					// Has a parent node
			for (j = 0 ; j <= tree[thisNode->prntNodePointer].count ; j ++) {	// Get the position (index) of the given key in the key set in the node
				if (tree[thisNode->prntNodePointer].nodePointer[j] == nodeIndex)
					break ;
			}
			prntKeyPos = j ;

			if (prntKeyPos > 0) {								// Find the left and right siblings
				leftSibling = tree[thisNode->prntNodePointer].nodePointer[prntKeyPos - 1] ;
			}
			else {
				leftSibling = -1 ;
			}

			if (prntKeyPos == tree[thisNode->prntNodePointer].count) { // This is the rightmost sub-tree
				rightSibling = -1 ;
			}
			else if (prntKeyPos == TREE_ORDER) {				// Absolute rightmost sub-tree
				rightSibling = -1 ;
			}
			else {
				rightSibling = tree[thisNode->prntNodePointer].nodePointer[prntKeyPos + 1] ;
			}
		}
		else {
			leftSibling = -1 ;
			rightSibling = -1 ;
		}

		if (leftSibling != -1) {
			suc.leftSiblingCount = tree[leftSibling].count ;
		}
		else {
			suc.leftSiblingCount = 0 ;
		}

		if (rightSibling != -1) {
			suc.rightSiblingCount = tree[rightSibling].count ;
		}
		else {
			suc.rightSiblingCount = 0 ;
		}

		return suc ;
	}
	else {
		return _GetSucc (thisNode->nodePointer[0]) ;
	}
}

Predecessor GetPred (int nodeIndex, int pos) {					// Get the predecessor key
	return _GetPred (tree[nodeIndex].nodePointer[pos], tree[tree[nodeIndex].nodePointer[pos]].count) ;
}

Predecessor _GetPred (int nodeIndex, int pos) {					// Recursive pair of GetPred
	int j ;
	int prntKeyPos ;
	int leftSibling, rightSibling ;
	node * thisNode ;

	thisNode = &tree[nodeIndex] ;

	if (thisNode->nodePointer[pos] == -1) {						// Reached a leaf node
		pred.key = thisNode->key[tree[nodeIndex].count - 1] ;	// Always the last key in the node
		pred.nodeIndex = nodeIndex ;
		pred.position = thisNode->count - 1 ;

		if (thisNode->prntNodePointer != -1) {					// Has a parent node
			for (j = 0 ; j <= tree[thisNode->prntNodePointer].count ; j ++) {	// Get the position (index) of the given key in the key set in the node
				if (tree[thisNode->prntNodePointer].nodePointer[j] == nodeIndex)
					break ;
			}
			prntKeyPos = j ;

			if (prntKeyPos > 0) {								// Find the left and right siblings
				leftSibling = tree[thisNode->prntNodePointer].nodePointer[prntKeyPos - 1] ;
			}
			else {
				leftSibling = -1 ;
			}

			if (prntKeyPos == tree[thisNode->prntNodePointer].count) {// This is the rightmost sub-tree
				rightSibling = -1 ;
			}
			else if (prntKeyPos == TREE_ORDER) {				// Absolute rightmost sub-tree
				rightSibling = -1 ;
			}
			else {
				rightSibling = tree[thisNode->prntNodePointer].nodePointer[prntKeyPos + 1] ;
			}
		}
		else {
			leftSibling = -1 ;									// has no siblings (must be the root node)
			rightSibling = -1 ;
		}

		if (leftSibling != -1) {
			pred.leftSiblingCount = tree[leftSibling].count ;	// Check how many available keys there are in the left sibling
		}
		else {
			pred.leftSiblingCount = 0 ;
		}

		if (rightSibling != -1) {
			pred.rightSiblingCount = tree[rightSibling].count ;// Check how many available keys there are in the right sibling
		}
		else {
			pred.rightSiblingCount = 0 ;
		}

		return pred ;
	}
	else {
		return _GetPred (thisNode->nodePointer[pos], tree[thisNode->nodePointer[pos]].count) ; // If it has children nodes, recursively traverse those too
	}
}
