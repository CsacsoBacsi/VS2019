from GlobalTest import * # Now x can be referenced without GlobalTest. Not good practice! *** Only do it for constants! ***
import GlobalTest as gt

def myfunc ():
    global x # Otherwise no change in x. x here is module global, not GlobalTest's x!
    x = 10 # Otherwise local (to the function) x
#    global y # Otherwise no change in module global y
    y = 0 # Local y, module y is not affected

#def main (): # With main, things become local as main is a function
# print ("x upon entry: ", x) # -1 as brings in x from GlobalTest but it is a new x!!!! GlobalTest.x is still -1. It errors as it is taken as local!
x = 5 # Module global, never across all modules!
print ("Id of modul global x: ", id(x))
print ("Id of GlobalTest.x: ", id (gt.x))
print ("Is x equal x?", x is gt.x)
print ("x after new value assignment: ", x)
#print (GlobalTest.x) # Since it is import *, this module is unknown. Its variables are known
y = -2 # Module global

myfunc ()
print ("x changed in function with global keyword: ", x) # Prints 10, the module global x
print ("y changed in function without global keyword: ", y) # Prints -2, the module global y

gt.z = 100 # Added to an imported module at runtime!
print ("z added at runtime! ", gt.z)

#if __name__ == "__main__":
#    main ()
