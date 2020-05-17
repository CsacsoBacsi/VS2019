# --------------------------------------------------------------------

import os
from copy import deepcopy

# --------------------------------------------------------------------

colours1 = ["red", "blue"]
colours2 = colours1 # Their IDs are the same. * Shallow copy *
colours2[1] = "green" # Changes colours1 [1] too!
colours2 = ["red", "blue"] # New list object created. Their IDs are now different

colours1 = ["red", "blue"]
colours2 = colours1[:] # Their IDs are different. * Deeper copy *
colours2[1] = "green" # Has no effect on colours1

colours1 = ["red", "blue", ["green", "yellow"]]
colours2 = colours1[:] # Their IDs are different but they share the same IDs for the sub-list!
colours2[2][1] = "brown" # colours1's same list value is the same ("brown")

colours1 = ["red", "blue", ["green", "yellow"]]
colours2 = deepcopy (colours1) # Creates a new sub-list for colours2. They do not share it anymore
colours2 [0] = "magenta"

# --------------------------------------------------------------------

# Another but same example
list1 = ['a','b','c','d']
list2 = list1[:] # Copy with no side effects. IDs are different
list2[1] = 'x'
print (list2)
print (id (list1))
print (id (list2))

lst1 = ['a','b',['ab','ba']] # The sub structure will not be deep copied! Only 'a' and 'b'
lst2 = lst1[:]
lst2[2][1] = 'd'
print (lst1)
print (lst2)
print (id (lst1[2]))
print (id (lst2[2])) # Same!

from copy import deepcopy
lst1 = ['a','b',['ab','ba']]
lst2 = deepcopy (lst1)
print (lst1)
print (lst2)

print (id (lst1))
print (id (lst2))
print (id (lst1[0]))
print (id (lst2[0]))
print (id (lst1[2]))
print (id (lst2[2])) # All different!

# --------------------------------------------------------------------

seta = {1,2,3,4,5,6,9}
setc = seta.copy () # Deep copy creates a new set
seta.clear ()
print (setc) # Has the values! With = this would be different. They would both be pointing at the same set

# --------------------------------------------------------------------

os.system ("pause")
