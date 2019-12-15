# JSON load to BigQuery test using a public JSON file
from google.cloud import bigquery
import apache_beam as beam
import apache_beam.options.pipeline_options as opt
import apache_beam.transforms.window as window

client = bigquery.Client () # Instantiate BigQuery client

# Establish dataset
dataset_id = 'Test_dataset'
dataset_ref = client.dataset (dataset_id)

# Configure job
job_config = bigquery.LoadJobConfig()
job_config.schema = [
    bigquery.SchemaField ("name", "STRING"),
    bigquery.SchemaField ("post_abbr", "STRING"),
]
job_config.source_format = bigquery.SourceFormat.NEWLINE_DELIMITED_JSON
uri = "gs://cloud-samples-data/bigquery/us-states/us-states.json"

# Create load job
load_job = client.load_table_from_uri (
    uri,
    dataset_ref.table ("us_states"),
    location="US",  # Location must match that of the destination dataset.
    job_config=job_config,
)  # API request
print("Starting job {}".format(load_job.job_id))

# Execute load job
load_job.result()  # Waits for table load to complete.
print("Job finished.")

destination_table = client.get_table(dataset_ref.table("us_states"))
print("Loaded {} rows.".format(destination_table.num_rows))
