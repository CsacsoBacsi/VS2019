# Uploads CSV to Google Store then loads it into BigQuery
from google.cloud import bigquery
from google.cloud import storage

# Constants
BUCKET    = 'human_resources_cr'
FILENAME  = 'Departments.csv'
DATASET   = "HR_dataset"
TABLENAME = 'Departments'

# Uploads CSV file
def gs_upload ():
    # Uploads a file to the bucket
    storage_client = storage.Client () # Instantiate Stroage client
    bucket = storage_client.get_bucket (BUCKET)
    blob = bucket.blob (FILENAME)

    blob.upload_from_filename ("D:/VS2017Projects/BigQuery/Input/" + FILENAME)

    print ('File {} uploaded to {}.'.format("D:/VS2017Projects/BigQuery/Input/" + FILENAME, 'gs://' + BUCKET + '/' + FILENAME))

# Create load job and load CSV to BigQuery
def load_csv ():
    client = bigquery.Client () # Instantiates BigQuery client
    dataset_ref = client.dataset (DATASET) # Establish dataset 

    job_config = bigquery.LoadJobConfig()
    schema = [
        bigquery.SchemaField('DEPARTMENT_ID', 'INTEGER', mode='REQUIRED'),
        bigquery.SchemaField('DEPARTMENT_NAME', 'STRING', mode='REQUIRED'),
        bigquery.SchemaField('MANAGER_ID', 'INTEGER', mode='REQUIRED'),
        bigquery.SchemaField('LOCATION_ID', 'INTEGER', mode='REQUIRED')
    ]
    job_config.schema = schema
    job_config.skip_leading_rows = 1

    load_job = client.load_table_from_uri (
        'gs://' + BUCKET + '/' + FILENAME,
        dataset_ref.table (TABLENAME),
        job_config = job_config)

    load_job.result()  # Waits for table load to complete.

    if load_job.state == 'DONE':
        print ("CSV file loaded successfully")

# Starts here if executed as script
if __name__ == '__main__':
    gs_upload ()
    load_csv ()