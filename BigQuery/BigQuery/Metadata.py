# Standalone script to depict BigQuery features
from __future__ import absolute_import
from google.cloud import bigquery

# Constants
PROJECT      = "famous-store-237108"
DATASET_UDM  = "UDM"
DATASET_CONS = "Consumption"
TABLE = "country_dim"

client = bigquery.Client () # Instantiate BigQuery client

query = ("SELECT column_name, data_type, is_nullable FROM `" + PROJECT + "." + DATASET_CONS + ".INFORMATION_SCHEMA.COLUMNS` WHERE table_name = '" + TABLE + "' limit 1000 ")
query_job = client.query (query)

rows = query_job.result ()

schema = {}
col_list = []

for row in rows:
    col_info = {}

    col_info ['name'] = row.column_name
    col_info ['type'] = row.data_type
    if row.is_nullable:
       col_info ['mode'] = 'REQUIRED'
    else:
        col_info ['mode'] = 'NULLABLE'

    col_list.append (col_info)

    print (row.column_name, row.data_type, row.is_nullable)

schema ['fields'] = col_list

t = 5
i = t
