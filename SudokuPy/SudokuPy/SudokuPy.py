import sys
import threading
import tkinter as tk
import tkinter.scrolledtext as tkscrolled
import time
from datetime import timedelta, datetime
import json
from xml.dom.minidom import parse
import xml.dom.minidom
from tkinter import messagebox
from tkinter.ttk import Progressbar

import Globals
from ConstantsPy import *
from SudokuEnginePy import *
from FunctionsPy import *

class solverThread (threading.Thread):
    def __init__(self, threadID, name, root):
        threading.Thread.__init__(self) # Init the super class
        self.threadID = threadID
        self.name = name
        self.root = root
        Globals.tk_widgets["root"] = root
      
    def run (self):
        SuDoKuEngine ()


class SudokuSolver (tk.Frame):

    def __init__(self, master = None): # The app inherits from Frame and master is the parent widget
        super ().__init__ (master) # Initialize the parent widget
        self.frame = tk.Frame (master, name = "sudokuframe")
        self.root = master
        self.root.resizable (width=FALSE, height=FALSE)
        self.root.protocol('WM_DELETE_WINDOW', self.closeWindow)
        self.pack ()
        self.createMenu ()
        self.createWidgets ()
        Globals.tk_widgets ["root"] = self.root

    def createMenu (self):
        self.menu = tk.Menu (self.root)
        self.root.config (menu = self.menu)
        #self.menu._configure (0, label = "Hi")

        self.fileMenu = tk.Menu (self.menu, tearoff = False)
        Globals.tk_widgets ["fileMenu"] = self.fileMenu
        self.menu.add_cascade (label = "File", menu = self.fileMenu)
        self.fileMenu.add_command (label = "Save", command = saveGridJSON)
        self.fileMenu.add_command (label = "Load", command = loadGridJSON)
        self.fileMenu.add_separator ()
        self.fileMenu.add_command (label = "Exit", command = self.closeWindow)

        self.helpMenu = tk.Menu (self.menu, tearoff = False)
        Globals.tk_widgets ["helpMenu"] = self.helpMenu
        self.menu.add_cascade (label = "Help", menu = self.helpMenu)
        self.helpMenu.add_command (label = "About", command = self.aboutDialog)

    def createWidgets (self):
        # Labels and buttons
        self.lbl_startgrid = tk.Label (text = "Starting grid")
        self.lbl_startgrid.place (x = 17, y = 34)
        self.lbl_solvedgrid = tk.Label (text = "Solved grid")
        self.lbl_solvedgrid.place (x = 17, y = 254)
        self.btn_clear = tk.Button (text = "Clear", height = 1, width = 8, command = resetBothGrids)
        self.btn_clear.place (x = 230, y = 70)
        Globals.tk_widgets ["btn_clear"] = self.btn_clear
        self.btn_solve = tk.Button (text = "Solve", height = 1, width = 8, command = self.startThread)
        self.btn_solve.place (x = 230, y = 105)
        Globals.tk_widgets ["btn_solve"] = self.btn_solve
        self.btn_stop = tk.Button (text = "Stop", height = 1, width = 8, command = self.stopThread)
        self.btn_stop.place (x = 230, y = 140)
        self.btn_stop.config (state = tk.DISABLED)
        Globals.tk_widgets ["btn_stop"] = self.btn_stop
        self.btn_next = tk.Button (text = "Next", height = 1, width = 8, command = self.nextSolve)
        self.btn_next.place (x = 230, y = 175)
        self.btn_next.config (state = tk.DISABLED)
        Globals.tk_widgets ["btn_next"] = self.btn_next
        self.btn_exit = tk.Button (text = "Exit", height = 1, width = 8, command = self.closeWindow)
        self.btn_exit.place (x = 230, y = 375)
        Globals.tk_widgets ["btn_exit"] = self.btn_exit
        self.btn_clear_log = tk.Button (text = "Clear log", height = 1, width = 9, command = resetLog)
        self.btn_clear_log.place (x = 520, y = 22)
        Globals.tk_widgets ["btn_clear_log"] = self.btn_clear_log

        # Text (application log)
        self.lbl_log = tk.Label (text = "Application log")
        self.lbl_log.place (x = 327, y = 34)
        self.log_window = tkscrolled.ScrolledText (height=28, width=64, borderwidth = 3, padx = 5, pady = 5, relief=tk.SUNKEN, font="Courier 8 normal", bg = "#e0e0e0", wrap = "word")
        self.log_window.place (x = 327, y = 55)
        self.log_window.config (state = tk.DISABLED)
        Globals.tk_widgets ["log_window"] = self.log_window

        # Log header
        mprintf (szLogHeader1 [Globals.langCode])
        mprintf (szLogHeader2 [Globals.langCode])
        mprintf (szLogHeader3 [Globals.langCode])
        mprintf (szLanguage [Globals.langCode] + "\n") # Display selected language

        # Draw solver field's cells        
        self.validateCommand = (self.frame.register (self.validateNums), '%S')
        self.drawCells ()

        # Radio buttons
        Globals.rbutton = tk.IntVar () # If 1 then single solve otherwise if 2 then multi
        Globals.rbutton.set (0) # This object is added at runtime to Globals!
        self.rbutton_singlesolve = tk.Radiobutton (text="Single solve", padx = 0, variable = Globals.rbutton, value = 0)
        Globals.tk_widgets ["rbutton_singlesolve"] = self.rbutton_singlesolve
        self.rbutton_multisolve = tk.Radiobutton (text="Multi solve", padx = 0, variable = Globals.rbutton, value = 1)
        Globals.tk_widgets ["rbutton_multisolve"] = self.rbutton_multisolve
        self.rbutton_singlesolve.place (x = 210, y = 225)
        self.rbutton_multisolve.place (x = 210, y = 255)

        self.labelSmiley = tk.Label ()
        self.labelSmiley.place (x = 235, y = 305)
        Globals.tk_widgets ["labelSmiley"] = self.labelSmiley

        # Toolbar
        self.toolbar = tk.Frame (self.root, name = "toolbarframe", relief=tk.RAISED)

        self.toolb_save = tk.Button (self.toolbar, width = 15, command = saveGridJSON)
        Globals.tk_widgets ["toolb_save"] = self.toolb_save
        self.img_save = tk.PhotoImage (file = "Save.gif")
        self.toolb_save.config (image = self.img_save, height = 15, width = 15)
        self.toolb_save.pack (side = tk.LEFT, padx = 2, pady = 2)
        
        self.toolb_load = tk.Button (self.toolbar, width = 15, command = loadGridJSON)
        Globals.tk_widgets ["toolb_load"] = self.toolb_load
        self.img_load = tk.PhotoImage (file = "Load.gif")
        self.toolb_load.pack (side = tk.LEFT, padx = 2, pady = 2)
        self.toolb_load.config (image = self.img_load, height = 15, width = 15)

        self.toolb_savexml = tk.Button (self.toolbar, width = 15, command = saveXML)
        Globals.tk_widgets ["toolb_savexml"] = self.toolb_savexml
        self.img_savexml = tk.PhotoImage (file = "XML.gif")
        self.toolb_savexml.config (image = self.img_savexml, height = 15, width = 15)
        self.toolb_savexml.pack (side = tk.LEFT, padx = 2, pady = 2)

        self.toolb_loadxml = tk.Button (self.toolbar, width = 15, command = loadXML)
        Globals.tk_widgets ["toolb_loadxml"] = self.toolb_loadxml
        self.img_loadxml = tk.PhotoImage (file = "XMLLoad.gif")
        self.toolb_loadxml.config (image = self.img_loadxml, height = 15, width = 15)
        self.toolb_loadxml.pack (side = tk.LEFT, padx = 2, pady = 2)

        self.toolb_log = tk.Button (self.toolbar, width = 15, command = resetLog)
        Globals.tk_widgets ["toolb_log"] = self.toolb_log
        self.img_log = tk.PhotoImage (file = "Log.gif")
        self.toolb_log.config (image = self.img_log, height = 15, width = 15)
        self.toolb_log.pack (side = tk.LEFT, padx = 2, pady = 2)

        self.toolb_clear = tk.Button (self.toolbar, width = 15, command = resetBothGrids)
        Globals.tk_widgets ["toolb_clear"] = self.toolb_clear
        self.img_clear = tk.PhotoImage (file = "Clear.gif")
        self.toolb_clear.pack (side = tk.LEFT, padx = 2, pady = 2)
        self.toolb_clear.config (image = self.img_clear, height = 15, width = 15)

        self.toolb_solve = tk.Button (self.toolbar, width = 15, command = self.startThread)
        Globals.tk_widgets ["toolb_solve"] = self.toolb_solve
        self.img_solve = tk.PhotoImage (file = "Solve.gif")
        self.toolb_solve.pack (side = tk.LEFT, padx = 2, pady = 2)
        self.toolb_solve.config (image = self.img_solve, height = 15, width = 15)

        self.toolb_stop = tk.Button (self.toolbar, width = 15, command = self.stopThread)
        Globals.tk_widgets ["toolb_stop"] = self.toolb_stop
        self.img_stop = tk.PhotoImage (file = "Stop.gif")
        self.toolb_stop.pack (side = tk.LEFT, padx = 2, pady = 2)
        self.toolb_stop.config (image = self.img_stop, height = 15, width = 15)
        self.toolb_stop.config (state = tk.DISABLED)

        self.toolb_next = tk.Button (self.toolbar, width = 15, command = self.nextSolve)
        Globals.tk_widgets ["toolb_next"] = self.toolb_next
        self.img_next = tk.PhotoImage (file = "Next.gif")
        self.toolb_next.pack (side = tk.LEFT, padx = 2, pady = 2)
        self.toolb_next.config (image = self.img_next, height = 15, width = 15)
        self.toolb_next.config (state = tk.DISABLED)

        self.toolb_hunflag = tk.Button (self.toolbar, width = 15, command = self.changeToHun)
        Globals.tk_widgets ["toolb_hunflag"] = self.toolb_hunflag
        self.img_hunflag = tk.PhotoImage (file = "HunFlag.gif")
        self.toolb_hunflag.config (image = self.img_hunflag, height = 15, width = 15)
        self.toolb_hunflag.pack (side = tk.LEFT, padx = 2, pady = 2)

        self.toolb_engflag = tk.Button (self.toolbar, width = 15, command = self.changeToEng)
        Globals.tk_widgets ["toolb_engflag"] = self.toolb_engflag
        self.img_engflag = tk.PhotoImage (file = "EngFlag.gif")
        self.toolb_engflag.config (image = self.img_engflag, height = 15, width = 15)
        self.toolb_engflag.pack (side = tk.LEFT, padx = 2, pady = 2)

        self.toolb_exit = tk.Button (self.toolbar, width = 15, command = self.closeWindow)
        Globals.tk_widgets ["toolb_exit"] = self.toolb_exit
        self.img_exit = tk.PhotoImage (file = "Exit.gif")
        self.toolb_exit.config (image = self.img_exit, height = 15, width = 15)
        self.toolb_exit.pack (side = tk.LEFT, padx = 2, pady = 2)

        if Globals.langCode == 0:
            self.toolb_hunflag.config (state = tk.NORMAL)
            self.toolb_engflag.config (state = tk.DISABLED)
        else:
            self.toolb_hunflag.config (state = tk.DISABLED)
            self.toolb_engflag.config (state = tk.NORMAL)

        self.progressBar = Progressbar (orient = tk.HORIZONTAL, length=150,  mode = 'indeterminate')
        Globals.tk_widgets["progressBar"] = self.progressBar

        #self.lbl_colHeader = tk.Label (text = "1     2     3    4     5     6    7     8     9")
        #self.lbl_colHeader.place (x = 25, y = 455)

        self.toolbar.pack (side = tk.TOP, fill = tk.X)
        self.frame.pack()
        
    def closeWindow (self):
        if Globals.canClose:
            if Globals.langCode == 0:
                if messagebox.askyesno ("Close the application", "Do you want to exit the app?") == True:
                    self.root.quit ()
            else:
                if messagebox.askyesno ("Az applikáció bezárása", "Ki szeretne lépni az applikációból?") == True:
                    self.root.quit ()
            

    def drawCells (self):
        # Starting grid
        count = 0
        bg = "white"
        for j in range (1, 10, 1):
            three = 0
            if count == 27:
                bg = "#e5e5e5"
            elif count == 54:
                bg = "white"
            for i in range (0, 9, 1):
                count += 1
                three += 1
                if three == 4 and bg == "#e5e5e5":
                    bg = "white"
                    three = 1
                elif three == 4 and bg == "white":
                    bg = "#e5e5e5"
                    three = 1
                self.thisCell = tk.Entry (name="starting-" + str ("%02d" % count), fg="black", bg = bg, textvariable = Globals.cellValues[0][count], disabledbackground = bg, justify=tk.CENTER, validate = "key", validatecommand=self.validateCommand)
                self.thisCell.bind ('<KeyPress>', self.setTo1Char)
                self.thisCell.place (x = 20 + i * 20, y = 35 + j * 20,  width=20, height=20)
                Globals.tk_widgets ["starting-" + str ("%02d" % count)] = self.thisCell # Register them in the global dictionary
        # Solved grid
        count = 0
        bg = "#e5e5e5"
        for j in range (1, 10, 1):
            three = 0
            if count == 27:
                bg = "white"
            elif count == 54:
                bg = "#e5e5e5"
            for i in range (0, 9, 1):
                count += 1
                three += 1
                if three == 4 and bg == "#e5e5e5":
                    bg = "white"
                    three = 1
                elif three == 4 and bg == "white":
                    bg = "#e5e5e5"
                    three = 1
                self.thisCell = tk.Entry (name="solved-" + str ("%02d" % count), state = tk.DISABLED, disabledbackground = bg, disabledforeground = "black", textvariable = Globals.cellValues[1][count], justify=tk.CENTER)
                #thisCell.bind ('<KeyPress>', self.setTo1Char)
                self.thisCell.place (x = 20 + i * 20, y = 255 + j * 20,  width=20, height=20)
                Globals.tk_widgets ["solved-" + str ("%02d" % count)] = self.thisCell

    def validateNums (self, newValue):
        if len (newValue) == 0:
            return True
        if ord (newValue) < 49 or ord (newValue) > 57: # what is more reliable
            return False
        return True

    def setTo1Char (self, event): # Fired upon a keystroke
        x = str (event.widget)
        p = int (x [x.rfind ('starting-')+9:len (x)+1])
        Globals.cellValues [0][p].set ("")

    def startThread (self):
        # When the Solve button has been pressed
        initSolver () # Initialize the internal list (array)
        self.hThread = solverThread (1, "SolverThread", self.root) # Instantiate solver thread
        Globals.tk_widgets ["solverThread"] = self.hThread

        Globals.working = True # Set to true while solving the grid
        Globals.canClose = False
        Globals.solveMode = Globals.rbutton.get ()

        self.btn_stop.config (state = tk.NORMAL)
        self.btn_solve.config (state = tk.DISABLED)
        self.btn_clear.config (state = tk.DISABLED)
        self.btn_next.config (state = tk.DISABLED)
        self.btn_exit.config (state = tk.DISABLED)
        self.btn_clear_log.config (state = tk.DISABLED)
        self.rbutton_singlesolve.config (state = tk.DISABLED)
        self.rbutton_multisolve.config (state = tk.DISABLED)
        self.fileMenu.entryconfig (3, state = tk.DISABLED)
        self.fileMenu.entryconfig (0, state = tk.DISABLED)
        self.fileMenu.entryconfig (1, state = tk.DISABLED)
        self.helpMenu.entryconfig (0, state = tk.DISABLED)
        self.toolb_stop.config (state = tk.NORMAL)
        self.toolb_solve.config (state = tk.DISABLED)
        self.toolb_clear.config (state = tk.DISABLED)
        self.toolb_exit.config (state = tk.DISABLED)
        self.toolb_save.config (state = tk.DISABLED)
        self.toolb_load.config (state = tk.DISABLED)
        self.toolb_savexml.config (state = tk.DISABLED)
        self.toolb_loadxml.config (state = tk.DISABLED)
        self.toolb_next.config (state = tk.DISABLED)
        if Globals.langCode == 0:
            self.toolb_hunflag.config (state = tk.NORMAL)
            self.toolb_engflag.config (state = tk.DISABLED)
        else:
            self.toolb_hunflag.config (state = tk.DISABLED)
            self.toolb_engflag.config (state = tk.NORMAL)

        Globals.canClose = False
        Globals.tk_widgets["progressBar"].place (x = 35, y = 465)
        Globals.tk_widgets["progressBar"].start ()
        setStateStartingGrid (tk.DISABLED)
        self.hThread.start () # Kick it off!

    def stopThread (self):
        Globals.terminateThread = True # User terminated the thread while it was running
        Globals.working = False
        Globals.canClose = True
        Globals.gridSolved = False
        threadEvent.set () # Signal the event. The htread now can come out of its wait state

        self.btn_stop.config (state = tk.DISABLED)
        self.btn_solve.config (state = tk.NORMAL)
        self.btn_clear.config (state = tk.NORMAL)
        self.btn_next.config (state = tk.DISABLED)
        self.btn_exit.config (state = tk.NORMAL)
        self.btn_clear_log.config (state = tk.NORMAL)
        self.rbutton_singlesolve.config (state = tk.NORMAL)
        self.rbutton_multisolve.config (state = tk.NORMAL)
        self.fileMenu.entryconfig (3, state = tk.NORMAL)
        self.fileMenu.entryconfig (0, state = tk.NORMAL)
        self.fileMenu.entryconfig (1, state = tk.NORMAL)
        self.helpMenu.entryconfig (0, state = tk.NORMAL)
        self.toolb_stop.config (state = tk.NORMAL)
        self.toolb_solve.config (state = tk.NORMAL)
        self.toolb_clear.config (state = tk.NORMAL)
        self.toolb_exit.config (state = tk.NORMAL)
        self.toolb_save.config (state = tk.NORMAL)
        self.toolb_load.config (state = tk.NORMAL)
        self.toolb_savexml.config (state = tk.NORMAL)
        self.toolb_loadxml.config (state = tk.NORMAL)
        self.toolb_next.config (state = tk.DISABLED)
        if Globals.langCode == 0:
            self.toolb_hunflag.config (state = tk.NORMAL)
            self.toolb_engflag.config (state = tk.DISABLED)
        else:
            self.toolb_hunflag.config (state = tk.DISABLED)
            self.toolb_engflag.config (state = tk.NORMAL)
        Globals.tk_widgets["progressBar"].place_forget ()

        setStateStartingGrid (tk.NORMAL)

    def nextSolve (self):
        #getStartTime () # User requests the next solution

        mprintf ("\r\n\r\n") ;
        #wsprintf (buffer, szLogDateTime[langCode], currentDateTime ()) ;
        #mprintf (buffer) ;
        #mprintf ("\r\n") ;

        threadEvent.set () # Signal the event. The thread now can come out of its wait state

    def changeToHun (self):
        Globals.langCode = 1
        self.toolb_hunflag.config (state = tk.DISABLED)
        self.toolb_engflag.config (state = tk.NORMAL)

        self.lbl_startgrid.config (text = "Kezdő rács")
        self.lbl_solvedgrid.config (text = "Megoldott rács")
        self.lbl_log.config (text = "Napló")
        
        self.btn_solve.config (text = "Megold")
        self.btn_clear.config (text = "Töröl")
        self.btn_stop.config (text = "Leállít")
        self.btn_clear_log.config (text = "Napló törlés")
        self.btn_next.config (text = "Következő")
        self.btn_exit.config (text = "Kilép")

        self.rbutton_singlesolve.config (text = "Egy megoldás")
        self.rbutton_multisolve.config (text = "Több megoldás")
        
        self.fileMenu.entryconfig (0, label = "Mentés")
        self.fileMenu.entryconfig (1, label = "Betölt")
        self.fileMenu.entryconfig (3, label = "Kilép")
        self.helpMenu.entryconfig (0, label = "Rólam")
        self.menu.entryconfig (1, label="Fajl") 
        self.menu.entryconfig (2, label = "Segito")
        self.root.title ("Sudoku megoldó")
        
        mprintf (szLanguage [Globals.langCode] + "\n") # Display selected language

    def changeToEng (self):
        Globals.langCode = 0
        self.toolb_hunflag.config (state = tk.NORMAL)
        self.toolb_engflag.config (state = tk.DISABLED)

        self.lbl_startgrid.config (text = "Starting grid")
        self.lbl_solvedgrid.config (text = "Solved grid")
        self.lbl_log.config (text = "Application log")
        
        self.btn_solve.config (text = "Solve")
        self.btn_clear.config (text = "Clear")
        self.btn_stop.config (text = "Stop")
        self.btn_clear_log.config (text = "Clear log")
        self.btn_next.config (text = "Next")
        self.btn_exit.config (text = "Exit")

        self.rbutton_singlesolve.config (text = "Single solve")
        self.rbutton_multisolve.config (text = "Multi solve")
        
        self.fileMenu.entryconfig (0, label = "Save")
        self.fileMenu.entryconfig (1, label = "Load")
        self.fileMenu.entryconfig (3, label = "Exit")
        self.helpMenu.entryconfig (0, label = "About")
        self.menu.entryconfig (1, label="File") 
        self.menu.entryconfig (2, label = "Help")
        self.root.title ("Sudoku solver")
        
        mprintf (szLanguage [Globals.langCode] + "\n") # Display selected language

    def aboutDialog (self):
        self.aboutWindow = tk.Toplevel (self.master) # Toplevel is the widget
        self.cw = AboutWindow (self.aboutWindow) # This is going to be the master of the child window
        self.x = Globals.tk_widgets ["root"].winfo_x ()
        self.y = Globals.tk_widgets ["root"].winfo_y ()
        self.w = Globals.tk_widgets ["root"].winfo_width ()
        self.h = Globals.tk_widgets ["root"].winfo_height ()
        self.aboutWindow.geometry("250x150+%d+%d" % (self.w/2+self.x-250/2, self.h/2+self.y-150/2)) # width x height + x_offset + y_offset:
        self.lbl_about = tk.Label (self.aboutWindow, text = "Sudoku Solver utility using brute force\n 2017 Csacso Software")
        self.lbl_about.place (x = 26, y = 30)
        self.cw.closeButton = tk.Button (self.aboutWindow, text = 'Close', width = 5 , command = self.cw.closeAbout)
        self.cw.closeButton.place (x = 100, y = 110)
        self.frame.pack ()

