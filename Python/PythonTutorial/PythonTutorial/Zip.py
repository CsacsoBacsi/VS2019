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

os.system ("pause")
