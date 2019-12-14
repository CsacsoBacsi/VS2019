from FunctionsPy import *
from ConstantsPy import *
import Globals

def SuDoKuEngine ():
    i = 0 # Loop variable
    x = 1 # Grid coordinate
    retVal = 0 # Return value from the recursive function

    # Initialization section
    Globals.terminateThread = False # As a default, do not terminate the thread
    Globals.gridArea [0] = -1 # Init unused first index value in the grid area
    Globals.numsDone [0] = 0 # Init unused first array member

    for i in range (1, 10, 1): # Set the count of unused numbers to an initial 9
        Globals.numsDone [i] = 9

    Globals.gridSolved = False # The grid is not solved yet
    Globals.recursiveCalls = 0 # Number of recursive calls going forward during "brute force"
    Globals.solvedNTimes = 0 # During multi-solve, it counts the number of solutions of the grid
    Globals.working = True
    Globals.canClose = False

    mprintf (szGridValidationCheck [Globals.langCode])
    resetGridSolved () # Initialize the resulting grid
    Globals.timeStart = currentNS () # Stopper start!

    readGrid () # Read the initial (setup) grid and populate the internally allocated array pgridArea
    if verifyGrid5 (): # Verify the grid set up by the user
        mprintf (szGridIsValid [Globals.langCode])
    else: # Invalid grid! Reset everything
        Globals.tk_widgets ["btn_stop"].config (state = tk.DISABLED)
        Globals.tk_widgets ["btn_solve"].config (state = tk.NORMAL)
        Globals.tk_widgets ["btn_clear"].config (state = tk.NORMAL)
        Globals.tk_widgets ["btn_next"].config (state = tk.DISABLED)
        Globals.tk_widgets ["btn_exit"].config (state = tk.NORMAL)
        Globals.tk_widgets ["btn_clear_log"].config (state = tk.NORMAL)
        Globals.tk_widgets ["rbutton_singlesolve"].config (state = tk.NORMAL)
        Globals.tk_widgets ["rbutton_multisolve"].config (state = tk.NORMAL)
        Globals.tk_widgets ["fileMenu"].entryconfig (3, state = tk.NORMAL)
        Globals.tk_widgets ["fileMenu"].entryconfig (0, state = tk.NORMAL)
        Globals.tk_widgets ["fileMenu"].entryconfig (1, state = tk.NORMAL)
        Globals.tk_widgets ["helpMenu"].entryconfig (0, state = tk.NORMAL)
        Globals.tk_widgets ["toolb_stop"].config (state = tk.DISABLED)
        Globals.tk_widgets ["toolb_solve"].config (state = tk.NORMAL)
        Globals.tk_widgets ["toolb_clear"].config (state = tk.NORMAL)
        Globals.tk_widgets ["toolb_exit"].config (state = tk.NORMAL)
        Globals.tk_widgets ["toolb_hunflag"].config (state = tk.NORMAL)
        Globals.tk_widgets ["toolb_save"].config (state = tk.NORMAL)
        Globals.tk_widgets ["toolb_load"].config (state = tk.NORMAL)
        Globals.tk_widgets ["toolb_savexml"].config (state = tk.NORMAL)
        Globals.tk_widgets ["toolb_loadxml"].config (state = tk.NORMAL)
        Globals.tk_widgets ["toolb_next"].config (state = tk.DISABLED)
        if Globals.langCode == 0:
            Globals.tk_widgets["toolb_hunflag"].config (state = tk.NORMAL)
            Globals.tk_widgets["toolb_engflag"].config (state = tk.DISABLED)
        else:
            Globals.tk_widgets["toolb_hunflag"].config (state = tk.DISABLED)
            Globals.tk_widgets["toolb_engflag"].config (state = tk.NORMAL)

        Globals.working = False
        Globals.canClose = True
        mprintf (szGridIsInvalid [Globals.langCode])
        Globals.tk_widgets["progressBar"].stop ()
        Globals.tk_widgets["progressBar"].place_forget ()
        setStateStartingGrid (tk.NORMAL)
        if Globals.langCode == 0:
            retval = messagebox.showerror ("Error", "The grid is invalid, please check the cell values!")
        else: 
            retval = messagebox.showerror ("Hiba", "Helytelen rács! Ellenőrizze a számokat a cellákban!")
        return -1
    
    mprintf (szStartingGrid [Globals.langCode])
    printGrid ()
    mprintf (szSolvingGrid [Globals.langCode])

    for i in range (1, 11, 1): # Set number of unused numbers based on the grid after set up
        for  k in range (1, 82, 1):
            if Globals.gridArea [k] == i:
                Globals.numsDone [i] -= 1

	# This is the core engine of the SuDoKu solver
    retVal = recursiveSolve (x) # Call the main function

    if retVal == -2: # Unknown outcome
        Globals.tk_widgets ["btn_stop"].config (state = tk.DISABLED)
        Globals.tk_widgets ["btn_solve"].config (state = tk.NORMAL)
        Globals.tk_widgets ["btn_clear"].config (state = tk.NORMAL)
        Globals.tk_widgets ["btn_next"].config (state = tk.DISABLED)
        Globals.tk_widgets ["btn_exit"].config (state = tk.NORMAL)
        Globals.tk_widgets ["btn_clear_log"].config (state = tk.NORMAL)
        Globals.tk_widgets ["rbutton_singlesolve"].config (state = tk.NORMAL)
        Globals.tk_widgets ["rbutton_multisolve"].config (state = tk.NORMAL)
        Globals.tk_widgets ["fileMenu"].entryconfig (3, state = tk.NORMAL)
        Globals.tk_widgets ["fileMenu"].entryconfig (0, state = tk.NORMAL)
        Globals.tk_widgets ["fileMenu"].entryconfig (1, state = tk.NORMAL)
        Globals.tk_widgets ["helpMenu"].entryconfig (0, state = tk.NORMAL)
        Globals.tk_widgets ["toolb_stop"].config (state = tk.DISABLED)
        Globals.tk_widgets ["toolb_solve"].config (state = tk.NORMAL)
        Globals.tk_widgets ["toolb_clear"].config (state = tk.NORMAL)
        Globals.tk_widgets ["toolb_exit"].config (state = tk.NORMAL)
        Globals.tk_widgets ["toolb_save"].config (state = tk.NORMAL)
        Globals.tk_widgets ["toolb_load"].config (state = tk.NORMAL)
        Globals.tk_widgets ["toolb_savexml"].config (state = tk.NORMAL)
        Globals.tk_widgets ["toolb_loadxml"].config (state = tk.NORMAL)
        Globals.tk_widgets ["toolb_next"].config (state = tk.DISABLED)
        if Globals.langCode == 0:
            Globals.tk_widgets["toolb_hunflag"].config (state = tk.NORMAL)
            Globals.tk_widgets["toolb_engflag"].config (state = tk.DISABLED)
        else:
            Globals.tk_widgets["toolb_hunflag"].config (state = tk.DISABLED)
            Globals.tk_widgets["toolb_engflag"].config (state = tk.NORMAL)
        Globals.tk_widgets["progressBar"].stop ()
        Globals.tk_widgets["progressBar"].place_forget ()
        setStateStartingGrid (tk.NORMAL)

        mprintf (szThreadTermin [Globals.langCode])
        Globals.working = False
        Globals.canClose = True

        return 0

    if Globals.solveMode == 0: # Single-solve mode
        Globals.timeEnd = currentNS () # Stopper start!
        if retVal == -1:
            mprintf (szGridCantSolved [Globals.langCode])
            Globals.recursiveCalls -= 1
            buf =  szNoRecCalls [Globals.langCode] % Globals.recursiveCalls
            mprintf (buf)
            Globals.tk_widgets["progressBar"].stop ()
            Globals.tk_widgets["progressBar"].place_forget ()
            if Globals.langCode == 0:
                retval = messagebox.showerror ("Sudoku", "The grid could not be solved!")
            else: 
                retval = messagebox.showerror ("Sudoku", "A rácsot nem lehet megoldani!")
        elif retVal == 0:
            mprintf (szSolvedGrid [Globals.langCode])
            printGrid ()
            writeGrid ()

            buf = "Elapsed seconds: %f\n" % ((int (Globals.timeEnd - Globals.timeStart)) / 1000000000)
            mprintf (buf)

            mprintf (szVerification1 [Globals.langCode]) # Various solved grid verifications
            if verifyGrid1 ():
                mprintf (szVerification1OK [Globals.langCode])
            else:
                mprintf (szVerification1FD [Globals.langCode])
            mprintf (szVerification2 [Globals.langCode])
            if verifyGrid2 ():
                mprintf (szVerification2OK [Globals.langCode])
            else:
              mprintf (szVerification2FD [Globals.langCode])
            mprintf (szVerification3 [Globals.langCode])
            if verifyGrid3 ():
                mprintf (szVerification3OK [Globals.langCode])
            else:
                mprintf (szVerification3FD [Globals.langCode])
            mprintf (szVerification4 [Globals.langCode])
            if verifyGrid4 ():
                mprintf (szVerification4OK [Globals.langCode])
            else:
                mprintf (szVerification4FD [Globals.langCode])

            Globals.recursiveCalls -= 1
            buf = szNoRecCalls3 [Globals.langCode] % Globals.recursiveCalls
            mprintf (buf)

    else:
        if retVal == -1: # No more solutions found
            Globals.timeEnd = currentNS ()
            Globals.tk_widgets["progressBar"].stop ()
            Globals.tk_widgets["progressBar"].place_forget ()

            if Globals.solvedNTimes == 0:
                mprintf (szGridCantSolved [Globals.langCode])
                buf = "Elapsed seconds: %f\n" % ((int (Globals.timeEnd - Globals.timeStart)) / 1000000000)
                mprintf (buf)
                if Globals.langCode == 0:
                    retval = messagebox.showerror ("Sudoku", "The grid could not be solved!")
                else: 
                    retval = messagebox.showerror ("Sudoku", "A rácsot nem lehet megoldani!")
            else:
                mprintf (szNoMoreSolution [Globals.langCode])
                buf = "Elapsed seconds: %f\n" % ((int (Globals.timeEnd - Globals.timeStart)) / 1000000000)
                mprintf (buf)
                if Globals.langCode == 0:
                    retval = messagebox.showinfo ("Grid solve", "No more possible solutions found!")
                else:
                    retval = messagebox.showinfo ("Rács megoldás", "Nincs már több lehetséges megoldás'")
        elif retVal == 0:
            mprintf ("")
        else:
            mprintf (szUnknownOutcome [Globals.langCode])

    Globals.tk_widgets ["btn_stop"].config (state = tk.DISABLED)
    Globals.tk_widgets ["btn_solve"].config (state = tk.NORMAL)
    Globals.tk_widgets ["btn_clear"].config (state = tk.NORMAL)
    Globals.tk_widgets ["btn_next"].config (state = tk.DISABLED)
    Globals.tk_widgets ["btn_exit"].config (state = tk.NORMAL)
    Globals.tk_widgets ["btn_clear_log"].config (state = tk.NORMAL)
    Globals.tk_widgets ["rbutton_singlesolve"].config (state = tk.NORMAL)
    Globals.tk_widgets ["rbutton_multisolve"].config (state = tk.NORMAL)
    Globals.tk_widgets ["fileMenu"].entryconfig (3, state = tk.NORMAL)
    Globals.tk_widgets ["fileMenu"].entryconfig (0, state = tk.NORMAL)
    Globals.tk_widgets ["fileMenu"].entryconfig (1, state = tk.NORMAL)
    Globals.tk_widgets ["helpMenu"].entryconfig (0, state = tk.NORMAL)
    Globals.tk_widgets ["toolb_stop"].config (state = tk.DISABLED)
    Globals.tk_widgets ["toolb_solve"].config (state = tk.NORMAL)
    Globals.tk_widgets ["toolb_clear"].config (state = tk.NORMAL)
    Globals.tk_widgets ["toolb_exit"].config (state = tk.NORMAL)
    Globals.tk_widgets ["toolb_save"].config (state = tk.NORMAL)
    Globals.tk_widgets ["toolb_load"].config (state = tk.NORMAL)
    Globals.tk_widgets ["toolb_savexml"].config (state = tk.NORMAL)
    Globals.tk_widgets ["toolb_loadxml"].config (state = tk.NORMAL)
    Globals.tk_widgets ["toolb_next"].config (state = tk.DISABLED)
    if Globals.langCode == 0:
        Globals.tk_widgets["toolb_hunflag"].config (state = tk.NORMAL)
        Globals.tk_widgets["toolb_engflag"].config (state = tk.DISABLED)
    else:
        Globals.tk_widgets["toolb_hunflag"].config (state = tk.DISABLED)
        Globals.tk_widgets["toolb_engflag"].config (state = tk.NORMAL)
    Globals.tk_widgets["progressBar"].stop ()
    Globals.tk_widgets["progressBar"].place_forget ()
    setStateStartingGrid (tk.NORMAL)

    if Globals.gridSolved:
        animateSmiley (0.2)

    Globals.working = False
    Globals.canClose = True

    return 0

