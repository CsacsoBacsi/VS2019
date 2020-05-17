# --------------------------------------------------------------------

import os

# --------------------------------------------------------------------

# Multiple (variable length) function arguments
def test_var_args (f_arg, *args):
    print ("First, normal arg: " + f_arg)
    for arg in args: # *args is like an array of parameters
        print ("Another arg through *args: ", arg)

test_var_args ('Normal', 'Python', 'C++', 'Asm')

# --------------------------------------------------------------------

# Multiple (variable length) keyword/value function arguments
def test_kw_args (** kwargs):
    if kwargs is not None:
        for key, value in kwargs.items (): # Iterates over a dict's key-value pair. KeyWord arguments array
            print ("%s == %s" % (key, value))
 
test_kw_args (par1 = "param1", par2 = "param2", par3 = "param3")

# --------------------------------------------------------------------

os.system ("pause")

