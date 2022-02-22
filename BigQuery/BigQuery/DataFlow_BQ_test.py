# Creates a pipeline that listens to Pub/Sub topic messages streamed from Oracle db and processes them
from __future__ import absolute_import

from google.cloud import bigquery
from google.cloud import pubsub_v1
import apache_beam as beam
import apache_beam.options.pipeline_options as opt
import apache_beam.transforms.window as window # Not used

# Constants
PROJECT    = "organic-palace-306416"
TOPIC      = "BQTopic"
SUBSCRIPTION = "BQTopic-sub"
DATASET    = "test"
TABLE_NAME = "Employee"

# Transformations
class createDict (beam.DoFn):
    def process (self, element):
        columns = ['EMPLOYEE_ID', 'FIRST_NAME', 'LAST_NAME', 'EMAIL', 'JOB_ID', 'SALARY']
        values = element.split (b',') # Convert string to list
        col_val = dict (zip (columns, values)) # Merge the two lists and generate a dictionary
        print (col_val)
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

#data = 1, 'Greg', 'Nichols', 'Greg@tx.com',1000, 34000

# Program entry point
def run ():
    # Get the Pub/Sub topic object
    topic_name = 'projects/{project_id}/topics/{topic}'.format(project_id = PROJECT, topic = TOPIC)
    subscription_name = 'projects/{project_id}/subscriptions/{subscription}'.format (project_id = PROJECT, subscription = SUBSCRIPTION)
    publisher = pubsub_v1.PublisherClient () # Creates a publisher client
    topic_path = publisher.topic_path (PROJECT, TOPIC) # Creates a fully qualified topic path. Same as previous row

    for i in range (1, 1000001, 1):
        msg = f"{i}, 'Csacsi', 'Bacsi', 'csacso@hotmail.com', 111, 50000"
        msg = bytes (msg, 'utf-8')
        publisher.publish (topic_name, msg)

    # Build and run the pipeline
    pipeline_options = opt.PipelineOptions ()
    pipeline_options.view_as (opt.StandardOptions).streaming = True # Set options first
    google_cloud_options = pipeline_options.view_as (opt.GoogleCloudOptions)
    google_cloud_options.project = PROJECT
    google_cloud_options.job_name = 'myjobx2'
    google_cloud_options.staging_location = 'gs://csacsi/staging'
    google_cloud_options.temp_location = 'gs://csacsi/temp'
    google_cloud_options.region = 'europe-west2'
    workerOptions = pipeline_options.view_as (opt.WorkerOptions)
    workerOptions.num_workers = 3
    pipeline_options.view_as (opt.StandardOptions).runner = 'DataflowRunner'

    with beam.Pipeline (options=pipeline_options) as pcoll: # Creates a pipeline

        messages = pcoll | "Read from pubSub" >> beam.io.ReadFromPubSub (subscription=subscription_name, id_label='message_id') # Read the pubsub topic into a PCollection (creates the pipeline)

        # PCollection: immutable, elements are of same type, no random access. Can be bounded or stream. Windows are used with timestamps
        # Transforms: ParDo, Combine, composite: combines core transforms
        ''' [Final Output PCollection] = ([Initial Input PCollection] | [First Transform] | [Second Transform] | [Third Transform]) '''

        dict_rows = messages | "Convert to dict" >> beam.ParDo (createDict ())

        rows_to_insert = dict_rows | "Up salaries by 10%" >> beam.ParDo (upSalaries10pct ())

        #byte_stream = rows | "Convert to byte" >> beam.ParDo (convertToByte ())

        rows_to_insert | beam.io.WriteToBigQuery (table   = TABLE_NAME,
                                                  dataset = DATASET,
                                                  project = PROJECT,
                                                  schema  = ("EMPLOYEE_ID:INTEGER,"
                                                             "FIRST_NAME:STRING,"
                                                             "LAST_NAME:STRING,"
                                                             "EMAIL:STRING,"
                                                             "JOB_ID:INTEGER," 
                                                             "SALARY:INTEGER"),
                                                  create_disposition=beam.io.BigQueryDisposition.CREATE_IF_NEEDED, # Creates table if does not exist CREATE_IF_NEEDED
                                                  write_disposition=beam.io.BigQueryDisposition.WRITE_APPEND, # Could be WRITE_TRUNCATE
                                                  ignore_insert_ids = True)

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


