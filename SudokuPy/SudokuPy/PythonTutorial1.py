import cx_Oracle
import time
import sys
from datetime import timedelta, datetime
import json
import threading
import queue
from xml.dom.minidom import parse
import xml.dom.minidom

# Modules
import Mymath # Mymath is a py file containing functions

print (Mymath.add_them (5, 6)) # Reference imported function add_them. # Import does not place the function names into the current symbol table. It has to be referenced
ad = Mymath.add_them # Give it another name if used frequently
print (ad (3, 2))

from Mymath import mul_them as mu # Places mu_them in the current symbol table. No need to reference
print (mu (6, 6))

print (__name__) # __name__ holds the current module name. Or __main__ if invoked as script
print (sys.path)

print (dir (Mymath)) # Names the module defined
import importlib
importlib.reload (Mymath) # Needed, if working within the interpreter and the module changes
# Upon load of a module, __init__.py can initialize it. Also denotes the dir as a package dir

# Helper functions
def printf (format, *args):
  sys.stdout.write (format % args) # Like printf. The arguments after % formatted according to format

def printException (exception):
  error, = exception.args # Comma is needed when there is just 1 value
  printf ("Error code = %s\n", error.code)
  printf ("Error message = %s\n", error.message)

# Tutorial START
print("Hello, World!") # First ever Python program/command
print (sys.argv[0], len(sys.argv)) # Length of argv as it is a list

if 5 > 2:
    print ("Five is greater than two!") # Requires indentation instead of e.g. curly brackets

# This is a comment by the way
"""This is a
multiline docstring."""

x = 4 # x is of type int # Type is defined at assignment
x = "Sally" # x is now of type str # Weekly typed language
print (x)

x = "awesome"
print ("Python is " + x) # Concatenation
print (type(x)) # Check type

x = int(1)   # x will be 1 - Casting with a constructor
y = int(2.8) # y will be 2
z = int("3") # z will be 3
w = float("4.2") # w will be 4.2

a = "hello"
print(a[1]) # Use [] notation to access each char

b = "world"
print(b[2:5]) # Substring from 2 to 5 inclusive. Starts at 0

a = " Hello, World! "
print(a.strip()) # Strips whitespace
print(len(a)) # Length of a
print(a.upper()) # Uppercase / lowercase
print(a.replace("H", "J")) # Replace
print(a.split(",")) # Splits string if it finds the separator

#print("Enter your name:")
#x = input() # User input
#print("Hello, " + x)

x = 5
x <<= 3 # Shift left 3 times (multiply by 8)
x &= 3 # Bit AND
x |= 3 # Bit OR

x = ["apple", "banana"]
y = ["apple", "banana"]
z = x

print(x is z) # returns True because z is the same object as x
print(x is y) # returns False because x is not the same object as y, even if they have the same content
print(x == y) # to demonstrate the difference betweeen "is" and "==": this comparison returns True because x is equal to y

print("banana" in x) # returns True because a sequence with the value "banana" is in the list

''' List is a collection which is ordered and changeable. Allows duplicate members
    Tuple is a collection which is ordered and unchangeable. Allows duplicate members
    Set is a collection which is unordered and unindexed. No duplicate members
    Dictionary is a collection which is unordered, changeable and indexed. No duplicate members'''

# List
thislist = ["apple", "banana", "cherry"] # Angle brackets []
thislist[1] = "blackcurrant"
print(thislist) # Change the second item on the list

thislist = list(("apple", "banana", "cherry")) # Use the List constructor (note the double brackets)
thislist.append("orange")
thislist.remove("banana")
print(thislist)
print(len(thislist)) # Length of elements in the array

thislist += ["pineapple", "coconut"] # Concatenation
thispartlist = thislist [2:3] # From and including position 2 to 3 excluding. Slice notation
print(thislist)
print(len(thislist))
print(thispartlist)
print(len(thispartlist))

it = iter (thislist) # Get the iterator
print (next (it)) # Call the iterator's next () method to advance it (FOR loops do it)
print (next (it))
print (next (it))

