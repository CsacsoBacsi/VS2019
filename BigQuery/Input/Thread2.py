import time
import sys
#from google.cloud import bigquery
import apache_beam as beam
import apache_beam.options.pipeline_options as opt
#import apache_beam.transforms.window as window # Not used
from apache_beam.io.gcp.internal.clients import bigquery
from apache_beam.io.gcp.bigquery import BigQueryDisposition
import threading

# Constants
PROJECT      = "famous-store-237108"
DATASET_UDM  = "UDM"
DATASET_CONS = "Consumption"

# Helper functions
def printf (format, *args):
  sys.stdout.write (format % args) # Like printf. The arguments after % formatted according to format

def printException (exception):
  error, = exception.args # Comma is needed when there is just 1 value
  printf ("Error code = %s\n", error.code)
  printf ("Error message = %s\n", error.message)

# Transformations
class createDict (beam.DoFn): # DoFn - lowest level transformation. Total user control
    def process (self, element):
        columns = ['DEPARTMENT_ID', 'DEPARTMENT_NAME', 'MANAGER_ID', 'LOCATION_ID']
        col_val = dict (zip (columns, element)) # Merge the two lists and generate a dictionary
        print (col_val)
        return [col_val]

class id2key (beam.DoFn):
    def process (self, element):
        f = 2
        g = f
        return element

def populate_country_dim ():
    # UDM table
    UDM_table_spec_location = bigquery.TableReference (projectId = PROJECT, datasetId = DATASET_UDM, tableId = 'location')

    # Consumption table
    CONS_table_spec_country_dim = bigquery.TableReference (projectId = PROJECT, datasetId = DATASET_CONS, tableId = 'country_dim')

    country_schema =  ({'fields': [{'name': "LOCATION_KEY", 'type': 'INTEGER', 'mode': 'REQUIRED'},
                                   {'name': "CTRY_ISO2_CDE", 'type': 'STRING', 'mode': 'REQUIRED'},
                                   {'name': "CTRY_ISO3_CDE", 'type': "STRING", 'mode': "REQUIRED"},
                                   {'name': "CTRY_NAME", 'type': "STRING", 'mode': "REQUIRED"},
                                   {'name': "REGION_NAME", 'type': "STRING", 'mode': "REQUIRED"},
                                   {'name': "CPTL_CITY_NAME", 'type': "STRING", 'mode': "REQUIRED"},
                                   {'name': "DEL_REC_IND", 'type': "BOOLEAN", 'mode': "REQUIRED"},
                                   {'name': "ACTV_REC_IND", 'type': "BOOLEAN", 'mode': "REQUIRED"},
                                   {'name': "REC_CREAT_DT_TM", 'type': "TIMESTAMP", 'mode': "REQUIRED"},
                                   {'name': "REC_UPDT_DT_TM", 'type': "TIMESTAMP", 'mode': "NULLABLE"}]
                      })
    
    location_query = 'SELECT LOCATION_ID as LOCATION_KEY, CTRY_ISO2_CDE, CTRY_ISO3_CDE, CTRY_NAME, REGION_NAME, CPTL_CITY_NAME, DEL_REC_IND, '\
                     'ACTV_REC_IND, REC_CREAT_DT_TM, REC_UPDT_DT_TM '\
                     'FROM [famous-store-237108:UDM.location]'
    # Build and run the pipeline
    pipeline_options = opt.PipelineOptions () # This is deprecated, not future proof. Replacement TBA
    pipeline_options.view_as (opt.StandardOptions).streaming = False # Set options first
    google_cloud_options = pipeline_options.view_as (opt.GoogleCloudOptions)
    google_cloud_options.project = PROJECT
    google_cloud_options.job_name = 'loadcountryno'
    google_cloud_options.staging_location = 'gs://csacsi/staging'
    google_cloud_options.temp_location = 'gs://csacsi/temp'
    google_cloud_options.region = 'europe-west1'

    with beam.Pipeline (options = pipeline_options) as pcoll: # Creates a pipeline, PCollection instance

        #rows = pcoll | "Read from UDM.location" >> beam.io.Read (beam.io.BigQuerySource (UDM_table_spec_location)) # Read from UDM.location
        rows = pcoll | "Read from UDM.location" >> beam.io.Read (beam.io.BigQuerySource (query = location_query)) # Read from UDM.location

        ''' [Final Output PCollection] = ([Initial Input PCollection] | [First Transform] | [Second Transform] | [Third Transform]) '''

        #dict_rows = rows | "Convert to dictionary" >> beam.ParDo (createDict ()) # Convert tuples returned by Oracle into dictionary needed for BigQuery

        #rows = rows | beam.ParDo (id2key ())

        rows | "Write to Consumption.Country_dim" >> beam.io.WriteToBigQuery (CONS_table_spec_country_dim,
                                             schema  = country_schema, # schema variable (list) could be used
                                             create_disposition=BigQueryDisposition.CREATE_NEVER,
                                             write_disposition=BigQueryDisposition.WRITE_TRUNCATE)

