import sys
import cx_Oracle
import datetime

# Helper functions
def printf (format, *args):
  sys.stdout.write (format % args) # Like printf. The arguments after % formatted according to format

def printException (exception):
  error, = exception.args # Comma is needed when there is just 1 value
  printf ("Error code = %s\n", error.code)
  printf ("Error message = %s\n", error.message)

# TNS entry
dsn_tns = """(DESCRIPTION =
  (ADDRESS_LIST =
    (ADDRESS = (PROTOCOL = TCP)(HOST = localhost)(PORT = 1521))
  )
  (CONNECT_DATA =
    (SID = PDB2)
  )
)"""

# Alternative connections
dsnStr = cx_Oracle.makedsn ("localhost", "1521", "pdb2")
db = cx_Oracle.connect(user="python", password="python", dsn=dsnStr)
db.close ()

db = cx_Oracle.connect ('python', 'python', 'localhost:1521/PDB2')
db.close ()

# ***
# *** Example 1 - Select 3 columns with cursor.execute. Exception handling ***********************************************************************************************
# ***

printf ("\n*** Example 1 ***\n\n")

# Connect
db = cx_Oracle.connect (user="python", password="python", dsn=dsn_tns)
csr = db.cursor ()

try:
  csr.execute ('SELECT event_id, runner_id, runner_name FROM REGISTRATIONS')
except cx_Oracle.DatabaseError as exception:
  printf ('Failed to select from table REGISTRATIONS\n')
  printException (exception)
  csr.close ()
  db.close ()
  exit (1)

# Process rows
table_values = csr.fetchall()
for row in table_values:
  print (row) # Comes back as a list
  print (row[0], row[1], row[2]) # Columns

# Close cursor and connection
csr.close ()
db.close ()

# ***
# *** Example 2 - Select count (single row/value) with cursor.execute ***********************************************************************************************
# ***

printf ("\n*** Example 2 ***\n\n")

db = cx_Oracle.connect (user="python", password="python", dsn=dsn_tns)
csr = db.cursor ()

csr.execute ('SELECT count (*) FROM REGISTRATIONS')
count = csr.fetchone ()[0]  # We are expecting a single row. [0] means first column
printf ('Count (with fetchone) = %d\n', count)
csr.close ()

csr = db.cursor ()
csr.execute ('SELECT count (*) FROM REGISTRATIONS')
count = csr.fetchall ()[0][0] # Alternativ. [0] means first row, [0] means first column
printf ("Count (with fetchall) = %d\n",count)

csr.close ()
db.close ()

# ***
# *** Example 3 - Select with separated out SQL ***********************************************************************************************
# ***

printf ("\n*** Example 3 ***\n\n")
db = cx_Oracle.connect (user="python", password="python", dsn=dsn_tns)
csr = db.cursor ()

sql = """SELECT event_id, runner_id, runner_name
         FROM   registrations
         WHERE  paid = 'Y'
         ORDER BY dob DESC"""

csr.execute (sql)
result = csr.fetchall () # All results at once in a 2 dimensional array

for row in result:
  printf ("%d;%d;%s\n", row[0], row[1], row[2])

csr.close ()

# Alternativ solution to use fetchall in FOR
printf ("\n")
csr = db.cursor ()
csr.execute (sql)
for event, runner, name in csr.fetchall ():
  printf ("%d;%d;%s\n", event, runner, name)

csr.close ()
db.close ()

# ***
# *** Example 4 - Bind variables ***********************************************************************************************
# ***

printf ("\n*** Example 4 ***\n\n")
db = cx_Oracle.connect (user="python", password="python", dsn=dsn_tns)
csr = db.cursor ()

sql = """SELECT event_id, runner_id, runner_name
         FROM   registrations
         WHERE  paid = :p
         ORDER BY dob DESC"""

csr.execute (sql, p = 'N') # Multiple bind variables possible
result = csr.fetchall () # All results at once in a 2 dimensional array

for row in result:
  printf ("%d;%d;%s\n", row[0], row[1], row[2])

