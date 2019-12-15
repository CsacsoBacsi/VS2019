# Creates a pipeline that listens to Pub/Sub topic messages streamed from Oracle db and processes them
from __future__ import absolute_import

from google.cloud import bigquery
from google.cloud import pubsub_v1
import apache_beam as beam
import apache_beam.options.pipeline_options as opt
import apache_beam.transforms.window as window # Not used
import time
import sys
import threading
import os

# Constants
PROJECT    = "famous-store-237108"
TOPIC      = "Topic1M"
SUBSCRIPTION = "Subs1M"
DATASET    = "HR_dataset"
TABLE_NAME = "Messages"
ofile = None

publisher = pubsub_v1.PublisherClient () # Creates a publisher client

# Transformations
class createDict (beam.DoFn):
    def process (self, element):
        columns = ['MESSAGE']
        values = element.split (b',') # Convert string to list
        col_val = dict (zip (columns, values)) # Merge the two lists and generate a dictionary
        print (col_val)
        return [col_val]

class convertToByte (beam.DoFn):
    def process (self, element):
        b_element = bytes (element, 'utf-8') # When streaming, data must be a byte stream
        return [b_element]

class writeToFile (beam.DoFn):
    def process (self, element):
        global ofile
        ofile.write (str (element))
        ofile.flush ()
        if str (element) == "b'END'":
            ofile.close ()

class myThread (threading.Thread):
    def __init__(self, threadID, name):
        threading.Thread.__init__(self) # Init the super class
        self.threadID = threadID
        self.name = name
      
    def run (self): # Upon thread.start this function executes unless target = func and args = (1,2) specified. Func with args must be defined first
        print ("Starting thread " + self.name)
        print ("Waiting 3 secs...")
        time.sleep (3)
        publisher = pubsub_v1.PublisherClient () # Creates a publisher client
        topic_name = 'projects/{project_id}/topics/{topic}'.format(project_id = PROJECT, topic = TOPIC)

        print ("Publishing messages...")
        for i in range (1, 1001, 1):
            publisher.publish (topic_name, bytes ("Message #{} - ".format (str (i)), 'utf-8'))
        publisher.publish (topic_name, bytes ("END", 'utf-8')) # So that the file can be closed
        print ("Done publishing messages!")
        #print ("Creating/opening file for append...")
        #completeName = os.path.join ("D:/", "output.txt")
        #global ofile
        #ofile = open (completeName, "a+")
        print ("Sleeping for another 10 secs...")
        time.sleep (10)
        print ("Publishing messages again...")
        for i in range (1, 1001, 1):
            publisher.publish (topic_name, bytes ("Message #{} - ".format (str (i)), 'utf-8'))
        print ("Exiting thread " + self.name)

def pubMsg ():
    thread1 = myThread (1, "Thread-1")
    thread1.start ()

# Program entry point
def runDF ():
    # Get the Pub/Sub topic object
    topic_path = publisher.topic_path (PROJECT, TOPIC) # Creates a fully qualified topic path. Same as previous row

    # Build and run the pipeline
    pipeline_options = opt.PipelineOptions ()
    pipeline_options.view_as (opt.StandardOptions).streaming = True # Set options first

    google_cloud_options = pipeline_options.view_as (opt.GoogleCloudOptions)
    google_cloud_options.project = PROJECT
    google_cloud_options.job_name = 'myjobx'
    google_cloud_options.staging_location = 'gs://csacsi/staging'
    google_cloud_options.temp_location = 'gs://csacsi/temp'
    #google_cloud_options.region = 'europe-west4'
    pipeline_options.view_as (opt.StandardOptions).runner = 'DirectRunner'

    with beam.Pipeline (options=pipeline_options) as pcoll: # Creates a pipeline

        messages = pcoll | "Read from PubSub" >> beam.io.ReadFromPubSub (topic_path) # Read the pubsub topic into a PCollection (creates the pipeline)
        messages | "Write messages to file" >> beam.ParDo (writeToFile ())

        #dict_rows = messages | "Convert to dict" >> beam.ParDo (createDict ())
        #dict_rows | beam.io.WriteToBigQuery (table   = TABLE_NAME,
        #                                     dataset = DATASET,
        #                                     project = PROJECT,
        #                                     schema  = ("MESSAGE:STRING"),
        #                                     create_disposition=beam.io.BigQueryDisposition.CREATE_IF_NEEDED, # Creates table if does not exist CREATE_IF_NEEDED
        #                                     write_disposition=beam.io.BigQueryDisposition.WRITE_APPEND) # Could be WRITE_TRUNCATE

        #byte_stream = rows | "Convert to byte" >> beam.ParDo (convertToByte ())

# **************************************************** End of code ********************************************************

# Alternative solution using the subscribers callback to write to BigQuery - not using beam/DataFlow
def getMsg ():
    subscriber = pubsub_v1.SubscriberClient ()
    subscription_path = subscriber.subscription_path (PROJECT, SUBSCRIPTION)

    print ("Creating/opening file2 for append...")
    completeName = os.path.join ("D:/", "output2.txt")
    global ofile
    ofile = open (completeName, "a+")
       
    def callback (message): # When a message is received it is processed and acknowledged here 
        print('Received message: {}'.format (message))
        writeToFile2 (message.data)
        message.ack ()

    future = subscriber.subscribe (subscription_path, callback=callback)
    print ('Listening for messages on {}'.format (subscription_path))

    #future = subscription.open (callback) # Program blocks here and waits for published messages
    try:
        future.result ()
    except Exception as e:
        print('Listening for messages on {} threw an Exception: {}'.format(subscription_name, e))
        raise

# Write to File
def writeToFile2 (line):
    global ofile
    ofile.write (str (line))
    ofile.flush ()
    #if str (line) == "b'END'":
    #    ofile.close ()
    
# Starts here if executed as script
if __name__ == '__main__':
    pubMsg () # Publish messages to a topic
    getMsg () # Retrieve messages
    #runDF () # Run DataFlow and process the previously generated messages

