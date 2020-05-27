# --------------------------------------------------------------------

import os

# -------------------------------------------------------------------

# Preqel
def succ (x):
    return x + 1
successor = succ # Function pointer pointing at the same code
successor(10)
succ(10)
del succ # Deletes a pointer not the function itself
successor(10) # Still exists

def f ():  
    def g (): # Function inside another
        print ("Hi, it's me 'g'")
    print ("This is the function 'f'")
    g ()
f ()

def g2 ():
    print ("Hi, it's me 'g2'")
    
def f2 (func): # Function pointer as parameter
    print ("Hi, it's me 'f'")
    func ()
f2 (g2)

def g3 ():
    print ("Hi, it's me 'g'")
    
def f3 (func):
    print("Hi, it's me 'f'")
    func ()
    print ("func's real name is " + func.__name__) # With proper function name
f3 (g3)

def f4 (x):
    def g4 (y):
        return y + x + 3 
    return g # Function returning function
nf1 = f4 (1)
nf2 = f4 (3)
print (nf1 (1))
print (nf2 (1))

# -------------------------------------------------------------------

def f_decorator (func): # Parameter is a function (to be decorated), return value is a function too which wraps the func parameter function
    def f_wrapper (p_param): # The number of parameters must match that of the params of the dunction to be decorated because basically the f_wrapper will be called
        print ("*** This is the decoration ***")
        p_param -= 1
        return func (p_param) # func does its job by default. The previous two lines are the decoration
    return f_wrapper # Returns the wrapper function

def func_to_be_decorated (p_param):
    p_param *= p_param
    return p_param

wrapper_func = f_decorator (func_to_be_decorated)
print (wrapper_func (6)) # Result must be 6 - 1 ** 2 = 25

# Instead of the f_decorator call, we can use the @ syntax
@f_decorator
def func_to_be_decorated2 (p_param):
    p_param *= p_param
    return p_param
print (func_to_be_decorated2 (5))

# func_to_be_decorated is given to the decorator which in turn returns the wrapper (which does the decoration). We then call that wrapper with a parameter
# which does something with that parameter before passes it to the function to be decorated.
# Use case: check the validity of that parameter
# Count function calls
def call_counter (func):
    def helper (x):
        helper.calls += 1 # Function is an object. Can have attributes
        return func (x)
    helper.calls = 0
    return helper

@call_counter # Creates the object
def succ (x):
    return x + 1

print (succ.calls)
for i in range (10):
    succ (i)
print (succ.calls)

# Decorator with parameters
def greeting (expr): # expr = decorator param
    def greeting_decorator (func):
        def function_wrapper (x):
            print (expr + ", " + func.__name__ + " returns:")
            func (x)
        return function_wrapper
    return greeting_decorator

@greeting ("Good morning!")
def foo (x):
    print (42)

foo ("Hi")

# --------------------------------------------------------------------

# @classmethod decorator
# The method is called without an instance but it also creates one. You call the method that creates an instance object as well!
# Static method knows nothing about the class and just deals with the parameters
# Class method works with the class since its parameter is always the class itself.
class Student (object):
    def __init__(self, first_name, last_name):
        self.first_name = first_name
        self.last_name = last_name

    @classmethod
    def from_string (cls, name_str):
        first_name, last_name = map (str, name_str.split (' '))
        student = cls (first_name, last_name) # Creates instance using cls, the class
        return student

scott = Student.from_string ('Scott Robinson') # The meth0od can be called from an uninstantiated class object. Creates an instance object
stud = Student ()
stud.from_string ('Scott Robinson') # Can also be called from instance
print (scott.first_name)

# @staticmethod Decorator
# You can call this static method without an instance object. No object is created, yet can be called
class Student (object):

    @staticmethod
    def is_full_name (name_str):
        names = name_str.split (' ')
        return len (names) > 1

print (Student.is_full_name ('Scott Robinson')) # No need for instance. True static method. Does not create instance object.

# --------------------------------------------------------------------

os.system ("pause")