def populate_currency_dim ():
    # UDM table
    UDM_table_spec_currency = bigquery.TableReference (projectId = PROJECT, datasetId = DATASET_UDM, tableId = 'currency')

    # Consumption tables
    CONS_table_spec_currency_dim = bigquery.TableReference (projectId = PROJECT, datasetId = DATASET_CONS, tableId = 'currency_dim')

    currency_schema =  ({'fields': [{'name': "CURRENCY_KEY", 'type': 'INTEGER', 'mode': 'REQUIRED'},
                                    {'name': "CRNCY_CDE", 'type': 'STRING', 'mode': 'REQUIRED'},
                                    {'name': "CRNCY_NAME", 'type': "STRING", 'mode': "REQUIRED"},
                                    {'name': "DEL_REC_IND", 'type': "BOOLEAN", 'mode': "REQUIRED"},
                                    {'name': "ACTV_REC_IND", 'type': "BOOLEAN", 'mode': "REQUIRED"},
                                    {'name': "DCML_ADJ_NUM", 'type': "INTEGER", 'mode': "REQUIRED"},
                                    {'name': "REC_CREAT_DT_TM", 'type': "TIMESTAMP", 'mode': "REQUIRED"},
                                    {'name': "REC_UPDT_DT_TM", 'type': "TIMESTAMP", 'mode': "NULLABLE"}]
                       })
    
    currency_query = 'SELECT CURRENCY_ID as CURRENCY_KEY, CRNCY_CDE, CRNCY_NAME, DEL_REC_IND, ACTV_REC_IND, DCML_ADJ_NUM, REC_CREAT_DT_TM, REC_UPDT_DT_TM '\
                     'FROM [famous-store-237108:UDM.currency]'
    
    # Build and run the pipeline
    pipeline_options = opt.PipelineOptions () # This is deprecated, not future proof. Replacement TBA
    pipeline_options.view_as (opt.StandardOptions).streaming = False # Set options first
    google_cloud_options = pipeline_options.view_as (opt.GoogleCloudOptions)
    google_cloud_options.project = PROJECT
    google_cloud_options.job_name = 'loadcurrency'
    google_cloud_options.staging_location = 'gs://csacsi/staging'
    google_cloud_options.temp_location = 'gs://csacsi/temp'
    google_cloud_options.region = 'europe-west1'

    with beam.Pipeline (options = pipeline_options) as pcoll: # Creates a pipeline, PCollection instance

        #rows = pcoll | "Read from UDM.location" >> beam.io.Read (beam.io.BigQuerySource (UDM_table_spec_location)) # Read from UDM.location
        rows = pcoll | "Read from UDM.currency" >> beam.io.Read (beam.io.BigQuerySource (query = currency_query)) # Read from UDM.location

        #rows = rows | beam.ParDo (id2key ())

        rows | "Write to Consumption.Currency_dim" >> beam.io.WriteToBigQuery (CONS_table_spec_currency_dim,
                                             schema  = currency_schema, # schema variable (list) could be used
                                             create_disposition=BigQueryDisposition.CREATE_NEVER,
                                             write_disposition=BigQueryDisposition.WRITE_TRUNCATE)

class DFThread (threading.Thread):
   def __init__ (self, threadID, name, DFFunc):
      threading.Thread.__init__(self)
      self.threadID = threadID
      self.name = name
      self.func = DFFunc

   def run (self):
      printf ("Starting %s with %s as callback", self.name, self.func)
      self.func ()

# Program entry point
def main ():

    threads = []

    # Create new threads
    threadCountry = DFThread (1, "Thread-Country", populate_country_dim)
    threadCurrency = DFThread (2, "Thread-Currency", populate_currency_dim)

    # Start Threads
    #threadCountry.start ()
    threadCurrency.start ()

    # Add threads to thread list
    #threads.append (threadCountry)
    threads.append (threadCurrency)

    # Wait for all threads to complete
    for thisThread in threads:
        thisThread.join ()

# Entry point if run as script
if __name__ == '__main__':
    main ()
