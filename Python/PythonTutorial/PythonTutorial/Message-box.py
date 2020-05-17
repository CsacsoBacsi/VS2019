# --------------------------------------------------------------------

import os
from tkinter import messagebox

# --------------------------------------------------------------------

filename = "Myfile.xml"
retval = messagebox.showinfo ("Load grid from XML", "File " + filename + " successfully loaded")
print ("Showinfo retval:", retval)
retval = messagebox.askyesno ("Do you love me?", "Just say yes!")
print ("Askyesno retval:", retval)
retval = messagebox.showwarning ("Warning", "File may not have been loaded")
print ("Showwarningetval:", retval)
retval = messagebox.showerror ("Error", "File could not be loaded")
print ("Showerror retval:", retval)
retval = messagebox.askquestion("Do you still love me?", "I hope so babe, but are you?")
print ("Askquestion retval:", retval)
retval = messagebox.askokcancel("Endurance walking", "Shall we continue?")
print ("Askokcancel retval:", retval)
retval = messagebox.askretrycancel("We failed once", "Shall we try again?")
print ("Askretrycancel retval:", retval)

# --------------------------------------------------------------------

os.system ("pause")
