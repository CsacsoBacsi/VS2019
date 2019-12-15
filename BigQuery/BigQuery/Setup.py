# Standalone script that sets up dataset, target table and Pub/Sub topic to "stream" Oracle data into BigQuery 
from __future__ import absolute_import
from google.cloud import bigquery
from google.cloud import pubsub_v1
import sys

# Constants
PROJECT    = "famous-store-237108"
DATASET    = "HR_dataset"
TABLE_NAME = "Employee"
TOPIC      = "BQTopic"
TOPIC_NAME = 'projects/{project_id}/topics/{topic}'.format (project_id = PROJECT, topic = TOPIC)

client = bigquery.Client () # Instantiates BigQuery client

# *** Create Dataset ***
dataset_id = ("{}." + DATASET).format (client.project)
dataset = bigquery.Dataset (dataset_id)

dataset.location = "europe-west2" # London
dataset.friendly_name = "Human Resources dataset"
dataset.description = "Oracle HR dataset"

# Get list of existing datasets
datasets = list (client.list_datasets ())
project = client.project

if datasets: # Dataset(s) exist(s)
    found = False
    print ("Datasets in project {}:".format(project))
    for this_dataset in datasets: # Loop over existing datasets
        print ("{}".format (this_dataset.dataset_id))
        if this_dataset.dataset_id == DATASET: # Check if the one to be created exists or not
            found = True
    if not found:
        try: # Dataset does not exist yet so create it
            dataset = client.create_dataset (dataset)
            print ("Created dataset {}.{}".format(client.project, dataset.dataset_id))
        except:
            print ("Dataset could not be created!")
            sys.exit () # Terminate program
else: # No datasets in project
    print("{} project does not contain any datasets.".format (project))

# View tables in dataset
print ("Tables:")
tables = list (client.list_tables (dataset))
if tables:
    for table in tables:
        print("{}".format (table.table_id))
else:
    print("This dataset does not contain any tables.")

# *** Create table ***
SCHEMA = [
    bigquery.SchemaField ("EMPLOYEE_ID", "INTEGER", mode="REQUIRED"),
    bigquery.SchemaField ("FIRST_NAME", "STRING", mode="REQUIRED"),
    bigquery.SchemaField ("LAST_NAME", "STRING", mode="REQUIRED"),
    bigquery.SchemaField ("EMAIL", "STRING", mode="REQUIRED"),
    bigquery.SchemaField ("JOB_ID", "STRING", mode="REQUIRED"),
    bigquery.SchemaField ("SALARY", "INTEGER", mode="REQUIRED"),
]

table_id = dataset_id + "." + TABLE_NAME

table = bigquery.Table (table_id, schema = SCHEMA)
try:
    table = client.create_table (table)
    print ("Created table {}.{}.{}".format (table.project, table.dataset_id, table.table_id))
except:
    print ("Table already exists!")

# Metadata of the table
table = client.get_table (table_id)

print("Got table '{}.{}.{}'.".format (table.project, table.dataset_id, table.table_id))

print("Table schema: {}".format(table.schema))
print("Table description: {}".format (table.description))
print("Table has {} rows".format (table.num_rows))

'''
You can query the INFORMATION_SCHEMA.TABLES and INFORMATION_SCHEMA.TABLE_OPTIONS views to retrieve metadata about tables 
and views in a project. You can also query the INFORMATION_SCHEMA.COLUMNS and INFORMATION_SCHEMA.COLUMN_FIELD_PATHS views 
to retrieve metadata about the columns (fields) in a table.
'''

# *** Create Pub/Sub topic (BQTopic) ***
client = pubsub_v1.PublisherClient () # Creates a publisher client

topic_path = client.topic_path (PROJECT, TOPIC) # Creates a fully qualified topic path. Same as previous row
project_path = client.project_path (PROJECT) # Creates a fully qualified project path

found = False # Check if topic exists in project
for topic in client.list_topics (project_path): # topic is a fully qualified topic path
    if topic.name == TOPIC_NAME:
        found = True

if not found: # If not found, create it
    client.create_topic (TOPIC_NAME)
    print ("Pub/Sub topic {} has been created.".format (TOPIC_NAME))
else:
    print ("Pub/Sub topic {} already exists.".format (TOPIC_NAME))
