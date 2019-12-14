import sys
from django.db import models
from django.contrib.auth.models import User
import cx_Oracle
import SudokuSolver.code.Globals as Globals


class SudokuUser:
    def __init__ (self, userID, userName, sessionStart):
        self.userID = userID
        self.userName = userName
        self.sessionStart = sessionStart

dsn_tns_ng177hz = """(DESCRIPTION =
  (ADDRESS_LIST =
    (ADDRESS = (PROTOCOL = TCP)(HOST = localhost)(PORT = 1521))
  )
  (CONNECT_DATA =
    (SID = PDB2)
  )
)"""

dsn_tns = """(DESCRIPTION = 
     (ADDRESS_LIST =
      (ADDRESS = (COMMUNITY = tcp.world) (PROTOCOL = TCP) (HOST = aepw04-bulwscan.e-ssi.net)(PORT = 1521))
      (ADDRESS = (COMMUNITY = tcp.world) (PROTOCOL = TCP) (HOST = aepw04-shwdscan.e-ssi.net)(PORT = 1521))
     )
      (CONNECT_DATA =
         (SERVICE_NAME = aepw04_clt.world)
         (FAILOVER_MODE =
           (TYPE = SELECT)
           (RETRIES = 1000)
           (DELAY = 5)
           (METHOD = BASIC)
         )
      )
   )""" 

# Helper functions
def printf (format, *args):
  sys.stdout.write (format % args) # Like printf. The arguments after % formatted according to format

def saveGrid (user_id, title, created_datetime, time_taken, comment, grid):
    retval = checkConn ()
    if retval != 0:
        return retval

    csr = Globals.db.cursor ()

    sqlrowcnt = csr.var (cx_Oracle.NUMBER)
    retval   = csr.var (cx_Oracle.NUMBER)

    # to_date (:p_created_datetime, \'YYYY-MM-DD HH24:MI:SS\')
    #  p_created_datetime = created_datetime,
    #sql_header = "INSERT INTO SUDOKU_GRID_HEADER (user_id, grid_title, created_Datetime, time_taken, grid_comment, grid_id) VALUES (:p_user_id, :p_title, to_date (:p_created_datetime, 'YYYY-MM-DD HH24:MI:SS'), :p_time_taken, :p_comment)"
    #sql_grid =   "INSERT INTO SUDOKU_GRID_DETAIL (grid_id, cell_id, cell_val) VALUES (:p_grid_id, :p_cell_id, :p_cell_val)"

    csr.callproc ('PCK_SUDOKU_SOLVER.insertHeader', (user_id, title, created_datetime, time_taken, comment, sqlrowcnt, retval))

    printf ("PCK_SUDOKU_SOLVER.insertHeader - SQL row count: %d\n", sqlrowcnt.getvalue ())
    printf ("PCK_SUDOKU_SOLVER.insertHeader - Return value: %d\n", retval.getvalue ())

    #csr.execute (sql_header, p_user_id = user_id, p_title = title, p_created_datetime = created_datetime, p_time_taken = time_taken,  p_comment = comment)
    for i in range (1, 82, 1):
        if grid[i] != 0:
            #csr.execute (sql_grid, p_grid_id = 1, p_cell_id = i, p_cell_val = grid[i])
            csr.callproc ('PCK_SUDOKU_SOLVER.insertGrid', (i, grid[i], sqlrowcnt, retval))
            printf ("PCK_SUDOKU_SOLVER.insertGrid - SQL row count: %d\n", sqlrowcnt.getvalue ())
            printf ("PCK_SUDOKU_SOLVER.insertGrid - Return value: %d\n", retval.getvalue ())

    csr.close ()
    Globals.db.commit () # Commit
    #db.close ()

