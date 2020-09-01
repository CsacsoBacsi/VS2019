# --------------------------------------------------------------------

import os

# --------------------------------------------------------------------

# We can define a class A with type (classname, superclasses, attributedict)
# "classname" is a string defining the class name and becomes the name attribute; 
# "superclasses" is a list or tuple with the superclasses of our class. This list or tuple will become the bases attribute; 
# the attributes_dict is a dictionary, functioning as the namespace of our class. It contains the definitions for the 
# class body and it becomes the dict attribute.

class Robot:

    counter = 0

    def __init__ (self, name):
        self.name = name

    def sayHello (self):
        return "Hi, I am " + self.name


def Rob_init (self, name):
    self.name = name

Robot2 = type ("Robot2", 
              (), 
              {"counter":0, 
               "__init__": Rob_init,
               "sayHello": lambda self: "Hi, I am " + self.name})

x = Robot2 ("Marvin")
print (x.name)
print (x.sayHello ())

y = Robot ("Marvin")
print (y.name)
print (y.sayHello ())

print (x.__dict__)
print (y.__dict__)

# --------------------------------------------------------------------

os.system ("pause")