class AboutWindow (): # Class for a child window which is opened by its parent. They are linked!
    def __init__ (self , master):
        self.master = master
        self.frame = tk.Frame (master) # Frame is just something to help you position your widgets. It is not a window
        master.title ("About Sudoku solver")

    def closeAbout (self):
        self.master.destroy () # Destroys the frame the About dialog window is sitting on


def initSudoku ():
    for i in range (0, 2): # Two rows: one for the starting grid and one for the solved one
        row = [] 
        for j in range (1, 83):
            row.append (tk.StringVar ()) 
        Globals.cellValues.append (row)

    for i in range (1, 83, 1): # Initialize arrays
        Globals.gridArea.append (0)
        Globals.prev_gridArea.append (0)

def main ():

    root = tk.Tk () # Initialize the GUI
    root.title("Sudoku solver")

    root.geometry("810x500+500+250") # width x height + x_offset + y_offset:
    initSudoku () # Initialize global arrays, variables
    solver = SudokuSolver (master = root)
    solver.master.iconbitmap('SuDoKu.ico')
    root.mainloop () # Main loop

    exit (0)

if __name__ == '__main__':
    main ()

''' Main
    Creates root, inits Sudoku, instantiates SudokuSolver class, goes into infinite looping
    SudokuSolver class creates frame, menu and widgets, amongst these the Solve button
    Solve button instantiates Thread, calls startThread which in turn calls the thread's run method which calls SudokuEngine
    SudokuEngine calls recursiveSolve
'''