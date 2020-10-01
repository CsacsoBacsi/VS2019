# --------------------------------------------------------------------

import os
import json

# --------------------------------------------------------------------

blackjack_hand = (8, "Q") # Tuple
encoded_hand = json.dumps (blackjack_hand) # Becomes a string '[8, "Q"]'
decoded_hand = json.loads (encoded_hand) # Now a list [8, 'Q']

print (blackjack_hand == decoded_hand) # False
print (type (blackjack_hand))
print (type (decoded_hand))
print (blackjack_hand == tuple (decoded_hand)) # True
print (decoded_hand)
print (encoded_hand)

# --------------------------------------------------------------------

json_data1 = {
    "president": {
        "name": "George Bush",
        "species": "Human"
    }
}

with open ("president.json", "w") as write_file: # with means that the unmanaged resource gets closed, garbage collected when goes out of scope
    json.dump (json_data1, write_file, indent = 4, separators = (',', ': '))

with open ("president.json", "r") as read_file:
    data = json.load (read_file) # Creates a dict
print (data.items ())
print (data)

print (data['president']['name']) # Dict. Key=president. Get president's value which is another dict. Get the value of that for key "name"

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
car_list = json.dumps (json_data2) # Creates a string
cars = json.loads (car_list) # Creates a dict
# cars2 = json.loads (data3) # Can not use a dict here

print (cars['cars']['1']['colour']) # Must use string keys

# --------------------------------------------------------------------

with open ("cars.json", "r") as read_file:
    data = json.load (read_file) # Creates a dict
print (data.items ())
print (data)

with open ("lotto.json", "r") as read_file:
    data = json.load (read_file)
print (data.items ())
print (data)
print (data['lotto']['2'][3]) # 4th lotto number on 2nd week

# --------------------------------------------------------------------

data = {}  
data['people'] = [] # Array follows
data['people'].append ({ # Array of dictionary objects
    'name': 'Scott',
    'website': 'stackabuse.com',
    'from': 'Nebraska'
})
data['people'].append ({  
    'name': 'Larry',
    'website': 'google.com',
    'from': 'Michigan'
})
data['people'].append ({  
    'name': 'Tim',
    'website': 'apple.com',
    'from': 'Alabama'
})

with open ('data.txt', 'w') as outfile:  
    json.dump (data, outfile, indent = 4, separators = (',', ': '))

# --------------------------------------------------------------------

# More on JSON (Sudoku)
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
for i in range (1, 82, 1):
    gridArea [i] = 0

with open ('sudoku.json') as json_file:  
    grid = json.load (json_file)
    for p in grid ['Sudoku Grid']:
        gridArea [p ['cell number']] = p ['cell value']

for i in range (1, 82, 1):
    if gridArea [i] != 0:
        print ("Cell: ", str (i), "Value: ", str (gridArea [i]))

# --------------------------------------------------------------------

os.system ("pause")
