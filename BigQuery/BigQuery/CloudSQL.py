import os
import MySQLdb

INSTANCE_NAME = 'famous-store-237108:europe-west1:csql1 '

db = MySQLdb.connect (host='127.0.0.1', port=3306, db='mydb', user='root', password='fat1ma72')

cursor = db.cursor()
cursor.execute('select table_schema, table_name, table_type from information_schema.tables')

for row in cursor.fetchall():
    print ("Table schema: " + str(row[0]) + " Table name: " + str(row[1]) + " Table type: " + str(row[2]) + "\n")
db.close ()
