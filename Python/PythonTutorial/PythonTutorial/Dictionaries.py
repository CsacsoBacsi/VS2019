# --------------------------------------------------------------------

import os

# --------------------------------------------------------------------

thisdict = {"apple": "green", "banana": "yellow", "cherry": "red"} # Key-value pairs
print (thisdict)
thisdict["apple"] = "red" # Changes the value under an existing key
print (thisdict)
thisdict = dict (apple="green", banana="yellow", cherry="red") # Note that keywords are not string literals and the use of equals rather than colon for the assignment
print (thisdict)
thisdict["orange"] = "purple" # Adds new item
print (thisdict)
del (thisdict["banana"]) # Delete item
print (thisdict)
print (len (thisdict))
thisdict.update (kiwi="green", melon="red", banana="brown") # Adds multiple values at once

if 'cherry' in thisdict: # Test existence of a key
    print ("Cherry exists")
thisdict2 = thisdict.copy () # Deep copy like sets
thisdict["cherry"] = "reddish"
print (thisdict2)
print (thisdict)
for key in thisdict2.keys():
    print (key)
for val in thisdict2.values ():
    print (val)
thisdict_list = list (thisdict.items ()) # Creates a list of the dict
print (thisdict_list [2][1]) # 3rd dict item's value

# --------------------------------------------------------------------

city_pop = {"New York City":8550405, "Los Angeles":3971883, "Toronto":2731571, "Chicago":2720546, "Houston":2296224, 
            "Montreal":1704694, "Calgary":1239220, "Vancouver":631486, "Boston":667137}
print (city_pop ["Chicago"])
city_pop ["Halifax"] = 390096
print (len (city_pop))
print ("Houston" in city_pop)
print (city_pop.pop ("Boston")) # Removes key/value
print (city_pop)
(city, state) = city_pop.popitem ()
print (city, state)

# --------------------------------------------------------------------

knowledge = {"Frank": {"Perl"}, "Monica":{"C","C++"}} # Frank will be overwritten
knowledge2 = {"Guido":{"Python"}, "Frank":{"Perl", "Python"}}
knowledge.update (knowledge2)

# --------------------------------------------------------------------

d = {"a":123, "b":34, "c":304, "d":99}
for key in d: # Or d.keys ()
    print (key)

for value in d.values ():
    print (value)

# --------------------------------------------------------------------

w = {"house":"Haus", "cat":"", "red":"rot"}
items_view = w.items ()
items = list (items_view) # List of key/value pair tuples
print (items)

keys_view = w.keys ()
keys = list (keys_view)
print (keys)

values_view = w.values ()
values = list (values_view)
print (values)

# --------------------------------------------------------------------

dishes = ["pizza", "sauerkraut", "paella", "hamburger"]
countries = ["Italy", "Germany", "Spain", "USA"]
country_specialities_iterator = zip (countries, dishes) # Returns an iterator
country_specialities = list (country_specialities_iterator)
print (country_specialities)

country_specialities_dict = dict (country_specialities)
print (country_specialities_dict)

dishes = ["pizza", "sauerkraut", "paella", "hamburger"]
countries = ["Italy", "Germany", "Spain", "USA"]
print (dict (zip (countries, dishes)))

# --------------------------------------------------------------------

os.system ("pause")
