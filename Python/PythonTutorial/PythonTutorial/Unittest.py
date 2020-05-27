# --------------------------------------------------------------------

import doctest
import unittest
import os
import sys

# --------------------------------------------------------------------

def sq (x) -> int: # Doc string contains expected results. Reises exceptions when not met
    '''
    Calculates the square of the input number 

    >>> sq(0)
    0
    >>> sq (1)
    1
    >>> sq (10) 
    100
    >>> sq (15)
    225
    
    '''

    return x ** 2

# --------------------------------------------------------------------

class sqtest (unittest.TestCase): # Assertions
    def testFunc (self): # Must start with "test" but the name itself can be arbitrary
        self.assertEqual (sq (1), 1)
        self.assertEqual (sq (5), 26) # Fails
        self.assertFalse (sq (0))

if __name__ == "__main__":
    doctest.testmod 
    os.system ("pause")
    del sys.argv[1:] # Otherwise command line argumebts are treated as test cases!
    unittest.main ()
    os.system ("pause")

# --------------------------------------------------------------------

