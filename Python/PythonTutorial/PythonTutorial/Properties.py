# --------------------------------------------------------------------

import os

# --------------------------------------------------------------------

class MyClass:

    def __init__ (self, a):
        self.MyAtt = a # Public property


x = MyClass (10) # New instance. Sets MyAtt to 10 by the __init__ method
print (x.MyAtt) 

class MyClassP:

    def __init__(self, a):
        self.MyAtt = a # Private proprty. Accessible via getter and setter method

    @property
    def MyAtt (self): # Getter
        return self.__MyAtt

    @MyAtt.setter
    def MyAtt(self, val): # Setter
        if val < 0:
            self.__MyAtt = 0
        elif val > 1000:
            self.__MyAtt = 1000
        else:
            self.__MyAtt = val


x = MyClassP (15)
print (x.MyAtt)
x = MyClassP (1001)
print (x.MyAtt)
x = MyClassP (-5)
print (x.MyAtt)

# --------------------------------------------------------------------

os.system ("pause")
