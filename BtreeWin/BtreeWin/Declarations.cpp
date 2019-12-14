// B-tree (Balanced tree) declarations

#include "Btree.h"
// Windows
HWND	hDlg ;
HWND	hAboutDlg ;
HWND	hHelpDlg ;
FILE *	stream ;
HWND hTreeView ;
HWND hTreeViewP ;
char nullchar[3]{ 0 } ;

// Structures
node tree[NODES] ;
node stree[NODES] ;
bool btree[NODES] ;
bool sbtree[NODES] ;
Deltype * dtype ;
Successor suc ;
Predecessor pred ;

// Globals
int tblRowNum ;													// The virtual db table's row number
int nodeCount ;													// Keeps track of created node counts
int snodeCount ;												// Keeps track of created node counts in the shadow tree
int nodeHWM ;													// High Water Mark. Highest allocated node index
int snodeHWM ;													// High Water Mark. Highest allocated node index in the shadow tree
int rootNodeIndex ;												// Keeps track of which node is the root one
int srootNodeIndex ;											// Keeps track of which node is the root one in the shadow tree
bool success ;													// Indicates whether the deletion was successful or not
int dtypeInd ;													// Pointer index to the deletion type history array
bool recur = false ;											// Recursive indicator

// Function prototypes
// Btree utils
int main () ;
void PopulateTree () ;
int CreateNode (node *) ;
void InitNode (node *) ;
insInfo Find (node *, int, int) ;
int GetRowNum (int, int) ;
void TraverseTree (node *, int) ;
bool CheckTree () ;

// Insert
int GetInsertPos (node *, int) ;
bool Insert (int, int) ;
bool InsKey (insInfo) ;
void Split (insInfo) ;

// Delete
bool Delete (int) ;
bool DelKey (int, int, int) ;
void GetDelType (delInfo *, int, int, int) ;
void DelKey1 (int, int, int, char) ;
void DelKey2a (delInfo *, int) ;
void DelKey2b (delInfo *, int) ;
void DelKey2c (delInfo *, int) ;
void DelKey3a (delInfo *, int) ;
void DelKey3b (delInfo *, int) ;
void DelKey3c (delInfo *, int) ;
void DelKey3d (delInfo *, int) ;
Successor  GetSucc (int, int) ;
Successor _GetSucc (int) ;										// Recursive pair of GetSucc
Predecessor  GetPred (int, int) ;
Predecessor _GetPred (int, int) ;								// Recursive pair of GetPred