def getUserList ():
    retval = checkConn ()
    if retval != 0:
        return retval
    
    csr = Globals.db.cursor ()
    out_csr = csr.var (cx_Oracle.CURSOR)
    retval2  = csr.var (cx_Oracle.NUMBER)
    params = csr.callproc ('PCK_SUDOKU_SOLVER.getUserList', (out_csr, retval2)) # Returns all IN and OUT params in params as a list (or tuple)

    user_list = []
    for row in params[0]:
        user_list.append (row) # Build a list of tuples (which contain the columns queried: grid_id and grid_title)

    # Close cursor and connection
    csr.close ()

    # Return table_values
    if params[1] != 0: # Database error during cursor fetch
        Globals.oraError = str (params[1])
        return '2'
    if len (user_list) == 0 and params[1] == 0: # No user to fetch, table is empty
        return '4'
    return user_list # First out parameter, the only one by the way

def getUserName (user_id):
    retval = checkConn ()
    if retval != 0:
        return retval
    
    csr = Globals.db.cursor ()
    out_user_name = csr.var (cx_Oracle.STRING)
    retval2  = csr.var (cx_Oracle.NUMBER)
    params = csr.callproc ('PCK_SUDOKU_SOLVER.getUserName', (user_id, out_user_name, retval2)) # Returns all IN and OUT params in params as a list (or tuple)

    user_name = params[1]

    # Close cursor and connection
    csr.close ()

    # Return table_values
    if params[2] != 0: # Database error during cursor fetch
        Globals.oraError = str (params[2])
        return '2'
    if len (user_name) == '' and params[2] == 0: # Could not fetch user name
        return '4'
    return user_name # First out parameter

def getGridList (user):
    retval = checkConn ()
    if retval != 0:
        return retval
    
    csr = Globals.db.cursor ()
    out_csr = csr.var (cx_Oracle.CURSOR)
    retval2  = csr.var (cx_Oracle.NUMBER)
    params = csr.callproc ('PCK_SUDOKU_SOLVER.getGridList', (user, out_csr, retval2)) # Returns all IN and OUT params in params as a list (or tuple)

    grid_list = []
    for row in params[1]:
        grid_list.append (row) # Build a list of tuples (which contain the columns queried: grid_id and grid_title)

    # Close cursor and connection
    csr.close ()

    # Return table_values
    if params[2] != 0: # Database error during cursor fetch
        Globals.oraError = str (params[2])
        return '2'
    if len (grid_list) == 0 and params[2] == 0: # No grid to fetch, table is empty
        return '4'
    return grid_list # First out parameter

def retrieveGridHeader (grid_id):
    retval = checkConn ()
    if retval != 0:
        return retval

    csr = Globals.db.cursor ()

    out_csr = csr.var (cx_Oracle.CURSOR)
    retval2  = csr.var (cx_Oracle.NUMBER)
    #sql = """SELECT user_id, grid_title, created_datetime, time_taken, grid_comment FROM SUDOKU_GRID_HEADER WHERE  grid_id = :p_grid_id  """

    params = csr.callproc ('PCK_SUDOKU_SOLVER.getGridHeader', (grid_id, out_csr, retval2))
    for grid_header in params[1]: # Since it is just one single row, the loop runs once leaving grid_header populated
        pass 
    #csr.execute (sql, p_grid_id = grid_id) # Multiple bind variables possible
    #result = csr.fetchone () # All results at once in a 2 dimensional array

    csr.close ()
    #db.close ()

    # Return result
    if params[2] != 0: # Database error during cursor fetch
        Globals.oraError = str (params[2])
        return '2'

    return grid_header

def deleteGridHeader (grid_id):
    retval = checkConn ()
    if retval != 0:
        return retval

    csr = Globals.db.cursor ()

    out_rowcnt = csr.var (cx_Oracle.NUMBER)
    retval2  = csr.var (cx_Oracle.NUMBER)

    params = csr.callproc ('PCK_SUDOKU_SOLVER.deleteHeader', (grid_id, out_rowcnt, retval2))
   
    csr.close ()

    # Return result
    if params[2] != 0: # Database error during cursor fetch
        Globals.oraError = str (params[2])
        return '2'
    elif params[2] == 0 and params[1] != 1:
        return '5'
    else:
        return 0

