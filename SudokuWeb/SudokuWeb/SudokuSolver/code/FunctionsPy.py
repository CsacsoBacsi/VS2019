import sys
from time import gmtime, strftime
import time
from SudokuSolver.code.ConstantsPy import *
import SudokuSolver.code.Globals as Globals
import tkinter as tk
import json
from xml.dom.minidom import *
#import xml.dom.minidom
from tkinter.filedialog import *
from tkinter import messagebox

def printf (format, *args):
    sys.stdout.write (format % args) # Like printf. The arguments after % formatted according to format

def AppendText (msg):
    printf ("%s", msg)
#    Globals.tk_widgets ["log_window"].config (state = tk.NORMAL) # Enable it
#    Globals.tk_widgets ["log_window"].insert (tk.END, msg) # Write to it
#    Globals.tk_widgets ["log_window"].yview_scroll (1, 'unit')
#    Globals.tk_widgets ["log_window"].config (state = tk.DISABLED) # Then disable it
    Globals.log += msg
    
def mprintf (msg):
    if Globals.enableLogging or Globals.clearLog: # Enable printing if the user clicked on the clear log button (display the log header)
        AppendText (str (msg))

def resetLog ():
#    Globals.tk_widgets ["log_window"].config (state = tk.NORMAL) # Enable it    
#    Globals.tk_widgets ["log_window"].delete ("1.0", tk.END)
#    Globals.tk_widgets ["log_window"].config (state = tk.DISABLED) # Then disable it
    Globals.clearLog = True
    mprintf (szLogHeader1 [Globals.langCode]) # Log header
    mprintf (szLogHeader2 [Globals.langCode])
    mprintf (szLogHeader3 [Globals.langCode])

    mprintf (szLanguage[Globals.langCode] + "\n") # Display selected language
    Globals.clearLog = False

def initSolver ():
    print ("Sudoku")

    Globals.enableLogging = True
    Globals.clearLog = False 
    Globals.canClose = True

def readGrid (grid):

    for i in range (1, 82, 1):
        Globals.gridArea [i] = grid [i]

def currentNS ():
    return time.time_ns ()

# Checks if a given number can go in that row or not
def checkRow (x, numVal, preCheck):
    rowNum = (x - 1) / 9 + 1

    for i in range (int (rowNum) * 9 - 8, int (rowNum) * 9 + 1, 1):
        if preCheck:
            if Globals.gridArea [i] == numVal and x != i:
                return False
        else:
            if Globals.gridArea [i] == numVal:
                return False
    return True

# Checks if a given number can go in that column or not
def checkCol (x, numVal, preCheck):
    colNum = x % 9

    for i in range (colNum, 82, 9):
        if preCheck:
            if Globals.gridArea [i] == numVal and x != i:
                return False
        else:
            if Globals.gridArea [i] == numVal:
                return False
    return True

# Checks if a given number can go in that region (3 x 3) or not
def checkRegion (x, numVal, preCheck):

    lx = x
    lx = lx - int (((x - 1) / 9)) * 9
    upperLeft = int (((lx - 1) / 3)) * 3 + 1 # Upper-left corner of a given region

    if x > 54: # 3rd region
        upperLeft += 54
    elif x > 27: # 2nd region
        upperLeft += 27

    # Region upper-left corners
    # 1,2,3,10,11,12,19,20,21 = 1 // 4,5,6,13,14,15,22,23,24 = 4 // 7,8,9,16,17,18,25,26,27 = 7
    # 28,29,30,37,38,39,46,47,48 = 28 // 31,32,33,40,41,42,49,50,51 = 31 // 34,35,36,43,44,45,52,53,54 = 34
    # 55,56,57,64,65,66,73,74,75 = 55 // 58,59,60,67,68,69,76,77,78 = 58 // 61,62,63,70,71,72,79,80,81 = 61
    if preCheck:
        if  (Globals.gridArea [int (upperLeft)] == numVal and int (upperLeft) != x) or (Globals.gridArea [int (upperLeft) + 1] == numVal and int (upperLeft) + 1 != x) or \
			(Globals.gridArea [int (upperLeft) + 2] == numVal  and int (upperLeft) + 2 != x) or (Globals.gridArea [int (upperLeft) + 9] == numVal  and int (upperLeft) + 9 != x) or \
			(Globals.gridArea [int (upperLeft) + 10] == numVal and int (upperLeft) + 10 != x) or (Globals.gridArea [int (upperLeft) + 11] == numVal  and int (upperLeft) + 11 != x) or \
			(Globals.gridArea [int (upperLeft) + 18] == numVal and int (upperLeft) + 18 != x) or (Globals.gridArea [int (upperLeft) + 19] == numVal  and int (upperLeft) + 19 != x) or \
			(Globals.gridArea [int (upperLeft) + 20] == numVal and int (upperLeft) + 20 != x):
            return False
    else:
        if  Globals.gridArea [int (upperLeft)] == numVal or Globals.gridArea [int (upperLeft) + 1] == numVal or Globals.gridArea [int (upperLeft) + 2] == numVal or \
			Globals.gridArea [int (upperLeft) + 9] == numVal or Globals.gridArea [int (upperLeft) + 10] == numVal or Globals.gridArea [int (upperLeft) + 11] == numVal or \
			Globals.gridArea  [int (upperLeft) + 18] == numVal or Globals.gridArea [int (upperLeft) + 19] == numVal or Globals.gridArea [int (upperLeft) + 20] == numVal:
            return False

    return True