# Tuple
thistuple = ("apple", "banana", "cherry") # Brackets ()
print(thistuple[1])
#thistuple[1] = "blackcurrant" # Can not be changed, throws an error
thistuple = tuple(("apple", "banana", "cherry")) # Use Tuple constructor (note the double round-brackets)
print(thistuple)
print(len(thistuple))

# Set
thisset = {"apple", "banana"} # Curly brackets
print(thisset)
thisset = set(("apple", "banana", "cherry")) # Use Set constructor (note the double round-brackets)
print(thisset) 
thisset.add("orange")
thisset.remove("banana")
print(len(thisset))

seta = {1,2,3,4,5,6,9}
setb = {1,2,7,8}
print (seta - setb)
print (seta | setb)
print (seta & setb)

# Dictionary
thisdict = {"apple": "green", "banana": "yellow", "cherry": "red"} # Key-value pairs
print(thisdict)
thisdict["apple"] = "red"
print(thisdict)
thisdict = dict(apple="green", banana="yellow", cherry="red") # note that keywords are not string literals and the use of equals rather than colon for the assignment
print(thisdict)
thisdict["orange"] = "purple"
print(thisdict)
del(thisdict["banana"])
print(thisdict)
print(len(thisdict))

# Conditional
a = 200
b = 33
if b > a:
    print("b is greater than a")
elif a == b:
    print("a and b are equal")
else:
    print("a is greater than b")

# While loop
i2 = 0
while i2 < 8:
    i2 += 1
    if i2 == 6:
        break
    if i2 == 3:
        continue
    print(i2)

# For loop
for x in thislist:
    print(x)
    # Break and Continue is the same as for the While-loop

for x in range(2, 10, 2): # In the range of 2 to 9 with 2 as increment
    print(x)

for i in range (len (thislist)): # Combine range with the length of the list
    print (thislist [i])

# Functions - recursion
def tri_recursion (k): # tri_recursion (def_param = 10) -> Sets the default parameter if none given
    if k > 0:
        result = k + tri_recursion (k - 1) # (1 + 0) + (2 + 1) + (3 + 3) + (4 + 6) + (5 + 10) + (6 + 15)
        print (result)
    else:
        result = 0
    return result

print ("\n\nRecursion Example Results")
tri_recursion (6)

# Lambda functions
def myfunc (n):
  return lambda i: i * n # i is the parameter

doubler = myfunc (2) # Creates 2 functions (basically function pointers)
tripler = myfunc (3)
val = 11
print ("Doubled: " + str (doubler (val)) + ". Tripled: " + str (tripler (val))) # Call the function via the func pointer

# Functions
def myfunc (arg1, *args, **keywords):
    print("Arg1: ", arg1)

    print ("Formal params:") # Arbitrary argument list
    for arg in args: # Formal parameters
        print (arg)
        
    print ("Keyword arguments: ") # Beyond the formal params, it can only be keyword
    for kw in keywords:
        print(kw, ":", keywords[kw])

myfunc ("I am argument 1", "Formal arg 1", "Formal arg 2", "Formal arg 3", kw1="kw1", kw2="kw2", kw3="kw3")

# Classes
class MyClass:
    """A simple example class"""
    i = 2 # Class variable, like static in C++

    @staticmethod
    def f1 ():
        return 'Hello world (static)'
    def f2 (self): # Otherwise errors saying f2 is defined with no parameter however self is still passed to it!
        return 'Hello world'

    def __init__(self, p1, p2): # It is like a constructor. Initializes the local attributes
        self.num1 = p1
        self.num2 = p2
        #self.i = 3

    def f3 (self):
        print ((self.num1 + self.num2) * MyClass.i) # Without MyClass i is not found. Weird.

inst1 = MyClass (0, 0)
print (inst1.f1())
print (inst1.f2())

inst2 = MyClass (3, 5) # Calls the __init__ function
inst2.f3 () # 16 -> (3 + 5) * 2
print ((inst2.num1 + inst2.num2) * inst2.i) # 16. inst2.i is the class variable
inst2.i = 9
print (inst2.i) # 9
print (MyClass.i) # 2
inst2.k = 5 # Created k on the fly
print (inst2.k) # 5

