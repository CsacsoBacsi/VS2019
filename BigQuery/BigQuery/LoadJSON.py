# Standalone script to load BigQuery table from JSON file stored on Google Store
from google.cloud import bigquery
import apache_beam as beam
import apache_beam.options.pipeline_options as opt
import apache_beam.transforms.window as window # Not used

# Constants
PROJECT    = "famous-store-237108"
DATASET    = "HR_dataset"
TABLE_NAME = "Departments"

# Set dataset
client = bigquery.Client () # Instantiates BigQuery client

dataset_id = ("{}." + DATASET).format (client.project)
dataset_id = DATASET
dataset_ref = client.dataset (dataset_id)

# Configure load job
job_config = bigquery.LoadJobConfig ()
job_config.schema = [
    bigquery.SchemaField ("DEPARTMENT_ID", "INTEGER"),
    bigquery.SchemaField ("DEPARTMENT_NAME", "STRING"),
    bigquery.SchemaField ("MANAGER_ID", "INTEGER"),
    bigquery.SchemaField ("LOCATION_ID", "INTEGER"),
]
job_config.source_format = bigquery.SourceFormat.NEWLINE_DELIMITED_JSON
uri = "gs://human_resources_cr/Departments.json" # Google Store URI

load_job = client.load_table_from_uri ( # Creates load job. In BigQuery everything goes through jobs
    uri,
    dataset_ref.table (TABLE_NAME),
    location = "europe-west2",  # Location must match that of the destination dataset.
    job_config = job_config,
) # API request
print("Starting job {}".format (load_job.job_id))

load_job.result () # Waits for table load to complete.
print ("Job complete.")

destination_table = client.get_table (dataset_ref.table (TABLE_NAME))
print ("Loaded {} rows.".format (destination_table.num_rows)) # Returns number of total rows in table not rows loaded