# Check if any of the numbers (from 1 to 9) only one left because that has a fix place
def checkSingleChoice ():

    index = 0
    for i in range (1, 10, 1): # FOR all the numbers (from 1 to 9)
        index = 0
        if Globals.numsDone[i] == 1:
            for k in range (1, 74, 9):
                retVal = checkRow (k, i, False)
                if retVal:
                    index = k
                    break
            if index != 0:
                for j in range (index, index + 10, 1):
                    retVal = checkCol (j, i, False)
                    if retVal:
                        index = j
                        break
        if index != 0 and Globals.gridArea [index] == 0: # Only if the grid cell is not occupied
            Globals.gridArea [index] = i
            Globals.numsDone [i] -= 1
            return index

    return -1 # No single choice this time

# Checks if all numbers had been used
def verifyGrid1 ():
    for i in range (1, 10, 1):
        if Globals.numsDone [i] != 0:
            return False
    return True

# Checks if every row has unique numbers
def verifyGrid2 ():
    numbers = [0 for x in range (1, 10, 1)] # Initializes the array with zeros

    for j in range (0, 9, 1):
        for i in range (j * 9 + 1, j * 9 + 10, 1):
            if Globals.gridArea [i] != 0:
                numbers [Globals.gridArea [i] - 1] = 1
        for k in range (0, 9, 1):
            if numbers[k] != 1:
                return false
        for k in range (0, 9, 1):
            numbers[k] = 0
    return True

# Checks if every column has unique numbers
def verifyGrid3 ():

    numbers = [0 for x in range (1, 10, 1)]

    for j in range (0, 9, 1):
        for i in range (1, 74, 9):
            if Globals.gridArea [i] != 0:
                numbers [Globals.gridArea [i + j] - 1] = 1
        for k in range (0, 9, 1):
            if numbers [k] != 1:
                return False
        for k in range (0, 9, 1):
            numbers [k] = 0
    return True

# Checks if the sum of all grid cells is 405
def verifyGrid4 ():

    sum = 0
    for i in range (1, 82, 1):
        sum += Globals.gridArea [i]

    if sum == 405: # sum (1-9) * 9 = 405
        return True
    else:
        return False

def verifyGrid5 ():

    for i in range (1, 82, 1):
        if Globals.gridArea [i] != 0:
            if checkRow (i, Globals.gridArea [i], True) and checkCol (i, Globals.gridArea [i], True) and checkRegion (i, Globals.gridArea [i], True):
                continue
            else:
                return False
    return True

def printGrid ():
    mprintf ("   ")
    line = ""
    for i in range (1, 10, 1):
        buf = "%s" % chr (i + 48) # Lower-case letter columns
        line += buf
    mprintf (line)
    mprintf ("\r\n")

    line = ""
    mprintf ("  ")
    for i in range (1, 11, 1):
        line += "-"
    mprintf (line)
    mprintf ("\r\n")

    line = ""
    for i in range (0, 9, 1):
        buf = " %s|" % chr (i + 65) # Upper-case letter rows
        mprintf (buf)
        line = ""
        for j in range (1, 10, 1):
            buf = "%d" % Globals.gridArea [i * 9 + j]
            line += buf
        mprintf (line)
        mprintf ("\r\n")
    mprintf("\r\n")

def printGrid2 ():
    mprintf ("   ")
    line = ""
    for i in range (1, 10, 1):
        buf = "%s", chr (i + 48) # Lower-case letter columns
        line += buf
    mprintf (line)
    mprintf ("\r\n")

    mprintf ("  ")
    line = ""
    for i in range (1, 11, 1):
        line += "-"
    mprintf (line)
    mprintf ("\r\n")

    line = ""
    for i in range (0, 9, 1):
        buf = " %s|" % chr (i + 65) # Upper-case letter rows
        mprintf (buf)
        line = ""
        for j in range (1, 10, 1):
            if Globals.cellValues [i * 9 + j].get () != "":
                buf = "%d" % int (Globals.cellValues [0][i * 9 + j].get ())
                line += buf
            else:
                mprintf (" ")
        mprintf (line)
        mprintf ("\r\n")
    mprintf("\r\n")

