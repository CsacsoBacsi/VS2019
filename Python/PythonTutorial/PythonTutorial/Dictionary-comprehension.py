# --------------------------------------------------------------------

import os

# --------------------------------------------------------------------

# Generic: dict_variable = {key:value transformation for (key,value) in dictionary.items() filter}
dict1 = {'a': 1, 'b': 2, 'c': 3, 'd': 4, 'e': 5} # Double them
dict_dbl = {k:v * 2 for k,v in dict1.items ()}
print (dict1)
print (dict_dbl)

fahrenheit = {'t1':-30, 't2':-20, 't3':-10, 't4':0}

# --------------------------------------------------------------------

# Get the corresponding `celsius` values
celsius = list (map (lambda f: (f-32) * 5 / 9, fahrenheit.values ()))
print (celsius)

celsius_dict = dict (zip (fahrenheit.keys (), celsius))
print (celsius_dict)

celsius = {k:(v - 32) * 5 / 9 for k,v in fahrenheit.items ()}
print (celsius)

celsius = {k:(v - 32) * 5 / 9 for k,v in fahrenheit.items () if v > -20 and v != 0}
print (celsius)

dict1 = {'a': 1, 'b': 2, 'c': 3, 'd': 4, 'e': 5, 'f':6}

evens = {k:'even' if v%2 == 0 else 'odd' for k,v in dict1.items ()}
print (evens)

# --------------------------------------------------------------------

os.system ("pause")
