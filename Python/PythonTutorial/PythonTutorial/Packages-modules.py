# --------------------------------------------------------------------

import sys
import os

# --------------------------------------------------------------------

import Mypack # Does nothing just calls __init__.py. This file means it is a package
# Either each __init__.py imports the modules or
# __all__ defines the modules to be imported upon import *
from Mypack import * ; # __init__.py executes. Modules a and b are not yet accessible!
                       # Not enough! * = __all__ list which needs defining!
#from Mypack import a, b # Or use __init__.py to import them
from Mypack.sub1 import * ; # The __all__ list must be defined in the __init__.py
Mypack ;

# __init__.py required to import module a and b and sub1.a and sub1.b
# Needs module a and __init__.py
Mypack.a.bar () ;
# Or alternatively from Mypack import sub1.a, sub1.b
Mypack.sub1.a.bar2 () ;

Mypack.sub1.b.foo2 () ;
print (dir ()) ;

# --------------------------------------------------------------------

import Mymath # Mymath is a py file containing functions

print (Mymath.add_them (5, 6)) # Reference imported function add_them. # Import does not place the function names into the current symbol table. It has to be referenced
ad = Mymath.add_them # Give it another name if used frequently
print (ad (3, 2))

from Mymath import mul_them as mu # Places mul_them in the current symbol table. No need to reference
print (mu (6, 6))

print (__name__) # __name__ holds the current module name. Or __main__ if invoked as script
print (sys.path) # All Python paths

print (dir (Mymath)) # Names (objects) the module defined
import importlib
importlib.reload (Mymath) # Needed, if working within the interpreter and the module changes

# --------------------------------------------------------------------

os.system ("pause")