def retrieveGridCells (grid_id):
    retval = checkConn ()
    if retval != 0:
        return retval

    csr = Globals.db.cursor ()

    out_csr = csr.var (cx_Oracle.CURSOR)
    retval2  = csr.var (cx_Oracle.NUMBER)

    grid_cells = []
    params = csr.callproc ('PCK_SUDOKU_SOLVER.getGridCells', (grid_id, out_csr, retval2))
    for grid_cellvals in params[1]:
        grid_cells.append (grid_cellvals)

    csr.close ()

    if params[2] != 0: # Database error during cursor fetch
        Globals.oraError = str (params[2])
        return '2'

    return grid_cells

def checkConn ():
    if Globals.db == None: # No connection in place
        retval = -1
    else:
        retval = ora_try ()

    if retval == 0:
        return 0
    elif retval == -1: # Operational error (connection dropped or has not even been made yet)
        retval2 = oraConnect () # Create connection
        if retval2 != 0:
            return "1"
        else:
            return 0
    elif retval == -2: # Database error
        return "2"
    elif retval == -3:
        return "3"

def ora_try ():
    try:
        csr = Globals.db.cursor ()
        csr.execute ('SELECT count (*) FROM DUAL')
        count = csr.fetchone ()[0]  # We are expecting a single row. [0] means first column
        if count != 1:
            csr.close ()
            if Globals.db != None:
                Globals.db.close ()
                Globals.db = None
            Globals.oraError = "Oracle error. Can not even select from DUAL..."
            print (Globals.oraError)
            return -1
    except cx_Oracle.OperationalError as exception:
        Globals.oraError = "Oracle connection error. Code: %d, Message: %s" % (exception.args[0].code, exception.args[0].message)
        Globals.oraError.replace ('\n', ' * ')
        print (Globals.oraError)
        if csr:
            csr.close ()
        if Globals.db != None:
            Globals.db.close ()
        Globals.db = None
        return -1
    except cx_Oracle.DatabaseError as exception:
        Globals.oraError = "Oracle database error. Code: %d, Message: %s" % (exception.args[0].code, exception.args[0].message)
        Globals.oraError.replace ('\n', ' * ')
        print (Globals.oraError)
        if csr:
            csr.close ()
        if Globals.db != None:
            Globals.db.close ()
            Globals.db = None
        return -2
    except Exception as exception:
        if hasattr (exception.args[0], 'code'):
            Globals.oraError = "Oracle error. Code: %d, Message: %s" % (exception.args[0].code, exception.args[0].message)
            Globals.oraError.replace ('\n', ' * ')
        else:
            Globals.oraError = "Non-Oracle error. %s" % exception.args[0]
            Globals.oraError.replace ('\n', ' * ') 
        print (Globals.oraError)
        if csr:
            csr.close ()
        if Globals.db != None:
            Globals.db.close ()
            Globals.db = None
        return -3
    return 0

def oraConnect ():
    csr = None
    try:
        #Globals.db = cx_Oracle.connect ('C23833', 'V1lacsek987!', dsn_tns) # Connect to Oracle
        Globals.db = cx_Oracle.connect (user="python", password="django", dsn=dsn_tns_ng177hz)
        csr = Globals.db.cursor ()
        csr.execute ('SELECT count (*) FROM DUAL')
        count = csr.fetchone ()[0]  # We are expecting a single row. [0] means first column
        if count != 1:
            csr.close ()
            if Globals.db != None:
                Globals.db.close ()
                Globals.db = None
                Globals.oraError = "Oracle query error. Can't even select from DUAL"
                print (Globals.oraError)
                return -1
    except Exception as exception:
        Globals.oraError = "Oracle error. Code: %d, Message: %s" % (exception.args[0].code, exception.args[0].message)
        Globals.oraError.replace ('\n', ' * ')
        print (Globals.oraError)
        if csr:
            csr.close ()
        if Globals.db != None:
            Globals.db.close ()
            Globals.db = None
        return -1
    return 0