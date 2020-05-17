# --------------------------------------------------------------------

import os

# --------------------------------------------------------------------

# Oracle db
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
   )""" # Triple " allows multine line string here. Also, nothing needs to be escaped within them

#db = cx_Oracle.connect ('C23833', 'V1lacsek123!', 'aepw04-shwdscan.e-ssi.net:1521/aepw04_clt.world') # Connect method 1
db = cx_Oracle.connect ('C23833', 'V1lacsek123!', dsn_tns) # Connect method 2

csr = db.cursor ()
csr.execute ('SELECT * FROM CSABA_SRC')
for row in csr:
  print (row) # Comes back as a list
  print (row[0]) # First column

csr.close ()
db.close ()

# --------------------------------------------------------------------

start = time.time ()
db2 = cx_Oracle.connect ('C23833', 'V1lacsek123!', dsn_tns) # Connect method 2
csr2 = db2.cursor ()
tbl_name_len = 10
csr2.arraysize = 10 # Allocate memory for 10 rows fetched at a time. Batches of 10 rows will be returned
csr2.prepare ("select * from all_tables where owner = 'C23833' and length (table_name) > :len")
csr2.execute (None, {'len': tbl_name_len}) # Bind variable. must be a dictionary object

res = csr2.fetchall()
for row in res:
  print (row[1])

csr2.close ()
db2.close ()

elapsed = (time.time() - start)
print ("Elapsed:", elapsed, "seconds")

# --------------------------------------------------------------------

os.system ("pause")
