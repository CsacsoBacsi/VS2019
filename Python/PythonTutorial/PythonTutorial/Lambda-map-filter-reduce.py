# --------------------------------------------------------------------

import os
import functools

# --------------------------------------------------------------------

# Lambda functions
def myfunc (n):
  print ("n: ", n)
  return lambda i: i * n # i is the parameter

doubler = myfunc (2) # Creates 2 functions (basically function pointers)
tripler = myfunc (3)
val = 11
print ("Doubled: " + str (doubler (val)) + ". Tripled: " + str (tripler (val))) # Call the function via the func pointer

squared = lambda i: i ** 2
print (squared (4))

# --------------------------------------------------------------------

# Map
numlist = [2, 4, 5, 7, 11, 14]
squaredlist = list (map (squared, numlist)) # Map applies the function to each element of the list. More than one list is possible. They are synchronized
squaredlist2 = list (map (lambda i: i ** 2, numlist)) # No need to define a function separately. Noname, throwaway function
for i in squaredlist:
    print (i)
print ("")
for i in squaredlist2:
    print (i)

# --------------------------------------------------------------------

# Filter
print ("")
divbytwo = list (filter (lambda num: int (num / 2) * 2 == num, numlist)) # Returns those elements for which the function returns true
for i in divbytwo:
    print (i)

# --------------------------------------------------------------------

# Reduce
print ("")
maxval = functools.reduce (lambda a, b: a if a > b else b, numlist) # Reduce moved to functools module. Operates on first 2 then on result and 3rd, result and 4th, etc.
print ("Maxval: ", maxval)

# --------------------------------------------------------------------

os.system ("pause")
