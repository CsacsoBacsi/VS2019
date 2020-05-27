# --------------------------------------------------------------------

import os

# --------------------------------------------------------------------

list_a = [1, 2, 3]
list_b = ['a', 'b', 'c', 'd', 'e']

zipped_list = list (zip (list_a, list_b)) # Iterates one by one and merges them
print (zipped_list)
zipped_list2 = list (zip (list_b, list_a))
print (zipped_list2)

zipper_list = [(1, 'a'), (2, 'b'), (3, 'c')]
list_a, list_b = zip (*zipper_list)
print (list_a)
print (list_b)

# --------------------------------------------------------------------

location = ["Helgoland", "Kiel", "Berlin-Tegel", "Konstanz", "Hohenpeißenberg"] # Multiple lists
air_pressure = [1021.2, 1019.9, 1023.7, 1023.1, 1027.7]
temperatures = [6.0, 4.3, 2.7, -1.4, -4.4]
altitude = [4, 27, 37, 443] # Loop stops at shortest list
                
for t in zip (location, air_pressure, temperatures, altitude):
    print (t)

for i in zip():
    print("This will not be printed")

s = "Python"
for t in zip (s):
    print (t) # Prints it char by char

# --------------------------------------------------------------------

cities_and_population = [("Zurich", 415367),
                         ("Geneva", 201818),
                         ("Basel", 177654),
                         ("Lausanne", 139111),
                         ("Bern", 133883),
                         ("Winterthur", 111851)]

cities, populations = list (zip (*cities_and_population)) # Splits the lists. * is needed!
print (cities)
print (populations)

abc = "abcdef"
morse_chars = [".-", "-...", "-.-.", "-..", ".", "..-."]
               
text2morse = dict (zip (abc, morse_chars)) # Creates a dict
print (text2morse)

# --------------------------------------------------------------------

os.system ("pause")