char * helpInsertGeneral = 
"Insertion general\r\n\r\n\
Insertion only occurs on a leaf node. First we must find the insertion point\r\n\
where the new key can be inserted at. at any given time, there must at least be\r\n\
MIN_KEYS number of keys in each and every node (except the root node) and there\r\n\
can not be more than MAX_KEYS (TREE_ORDER - 1).\r\n\r\n\
\
Type 1 insertion occurs if the node we would like to insert the new key into has\r\n\
less than MAX_KEYS keys. In this case a simple insertion occurs at the correct\r\n\
insertion point.\r\nType 2 insertion occurs if the node we would like to insert the\r\n\
new key into already has MAX_KEYS (i.e. it is full) and upon insertion of this\r\n\
additional key an overflow occurs. In such cases, the overflowed node must be split.\r\n\
\
Splitting means a creation of a new (rigth split node). The key to the left of the\r\n\
median value in the node to be split stay where they are. The median key is promoted\r\n\
to the parent (it becomes an insert into the parent node). If a parent node does not\r\n\
exist, it must be created and initialized. This is how the tree expands with new\r\n\
levels Upwards. If the parent node already exists, we must find where to insert this\r\n\
median key. This may boil down to a type 1 insert unless the parent	node already has\r\n\
MAX_KEYS therefore overflows. This will trigger a parent node split, the median being\r\n\
promoted a level higher, etc. The initial insertion into a leaf node may trigger\r\n\
several splits on several levels in the whole tree until a node is found that has\r\n\
enough room to accommodate the median from below.\r\n\r\n\
\
During splits, if they occur on non-leaf nodes, we must ensure that the newly created\r\n\
node has the correct children and these children point at the correct parent node too.\r\n\
The new node's parent pointer must also be correctly set. Special care needed in\r\n\
situations when the right most child node splits. Node pointers  and parent pointers\r\n\
must be correctly set, whole sub-trees can move from one parent to another. The\r\n\
growth of the tree is only limited by the number of allocated nodes." ;
char * helpDeleteGeneral = 
"Deletion general\r\n\r\n\
\
If the initial deletion (when the DelKey function is called via Delete the first time)\r\n\
occurs on a leaf node, the deletion type can only either be type 1 or type 2 (and its\r\n\
variants).\r\n\r\n\
\
Type 1 is a simple deletion from the node when there will be enough keys remaining in\r\n\
the node after the deletion (number of keys greater than MIN_KEYS which is half of\r\n\
TREE_ORDER - 1). In other words, there is no underflow in the node as a result of the\r\n\
key deletion.\r\n\
Type 2 deletion occurs when an underflow happens in the node where a key is about to\r\n\
be deleted from.\r\n\
Type 2a handles cases when the left sibling can help out as it has more than MIN_KEYS\r\n\
keys and can hand over its rigthmost key.\r\n\
Type 2b is similar to type 2a however in this case it is the right sibling that hands\r\n\
its first key (leftmost) over.\r\n\
In both cases the handover occurs via the parent key. The relinquished key replaces\r\n\
the parent key which in turn replaces the deleted key in the underflowed node. This is\r\n\
also called \"rotation\" as the keys move around from left to right or right to left\r\n\
via the parent node. Please note that if non-leaf keys are involved in this, the node\r\n\
pointer of the key is also moving together with the relinquished key but does not stop\r\n\
at the parent but makes it over to the underflowed node.\r\n\r\n\
\
Type 2c is a special case when no sibling can help out and the node the key is deleted\r\n\
from underflows. In this keys the opposite of an insert must happen (when no more key\r\n\
fits in the node as it is full) i.e. the parent key must descend and the two children\r\n\
nodes must be merged. There are two cases: when the right child's keys merge into the\r\n\
left child node and vice versa when the left child's keys merge into the right child\r\n\
node. In both cases the parent key descends in the middle (median) then the original\r\n\
key marked for deletion can be deleted. Since one of the children (the one that merges\r\n\
into the other one) ceases to exist, the parent's node pointers must be adjusted\r\n\
accordingly.\r\n\r\n\
\
In such cases when nodes need merging and the parent key must descend (meaning it is\r\n\
deleted from the parent node) it can happen that the parent node underflows as a result\r\n\
triggering another 2a, 2b or even another 2c deletion. This can spiral up to as far as\r\n\
the root node. Code-wise it is a recursive call to the DelKey functions. The only\r\n\
exception to the rule is the root key that can hold less than MIN_KEYS keys. When the\r\n\
last key from the root node is deleted (e.g. as part of the children's merge) the tree\r\n\
collapses. It becomes flatter by one level. The node the other node was merged into\r\n\
becomes the new root node. This goes on until all keys from the last (root) node is\r\n\
deleted in which case the root node pointer is reset to zero.\r\n\r\n\
\
Type 3 deletions can only occur if the initial deletion happens to a non-leaf node. In\r\n\
these cases either the predecessor or the successor key can replace the deleted key.\r\n\
This key comes from a leaf node possibly several levels below the parent node. If\r\n\
the node holding the predecessor has enough keys (does not underflow due to the\r\n\
predecessor key's deletion) than the deletion is of type 3a.\r\n\
Type 3b handles the case when the node that holds the successor has enough keys to\r\n\
promote it. Type 3a is chosen also if although the predecessor's node underflows, one\r\n\
of its siblings (it may have two or just one) is rich (has enough keys) therefore can\r\n\
help out. Likewise, type 3b is chosen also if although the successor's node underflows,\r\n\
one of its siblings (it may have two or just one) is rich (has enough keys) therefore\r\n\
can help out.\r\n\r\n\
\
Type 3c and type 3d occur when neither node holding the predecessor and the successor\r\n\
respectively has enough keys remaining after the deletion (key promotion) and neither\r\n\
of their siblings are rich to help out with a spare key. We must decide though which\r\n\
key (predecessor or successor) to promote. In this decision the only decisive factor is\r\n\
the number of keys in the direct children. If the left child has more keys than MIN_KEYS,\r\n\
then the predecessor is chosen otherwise the right child's route down to the successor\r\n\
irrespective to whether the right child has more keys than MIN_KEYS or not. This might\r\n\
save us eventually an extra 2c type deletion. On the leaf level, the promotion of either\r\n\
the predecessor or the successor will always kick off a type 2 deletion that in turn can\r\n\
trigger further deletions in the sub-tree going higher and higher towards the root." ;
char * helpDeleteType1 =
"Deletion type 1\r\n\r\n\
Delete a key from a node (usually from a leaf but maybe from the root).\r\n\
From the deletion point on, shift everything left (just deleting what needs to be).\r\n\
Sometimes during merges there are 5 keys temporarily so delete anything beyond the last\r\n\
key manually. Type 1 is the simplest form or when the rightmost key from a non-leaf node\r\n\
is deleted, the code must chose which of the two node pointers needs deleting. In type 1\r\n\
it is the one below the key. In type 2 it is the rightmost node pointer (beyond the last\r\n\
key). Finally, adjust the count after the deletion" ;
char * helpDeleteType2a =
"Deletion type 2a\r\n\r\n\
Delete from a leaf node where the node has underflowed due to a deletion and the left\r\n\
sibling node (being rich) then offers its rightmost key that goes up to replace the parent\r\n\
key in the parent node. That parent key in turn will descend and replace the deleted key\r\n\
in the underflowed node restoring the required minimum key count. This is also called\r\n\
\"rotation\" as the keys move around through the parent node. The same is happening for\r\n\
non-leaf nodes when the initial deletion occurred on a leaf node (originated from there).\r\n\r\n\
\
First, save the left sibling's rightmost key as it will go up to replace the parent key,\r\n\
then delete it. Move this key up to replcae the parent key. In the underflowed node, move\r\n\
everything right to make space for the parent key that comes down if the key to be deleted\r\n\
is not the first one. Otherwise the parent key simply goes in the first position replacing\r\n\
the deleted key. If the left sibling is a non-leaf node, its node pointer and row number\r\n\
must travel over to the other sibling it helped out" ;
char * helpDeleteType2b =
"Deletion type 2b\r\n\r\n\
Delete from a leaf node where the node has underflowed due to a deletion and the right\r\n\
sibling node then offers its leftmost key that goes up to replace the parent key in the\r\n\
parent node. That parent key in turn will replace the deleted key in the underflowed node\r\n\
restoring the right key count. This is also called as \"rotation\" as the keys move around\r\n\
through the parent node. The same is happening for non-leaf nodes when the initial deletion\r\n\
occurred on a leaf node (it started there).\r\n\r\n\
\
First, save the right sibling's (first) leftmost key as it will go up to replace the parent\r\n\
key, then delete it. Move this key up to replcae the parent key. In the underflowed node,\r\n\
move everything left as the parent key will be the rightmost key that comes down if the key\r\n\
to be deleted is not the rightmost one. Otherwise the parent key simply goes in the last\r\n\
position replacing the deleted key. If the right sibling is a non-leaf node, its node pointer\r\n\
and row number must travel over to the other sibling it helped out" ;
char * helpDeleteType2c =
"Deletion type 2c\r\n\r\n\
Delete a key from a node that underflows but none of its siblings (can be just one) is\r\n\
rich and can't help out. In this case the node must merge its keys with the keys of\r\n\
either its siblings. The merge also involves a parent key coming down in the middle.\r\n\
(The opposite of insert where the key (median) was promoted to the parent). The key is\r\n\
then gets deleted. The same is happening for non-leaf nodes when the initial deletion\r\n\
occurred on a leaf node (it originated from there). First, save the parent key and its\r\n\
row number as it gets deleted (when it comes down as the median).\r\n\r\n\
\
If the right sibling is available, shift everything left in the node from the point of\r\n\
the deletion thus deleting the key and moving the remaining keys to the left. Insert the\r\n\
parent key then (in the middle) and copy everything from the right sibling into this node.\r\n\
While copying, erase the keys, row numbers and node pointers from the right sibling. The\r\n\
rightmost node pointer value in the right sibling must be copied and erased \"manually\"\r\n\
(outside the loop). The node count is set to zero, the parent index to -1 actually giving\r\n\
the node back to the free list. Since a node ceases to exist, the parent's node pointer\r\n\
must be adjusted accordingly. This adjustment is a bit tricky as it must be carried out\r\n\
differently if the node that ceases to exist is a left or right sibling (or rigthmost node\r\n\
in the sub-tree). If the left sibling is available, copy everything excluding the key to\r\n\
be deleted to the right hand side of the median to make space for the keys of the left\r\n\
sibling (these keys are lower).\r\n\
Insert the parent key then (in the middle) and copy everything from the left sibling into\r\n\
the node to the left side of the parent key. While copying, erase the keys, row numbers and\r\n\
node pointers from the left sibling.\r\n\
The node count is set to zero, the parent index to -1 actually giving the node back\r\n\
to the free list. The parent key that has come down in both cases is then deleted\r\n\
(which can kick of a set of recursive calls if underflows). If the parent (root) no\r\n\
longer has any keys (count = 0) then the root node index global pointer is updated. The\r\n\
new root will be the node we merged the other node into." ;
char * helpDeleteType3a =
"Deletion type 3a\r\n\r\n\
Delete a key from a parent node. This eventually boils down to a type 1 deletion because\r\n\
the first thing to do is to find either a predecessor or a successor to the key value to be\r\n\
deleted. They are always found at the very bottom of the sub-tree in a leaf node either as\r\n\
the first key successor) or the rightmost (last) one (predecessor). In this function, first\r\n\
the predecessor's key value and row number replace the key and row number of the parent node\r\n\
key to be deleted. The last step is to try deleting the predecessor from the leaf node. The\r\n\
simplest case is a type 1 deletion which happens if the leaf node holding the predecessor\r\n\
key does not underflow upon its key being deleted. In this function this is the case." ;
char * helpDeleteType3b =
"Deletion type 3b\r\n\r\n\
Delete a key from a parent node. This eventually boils down to a type 1 deletion because\r\n\
the first thing to do is to find either a predecessor or a successor to the key value to be\r\n\
deleted. They are always found at the very bottom of the sub-tree in a leaf node either as\r\n\
the first key (successor) or the rightmost (last) one (predecessor). In this function, first\r\n\
the successor's key value and row number replace the key and row number of the parent node\r\n\
key to be deleted. The last step is to try deleting the successor from the leaf node. The\r\n\
simplest case is a type 1 deletion which happens if the leaf node holding the successor does\r\n\
not underflow upon its key being deleted. In this function this is the case." ;
char * helpDeleteType3c =
"Deletion type 3c\r\n\r\n\
Delete a key from a parent node. This eventually boils down to a type 1 deletion because the\r\n\
first thing to do is to find either a predecessor or a successor to the key value to be\r\n\
deleted. They are always found at the very bottom of the sub-tree in a leaf node either as\r\n\
the first key (successor) or the rightmost (last) one (predecessor). In this function, the\r\n\
predecessor was chosen to replace the parent node key to be deleted. The left child has\r\n\
enough keys so going for the predecessor saves us at least one DelKey2c call in the end.\r\n\
Hence the decision to go for the predecessor. An even more compelling reason to pick the\r\n\
predecessor is if the node holding the predecessor key has a sibling (left or right or\r\n\
both) that is rich, i.e. has at least one key that it can offer to replace the predecessor\r\n\
key and repair the underflow.\r\n\r\n\
\
The predecessor key value and row number replace the key and row number of the parent node\r\n\
key to be deleted. The last step is to try deleting the predecessor from the leaf node. This\r\n\
will however create a spiral upstream and trigger a series of type 2 deletions (DelKey2c) if\r\n\
any node in the sub-tree underflows. The simplest case is a type 1 deletion which happens if\r\n\
the leaf node holding the predecessor does not underflow upon the predecessor key deletion.\r\n\
Please note that any further deletions triggered by underflows can only use type 1 or type 2\r\n\
deletions. Type 3 deletions can only occur if the initial key deletion occurs on a non-leaf node!" ;
char * helpDeleteType3d =
"Deletion type 3d\r\n\r\n\
Delete a key from a parent node. This eventually boils down to a type 1 deletion because the\r\n\
first thing to do is to find either a predecessor or a successor to the key value to be\r\n\
deleted. They are always found at the very bottom of the sub-tree in a leaf node either as\r\n\
the first key (successor) or the rightmost (last) one (predecessor). In this function, the\r\n\
successor was chosen to replace the parent node key to be deleted. The right child has enough\r\n\
keys so going for the successor saves us at least one DelKey2c call in the end. Hence the\r\n\
decision to go for the succcessor. An even more compelling reason to pick the successor is\r\n\
if the node holding the successor key has a sibling (left or right or both) that is rich, i.e.\r\n\
has at least one key that it can offer to replace the successor key and repair the underflow.\r\n\r\n\
\
The successor key value and row number replace the key and row number of the parent node key\r\n\
to be deleted. The last step is to try deleting the successor from the leaf node. This will\r\n\
however create a spiral upstream and trigger a series of type 2 deletions (DelKey2c) if any\r\n\
node in the sub-tree underflows. The simplest case is a type 1 deletion which happens if the\r\n\
leaf node holding the successor does not underflow upon the successor key deletion. Please\r\n\
note that any further deletions triggered by underflows can only use type 1 or type 2\r\n\
deletions. Type 3 deletions can only occur if the initial key deletion occurs on a non-leaf\r\n\
node!" ;
