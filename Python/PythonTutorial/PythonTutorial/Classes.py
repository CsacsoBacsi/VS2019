# --------------------------------------------------------------------

import os

# --------------------------------------------------------------------

class MyClass:
    """A simple example class"""
    i = 2 # Class variable, like static in C++

    @staticmethod
    def f1 (): # No self parameter
        return 'Hello world (static)'

    def f2 (self): # Otherwise errors saying f2 is defined with no parameter however self is still passed to it!
        return 'Hello world'

    def __init__ (self, p1, p2): # It is like a constructor. Initializes the local attributes
        self.num1 = p1
        self.num2 = p2
        #self.i = 3

    def f3 (self):
        print ((self.num1 + self.num2) * MyClass.i) # Without MyClass i is not found. Weird.

inst1 = MyClass (0, 0)
print (inst1.f1 ())
print (inst1.f2 ())

inst2 = MyClass (3, 5) # Calls the __init__ function
inst2.f3 () # 16 -> (3 + 5) * 2
print ((inst2.num1 + inst2.num2) * inst2.i) # 16. inst2.i is the class variable
inst2.i = 9 # Creates a new, local i
print (inst2.i) # 9
print (MyClass.i) # 2
inst2.k = 5 # Created k on the fly
print (inst2.k) # 5

# --------------------------------------------------------------------

# Inheritance
print ("")
class prntClass:
    prnt_st_var1 = 1
    prnt_st_var2 = 2

    def __init__ (self, p1, p2):
        self.prnt_num1 = p1
        self.prnt_num2 = p2

    def prnt_f1 (self): # When called from an instance, self is passed
        print ("Parent function f1")
    def prnt_fov (self):
        print ("Parent function fov")

class chldClass (prntClass):
    chld_st_var1 = 3
    chld_st_var2 = 4

    def __init__ (self, p1, p2):
        self.chld_num1 = p1
        self.chld_num2 = p2
        super().__init__(1, 2) # Initialize the parent class

    def chld_f1 (self):
        print ("Child function f1")

    def prnt_fov (self):
        print ("Child function fov")

c1 = chldClass (7, 8)
print (c1.chld_st_var1, c1.chld_num1)
print (c1.prnt_st_var1, c1.chld_st_var2) # No prnt_num1
c1.chld_f1 ()
c1.prnt_f1 ()
c1.prnt_fov () # Overrides the parent's
prntClass.prnt_fov (None) # As it is not called from an instance

# --------------------------------------------------------------------

class Robot (object): # The bare minimum class
    pass

    def __str__ (self):
        return "Bare minimum class"

    def __init__(self):
        self.__priv = "I am private" # Double underscore
        self._prot = "I am protected"
        self.pub = "I am public"

    def __del__(self): # Destructor if method del is called
        print ("Object deleted")

x = Robot ()
Robot.brand = "X1" # Creates a class variable
x.brand = "Y2"
print (Robot.brand) # Prints X1
y = Robot () # Another instance with no instance variable
print (y.brand) # Prints X1 - prints the class variable
Robot.brand = "X2"
print (y.brand) # Prints X2 as no local variables so prints the class variable
print (y.__dict__) # Prints an empty dictionary
print (Robot.__dict__)
print (str (y)) # Calls __str__
del x
del y

# --------------------------------------------------------------------

os.system ("pause")
