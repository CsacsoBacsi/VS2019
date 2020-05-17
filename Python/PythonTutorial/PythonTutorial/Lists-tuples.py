# --------------------------------------------------------------------

import os

# --------------------------------------------------------------------

''' List is a collection which is ordered and changeable. Allows duplicate members
    Tuple is a collection which is ordered and unchangeable. Allows duplicate members
    Set is a collection which is unordered and unindexed. No duplicate members
    Dictionary is a collection which is unordered, changeable and indexed. No duplicate members
    Can contain single and double quotes too!'''

# List
thislist = ["apple", "banana", "cherry"] # Angle brackets [] mean create list
thislist[1] = "blackcurrant"
print (thislist) # Change the second item on the list

thislist = list (("apple", "banana", "cherry")) # Use the List constructor (note the double brackets)
thislist.append ("orange")
thislist.append (["fruit1", "fruit2"]) # This adds it as a sub-list! Could have been a tuple as well or any other object!
thislist.extend (["fruit3", "fruit4"]) # Whereas extend adds them one by one
thislist.remove ("banana")
thislist.insert (2, "banana") # Inserts at a given position
print (thislist)
print (len (thislist)) # Length of elements in the array

thislist += ["pineapple", "coconut"] # Concatenation. Very slow!
thispartlist = thislist [2:3] # From and including position 2 to 3 excluding. Slice notation
print (thislist)
print (len (thislist))
print (thispartlist)
print (len (thispartlist))

# --------------------------------------------------------------------

# Tuple
thistuple = ("apple", "banana", "cherry") # Brackets ()
print (thistuple[1])
#thistuple[1] = "blackcurrant" # Can not be changed, immutable. Throws an error
thistuple = tuple (("apple", "banana", "cherry")) # Use Tuple constructor (note the double round-brackets)
print (thistuple)
print (len (thistuple))

text = "This is a text"
print (text [0], text [5], text [-1]) ;
lst = ["one", "two", "three", "four"]
print (lst[0], lst [-1]) ;
print (len (lst)) ;

subl = [["one", "two"],["Csacsi", "Andy", "Fler"]]
print (subl[0])
print (subl[1][2])
subl[1][2] = "Fleur"
print (subl[1][2])

print (text[0:3])
print (text[5:])
print (text[:])
print (text[:-5])
print (text[::2])

colours1 = ["red", "green","blue"]
colours2 = ["black", "white"]
colours = colours1 + colours2
print (colours)

print ("green" in colours)
print (["green"] in colours) # List in another list
print ('x' in text)

print (3 * lst)
print (3 * [lst])
lst2 = 3 * [lst]
print (lst2 [0][0])
lst2 [0][0] = "One"
print (lst2)
print ([lst2])

# --------------------------------------------------------------------

colours.append ("cyan") # Appends to the end
colours.pop (0) # Removes first element
print (colours)
colours.pop () # Removes last element. Equals to -1
print (colours)
colours2 = ["yellow", "brown"]
colours.extend (colours2)
print (colours)
colours.append (colours2)
print (colours)
colours.remove ("blue")
print (colours)
print (colours.index ("yellow"), 2, 5) # Search between the 3rd and 5th element
colours.insert (2, "magenta") # Insert at 3rd position (starts with 0)
print (colours)

# --------------------------------------------------------------------

os.system ("pause")
