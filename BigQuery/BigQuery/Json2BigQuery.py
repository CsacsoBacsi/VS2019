# Standalone script to load BigQuery table from JSON file stored on local hard drive
import time
import sys
from google.cloud import bigquery
import apache_beam as beam
import apache_beam.options.pipeline_options as opt
import apache_beam.transforms.window as window
import json

# Constants
PROJECT    = "famous-store-237108"
DATASET    = "HR_dataset"
TABLE_NAME = "Departments"

# Open and load from JSON file
def loadFromJSON ():
    FILENAME = "Departments.txt"
    filename = "D:/VS2017Projects/BigQuery/Input/" + FILENAME
    with open (filename) as json_file:
         rows = json.load (json_file)
    return rows
 
# Program entry point
def main ():
    rows = loadFromJSON ()

    # Build and run the pipeline
    pipeline_options = opt.PipelineOptions ()
    pipeline_options.view_as (opt.StandardOptions).streaming = False # Set options first

    with beam.Pipeline (options = pipeline_options) as pcoll: # Creates a pipeline. PCollection object

        rows = pcoll | "Create from department resultset" >> beam.Create (rows) # Read in-memory dictionary (rows) into a PCollection (creates the pipeline)

        rows | beam.io.WriteToBigQuery (table   = TABLE_NAME,
                                        dataset = DATASET,
                                        project = PROJECT,
                                        schema  = ("DEPARTMENT_ID:INTEGER,"
                                                   "DEPARTMENT_NAME:STRING,"
                                                   "MANAGER_ID:INTEGER,"
                                                   "LOCATION_ID:INTEGER"),
                                        create_disposition=beam.io.BigQueryDisposition.CREATE_IF_NEEDED, # Creates table if does not exist
                                        write_disposition=beam.io.BigQueryDisposition.WRITE_APPEND) # Could be WRITE_TRUNCATE

# IF run as script and not just imported
if __name__ == '__main__':
    main ()
