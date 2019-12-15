import time
import sys
import apache_beam as beam
import apache_beam.options.pipeline_options as opt
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
        element['location_key'] = element.pop ('location_id')
        return [element]

def populate_table (source_query, source_table_spec, target_table_spec, target_schema, runner): # staging, temp, job, create/write disposition


    # Build and run the pipeline
    pipeline_options = opt.PipelineOptions () # This is deprecated, not future proof. Replacement TBA
    google_cloud_options = pipeline_options.view_as (opt.GoogleCloudOptions)
    google_cloud_options.project = target_table_spec.projectId
    google_cloud_options.job_name = 'load' + target_table_spec.tableId
    google_cloud_options.staging_location = 'gs://csacsi/staging'
    google_cloud_options.temp_location = 'gs://csacsi/temp'
    google_cloud_options.region = 'europe-west1'
    pipeline_options.view_as (opt.StandardOptions).runner = runner
    pipeline_options.view_as (opt.StandardOptions).streaming = False # Set options first
    all_options = pipeline_options.get_all_options () # For testing purposes only
    #--project famous-store-237108 --region europe-west1 --runner DataflowRunner --temp_location gs://csacsi/temp --staging_location gs://csacsi/staging --num_workers 2 --max_num_workers 5

    with beam.Pipeline (options = pipeline_options) as pcoll: # Creates a pipeline, PCollection instance

        #rows = pcoll | "Read from UDM.location" >> beam.io.Read (beam.io.BigQuerySource (source_table_spec)) # Read using a table spec
        rows = pcoll | "Read from UDM." + source_table_spec.tableId >> beam.io.Read (beam.io.BigQuerySource (query = source_query, use_standard_sql = True)) # Read using a query

        #dict_rows = rows | "Convert to dictionary" >> beam.ParDo (createDict ()) # Convert tuples returned by Oracle into dictionary needed for BigQuery
        rows = rows | beam.ParDo (id2key ()) # Replace ID columns with KEY

        rows | "Write to Consumption." + target_table_spec.tableId >> beam.io.WriteToBigQuery (target_table_spec,
                                             schema  = target_schema, # schema variable (list) could be used
                                             create_disposition=BigQueryDisposition.CREATE_NEVER,
                                             write_disposition=BigQueryDisposition.WRITE_TRUNCATE)
class DFThread (threading.Thread):
    def __init__ (self, threadID, name, DFFunc, source_query, source_table_spec, target_table_spec, target_schema, runner):
        threading.Thread.__init__(self)
        self.threadID = threadID
        self.name = name
        self.func = DFFunc
        self.source_table_spec = source_table_spec
        self.target_table_spec = target_table_spec
        self.source_query = source_query
        self.target_schema = target_schema
        self.runner = runner

    def run (self):
        printf ("\nStarting thread %s...\n", self.name)
        self.func (self.source_query, self.source_table_spec, self.target_table_spec, self.target_schema, self.runner)
        printf ("Thread %s terminated.\n", self.name)