# Inheritance
print ("")
class prntClass:
    prnt_st_var1 = 1
    prnt_st_var2 = 2

    def __init (self, p1, p2):
        self.prnt_num1 = p1
        self.prnt_num2 = p2

    def prnt_f1 (self): # When called from an instance, self is passed
        print ("Parent function f1")
    def prnt_fov (self):
        print ("Parent function ov")

class chldClass (prntClass):
    chld_st_var1 = 3
    chld_st_var2 = 4

    def __init__ (self, p1, p2):
        self.chld_num1 = p1
        self.chld_num2 = p2

    def chld_f1 (self):
        print ("Child function f1")

    def prnt_fov (self):
        print ("Child function ov")

c1 = chldClass (7,8)
print (c1.chld_st_var1, c1.chld_num1)
print (c1.prnt_st_var1, c1.chld_st_var2) # No prnt_num1
c1.chld_f1 ()
c1.prnt_f1 ()
c1.prnt_fov () # Overrides the parent's
prntClass.prnt_fov (None) # As it is not called from an instance

# Files
with open ("input.txt", "r") as inp:
    for line in inp:
        print (line, end='')

print ()

with open ("input.txt", "r") as inp:
    i = 0
    line = inp.readline ()
    while line != '':
        i = i + 1
        print (line.rstrip ('\n'), "", i)
        line = inp.readline ()

print ("One", "Two", "Three", i) # Leaves a space in between

f = open ('binfile.bin', 'wb') # Read-write binary
written = f.write (b'0123456789abcdef')
f.close () # Could be left open...

f = open ('binfile.bin', 'rb') # Read
f.seek (5) # Go to the 6th byte in the file
onebyte = f.read (1) # Read 1 byte
f.seek (-3, 2)  # Go to the 3rd byte before the end
print (f.tell ()) # Get current seek position
twobytes = f.read (2)
print (f.tell ()) # Position moves by two bytes (as expected)

f.close () # Needs closing as not in a with construct

# JSON
blackjack_hand = (8, "Q") # Tuple
encoded_hand = json.dumps(blackjack_hand) # Becomes a list
decoded_hand = json.loads(encoded_hand) # Tuple again

print (blackjack_hand == decoded_hand)
print (type (blackjack_hand))
print (type (decoded_hand))
print (blackjack_hand == tuple (decoded_hand))
print (decoded_hand)
print (encoded_hand)

json_data1 = {
    "president": {
        "name": "George Bush",
        "species": "Human"
    }
}

with open ("president.json", "w") as write_file: # with means that the unmanaged resource gets closed, garbage collected
    json.dump (json_data1, write_file, indent = 4, separators = (',', ': '))

with open ("president.json", "r") as read_file:
    data = json.load (read_file)
print (data.items ())
print (data)

print (data['president']['name']) # Dict. Key=president

json_data2 = {
    "cars": {
        1: {
            "type": "Honda",
            "colour": "Green"},
        2: {
            "type": "Opel",
            "colour": "Red"}
    }
}
car_list = json.dumps (json_data2)
cars = json.loads (car_list)
# cars2 = json.loads (data3) # Can not use a dict here

print (cars['cars']['1']['colour']) # Must use string keys

with open ("cars.json", "r") as read_file:
    data = json.load (read_file)
print (data.items ())
print (data)

with open ("lotto.json", "r") as read_file:
    data = json.load (read_file)
print (data.items ())
print (data)
print (data['lotto']['2'][3]) # 4th lotto number on 2nd week

# More on JSON (Sudoku)
data = {}  
data['people'] = [] # Array follows
data['people'].append({ # Array of dictionary objects
    'name': 'Scott',
    'website': 'stackabuse.com',
    'from': 'Nebraska'
})
data['people'].append({  
    'name': 'Larry',
    'website': 'google.com',
    'from': 'Michigan'
})
data['people'].append({  
    'name': 'Tim',
    'website': 'apple.com',
    'from': 'Alabama'
})

with open('data.txt', 'w') as outfile:  
    json.dump(data, outfile, indent = 4, separators = (',', ': '))

gridArea = []
for i in range (0, 82, 1): # Initialize arrays
    gridArea.append (0)

gridArea[1] = 1
gridArea[9] = 5
gridArea[12] = 3
gridArea[34] = 2
gridArea[56] = 8

