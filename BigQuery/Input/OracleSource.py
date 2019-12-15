import sys
import cx_Oracle
import datetime

# Constants
DSN_TNS = """(DESCRIPTION =
                 (ADDRESS_LIST =
                     (ADDRESS = (PROTOCOL = TCP)(HOST = localhost)(PORT = 1521))
                 )
                 (CONNECT_DATA =
                     (SID = PDB2)
                 )
             )
         """
# Helper functions
def printf (format, *args):
  sys.stdout.write (format % args) # Like printf. The arguments after % formatted according to format

def printException (exception):
  error, = exception.args # Comma is needed when there is just 1 value
  printf ("Error code = %s\n", error.code)
  printf ("Error message = %s\n", error.message)

# Oracle class
class Oracle:
    """ Oracle connection, cursor, fetch """

    conn = None # Connection object
    oraError = None # Oracle error
    csr = None # Cursor

    @staticmethod
    # Connect to Oracle
    def openConnection ():
        # Alternative connections
        '''dsnStr = cx_Oracle.makedsn ("localhost", "1521", "pdb2")
           conn = cx_Oracle.connect(user="hr", password="hr", dsn=dsnStr)
           conn.close ()

           conn = cx_Oracle.connect ('hr', 'hr', 'localhost:1521/PDB2')
           conn.close ()
        '''

        # Connect
        try:
            Oracle.conn = cx_Oracle.connect (user = "hr", password = "hr", dsn = DSN_TNS)
        except Exception as exception:
            Oracle.oraError = "Oracle error. Code: %d, Message: %s" % (exception.args[0].code, exception.args[0].message)
            Oracle.oraError.replace ('\n', ' * ')
            print (Oracle.oraError)
            Oracle.closeConnection ()
            return -1
        return 0

    @staticmethod    
    # Close cursor/database
    def closeConnection ():
        if Oracle.csr:
            Oracle.csr.close ()
        if Oracle.conn:
            Oracle.conn.close ()

    @staticmethod
    # Define then open cursor
    def openCursor ():
        try:
            Oracle.csr = Oracle.conn.cursor ()
            sql = """SELECT employee_id, first_name, last_name, email, job_id, salary
                     FROM   employees
                     WHERE  salary > 10000
                     ORDER BY salary DESC"""
            Oracle.csr.execute (sql)
        except cx_Oracle.DatabaseError as exception:
            Oracle.oraError = "Oracle database error. Code: %d, Message: %s" % (exception.args[0].code, exception.args[0].message)
            Oracle.oraError.replace ('\n', ' * ')
            print (Oracle.oraError)
            Oracle.closeConnection ()
            return -1
        except Exception as exception:
            if hasattr (exception.args[0], 'code'):
                Oracle.oraError = "Oracle error. Code: %d, Message: %s" % (exception.args[0].code, exception.args[0].message)
                Oracle.oraError.replace ('\n', ' * ')
            else:
                Oracle.oraError = "Non-Oracle error. %s" % exception.args[0]
                Oracle.oraError.replace ('\n', ' * ') 
                print (Oracle.oraError)
            Oracle.closeConnection ()
            return -1
        return 0

    @staticmethod
    # Fetch the result set
    def fetchResult ():

        result = Oracle.csr.fetchall () # All results at once in a 2 dimensional array

        # Loop over the result set
        for row in result:
            # printf ("%d;%s;%s;%s;%s;%d\n", row[0], row[1], row[2], row[3], row[4], row[5])
            pass

        return result

def main ():
    myOra = Oracle ()
    printf ("Connecting to Oracle as HR...\n")
    retval = myOra.openConnection ()
    if retval == 0:
        printf ("Connected to Oracle.\n")
    else:
        printf ("Connection to Oracle failed.\n")
        sys.exit ()
    retval = myOra.openCursor ()
    rows = myOra.fetchResult () # Result is a list of tuples

if __name__ == '__main__':
    main ()