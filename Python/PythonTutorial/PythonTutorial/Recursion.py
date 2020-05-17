# --------------------------------------------------------------------

import os

# --------------------------------------------------------------------

def tri_recursion (k): # tri_recursion (def_param = 10) -> Sets the default parameter if none given
    if k > 0:
        result = k + tri_recursion (k - 1) # (1 + 0) + (2 + 1) + (3 + 3) + (4 + 6) + (5 + 10) + (6 + 15)
        print (result)
    else:
        result = 0
    return result

print ("\n\nRecursion Example Results")
tri_recursion (6)

# --------------------------------------------------------------------

os.system ("pause")