grid = {}
grid ['Sudoku Grid'] = []

for i in range (1, 82, 1):
    if gridArea [i] != 0:
        grid ['Sudoku Grid'].append ({
              'cell number': i,
              'cell value': gridArea[i]})

with open ('sudoku.json', 'w') as outfile:  
    json.dump (grid, outfile, indent = 4, separators = (',', ': '))

grid = []
for i in range (1, 83, 1):
    gridArea [i] = 0

with open('sudoku.json') as json_file:  
    grid = json.load (json_file)
    for p in grid ['Sudoku Grid']:
        gridArea [p ['cell number']] = p ['cell value']

for i in range (1, 83, 1):
    if gridArea [i] != 0:
        print ("Cell: ", str (i), "Value: ", str (gridArea [i]))

# Datetime
start_date = datetime.strptime('2018-01-01', '%Y-%m-%d')
end_date = datetime.strptime('2018-01-31', '%Y-%m-%d')
print ("From " + str (start_date) + " to: " + str (end_date))

def daterange (start_date, end_date):
    for n in range (int ((end_date - start_date).days)):
        yield start_date + timedelta(n)

for single_date in daterange(start_date, end_date):
    print (single_date.strftime("%Y-%m-%d"))

# Iterables, generators, yield
mylist = [1, 2, 3] # Lists are stored in memory
for i in mylist:
    print (i)

mylist = [x*x for x in range(3)]
for i in mylist: # Lists can be iterated as many times as you want
    print(i)

mygenerator = (x*x for x in range(3)) # They generate but do not store in memory. You can not for loop it again
for i in mygenerator:
    print(i)

def createGenerator ():
    for i in range(3):
        yield i*i

for i in createGenerator():
    print(i)

# List comprehension
# Boils down to *result* = [*transform* *iteration* *filter*]
mystring = "Hello 12345 World"
numbers = [(int (x)) *2 for x in mystring if x.isdigit()]
print (numbers)

# Threading
exitFlag = 0
class myThread (threading.Thread):
    shared_resource = 0
    def __init__(self, threadID, name, counter, delay, e):
        threading.Thread.__init__(self) # Init the super class
        self.threadID = threadID
        self.name = name
        self.counter = counter
        self.delay = delay
        self.e = e
      
    def run (self):
        print ("Starting " + self.name)
        print_thread_time (self.name, self.counter, self.delay)
        print ("Exiting " + self.name)
        self.e.wait () # Wait until the event is signalled
        print ("Woke up from event")
        self.e.clear ()

def print_thread_time (threadName, counter, delay):
    while counter:
        if exitFlag:
            threadName.exit()
        time.sleep (delay) # In seconds
        # Get lock to synchronize threads
        threadLock.acquire () # Otherwise print lines could get intermingled
        print ("%s: %s" % (threadName, time.ctime (time.time ())))
        myThread.shared_resource += 1
        threadLock.release ()
        counter -= 1


# Create new threads
e = threading.Event ()
thread1 = myThread (1, "Thread-1", 7, 1, e)
thread2 = myThread (2, "Thread-2", 5, 2, e) # Every two seconds

# Create lock
threadLock = threading.Lock()
threads = []
threads.append(thread1)
threads.append(thread2)

# Start new Threads
thread1.start()
time.sleep (0.0001) # Otherwise starting thread messages get intermingled
thread2.start()

print ("Main thread sleeps for 12 secs...")
time.sleep (12)
e.set () # Fires to the event moving the threads out of waiting
print ("Event set")

for t in threads: # Wait for threads before main exit
    t.join ()
print (myThread.shared_resource)
print ("Exiting Main Thread")

# Queues - Producer - Consumer
class myThreadQ (threading.Thread):
    shared_resource = 0
    def __init__(self, threadID, name, queue):
        threading.Thread.__init__(self)
        self.threadID = threadID
        self.name = name
        self.queue = queue
      
    def run (self):
        print ("Starting " + self.name)
        process_data (self.name, self.queue)
        print ("Exiting " + self.name)

