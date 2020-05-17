# --------------------------------------------------------------------

import os

# --------------------------------------------------------------------

def t ():
    #print (s) # s referenced before assignment. s can not be both global and local!
    s = "I love London!" # Local s
    print (s) 

s = "I love Paris!" # Global s
t ()
print(s)

def g ():
    global t
    print (t) # t is now global
    t = "I love London!" # The global t is being modified
    print (t) 

t = "I love Paris!" # Global t
g ()
print(t)

def f ():
    city = "Hamburg"
    def g ():
        global city # Affects the global one only. Which gets defined on this line! Which is outside the function
        city = "Geneva"
    print ("Before calling g: " + city) # Hamburg. Local
    print ("Calling g now:")
    g ()
    print("After calling g: " + city) # Hamburg. Local
    
f ()
print ("Value of city in main: " + city) # Geneva. This is global city

def h ():
    city = "Munich" # This is nonlocal to g (). If not defined, it errors that non-local does not exist
    def g ():
        nonlocal city # Only inside nested function. Is not global! Enclosing function's local
        city = "Zurich"
    print ("Before calling g: " + city) # Munich. Local
    print ("Calling g now:")
    g ()
    print ("After calling g: " + city) # Zurich. Local. Modified by nested function via nonlocal operator
    
city = "Stuttgart"
h ()
print ("'City' in main: " + city) # Stuttgart. Global

# --------------------------------------------------------------------

gvar1 = 10 # By default it is global
gvar2 = 25

def somefunc (x):
    z = 4 # By default it is local
    print ("Id x: ", id (x), " value: ", x) # x is same as gvar1 (by id)
    x = 15 # Creates a new local variable
    print ("Id x: ", id (x), " value: ", x) # x has a different id now
    # gvar1 = 6 # Defines a local gvar1 but next line would fail as gvar1 can not be both local and global
    # global gvar1
    print ("Id gvar1: ", id (gvar1), " value: ", gvar1) # Global gvar1
    x = gvar1 # Restores x = gvar1
    print ("Id x: ", id (x), " value: ", x)
    # gvar1 = 1 # This would create a local gvar1 and the statements above would fail that reference this as above there it is not yet initialized!
    print ("Id gvar1: ", id (gvar1), " value: ", gvar1) # Still the global gvar1

print ("Id gvar1: ", id (gvar1), " value: ", gvar1)
somefunc (gvar1)
print ("Id gvar1: ", id (gvar1), " value: ", gvar1) # gvar1 stays the same thorugh all this
# nonlocalkeyword only used in nested functions to refer variables in the enclosing function

# --------------------------------------------------------------------

# It is passed by reference but if changed, it is passed by value as a new local variable is created
# Except for lists

def somefunc2 (xlist):
    print (xlist)
    xlist += [7,11] # Does not create new object. Modifies existing one
    print (xlist)

alist = [1,2,3,6,8]
somefunc2 (alist) # The original alist will be changed by the function
print (alist)

blist = [5,6,8,9,10]
somefunc2 (blist [:]) # Creates new object and copies values
print (blist)

# Good practice to create a seperate module for global variables and import them. That way global.var1 is the reference

# --------------------------------------------------------------------

os.system ("pause")
