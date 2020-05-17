# --------------------------------------------------------------------

import sys
import os

# --------------------------------------------------------------------

# Helper functions
def printf (format, *args): # Single * means named arguments
  sys.stdout.write (format % args) # Like printf. The arguments after % formatted according to format

def printException (exception):
  error, = exception.args # Comma is needed when there is just 1 value
  printf ("Error code = %s\n", error.code)
  printf ("Error message = %s\n", error.message)

# --------------------------------------------------------------------

print ("a", "b", sep = "") # No space between
print (192, 168, 178, 42, sep = ".")

print ()
for i in range (4): # 0 to 3. Disables new line
    print (i, end = " ")
    #print ("hi")

    # --------------------------------------------------------------------

import sys
print ("Error: 42", file = sys.stderr)

# --------------------------------------------------------------------

str = "Int param: ".format (5) # prints no arg
str = "Int param: {0:5d} float: {1:5.2f}".format (5, 7.876) # In first and second position
print (str, end = "\n")
print ("Hi")

printf ("Int: %d float: %5.2f\n", 4.5, 7.876)
str = "Int: {a:3d} float: {b:5.2f}".format (a=7, b=9.545)
print (str)

str = "Int: {a_var} float: {b_var}".format (a_var=7, b_var=9.545)
print (str)

print ("First")
print ("Second", end = "")
print ("Third")
print ("Fourth")

# --------------------------------------------------------------------

os.system ("pause")
