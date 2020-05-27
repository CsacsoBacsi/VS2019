'''
self.cidpress = self.point.figure.canvas.mpl_connect('button_press_event', self.on_press)
The . is just accessing an attribute. The attribute could be a class, an instance, a method/function,
etc. When you see something like a.b.c, it is referring to the attribute c of attribute b of a, where a, b, and c 
could be any of the types mentioned above
'''

# --------------------------------------------------------------------

class Foo:
    def __init__(self):
        import os

        self.number = 1
        self.module = os
        self.class_ = Exception
        self.function = dir

f = Foo()

f.module.path.join ('foo', 'bar')
raise f.class_ ('foo')
f.function('.')

print (callable(f.module))
print (callable(f.function))

# --------------------------------------------------------------------

def f(x) -> int: # Function annotations. Return value type
    return int (x)
print (f.__annotations__['return'])

def f (x: float) -> int: # Parameter annotation in function. Does not have to be int!
    return int (x)
print (f.__annotations__['x'])

# --------------------------------------------------------------------
