# Creates a pipeline that listens to Pub/Sub topic messages streamed from ORacle db and processes them
from __future__ import absolute_import

from google.cloud import bigquery
from google.cloud import pubsub_v1
import apache_beam as beam
import apache_beam.options.pipeline_options as opt
import apache_beam.transforms.window as window # Not used

# Constants
PROJECT        = "famous-store-237108"
TOPIC          = "BQTopic"
DATASET        = "HR_dataset"
TABLE_NAME_SRC = "Employee"
TABLE_NAME_TRG = "Employee2"

#client = bigquery.Client () # Instantiate BigQuery client

# Transformations
class createDict (beam.DoFn):
    def process (self, element):
        columns = ['EMPLOYEE_ID', 'FIRST_NAME', 'LAST_NAME', 'EMAIL', 'JOB_ID', 'SALARY']
        str_row = ','.join (str(e) for e in element)
        values = str_row.split (',') # Convert string to list
        col_val = dict (zip (columns, values)) # Merge the two lists and generate a dictionary
        #print (col_val)
        return [col_val]

class upSalaries10pct (beam.DoFn): # Salary rise
    def process (self, element):
        salary = float (element ['SALARY'])
        salary = salary + salary * 0.1
        element ['SALARY'] = salary

        return [element]

class convertToByte (beam.DoFn):
    def process (self, element):
        b_element = bytes (element, 'utf-8') # When streaming, data must be a byte stream
        return [b_element]

class SQLSelect (beam.DoFn):
    def start_bundle (self):
        self.BQclient = bigquery.Client ()

    def process (self, element):
        table_name_src = "`famous-store-237108.HR_dataset.Employee`"
        QUERY = ("SELECT EMPLOYEE_ID, FIRST_NAME, LAST_NAME, EMAIL, JOB_ID, SALARY FROM " + table_name_src + " WHERE 1 = 1 LIMIT 1000")
        query_job = self.BQclient.query (QUERY, location="europe-west2")
        rows = query_job.result ()

        for row in rows:
            #print (row)
            yield row

class SQLInsert (beam.DoFn):
    def start_bundle (self):
            self.BQclient = bigquery.Client ()

    def process (self, element):
        table_name_src = "`famous-store-237108.HR_dataset.Employee`"
        table_name_trg = "`famous-store-237108.HR_dataset.Employee2`"
        QUERY = ("INSERT INTO " + table_name_trg + "(EMPLOYEE_ID, FIRST_NAME) SELECT EMPLOYEE_ID, FIRST_NAME FROM " + table_name_src + " WHERE 1 = 1 LIMIT 1000")
        query_job = self.BQclient.query (QUERY, location="europe-west2")
        # rows = query_job.result ()

# Program entry point
def run ():
    # Get the Pub/Sub topic object
    publisher = pubsub_v1.PublisherClient () # Creates a publisher client
    topic_name = 'projects/{project_id}/topics/{topic}'.format(project_id = PROJECT, topic = TOPIC)
    topic_path = publisher.topic_path (PROJECT, TOPIC) # Creates a fully qualified topic path. Same as previous row

    # Build and run the pipeline
    pipeline_options = opt.PipelineOptions ()
    pipeline_options.view_as (opt.StandardOptions).streaming = False # Set options first
    option_list = pipeline_options.get_all_options ()
    pipeline_options.view_as (opt.SetupOptions).save_main_session = True
    google_cloud_options = pipeline_options.view_as (opt.GoogleCloudOptions)
    google_cloud_options.project = PROJECT
    google_cloud_options.job_name = 'myjob3'
    google_cloud_options.staging_location = 'gs://csacsi/staging'
    google_cloud_options.temp_location = 'gs://csacsi/temp'
    google_cloud_options.region = 'europe-west4'
    pipeline_options.view_as (opt.StandardOptions).runner = 'DataflowRunner'
#    pipeline_options.view_as (opt.StandardOptions).runner = 'DirectRunner'

    # INSERT INTO SELECT * FROM pattern pipeline
#    with beam.Pipeline (options=pipeline_options) as pcoll: # Creates a pipeline

#       rows = pcoll | "Read dummy" >> beam.Create (['Anything']) # Read something dummy (creates the pipeline)

#       byte_stream = rows | "Execute SQL Insert" >> beam.ParDo (SQLInsert ())

    # SELECT rows from table/view - create generator, convert to dictionary, insert into BQ pattern

    with beam.Pipeline (options=pipeline_options) as pcoll: # Creates a pipeline

        dummy = pcoll | "Read dummy" >> beam.Create (['Anything']) # Read something dummy (creates the pipeline)

        rows = dummy | "Execute SQL Select" >> beam.ParDo (SQLSelect ())

        dict_rows = rows | "Convert to dict" >> beam.ParDo (createDict ())
               
        dict_rows | beam.io.WriteToBigQuery (table   = TABLE_NAME_TRG,
                                             dataset = DATASET,
                                             project = PROJECT,
                                             schema  = ("EMPLOYEE_ID:INTEGER,"
                                                        "FIRST_NAME:STRING,"
                                                        "LAST_NAME:STRING,"
                                                        "EMAIL:STRING,"
                                                        "JOB_ID:STRING," 
                                                        "SALARY:INTEGER"),
                                             create_disposition=beam.io.BigQueryDisposition.CREATE_IF_NEEDED, # Creates table if does not exist CREATE_IF_NEEDED
                                             write_disposition=beam.io.BigQueryDisposition.WRITE_APPEND) # Could be WRITE_TRUNCATE  
        
# **************************************************** End of code ********************************************************


# Alternative solution using the subscribers callback to write to BigQuery - not using beam/DataFlow
def subscriber_fn (project, subscription_name):
    subscriber = pubsub.SubscriberClient ()
    subscription_path = subscriber.subscription_path(project, subscription_name)
       
    def callback(message): # When a message is received it is processed and acknowledged here 
        print('Received message: {}'.format(message))
        write2BQ (message.data)
        message.ack ()


    subscription = subscriber.subscribe (subscription_path, callback=callback)
    print('Listening for messages on {}'.format(subscription_path))

    future = subscription.open (callback) # Program blocks shere and waits for published messages
    try:
        future.result()
    except Exception as e:
        print('Listening for messages on {} threw an Exception: {}'.format(subscription_name, e))
        raise

# Write to BigQuery
def write2BQ (dataset_id, table_id, message):
    client = bigquery.Client () # Instantiate BigQuery client

    # Get dataset details
    dataset_ref = client.dataset (dataset_id)
    table_ref = dataset_ref.table(table_id)
    table = client.get_table(table_ref)

    errors = client.insert_rows (table, message) # Stream writing

    if not errors:
        print('Messages loaded into {}:{}'.format (dataset_id, table_id))
    else:
        print('Errors:')
        for error in errors:
            print(error)

# Starts here if executed as script
if __name__ == '__main__':
  run ()
