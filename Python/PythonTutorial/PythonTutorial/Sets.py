# --------------------------------------------------------------------

import os

# --------------------------------------------------------------------

thisset = {"apple", "banana"} # Curly brackets
print (thisset)
thisset = set (("apple", "banana", "cherry")) # Use Set constructor (note the double round-brackets)
print (thisset) 
thisset.add("orange")
thisset.remove("banana")
print (len (thisset))

# --------------------------------------------------------------------

seta = {1,2,3,4,5,6,9}
setb = {1,2,7,8}
print (seta - setb)
print (seta | setb)
print (seta & setb)

setc = seta.copy () # Deep copy creates a new set
seta.clear ()
print (setc) # Has the values! With = this would be different. They would both be pointing at the same set

seta = {1,2,3,4,5,6,9}
seta.difference_update (setb) # Removes all elements of another set. Removes setb elements from seta
seta.discard (9) # Removes given element (9)
seta.discard (11) # Does not exist, nothing happens. Remove () would raise an error

nothing_common = seta.isdisjoint (setb) # Returns true if the two sets have a null intersection
mybool = seta.issubset (setb) # Returns true if seta is the subset of setb
mybool = seta.issuperset (setb) # Returns true if seta is the the superset of setb

thisset.clear ()

# --------------------------------------------------------------------

os.system ("pause")
