# --------------------------------------------------------------------

import os
import sys

# --------------------------------------------------------------------

print ("Hello, World!") # First ever Python program/command
print (sys.argv[0], sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4], len (sys.argv)) # Length of argv as it is a list

# --------------------------------------------------------------------

# All variables are objects.
x = 25
print (id (x))
x = "Hello"
print (id (x))

x = 25
y = x
print (id (x), id (y))
y = 10
print (id (x), id (y))

str1 = "It's a string!"
# str [1] = "r" # Errors. Strings are immutable!
a = "Linux"
b = "Linux"
print (a is b)

a = "Linux-Unix!"
b = "Linux-Unix!" # Even the special chars are not special ones anymore
print (a is b)

# --------------------------------------------------------------------

# This is a comment by the way
"""This is a
multiline docstring."""

# --------------------------------------------------------------------

# Like sprintf in C++
a = 5
b = "hello"
lang = 0 # This could be a language index
format = ["A= #%d, B = %s\n", "C = %d, D = %s\n"] # It is a list, so can be indexed. Two formats for two different languages for example
buffer = format [lang] % (a, b)
print (buffer)

# --------------------------------------------------------------------

x = int (1)   # x will be 1 - Casting with a constructor. Always in parentheses
y = int (2.8) # y will be 2
z = int ("3") # z will be 3
w = float ("4.2") # w will be 4.2

a = "hello"
print (a[1]) # Use [] notation to access each char
# a[2] = 'x' - This is not allowed though. Strings are immutable in Python!

b = "world"
print (b[2:5]) # Substring from 2 to 4 inclusive. 5 is excluded, starts at 0

a = " Hello, World! "
print (a.strip ()) # Strips whitespace
print (len (a)) # Length of a
print (a.upper ()) # Uppercase / lowercase
print (a.replace ("H", "J")) # Replace
print (a.split (",")) # Splits string if it finds the separator. Returns a list
print (a[0:13:2]) # Slicing has a third argument which is the step parameter. Every second char in this case

# --------------------------------------------------------------------

# Conditional
a = 200
b = 33
if b > a:
    print("b is greater than a")
elif a == b:
    print("a and b are equal")
else:
    print("a is greater than b")

    # --------------------------------------------------------------------

# While loop
i2 = 0
while i2 < 8:
    i2 += 1
    if i2 == 6:
        break
    if i2 == 3:
        continue
    print(i2)

    # --------------------------------------------------------------------

# For loop
thislist = [5, 8, 1, 3, 0]
for x in thislist:
    print(x)
    # Break and Continue is the same as for the While-loop

for x in range (2, 10, 2): # In the range of 2 to 9 with 2 as increment
    print (x)

for i in range (len (thislist)): # Combine range with the length of the list
    print (thislist [i])

    # --------------------------------------------------------------------

#print("Enter your name:")
#x = input() #
# User input
#print("Hello, " + x)

# --------------------------------------------------------------------

x = 5
x <<= 3 # Shift left 3 times (multiply by 8)
x &= 3 # Bit AND
x |= 3 # Bit OR

# --------------------------------------------------------------------

x = ["apple", "banana"]
y = ["apple", "banana"]
z = x

print (x is z) # returns True because z is the same object as x
print (x is y) # returns False because x is not the same object as y, even if they have the same content
print (x == y) # to demonstrate the difference betweeen "is" and "==": this comparison returns True because x is equal to y

print ("banana" in x) # returns True because a sequence with the value "banana" is in the list
print (['zero', 'one'][False]) # It is going to be 'zero' because False is 0 and a subclass of int. So the list's zero-th indexed value
print (['one', 'two', 'three'][1]) # Like a two-dimensional array. We want index = 1 element

print (str (id (x)) + ' ' + str (id (y)) + ' ' + str (id (z))) # Unique object IDs. Needs converting to string because of print
print ("I am %d years old living in %s for the last %f years" % (50, 'London', 19.5))
print ("I'm using a single quote here.")
print ('I\'m using a single quote here too')
print ('*-*' * 5) # Prints it 5x

# --------------------------------------------------------------------

# Type
str1 = "Hi!"
l1 = list ((1, 2, 3))
print (str (type (str1)) + "\n" + str (type (l1)) + "\n")

x = 4 # x is of type int # Type is defined at assignment
x = "Sally" # x is now of type str # Weekly typed language
print (x)

x = "awesome"
print ("Python is " + x) # Concatenation
print (type (x)) # Check type

# --------------------------------------------------------------------

# All and any
print (all ([1, 2, 3, 4])) # has to test to the end!
# True
print (all ([0, 1, 2, 3, 4])) # 0 is False in a boolean context!
# False ^--stops here!
print (all ([]))
# True gets to end, so True!

print (any ([0, 0.0, '', (), [], {}])) # has to test to the end!
# False
print (any ([1, 0, 0.0, '', (), [], {}]))  # 1 is True in a boolean context!
# True  ^--stops here!
print (any ([]))
# False gets to end, so False!

# --------------------------------------------------------------------

os.system ("pause")