csr.close ()
db.close ()

# ***
# *** Example 5 - Prepare statements ***********************************************************************************************
# ***

printf ("\n*** Example 5 ***\n\n")
db = cx_Oracle.connect (user="python", password="python", dsn=dsn_tns)
csr = db.cursor ()

sql = """SELECT event_id, runner_id, runner_name
         FROM   registrations
         WHERE  paid = :p
         ORDER BY dob DESC"""

csr.prepare (sql) # Prepare or parse the statement
csr.execute (None, p = 'N') # None, because the statement has already been prepared
result = csr.fetchall () # All results at once in a 2 dimensional array

for row in result:
  printf ("%d;%d;%s\n", row[0], row[1], row[2])

csr.close ()

# Alternative
csr = db.cursor ()
csr.prepare (sql)
csr.execute (csr.statement, p = 'N') # Statement is the last prepared statement on the cursor
result = csr.fetchall () # All results at once in a 2 dimensional array

for row in result:
  printf ("%d;%d;%s\n", row[0], row[1], row[2])

csr.close ()
db.close ()

# ***
# *** Example 6 - Insert statements ***********************************************************************************************
# ***

printf ("\n*** Example 6 ***\n\n")
db = cx_Oracle.connect (user="python", password="python", dsn=dsn_tns)
csr = db.cursor ()

sql = "INSERT INTO registrations (event_id, runner_id, runner_name, dob, paid) VALUES (:p_event_id, :p_runner_id, :p_runner_name, :p_dob, :p_paid)"

l_dob = (datetime.date (1974, 9, 11))
csr.execute (sql, p_event_id = 1, p_runner_id = 5, p_runner_name = 'Judy', p_dob = l_dob, p_paid = 'Y')
# csr.execute (sql,{ 'p_event_id':1, 'p_runner_id': 'Judy', 'p_dob': l_dob, 'p_paid': 'Y'}) # A dictionary could have been used

csr.close ()
db.commit () # Commit

# With a prepare statement
csr = db.cursor ()
csr.prepare (sql)
csr.execute (None, p_event_id = 3, p_runner_id = 5, p_runner_name = 'Judy', p_dob = l_dob, p_paid = 'N')

csr.close ()
db.commit () # Commit

db.close ()

# ***
# *** Example 7 - Update statements ***********************************************************************************************
# ***

printf ("\n*** Example 7 ***\n\n")
db = cx_Oracle.connect (user="python", password="python", dsn=dsn_tns)
csr = db.cursor ()

sql = "UPDATE registrations set paid = :p_paid WHERE event_id = :p_event_id"

csr.execute (sql, p_event_id = 1, p_paid = 'Y')
# csr.execute (sql,{ 'p_event_id':1, 'p_paid': 'Y'}) # A dictionary could have been used

csr.close ()
db.commit () # Commit

# With a prepare statement
csr = db.cursor ()
csr.prepare (sql)
csr.execute (None, p_event_id = 2, p_paid = 'N')

csr.close ()
db.commit () # Commit

db.close ()

# ***
# *** Example 8 - Delete statements ***********************************************************************************************
# ***

printf ("\n*** Example 8 ***\n\n")
db = cx_Oracle.connect (user="python", password="python", dsn=dsn_tns)
csr = db.cursor ()

sql = "DELETE FROM registrations WHERE paid = :p_paid and runner_id = :p_runner_id"

csr.execute (sql, p_runner_id = 4, p_paid = 'Y')
# csr.execute (sql,{ 'p_runner_id':1, 'p_paid': 'Y'}) # A dictionary could have been used

csr.close ()
db.commit () # Commit

# With a prepare statement
csr = db.cursor ()
csr.prepare (sql)
csr.execute (None, p_runner_id = 5, p_paid = 'N')

csr.close ()
db.commit () # Commit

db.close ()

# ***
# *** Example 9 - Array Select ***********************************************************************************************
# ***

printf ("\n*** Example 9 ***\n\n")
db = cx_Oracle.connect (user="python", password="python", dsn=dsn_tns)
csr = db.cursor ()