# Program entry point
def main ():

    threads = []

    if sys.argv [1] == 'country_dim':
        source_table_spec = bigquery.TableReference (projectId = PROJECT, datasetId = DATASET_UDM, tableId = 'location')
        target_table_spec = bigquery.TableReference (projectId = PROJECT, datasetId = DATASET_CONS, tableId = 'country_dim')
        source_query = 'SELECT LOCATION_ID as LOCATION_KEY, CTRY_ISO2_CDE, CTRY_ISO3_CDE, CTRY_NAME, REGION_NAME, CPTL_CITY_NAME, DEL_REC_IND, '\
                       'ACTV_REC_IND, REC_CREAT_DT_TM, DATE (NULL) AS REC_UPDT_DT_TM '\
                       'FROM `' + source_table_spec.projectId + ':' + source_table_spec.datasetId + '.' + source_table_spec.tableId + '`'

        target_schema =  ({'fields': [{'name': "LOCATION_KEY", 'type': 'INTEGER', 'mode': 'REQUIRED'},
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
        runner = 'DirectRunner'
    elif sys.argv[1] == 'currency_dim':
         source_table_spec = bigquery.TableReference (projectId = PROJECT, datasetId = DATASET_UDM, tableId = 'currency')
         target_table_spec = bigquery.TableReference (projectId = PROJECT, datasetId = DATASET_CONS, tableId = 'currency_dim')

         source_query = 'SELECT CURRENCY_ID as CURRENCY_KEY, CRNCY_CDE, CRNCY_NAME, DEL_REC_IND, ACTV_REC_IND, DCML_ADJ_NUM, REC_CREAT_DT_TM, DATE (NULL) AS REC_UPDT_DT_TM '\
                        'FROM `' + source_table_spec.projectId + ':' + source_table_spec.datasetId + '.' + source_table_spec.tableId + '`'

         target_schema =  ({'fields': [{'name': "CURRENCY_KEY", 'type': 'INTEGER', 'mode': 'REQUIRED'},
                                       {'name': "CRNCY_CDE", 'type': 'STRING', 'mode': 'REQUIRED'},
                                       {'name': "CRNCY_NAME", 'type': "STRING", 'mode': "REQUIRED"},
                                       {'name': "DEL_REC_IND", 'type': "BOOLEAN", 'mode': "REQUIRED"},
                                       {'name': "ACTV_REC_IND", 'type': "BOOLEAN", 'mode': "REQUIRED"},
                                       {'name': "DCML_ADJ_NUM", 'type': "INTEGER", 'mode': "REQUIRED"},
                                       {'name': "REC_CREAT_DT_TM", 'type': "TIMESTAMP", 'mode': "REQUIRED"},
                                       {'name': "REC_UPDT_DT_TM", 'type': "TIMESTAMP", 'mode': "NULLABLE"}]
                       })
         runner = 'DirectRunner' 
    elif sys.argv[1] == 'forex_dim':
         source_table_spec = bigquery.TableReference (projectId = PROJECT, datasetId = DATASET_UDM, tableId = 'forex')
         target_table_spec = bigquery.TableReference (projectId = PROJECT, datasetId = DATASET_CONS, tableId = 'forex_dim')

         source_query = "SELECT FX_ID as FX_KEY, FX_DESCRIPTION, CONVERSION_CURRENCY, RATE, PARSE_DATE ('%d/%m/%Y', '01/06/2019') as START_DT, DATE (NULL) AS END_DT "\
                        "FROM `" + source_table_spec.projectId + "." + source_table_spec.datasetId + "." + source_table_spec.tableId + "`"

         target_schema =  ({'fields': [{'name': "FX_KEY", 'type': 'INTEGER', 'mode': 'REQUIRED'},
                                       {'name': "FX_DESCRIPTION", 'type': 'STRING', 'mode': 'REQUIRED'},
                                       {'name': "CONVERSION_CURRENCY", 'type': "STRING", 'mode': "REQUIRED"},
                                       {'name': "RATE", 'type': "FLOAT", 'mode': "REQUIRED"},
                                       {'name': "START_DT", 'type': "DATE", 'mode': "REQUIRED"},
                                       {'name': "END_DT", 'type': "DATE", 'mode': "NULLABLE"}]
                       })
         runner = 'DirectRunner'
    elif sys.argv[1] == 'date_dim':
        source_table_spec = bigquery.TableReference (projectId = PROJECT, datasetId = DATASET_UDM, tableId = 'date_view')
        target_table_spec = bigquery.TableReference (projectId = PROJECT, datasetId = DATASET_CONS, tableId = 'date_dim')

        source_query = "SELECT date_key, day, month, year, holiday_flag, day_type, week_number "\
                       "FROM `" + source_table_spec.projectId + "." + source_table_spec.datasetId + "." + source_table_spec.tableId + "`"

        target_schema =  ({'fields': [{'name': "DATE_KEY", 'type': 'DATE', 'mode': 'REQUIRED'},
                                       {'name': "DAY", 'type': 'STRING', 'mode': 'REQUIRED'},
                                      {'name': "MONTH", 'type': "STRING", 'mode': "REQUIRED"},
                                      {'name': "YEAR", 'type': "INTEGER", 'mode': "REQUIRED"},
                                      {'name': "HOLIDAY_FLAG", 'type': "BOOLEAN", 'mode': "REQUIRED"},
                                      {'name': "DAY_TYPE", 'type': "STRING", 'mode': "REQUIRED"},
                                      {'name': "WEEK_NUMBER", 'type': "INTEGER", 'mode': "REQUIRED"}]
                         })

        runner = 'DirectRunner'
    elif sys.argv[1] == 'operational_account_dim':
        source_table_spec = bigquery.TableReference (projectId = PROJECT, datasetId = DATASET_UDM, tableId = 'operation_account_view')
        target_table_spec = bigquery.TableReference (projectId = PROJECT, datasetId = DATASET_CONS, tableId = 'operational_account_dim')

        source_query = "SELECT account_key, account_type, account_status_type_cd, account_status_type_desc, funding_currency_cd, start_dt, end_dt "\
                       "FROM `" + source_table_spec.projectId + "." + source_table_spec.datasetId + "." + source_table_spec.tableId + "`"

        target_schema =  ({'fields': [{'name': "ACCOUNT_KEY", 'type': 'INTEGER', 'mode': 'REQUIRED'},
                                      {'name': "ACCOUNT_TYPE", 'type': 'STRING', 'mode': 'REQUIRED'},
                                      {'name': "ACCOUNT_STATUS_TYPE_CD", 'type': "STRING", 'mode': "REQUIRED"},
                                      {'name': "ACCOUNT_STATUS_TYPE_DESC", 'type': "STRING", 'mode': "REQUIRED"},
                                      {'name': "FUNDING_CURRENCY_CD", 'type': "STRING", 'mode': "REQUIRED"},
                                      {'name': "START_DT", 'type': "DATE", 'mode': "REQUIRED"},
                                      {'name': "END_DT", 'type': "DATE", 'mode': "NULLABLE"}]
                         })

        runner = 'DirectRunner'
    elif sys.argv[1] == 'party_dim':
        source_table_spec = bigquery.TableReference (projectId = PROJECT, datasetId = DATASET_UDM, tableId = 'organisation_name')
        target_table_spec = bigquery.TableReference (projectId = PROJECT, datasetId = DATASET_CONS, tableId = 'party_dim')

        source_query = "SELECT party_id as party_key, catgry_type_cd as party_type_cd, name as party_name, 'Legal Name' as party_name_type_cd, 'SIC' as party_category_type, "\
                       "'Financial Services' as party_category_type_desc, 'CIN' as party_id_type, PARSE_DATE ('%d/%m/%Y', '01/06/2019') as start_dt, DATE (NULL) as end_dt "\
                       "FROM `" + source_table_spec.projectId + "." + source_table_spec.datasetId + "." + source_table_spec.tableId + "`"

        target_schema =  ({'fields': [{'name': "PARTY_KEY", 'type': 'INTEGER', 'mode': 'REQUIRED'},
                                      {'name': "PARTY_TYPE_CD", 'type': 'STRING', 'mode': 'REQUIRED'},
                                      {'name': "PARTY_NAME", 'type': "STRING", 'mode': "REQUIRED"},
                                      {'name': "PARTY_NAME_TYPE_CD", 'type': "STRING", 'mode': "REQUIRED"},
                                      {'name': "PARTY_CATEGORY_TYPE", 'type': "STRING", 'mode': "REQUIRED"},
                                      {'name': "PARTY_CATEGORY_TYPE_DESC", 'type': "STRING", 'mode': "REQUIRED"},
                                      {'name': "PARTY_ID_TYPE", 'type': "STRING", 'mode': "REQUIRED"},
                                      {'name': "START_DT", 'type': "DATE", 'mode': "REQUIRED"},
                                      {'name': "END_DT", 'type': "DATE", 'mode': "NULLABLE"}]
                         })

        runner = 'DirectRunner'
    elif sys.argv[1] == 'receivable_finance_fact':
        source_table_spec = bigquery.TableReference (projectId = PROJECT, datasetId = DATASET_UDM, tableId = 'receivable_finance_fact')
        target_table_spec = bigquery.TableReference (projectId = PROJECT, datasetId = DATASET_CONS, tableId = 'receivable_finance_fact')

        source_query = "SELECT cust_oprt_account_number as account_key, location_id as location_key, currency_id as currency_key, date_id as date_key, "\
                       "outstanding_debit_bal as total_outstanding_debit_balance, outstanding_credit_bal as total_outstanding_credit_balance "\
                       "FROM `" + source_table_spec.projectId + "." + source_table_spec.datasetId + "." + source_table_spec.tableId + "`"

        target_schema =  ({'fields': [{'name': "ACCOUNT_KEY", 'type': 'INTEGER', 'mode': 'REQUIRED'},
                                      {'name': "LOCATION_KEY", 'type': 'INTEGER', 'mode': 'REQUIRED'},
                                      {'name': "CURRENCY_KEY", 'type': "STRING", 'mode': "REQUIRED"},
                                      {'name': "DATE_KEY", 'type': "DATE", 'mode': "REQUIRED"},
                                      {'name': "TOTAL_OUTSTANDING_DEBIT_BALANCE", 'type': "FLOAT", 'mode': "REQUIRED"},
                                      {'name': "TOTAL_OUTSTANDING_CREDIT_BALANCE", 'type': "FLOAT", 'mode': "REQUIRED"}]
                         })

        runner = 'DirectRunner'
    # Create new threads
    worker = DFThread (1, "Thread-" + target_table_spec.tableId, populate_table, source_query, source_table_spec, target_table_spec, target_schema, runner)

    # Start Thread
    worker.start ()

    # Add threads to thread list
    threads.append (worker)

    # Wait for all threads to complete
    for thisThread in threads:
        thisThread.join ()

# Entry point if run as script
if __name__ == '__main__':
    main ()


