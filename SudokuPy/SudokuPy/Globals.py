# Grid
gridArea        = [] # 82 positions, first (zeroth) not used
pgridArea       = 1 # For a better debugger view of the grid area (starts at index 1). Pointer in the gridarea
prev_gridArea   = []
pprev_gridArea  = 1 # For a better debugger view of the grid area (starts at index 1)
numsDone        = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0] # Registers how many of each number (1-9) are still available
pnumsDone       = 1 # Pointer for the "done" numbers array (list)
cellValues      = []

# Miscellaneous
enableLogging   = True
clearLog        = True
canClose        = True
langCode        = 0
solveMode       = 0
gridSolved      = False
recursiveCalls  = 0
variationsOnly  = False
terminateThread = False
solvedNTimes    = 0
timeStart       = 0
timeEnd         = 0

# Widgets
tk_widgets      = {}