def process_data (threadName, queue):
    while not exitFlag:
        queueLock.acquire () # Lock the queue
        if not workQueue.empty ():
            data = queue.get() # Fetch an item from the queue
            print ("%s processing %s" % (threadName, data))
        queueLock.release () # Release queue lock 
    time.sleep (1)

threadList = ["Thread-1", "Thread-2", "Thread-3"]
itemList = ["One", "Two", "Three", "Four", "Five"] # Queue items
queueLock = threading.Lock ()
workQueue = queue.Queue (10) # 10 is max size
threads = []
threadID = 1

for tName in threadList:
   thread = myThreadQ (threadID, tName, workQueue)
   thread.start()
   threads.append(thread)
   threadID += 1

# Fill the queue
queueLock.acquire ()
for word in itemList:
   workQueue.put(word)
queueLock.release ()

# Wait for queue to empty
while not workQueue.empty ():
   pass

# Notify threads it's time to exit
exitFlag = 1 # Otherwise threads stay in an everlasting loop

# Wait for all threads to complete
for t in threads:
   t.join ()
print ("Exiting Main Thread")

# Local vs global
gvar1 = 10 # By default it is global
gvar2 = 25

def somefunc (x):
    z = 4 # By default it is local
    print ("Id x: ", id (x), " value: ", x) # x is same as gvar1 (by id)
    x = 15 # Creates a new local variable
    print ("Id x: ", id (x), " value: ", x) # x has a different id now
    global gvar1
    x = gvar1 # Restores x = gvar1
    print ("Id x: ", id (x), " value: ", x)
    # gvar1 = 2 * x # Errors because it becomes a local gvar1 which is not initialized but assigned to x
    # global gvar1 # However, declared as global, we can now access it
    gvar1 = 3
    print ("Id gvar1: ", id (gvar1), " value: ", gvar1) # Still the global gvar1

print ("Id gvar1: ", id (gvar1), " value: ", gvar1)
somefunc (gvar1)
print ("Id gvar1: ", id (gvar1), " value: ", gvar1) # gvar1 stays the same thorugh all this

# It is passed by reference but if changed, it is passed by value as a new local variable is created
# Except for lists

def somefunc2 (xlist):
    print (xlist)
    xlist += [7,11]
    print (xlist)

alist = [1,2,3,6,8]
somefunc2 (alist) # The original alist will be changed by the function
print (alist)
blist = [5,6,8,9,10]
somefunc2 (blist [:])
print (blist)

# Good practice to create a seperate modul for global variables and import them. That way global.var1 is the reference

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

al = [1, 2, 3]
bl = al
bl.append (4)
bl = ['a', 'b']
print (al, bl) # prints 1,2,3,4 for a1

# XML
# Open XML document using minidom parser
DOMTree = xml.dom.minidom.parse ("movies.xml")
collection = DOMTree.documentElement
if collection.hasAttribute ("shelf"):
    print ("Root element : %s" % collection.getAttribute ("shelf"))

# Get all the movies in the collection
movies = collection.getElementsByTagName ("movie")

# Print detail of each movie.
for movie in movies:
    print ("*****Movie*****")
    if movie.hasAttribute ("title"):
        print ("Title: %s" % (movie.getAttribute ("title")))

    type = movie.getElementsByTagName('type')[0]
    print ("Type: %s" % (type.childNodes[0].data))
    format = movie.getElementsByTagName('format')[0]
    print ("Format: %s" % (format.childNodes[0].data))
    rating = movie.getElementsByTagName('rating')[0]
    print ("Rating: %s" % (rating.childNodes[0].data))
    description = movie.getElementsByTagName('description')[0]
    print ("Description: %s" % (description.childNodes[0].data))

print ("")
print (collection.attributes.keys, collection.attributes.values)
print (len (collection.attributes))
for attr in collection.attributes.items ():
    print (attr)

# Recursive parsing
print ("Complete parsing of the XML")

unique_id = 0
order_id = 1
parent_id = 0