def writeGrid ():

    for i in range (1, 82, 1):
        Globals.cellValues [1][i].set (Globals.gridArea [i])
        if (Globals.cellValues [0][i]).get () != "":
            (Globals.tk_widgets ["solved-" + str ("%02d" % i)]).config (disabledforeground = "#1E90FF", font = "Tktextfont 10 bold")

    # Traversing the tk widget hierarchy
    #for widget in tk_widgets["root"].winfo_children (): # Search for solved cells
    #    widgetstr = str (widget)
    #    if isinstance (widget, tk.Entry) and widgetstr [0:3] == ".so": # Entry widget and its name starts with .so meaning .solved
    #        index = int (widgetstr[8:10]) # .solved-01
    #        if (cellValues [0][index]).get () != "":
    #            widget.config (disabledforeground = "#1E90FF")
    #            widget.config (font = "Tktextfont 10 bold")

# During multi-solve mode, detects the changed cells compared to previous solved grid
def changedGrid ():

    if Globals.solvedNTimes <= 1: # First time there was no previous solved grid to compare to, so skip
        return

    for i in range (1, 82, 1):
        if Globals.gridArea [i] != Globals.prev_gridArea [i]: # Different from previous
            (Globals.tk_widgets ["solved-" + str ("%02d" % i)]).config (disabledforeground = "red", font = "Tktextfont 10 bold")

def resetGridSolved ():

    for i in range (1, 82, 1):
        Globals.cellValues [1][i].set ("")
        (Globals.tk_widgets ["solved-" + str ("%02d" % i)]).config (disabledforeground = "black", font = "Tktextfont 9 normal")

    # Traversing the tk widget hierarchy
    #for widget in tk_widgets ["root"].winfo_children (): # Restore font for user typed number cells in solved grid
    #    widgetstr = str (widget)
    #    if isinstance (widget, tk.Entry) and widgetstr [0:3] == ".so": # Entry widget and its name starts with .so meaning .solved
    #        widget.config (disabledforeground = "black")
    #        widget.config (font = "Tktextfont 9 normal")

def resetGridStarting ():

    for i in range (1, 82, 1):
        Globals.cellValues [0][i].set ("")

def resetBothGrids ():

    for i in range (1, 82, 1):
        Globals.cellValues [0][i].set ("")
    for i in range (1, 82, 1):
        Globals.cellValues [1][i].set ("")
        (Globals.tk_widgets ["solved-" + str ("%02d" % i)]).config (disabledforeground = "black", font = "Tktextfont 9 normal")

def setStateStartingGrid (state):

    for i in range (1, 82, 1):
        (Globals.tk_widgets ["starting-" + str ("%02d" % i)]).config (state = state)

def nextSolution ():

    #getEndTime () ;											// Get elapsed secs and recursive call statistics
    buf = szSolvedNTimes [Globals.langCode] % Globals.solvedNTimes
    mprintf (buf)
    printGrid ()
    #printTime ()
    Globals.recursiveCalls -= 1
    buf = szNoRecCalls3 [Globals.langCode] % Globals.recursiveCalls
    mprintf (buf)
    #sprintf_s (elapsedSecs, szElapsedSecs2 [langCode], (t_diff1 + t_diff2 + t_diff3) / 3)
    Globals.recursiveCalls = 0
    resetGridSolved ()

    writeGrid () # Displays the internal memory (pgridArea) content in the solved grid (list view)
    changedGrid ()
    for i in range (1, 82, 1):
        Globals.prev_gridArea [i] = Globals.gridArea [i] # This becomes the previous solved grid. Populate the previous grid area array
    
    Globals.tk_widgets ["btn_next"].config (state = tk.NORMAL)
    Globals.tk_widgets ["toolb_next"].config (state = tk.NORMAL)
    Globals.tk_widgets["progressBar"].place_forget ()
    animateSmiley (0.2)
    threadEvent.wait () # Suspends the engine thread and waits until the user continues or stops
    threadEvent.clear ()
    if Globals.terminateThread:
        return False
    Globals.timeStart = currentNS ()
    return True