sql = """SELECT event_id, runner_id, runner_name, dob, paid
         FROM   registrations
         WHERE  paid = 'Y' or paid = 'N'
         ORDER BY dob DESC"""

# Set array size to 4
csr.arraysize = 4

csr.execute (sql)

while True:
  rows = csr.fetchmany ()
  if rows == []:
    break ;
  printf ("Fetched %d rows\n", len (rows))
  for event_id, runner_id, runner_name, dob, paid in rows:
     printf (" %d;%d;%s;%s;%s\n", event_id, runner_id, runner_name, dob, paid)

csr.close ()
db.close ()

# ***
# *** Example 10 - Array Insert ***********************************************************************************************
# ***

printf ("\n*** Example 10 ***\n\n")
db = cx_Oracle.connect (user="python", password="python", dsn=dsn_tns)
csr = db.cursor ()

sql = "INSERT INTO registrations (event_id, runner_id, runner_name, dob, paid) VALUES (:p_event_id, :p_runner_id, :p_runner_name, :p_dob, :p_paid)"

csr.prepare (sql)

array=[]
l_dob = (datetime.date (2000, 1, 1))
array.append ((6, 6, 'Dummy', l_dob, 'N'))
array.append ((7, 6, 'Dummy1', l_dob, 'Y'))
array.append ((8, 6, 'Dummy2', l_dob, 'N'))

csr.executemany (None, array) # Execute many this time
# csr.executemany (sql, array)

csr.close ()
db.commit () # Commit

db.close ()

# ***
# *** Example 11 - Calling stored procedures ***********************************************************************************************
# ***

printf ("\n*** Example 11 ***\n\n")
db = cx_Oracle.connect (user="python", password="python", dsn=dsn_tns)
csr = db.cursor ()

sqlrowcnt = csr.var (cx_Oracle.NUMBER)
retval   = csr.var (cx_Oracle.NUMBER)
# retval.setvalue (0, -1) # If it is an IN/OUT parameter. The first param is normally zero in the setvalue function

p_event_id = 9
p_runner_id = 1
p_runner_name = 'Zsurka'
l_dob = (datetime.date (1987, 9, 26))
p_dob = l_dob
p_paid = 'Y'

csr.callproc ('PCK_REGISTRATIONS.InsertOne', (p_event_id, p_runner_id, p_runner_name, p_dob, p_paid, sqlrowcnt, retval))

printf ("SQL row count: %d\n", sqlrowcnt.getvalue ())
printf ("Return value: %d\n", retval.getvalue ())

csr.close ()
db.close ()

# ***
# *** Example 12 - Calling functions ***********************************************************************************************
# ***

printf ("\n*** Example 12 ***\n\n")
db = cx_Oracle.connect (user="python", password="python", dsn=dsn_tns)
csr = db.cursor ()

result = csr.var (cx_Oracle.NUMBER)

p_event_id = 9

csr.callfunc ('PCK_REGISTRATIONS.getRunnersPerEvent', result, [p_event_id])

printf ("SQL row count: %d\n", sqlrowcnt.getvalue ())
printf ("Return value: %d\n", retval.getvalue ())

printf ("Result: %d runners in event %d\n", result.getvalue (), p_event_id)

csr.close ()
db.close ()

# ***
# *** Example 13 - Returning a cursor ***********************************************************************************************
# ***

printf ("\n*** Example 13 ***\n\n")
db = cx_Oracle.connect (user="python", password="python", dsn=dsn_tns)
csr = db.cursor ()

out_csr = csr.var (cx_Oracle.CURSOR)

p_event_id = 9

params = csr.callproc ('PCK_REGISTRATIONS.getAllRunners', (out_csr,)) # Returns all IN and OUT params in params as a list (or tuple)

for runner in params[0]:
  printf ("%d %s\n", runner[0], runner[1])

csr.callproc ('PCK_REGISTRATIONS.restoreRows') # Erase all added rows

csr.close ()
db.close ()


