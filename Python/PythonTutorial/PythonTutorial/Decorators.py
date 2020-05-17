# --------------------------------------------------------------------

import os

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

# --------------------------------------------------------------------

# @classmethod decorator
# The method is called without an instance but it also creates one. You call the method that creates an instance object as well!
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