def saveGridJSON ():
    grid = {}
    grid ['Sudoku Grid'] = []
    
    for i in range (1, 82, 1):
        if (Globals.cellValues [0][i]).get () == "": # Nothing in cell
            continue
        else:
            grid ['Sudoku Grid'].append (
              {'cell number': i,
               'cell value': int ((Globals.cellValues [0][i]).get ())
              })

    options = {}
    options['defaultextension'] = ".json"
    options['filetypes'] = [("JSON files","*.json")]
    options['initialdir'] = None
    options['initialfile'] = None
    options['title'] = "Save grid as JSON"

    filename = asksaveasfilename (**options)

    if filename != "":
        try:
            with open (filename, 'w') as outfile:  
                json.dump (grid, outfile, indent = 4, separators = (',', ': '))
            if Globals.langCode == 0:
                retval = messagebox.showinfo ("Save grid as JSON", "File " + filename + " successfully saved")
            else:
                retval = messagebox.showinfo ("Rács lementése JSON fájlba", "A " + filename + " fájl sikeresen le lett mentve")
        except:
            if Globals.langCode == 0:
                retval = messagebox.showinfo ("Save grid as JSON", "File may not have been saved")
            else:
                retval = messagebox.showinfo ("Rács lementése JSON fájlba", "A fájl lementésekor hiba lépett fel")

def loadGridJSON ():
    try:
        filename = askopenfilename (initialdir = "./", title = "Load JSON into grid", filetypes = [("JSON files","*.json")])
        if filename != "":
            with open (filename) as json_file:
                grid = json.load (json_file)
    
            resetBothGrids ()
            for item in grid ['Sudoku Grid']:
                Globals.cellValues [0][item ['cell number']].set (item ['cell value'])
            if Globals.langCode == 0:
                retval = messagebox.showinfo ("Load grid from JSON", "File " + filename + " successfully loaded")
            else:
                retval = messagebox.showinfo ("A rács betöltése JSON fájlból", "A " + filename + " fájl sikeresen betöltődött")
    except:
        if Globals.langCode == 0:
            retval = messagebox.showwarning ("Load grid from JSON", "File may not have been loaded")
        else:
            retval = messagebox.showwarning ("A rács betöltése JSON fájlból", "A fájl betöltésekor hiba lépett fel")

def saveXML ():
    
    doc = Document () # New XML document

    root = doc.createElement ('SudokuGrid')
    doc.appendChild (root)

    for i in range (1, 82, 1):
        if (Globals.cellValues [0][i]).get () != "":
            cell = doc.createElement('CellValue')
            celltext = doc.createTextNode ((Globals.cellValues [0][i]).get ())
            cell.appendChild (celltext)
            cell.setAttribute ('GridRef', str (i))
            root.appendChild (cell)

    xml_str = doc.toprettyxml (indent="  ")

    options = {}
    options['defaultextension'] = ".xml"
    options['filetypes'] = [("XML files","*.xml")]
    options['initialdir'] = None
    options['initialfile'] = None
    options['title'] = "Save grid as XML"

    filename = asksaveasfilename (**options)

    if filename != "":
        try:
            file = open (filename, 'w')
            written = file.write (xml_str)
            file.close ()
            if Globals.langCode == 0:
                retval = messagebox.showinfo ("Save grid as JSON", "File " + filename + " successfully saved")
            else:
                retval = messagebox.showinfo ("Rács lementése JSON fájlba", "A " + filename + " fájl sikeresen le lett mentve")
        except:
            if Globals.langCode == 0:
                retval = messagebox.showinfo ("Save grid as JSON", "File may not have been saved")
            else:
                retval = messagebox.showinfo ("Rács lementése JSON fájlba", "A fájl lementésekor hiba lépett fel")

def loadXML ():
    try:
        xml_content = ""
        filename = askopenfilename (initialdir = "./", title = "Load XMLinto grid", filetypes = [("XML files","*.xml")])
        if filename != "":
            with open (filename) as xml_file:
                for line in xml_file:
                    xml_content += line

            resetBothGrids ()
            DOMTree = xml.dom.minidom.parseString (xml_content)
            root = DOMTree.documentElement
            cells = root.getElementsByTagName ("CellValue")
            for cell in cells:
                gridRef = int (cell.getAttribute ('GridRef'))
                cellValue = cell.firstChild.data
                (Globals.cellValues [0][gridRef]).set (cellValue)

            if Globals.langCode == 0:
                retval = messagebox.showinfo ("Load grid from XML", "File " + filename + " successfully loaded")
            else:
                retval = messagebox.showinfo ("A rács betöltése XML fájlból", "A " + filename + " fájl sikeresen betöltődött")
    except:
        if Globals.langCode == 0:
            retval = messagebox.showwarning ("Load grid from XML", "File may not have been loaded")
        else:
            retval = messagebox.showwarning ("A rács betöltése XML fájlból", "A fájl betöltésekor hiba lépett fel")

def animateSmiley (n):
    for i in range (1, 6, 1):
        smiley = PhotoImage (file = "Smiley" + str (i) + ".gif")
        Globals.tk_widgets ["labelSmiley"].configure (image = smiley)
        time.sleep (n)