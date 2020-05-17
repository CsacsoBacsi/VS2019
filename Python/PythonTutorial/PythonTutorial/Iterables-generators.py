# --------------------------------------------------------------------

import os

# --------------------------------------------------------------------

mylist = [1, 2, 3] # Lists are stored in memory
for i in mylist:
    print (i)

mylist = [x*x for x in range(3)]
for i in mylist: # Lists can be iterated as many times as you want
    print(i)

mygenerator = (x*x for x in range(3)) # They generate but do not store in memory. You can not for loop it again. See parenthesis instead of brackets
for i in mygenerator: # For loop iterates over it
    print (i)

def createGenerator ():
    for i in range (3):
        yield i * i

for i in createGenerator ():
    print (i)

# --------------------------------------------------------------------

for city in ["Berlin", "Vienna", "Zurich"]:
    print (city)
for city in ("Python", "Perl", "Ruby"):
    print (city)
for char in "Iteration is easy":
    print (char)

cities = ["Berlin", "Vienna", "Zurich"] # Iterable
single = 5
iterator_obj = iter (cities) # Iterator obj
print (iterator_obj)
#iterator_obj = iter (single) # Type error. Not iterable
#print (iterator_obj)

print (next (iterator_obj))
print (next (iterator_obj))
print (next (iterator_obj))

# --------------------------------------------------------------------

a = iter (range (5))
for i in a: # For itself advances the iterator
    print (i)
    #next (a) # Next advances it too

class myiter: # Add iterator to your custom class
    
    def __init__(self, data):
        self.data = data
        self.index = -1

    def __iter__ (self):
        return self

    def __next__ (self):
        if self.index == len (self.data) -1:
            raise StopIteration
        self.index = self.index + 1
        return self.data [self.index]

lst = [5, 8, 15, 9]
mylst = myiter (lst)
for e in mylst:
    print (e)

# --------------------------------------------------------------------

# *** Generators ***
mysum = sum (i * i for i in range (100000)) # Not using []. Not a stored list! Generator instead
mysum = sum (map (lambda i: i*i, range (1000000))) # Similarly

def my_gen():
    n = 1
    print('This is printed first')
    yield n

    n += 1
    print('This is printed second')
    yield n

    n += 1
    print('This is printed at last')
    yield n

a = my_gen ()
next (a) # n = 2. Local vars keep their values
next (a)

for item in my_gen (): # New generator!
    print (item)

# --------------------------------------------------------------------

my_list = [1, 3, 6, 10]
list_ = [x**2 for x in my_list] # List comprehension

generator = (x**2 for x in my_list) # Generator. Normal brackets
print (list_)
print (generator)

# --------------------------------------------------------------------

def powgen (max = 0):
    n = 0
    while n < max:
        yield 2 ** n
        n += 1

a = powgen (5)
print (next (a))
print (next (a))
print (next (a))

# --------------------------------------------------------------------

os.system ("pause")
