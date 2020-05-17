# --------------------------------------------------------------------

import os
import functools

# --------------------------------------------------------------------

transposed = []
matrix = [[1, 2, 3, 4], [4, 5, 6, 8]]

for i in range (len (matrix[0])): # Loop over row length (outer loop)
    transposed_row = []

    for row in matrix: # Loop over (2) rows
        transposed_row.append (row[i])
    transposed.append (transposed_row)

print (transposed)

# --------------------------------------------------------------------

matrix = [[1,2], [3,4], [5,6], [7,8]]
transposed = [[row[i] for row in matrix] for i in range (2)] # First i, then rows in matrix

print (transposed)

# --------------------------------------------------------------------

matrix = [[0, 0, 0], [1, 1, 1], [2, 2, 2],]
flat = [num for row in matrix for num in row] # From left to right

print (flat)

# --------------------------------------------------------------------

# Boils down to *result* = [*transform* *iteration* *filter*]
mystring = "Hello 12345 World"
numbers = [(int (x)) *2 for x in mystring if x.isdigit()]
print (numbers)

numbers = range (10)
new_list = [n**2 for n in numbers if n%2==0]
print (new_list)
new_list = [n**2 for n in numbers if not n%2] # Same as above
print (new_list)

# --------------------------------------------------------------------

# Three solutions to same problem
kilometer = [39.2, 36.5, 37.3, 37.8]
feet = list (map (lambda x: float (3280.8399) * x, kilometer))
print (feet)
feet2 = list ((float (3280.8399) * x for x in kilometer))
print (feet2)
feet2 = [float (3280.8399) * x for x in kilometer]
print (feet2)

# --------------------------------------------------------------------

sum_feet = functools.reduce (lambda x, y: x + y, feet) # Use first two elements, then the 3rd with the result. Add numbers together
print (sum_feet)
sum_feet = sum ([x for x in feet2])
print (sum_feet)

# --------------------------------------------------------------------

divided = [x for x in range(100) if x % 2 == 0 if x % 10 == 0] # Conditional compound
print (divided)
divided = [x for x in range(100) if x % 10 == 0 or x % 5 == 0]
print (divided)
divided = list (filter (lambda x: x % 10 == 0 or x % 5 == 0, range (100)))
print (divided)

# --------------------------------------------------------------------

two_dim = list (([1, 2], [3, 4], [5, 6])) # Flatten
print (two_dim)
flattened = [y for x in two_dim for y in x] # Left to right
print (flattened)

transposed = [[x [i] for x in two_dim] for i in range (2)]
print (transposed)

list5 = [x for x in two_dim]
print (list5)
for x, y in two_dim:
  print (x, y)

# --------------------------------------------------------------------

two_dim = list (([1, 2], [3, 4, 7], [5, 6, 8, 9])) # Flatten
flattened = [i for x in two_dim for i in range (len (x))]
print (flattened)

list_of_list = [[1,2,3],[4,5,6],[7,8]]
lol = [f for x in list_of_list for f in x]
print (lol)

# --------------------------------------------------------------------

os.system ("pause")
