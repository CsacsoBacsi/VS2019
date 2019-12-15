from __future__ import absolute_import

from google.cloud import bigquery
from google.cloud import pubsub_v1
import apache_beam as beam
import apache_beam.options.pipeline_options as opt
import apache_beam.transforms.window as window

class MyFn (beam.DoFn):
    def process (self, element):
        columns = ['id1', 'id2', 'val1']
        values =  element.split (b',')
        values [0] = int (values [0])
        values [1] = int (values [1])
        d = dict (zip (columns, values))
        print (d)
        return [d]

def run():

    ''' Create the Publisher '''
    publisher = pubsub_v1.PublisherClient () # Creates a publisher client
    topic_name = 'projects/{project_id}/topics/{topic}'.format(project_id="famous-store-237108",topic="BQTopic")
    topic_path = publisher.topic_path ("famous-store-237108", "BQTopic") # Creates a fully qualified topic path. Same as previous row

    project_path = publisher.project_path ("famous-store-237108") # Creates a fully qualified project path

    found = False # Check if topic exists in project
    for topic in publisher.list_topics (project_path): # topic is a fully qualified topic path
        if topic.name == topic_name:
            found = True
    if not found: # If not found, create it
        publisher.create_topic (topic_name)

    future = publisher.publish (topic_name, b"3,3,Three Three") # Publish a message
    if future._completed: # Check if successful
        print ("Message sent successfully!")

    """Build and run the pipeline."""

    pipeline_options = opt.PipelineOptions()
    pipeline_options.view_as (opt.StandardOptions).streaming = True


    with beam.Pipeline (options=pipeline_options) as p: # Creates a pipeline
    # Read the pubsub topic into a PCollection.
        msg = p | "Read from pubSub" >> beam.io.ReadFromPubSub (topic_path) # Read

        
        lines2 = (p | "Create from in-memory List" >> beam.Create([ # Create
                 'To be, or not to be: that is the question: ',
                 'Whether \'tis nobler in the mind to suffer ',
                 'The slings and arrows of outrageous fortune, ',
                 'Or to take arms against a sea of troubles, ']))

        # PCollection: immutable, elements are of same type, no random access. Can be bounded or stream. Windows are used with timestamps

        # Transforms: ParDo, Combine, composite: combines core transforms
        ''' [Final Output PCollection] = ([Initial Input PCollection] | [First Transform]
             | [Second Transform]
             | [Third Transform]) '''

        # Apply a ParDo to the PCollection "words" to compute lengths for each word.
        # ParDo: “Map” phase of a Map/Shuffle/Reduce-style algorithm
        # Filter, convert, pick part of the data, simple computation
        # You must supply a DoFn class
        rows = msg | "Convert to dict" >> beam.ParDo (MyFn ()) 

        #rows = [{"id1": 3, "id2": 3, "val1": "Three Three"}]
        rows | beam.io.WriteToBigQuery (table='mytable',
                                               dataset="mydataset",
                                               project="famous-store-237108",
                                               schema='id1:INTEGER, id2:INTEGER, val1:STRING',
                                               create_disposition=beam.io.BigQueryDisposition.CREATE_IF_NEEDED,
                                               write_disposition=beam.io.BigQueryDisposition.WRITE_APPEND) # Could be WRITE_TRUNCATE

# Alternative solution using the subscribers callback to write to BigQuery - not using beam/DataFlow
def subscriber_fn (project, subscription_name):
    subscriber = pubsub.SubscriberClient()
    subscription_path = subscriber.subscription_path(project, subscription_name)
       
    def callback(message):
        print('Received message: {}'.format(message))
        write2BQ (message.data)
        message.ack()


    subscription = subscriber.subscribe(subscription_path, callback=callback)
    print('Listening for messages on {}'.format(subscription_path))

    future = subscription.open(callback)
    try:
        future.result()
    except Exception as e:
        print('Listening for messages on {} threw an Exception: {}'.format(subscription_name, e))
        raise

def write2BQ (dataset_id, table_id, message):
    client = bigquery.Client()
    dataset_ref = client.dataset(dataset_id)
    table_ref = dataset_ref.table(table_id)
    table = client.get_table(table_ref)

    errors = client.insert_rows(table, tweets)

    if not errors:
        print('Loaded {} row(s) into {}:{}'.format(len(tweets), dataset_id, table_id))
    else:
        print('Errors:')
        for error in errors:
            print(error)

if __name__ == '__main__':
  run()
