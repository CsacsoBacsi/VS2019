
from pyhive import hive
PORT=10001
conn = hive.Connection (host="localhost", port=PORT, username="maria_dev", auth="NOSASL")

cursor = conn.cursor ()
cursor.execute ("SELECT truckid FROM trucks")
for result in cursor.fetchall ():
    print (result)