# The main SuDoKu solver engine. Called recursively during "brute force"
def recursiveSolve (x):
    saveFix = 0
    success = False

    if (Globals.terminateThread): # The user stopped the engine
        return -2

    Globals.recursiveCalls += 1 # Stores the number of recursive forward steps
    if int (Globals.recursiveCalls / 100000000) * 100000000 == Globals.recursiveCalls:
        buf = szNoRecCalls4 [Globals.langCode] % (currentDateTime (), Globals.recursiveCalls)
        mprintf (buf)
    if Globals.gridArea [x] != 0: # If the grid cell already contains a non-zero value go as far as it is zero
        i = x
        while i <= 81:
            if Globals.gridArea [i] == 0:
                break
            i += 1
        x = i

    saveX = x # Save the coordinate so that the function after a backtrack can pick up from where it left off

    for i in range (1, 10,  1): # Try each number (from 1 to 9)
        if Globals.terminateThread:	# If the user terminated this engine thread forcefully
            return -2

        if Globals.numsDone [i] == 0: # If this number has already been exhausted then skip it
            continue
        # Check if this number (i) is a valid number for this (x) cell 
        if Globals.gridArea [x] == 0 and checkRow (x, i, False) and checkCol (x, i, False) and checkRegion (x, i, False): # Number to be placed in a cell must satisfy all these criteria
            Globals.gridArea [x] = i # Populate cell
            Globals.numsDone [i] -= 1 # Register that another instance of this number (i) has been taken
            success = True

            fix = checkSingleChoice () # Check if there are any apparent choices available
            if fix != -1:
                saveFix = fix
            else:
                saveFix = 0

            if Globals.terminateThread:
                return -2

            retval = verifyGrid1 () # Check if all numbers have been used (basically the grid is fully filled)

            if retval:
                Globals.gridSolved = True
                if Globals.solveMode == 1:
                    Globals.solvedNTimes += 1 # In multi-solve mode, count the successful solutions
                    Globals.timeEnd = currentNS ()
                    buf = "Elapsed seconds: %f\n" % ((int (Globals.timeEnd - Globals.timeStart)) / 1000000000)
                    mprintf (buf)
                    if nextSolution (): # The user wants the next solution to be found
                        Globals.gridSolved = False
                        
                        success = False # Backtrack here
                        x = saveX # Restore grid cell position
                        Globals.gridArea [saveX] = 0 # Set cell to zero
                        Globals.numsDone [i] += 1 # Adjust unused number count

                        if saveFix != 0: # If this recursive call also found a fix value then get rid of that too as things changed
                            Globals.numsDone [Globals.gridArea [saveFix]] += 1
                            Globals.gridArea [saveFix] = 0
                            saveFix = 0
                        mprintf (szSolvingGrid [Globals.langCode])
                        Globals.tk_widgets ["progressBar"].place (x = 35, y = 465)
                        continue
                else:
                    break

            x += 1 # Otherwise take a step forward
            retVal = recursiveSolve (x) # Call the function recursively passing it the next grid cell to try to fill in
            if retVal == 0: # The grid is solved
                break

            success = False # Backtrack here
            x = saveX # Restore grid cell position
            Globals.gridArea [saveX] = 0 # Set cell to zero
            Globals.numsDone [i] += 1 # Adjust unused number count

            if saveFix != 0: # If this recursive call also found a fix value then get rid of that too as things changed
                Globals.numsDone [Globals.gridArea [saveFix]] += 1
                Globals.gridArea [saveFix] = 0
                saveFix = 0

    if Globals.gridSolved: # The grid is solved, return from the recursive call (go up and up the stack) 
        return 0

    return -1 # Failed to find a valid cell

# End of source file - SuDoKuEnginePy.py
