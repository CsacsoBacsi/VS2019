# Standalone script to depict BigQuery features
from __future__ import absolute_import
from google.cloud import bigquery

client = bigquery.Client () # Instantiate BigQuery client

# *** Dataset ***
dataset_id = "{}.mydataset".format (client.project)
dataset = bigquery.Dataset (dataset_id)

dataset.location = "US"
try:
    dataset = client.create_dataset (dataset)
    print ("Created dataset {}.{}".format(client.project, dataset.dataset_id))
except:
    print ("Dataset already exists!")

# List existing datasets
datasets = list (client.list_datasets())
project = client.project

if datasets:
    print ("Datasets in project {}:".format(project))
    for dataset in datasets:
        print ("\t{}".format (dataset.dataset_id))
else:
    print("{} project does not contain any datasets.".format(project))

# Properties of dataset
dataset = client.get_dataset(dataset_id)

print ("Friendly name: {}".format(dataset.friendly_name))
print ("Labels:")
labels = dataset.labels
if labels:
    for label, value in labels.items ():
        print("\t{}: {}".format(label, value))
else:
    print("\tDataset has no labels defined.")

# Update a property
dataset.friendly_name = "Updated friendly name."
dataset = client.update_dataset (dataset, ["friendly_name"])
dataset.description = "Test dataset"
dataset = client.update_dataset (dataset, ["description"])

# Delete dataset
#client.delete_dataset(dataset_id, delete_contents=True, not_found_ok=True)
#print ("Deleted dataset: %s." % (dataset_id))

# View tables in dataset
print ("Tables:")
tables = list(client.list_tables(dataset))
if tables:
    for table in tables:
        print("\t{}".format(table.table_id))
else:
    print("\tThis dataset does not contain any tables.")

# *** Create table ***
schema = [
    bigquery.SchemaField("id1", "INTEGER", mode="REQUIRED"),
    bigquery.SchemaField("id2", "INTEGER", mode="REQUIRED"),
    bigquery.SchemaField("val1", "STRING", mode="REQUIRED"),
]

table_id = dataset_id + ".mytable"

table = bigquery.Table (table_id, schema=schema)
try:
    table = client.create_table(table)
    print(    "Created table {}.{}.{}".format(table.project, table.dataset_id, table.table_id))
except:
    print ("Table already exists!")

# Metadata of the table
table = client.get_table(table_id)

print("Got table '{}.{}.{}'.".format(table.project, table.dataset_id, table.table_id))

print("Table schema: {}".format(table.schema))
print("Table description: {}".format(table.description))
print("Table has {} rows".format(table.num_rows))

'''
You can query the INFORMATION_SCHEMA.TABLES and INFORMATION_SCHEMA.TABLE_OPTIONS views to retrieve metadata about tables 
and views in a project. You can also query the INFORMATION_SCHEMA.COLUMNS and INFORMATION_SCHEMA.COLUMN_FIELD_PATHS views 
to retrieve metadata about the columns (fields) in a table.
'''
# Insert into table
table = client.get_table (table_id)
table_name = "mydataset.mytable"

rows_to_insert = [(1,1,"One, One"), (1,2,"One, Two"), (2,1,"Two, One"), (2,2,"Two, Two")]

#errors = client.insert_rows (table, rows_to_insert) # This is stream-insert

for row in rows_to_insert:
    str_row = ''
    for items in row:
        if isinstance (items, str):
            str_row = str_row + '"' + str (items) + '",'
        else:
            str_row = str_row + str (items) + ','
    str_row = str_row [0:len (str_row) - 1]
    QUERY = ("INSERT INTO `" + table_name + "`" +
             "(id1, id2, val1)"
             "values (" + str_row + ")")
    query_job = client.query (QUERY, location = "US")

# *** Query ***
QUERY = ("SELECT id1, id2, val1 FROM `" + table_name + "`" +
    'WHERE id1=1 '
    "LIMIT 100")
query_job = client.query (QUERY, location="US")
rows = query_job.result ()

for row in rows:
    print(row.id1)
    print (row[0])

# Update table data
QUERY = ("UPDATE `" + table_name + "`" +
    'SET val1="Hi!"'
    "WHERE id1 = 2")
query_job = client.query(QUERY, location="US")

# Delete table
#client.delete_table (table_id, not_found_ok=True)
#print("Deleted table '{}'.".format(table_id))