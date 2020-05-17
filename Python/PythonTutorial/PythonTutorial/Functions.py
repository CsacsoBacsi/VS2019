# --------------------------------------------------------------------

import os

# --------------------------------------------------------------------

def myfunc (arg1, *args, **keywords):
    print ("Arg1: ", arg1)

    print ("Formal params:") # Arbitrary argument list
    for arg in args: # Formal parameters
        print (arg)
        
    print ("Keyword arguments: ") # Beyond the formal params, it can only be keyword
    for kw in keywords:
        this_str = str (kw) + ": " + str (keywords[kw])
        print (this_str)

myfunc ("I am argument 1", "Formal arg 1", "Formal arg 2", "Formal arg 3", kw1="kw1", kw2="kw2", kw3="kw3")

# --------------------------------------------------------------------

def func_g ():
    print ("Hi, it's me 'g'")
    print ("Thanks for calling me")
    
def func_f (func): # Function as a parameter
    print ("Hi, it's me 'f'")
    print ("I will call 'func' now")
    func ()
    print ("func's real name is " + func.__name__) 
         
func_f (func_g)

# --------------------------------------------------------------------

def Hello (name="everybody"):
    """ Greets a person """
    print("Hello " + name + "!")

print ("The docstring of the function Hello: " + Hello.__doc__)
print (Hello ()) # Optional param

# --------------------------------------------------------------------

def ff (x = 0):
    return (x * 2, x / 2)
print (ff (10)[1]) # Returns second value

def arithmetic_mean (first, * values):
    return (first + sum (values)) / (1 + len (values))

print (arithmetic_mean (45, 32, 89, 78))

x = [3, 5, 9]
print (arithmetic_mean (*x)) # * unpacks the list into individual parameters

# --------------------------------------------------------------------

def fff (**kwargs):
    print (kwargs)
fff (de="German",en="English",fr="French")

def ref_demo (x):
    print ("x=",x," id=", id (x)) # Initially call by reference but 
    x = 42 # since it creates a new x variable, the global x stays untouched so copy by value
    print ("x=",x," id=",id (x))

def no_side_effects (cities):
    print (cities)
    cities = cities + ["Birmingham", "Bradford"] # Creates new local copy
    print (cities)

locations = ["London", "Leeds", "Glasgow", "Sheffield"]
no_side_effects (locations)
print (locations) # Locations have not changed. A new, function local city was created

def side_effects (cities):
    print (cities)
    cities += ["Birmingham", "Bradford"] # In-place operation. Changes the variable directly, without creating a local copy
    print (cities)
 
locations = ["London", "Leeds", "Glasgow", "Sheffield"]
side_effects (locations)
print (locations) # Locations have changed. No new, function local city was created.

def side_effects (cities):
    print (cities)
    cities += ["Paris", "Marseille"]
    print (cities)

locations = ["Lyon", "Toulouse", "Nice", "Nantes", "Strasbourg"]
side_effects (locations[:])
print (locations)

# --------------------------------------------------------------------

# There is no such thing as pass by reference. Objects only. So if you want to change soomething, put a list wrapper around it
def chg_int (inpint):
    newint = inpint[0] * 2 # Creates a new int
    print (newint)
    inpint [0] = newint # Reassigns value to position 0

chgint = 2
print (chgint)
wrapper = [chgint,] # Assigned to position 0 in the wrapper list
chg_int (wrapper)

print (chgint) # Has not changed
print (wrapper[0])

# --------------------------------------------------------------------

al = [1, 2, 3]
bl = al
bl.append (4)
bl = ['a', 'b']
print (al, bl) # prints 1,2,3,4 for a1

# --------------------------------------------------------------------

os.system ("pause")
