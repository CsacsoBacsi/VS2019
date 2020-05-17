# --------------------------------------------------------------------

import os
import pickle
import shelve

# --------------------------------------------------------------------

with open ("input.txt", "r") as inp: # The with construct makes sure the file is closed automatically at the end of the with-block
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

# --------------------------------------------------------------------

poem = open ("input.txt").readlines() # Read all in one as a list
print (poem[2]) # To access the 3rd line

poem = open ("input.txt").read() # Read all in one as a string
print(poem[12:20]) # Access various chars in that string

# --------------------------------------------------------------------

cities = ["Paris", "Dijon", "Lyon", "Strasbourg"]
fh = open ("data.pkl", "bw")
pickle.dump (cities, fh) # Dumps an object into binary
fh.close ()

fh = open("data.pkl", "rb") # Read the dump file back
villes = pickle.load (fh)
print (villes)

s = shelve.open ("MyShelve") # Pickle reads everything back, but we only need certain bits
s["street"] = "Fleet Str"
s["city"] = "London"
s.close ()

s = shelve.open ("MyShelve") # This could be opened in another py script
print (s["street"])

# --------------------------------------------------------------------

os.system ("pause")
