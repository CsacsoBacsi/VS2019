import time
import sys
from google.cloud import bigquery
import apache_beam as beam
import apache_beam.options.pipeline_options as opt
import apache_beam.transforms.window as window # Not used
import cx_Oracle

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
PROJECT    = "famous-store-237108"
DATASET    = "HR_dataset"
TABLE_NAME = "Departments"

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
            sql = """SELECT department_id, department_name, manager_id, location_id
                     FROM   departments
                     WHERE  manager_id is not null
                     ORDER BY department_id"""
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

# Transformations
class createDict (beam.DoFn): # DoFn - lowest level transformation. Total user control
    def process (self, element):
        columns = ['DEPARTMENT_ID', 'DEPARTMENT_NAME', 'MANAGER_ID', 'LOCATION_ID']
        col_val = dict (zip (columns, element)) # Merge the two lists and generate a dictionary
        print (col_val)
        return [col_val]

# Program entry point
def main ():
    # Instantiate class
    myOra = Oracle ()

    # Connect
    printf ("Connecting to Oracle as HR...\n")
    retval = myOra.openConnection ()
    if retval == 0:
        printf ("Connected to Oracle.\n")
    else:
        printf ("Connection to Oracle failed.\n")
        sys.exit ()

    # Open cursor
    retval = myOra.openCursor ()

    # Fetch rows
    rows = myOra.fetchResult () # Result is a list of tuples

    schema = [ # This could be generated from Oracle metadata (ALL_TAB_COLS system view)
        bigquery.SchemaField ("DEPARTMENT_ID", "INTEGER", mode="REQUIRED"),
        bigquery.SchemaField ("DEPARTMENT_NAME", "STRING", mode="REQUIRED"),
        bigquery.SchemaField ("MANAGER_ID", "INTEGER", mode="REQUIRED"),
        bigquery.SchemaField ("LOCATION_ID", "INTEGER", mode="REQUIRED")
    ]

    # Build and run the pipeline
    pipeline_options = opt.PipelineOptions () # This is deprecated, not future proof. Replacement TBA
    pipeline_options.view_as (opt.StandardOptions).streaming = True # Set options first

    with beam.Pipeline (options = pipeline_options) as pcoll: # Creates a pipeline, PCollection instance

        rows = pcoll | "Create from department resultset" >> beam.Create (rows) # Read in-memory row tuples into a PCollection (creates the pipeline)

        # PCollection: immutable, elements are of same type, no random access. Can be bounded or stream. Windows are used with timestamps
        # Transforms: ParDo, Combine, composite: combines core transforms
        ''' [Final Output PCollection] = ([Initial Input PCollection] | [First Transform] | [Second Transform] | [Third Transform]) '''

        dict_rows = rows | "Convert to dictionary" >> beam.ParDo (createDict ()) # Convert tuples returned by Oracle into dictionary needed for BigQuery

        dict_rows | beam.io.WriteToBigQuery (table   = TABLE_NAME,
                                             dataset = DATASET,
                                             project = PROJECT,
                                             schema  = ("DEPARTMENT_ID:INTEGER,"
                                                        "DEPARTMENT_NAME:STRING,"
                                                        "MANAGER_ID:INTEGER,"
                                                        "LOCATION_ID:INTEGER"), # schema variable (list) could be used
                                             create_disposition=beam.io.BigQueryDisposition.CREATE_IF_NEEDED, # Creates table if does not exist
                                             write_disposition=beam.io.BigQueryDisposition.WRITE_APPEND) # Could be WRITE_TRUNCATE

# Entry point if run as script
if __name__ == '__main__':
    main ()