# Top level node
doc = xml.dom.minidom.parse ("movies.xml")
def remove_blanks (node):
    _childNodes = node.childNodes[:] # Copy the list, not just its reference
    for x in _childNodes: # The original list of childNodes is changing during the for loop, hence the shallow copy
        if x.nodeType == xml.dom.minidom.Node.TEXT_NODE:
            if x.nodeValue[0] == '\n':
                node.removeChild (x) # Get rid of the CR-LF node
        elif x.nodeType == xml.dom.minidom.Node.ELEMENT_NODE:
            remove_blanks (x) # Call recursively

#doc = DOMTree.documentElement

remove_blanks (doc) # Get rid of CR-LF nodes as they count as a child
nodeType = doc.nodeType
nodeValue = doc.nodeValue
nodeName = doc.nodeName
noChildren = len (doc.childNodes)

def getNodeTypeText (nodeType):
    if nodeType ==  xml.dom.minidom.Node.ELEMENT_NODE:
        nodeTypeText = 'Element'
    elif nodeType == xml.dom.minidom.Node.ATTRIBUTE_NODE:
        nodeTypeText = 'Attribute'
    elif nodeType == xml.dom.minidom.Node.TEXT_NODE:
        nodeTypeText = 'Text'
    elif nodeType == xml.dom.minidom.Node.CDATA_SECTION_NODE:
        nodeTypeText = 'CData'
    elif nodeType == xml.dom.minidom.Node.ENTITY_REFERENCE_NODE:
        nodeTypeText = 'Entity reference'
    elif nodeType == xml.dom.minidom.Node.ENTITY_NODE:
        nodeTypeText = 'Entity'
    elif nodeType == xml.dom.minidom.Node.PROCESSING_INSTRUCTION_NODE:
        nodeTypeText = 'Processing instruction'
    elif nodeType == xml.dom.minidom.Node.COMMENT_NODE:
        nodeTypeText = 'Comment'
    elif nodeType == xml.dom.minidom.Node.DOCUMENT_NODE:
        nodeTypeText = 'Document'
    elif nodeType == xml.dom.minidom.Node.DOCUMENT_TYPE_NODE:
        nodeTypeText = 'Document type'
    elif nodeType == xml.dom.minidom.Node.DOCUMENT_FRAGMENT_NODE:
        nodeTypeText = 'Document fragment'
    elif nodeType == xml.dom.minidom.Node.NOTATION_NODE:
        nodeTypeText = 'Notation'
    else:
        nodeTypeText = ""
    return nodeTypeText

nodeTypeText = getNodeTypeText (nodeType)

print ('Id: ', unique_id, ' Nodename: ', nodeName, ' Parent id: ', "-", ' Parent nodename: ', '-', ' Order: ', order_id, ' Nodetype: ', nodeTypeText, ' Node value: ', nodeValue, ' Number of children: ', noChildren)

# Root node
unique_id += 1
rootNode = doc.firstChild
nodeType = rootNode.nodeType
nodeValue = rootNode.nodeValue
nodeName = rootNode.nodeName
parentNode = rootNode.parentNode
parent_nodeName = parentNode.nodeName
noChildren = len (rootNode.childNodes)

nodeTypeText = getNodeTypeText (nodeType)

print ('Id: ', unique_id, ' Nodename: ', nodeName, ' Parent id: ', parent_id, ' Parent nodename: ', parent_nodeName, ' Order: ', order_id, ' Nodetype: ', nodeTypeText, ' Node value: ', nodeValue, ' Number of children: ', noChildren)

# Process attributes if any
attr_order_id = 1
parent_id = unique_id
attrs = rootNode.attributes # Returuns a NamedNodeMap
parent_nodeName = nodeName

if attrs == None:
    range_end = 0
else:
    range_end = len (attrs)

for i in range (0, range_end):
    thisAttr = attrs.item(i)
    nodeName = thisAttr.nodeName
    nodeValue = thisAttr.nodeValue
    nodeType = thisAttr.nodeType

    unique_id += 1

    nodeTypeText = getNodeTypeText (nodeType)

    print ('Id: ', unique_id, ' Nodename: ', nodeName, ' Parent id: ', parent_id, ' Parent nodename: ', parent_nodeName, ' Order: ', attr_order_id, ' Nodetype: ', nodeTypeText, ' Node value: ', nodeValue, ' Number of children: ', '0')
    attr_order_id += 1
 
