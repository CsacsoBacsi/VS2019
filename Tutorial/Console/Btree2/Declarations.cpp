// B-tree (Balanced tree) declarations

#include "Btree.h"

// Structures
node tree [NODES] ;
bool btree [NODES] ;
Deltype * dtype ;
Successor suc ;
Predecessor pred ;

// Globals
int tblRowNum ;													// The virtual db table's row number
int nodeCount ;													// Keeps track of created node counts
int nodeHWM ;													// High Water Mark. Highest allocated node index
int rootNodeIndex ;												// Keeps track of which node is the root one
bool success ;													// Indicates whether the deletion was successful or not
int dtypeInd ;													// Pointer index to the deletion type history array
bool recur = false ;											// Recursive indicator

// Function prototypes
// Btree utils
void PopulateTree () ;
int CreateNode (node *) ;
void InitNode (node *) ;
insInfo Find (node *, int, int) ;
int GetRowNum (int, int) ;
void TraverseTree (node *, int) ;
void checkTree () ;

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
