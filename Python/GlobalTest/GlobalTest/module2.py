import GlobalTest as gt
from module1 import * # Brings in all variables module1 had, BUT creates new ones in this module and get initialized to module1's variables
import module1
# Runs module1 code! So func () is running

print ("x upon entry: ", x) # Prints 10 as this variable is initialized to module1's x
x = 9 # Module global

print ("Globaltest x: ", gt.x)
print ("Module1 initialized module global x: ", x)
myfunc ()
print ("Globaltest x: ", gt.x)
print ("Module global x: ", x)
#print ("Module1's y: ", y)
print ("Module1's z:", gt.z)