# Call recursive function to traverse the XML tree
def sp_parse_xml_recursive (parentNode, parent_id):
    order_id = 1 ;

    if len (parentNode.childNodes) > 0:
        allChildren = parentNode.childNodes
    else:
        return
    # Process all children
    for i in range (0, len (allChildren)):

        global unique_id
        unique_id += 1
        attr_parent_id = unique_id # This element is the parent of its attributes

        thisNode = allChildren[i]
        nodeName = thisNode.nodeName
        nodeValue = thisNode.nodeValue
        noChildren = len (thisNode.childNodes)
        parent_nodeName = thisNode.parentNode.nodeName
        nodeType = thisNode.nodeType
        nodeTypeText = getNodeTypeText (nodeType)

        print ('Id: ', unique_id, ' Nodename: ', nodeName, ' Parent id: ', parent_id, ' Parent nodename: ', parent_nodeName, ' Order: ', order_id, ' Nodetype: ', nodeTypeText, ' Node value: ', nodeValue, ' Number of children: ', noChildren)

        order_id = order_id + 1
        attr_order_id = 1
        attrs = thisNode.attributes
        parent_nodeName = nodeName

        if attrs == None:
            range_end = 0
        else:
            range_end = len (attrs)

        for i in range (0, range_end):

            thisAttr = attrs.item (i)
            nodeName = thisAttr.nodeName
            nodeValue = thisAttr.nodeValue
            nodeType = thisAttr.nodeType
            nodeTypeText = getNodeTypeText (nodeType)

            unique_id += 1

            print ('Id: ', unique_id, ' Nodename: ', nodeName, ' Parent id: ', attr_parent_id, ' Parent nodename: ', parent_nodeName, ' Order: ', attr_order_id, ' Nodetype: ', nodeTypeText, ' Node value: ', nodeValue, ' Number of children: ', '0')
            attr_order_id += 1

        # Call recursive function (itself) to process the next level (children of this node) of the XML hierarchy
        sp_parse_xml_recursive (thisNode, attr_parent_id)

    return

if noChildren > 0:
    sp_parse_xml_recursive (rootNode, parent_id)


exit (0)

# *******************************************************************************************
# Oracle db
dsn_tns = """(DESCRIPTION = 
     (ADDRESS_LIST =
      (ADDRESS = (COMMUNITY = tcp.world) (PROTOCOL = TCP) (HOST = aepw04-bulwscan.e-ssi.net)(PORT = 1521))
      (ADDRESS = (COMMUNITY = tcp.world) (PROTOCOL = TCP) (HOST = aepw04-shwdscan.e-ssi.net)(PORT = 1521))
     )
      (CONNECT_DATA =
         (SERVICE_NAME = aepw04_clt.world)
         (FAILOVER_MODE =
           (TYPE = SELECT)
           (RETRIES = 1000)
           (DELAY = 5)
           (METHOD = BASIC)
         )
      )
   )""" # Triple " allows multine line string here. Also, nothing needs to be escaped within them

#db = cx_Oracle.connect ('C23833', 'V1lacsek123!', 'aepw04-shwdscan.e-ssi.net:1521/aepw04_clt.world') # Connect method 1
db = cx_Oracle.connect ('C23833', 'V1lacsek123!', dsn_tns) # Connect method 2

csr = db.cursor ()
csr.execute ('SELECT * FROM CSABA_SRC')
for row in csr:
  print (row) # Comes back as a list
  print (row[0]) # First column

csr.close ()
db.close ()

start = time.time ()
db2 = cx_Oracle.connect ('C23833', 'V1lacsek123!', dsn_tns) # Connect method 2
csr2 = db2.cursor ()
tbl_name_len = 10
csr2.arraysize = 10 # Allocate memory for 10 rows fetched at a time. Batches of 10 rows will be returned
csr2.prepare ("select * from all_tables where owner = 'C23833' and length (table_name) > :len")
csr2.execute (None, {'len': tbl_name_len}) # Bind variable. must be a dictionary object

res = csr2.fetchall()
for row in res:
  print (row[1])

csr2.close ()
db2.close ()

elapsed = (time.time() - start)
print ("Elapsed:", elapsed, "seconds")

exit (0) # Terminate program
