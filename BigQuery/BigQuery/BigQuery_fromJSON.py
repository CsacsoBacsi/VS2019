from google.cloud import bigquery
import os, json
import pandas as pd
import numpy as np
import io

def format_schema(schema):
    formatted_schema = []
    for row in schema:
        formatted_schema.append(bigquery.SchemaField(row['name'], row['type'], row['mode']))
    return formatted_schema

able_schema = {"mode": "NULLABLE", "name": "empno", "type": "INTEGER"}, \
               {"mode": "NULLABLE", "name": "age",   "type": "INTEGER"}, \
               {"mode": "NULLABLE", "name": "name",  "type": "STRING"}, \
               {"mode": "REPEATED", "name": "sal", "type": "RECORD",
                 "fields": [ \
                   {"name": "mon", "type": "STRING"}, \
                   {"name": "amt", "type": "INTEGER"}, \
                   {"mode": "REPEATED", "name": "cost", "type": "RECORD"} ],\
                   "fields": [ \
                     {"name": "food", "type": "INTEGER"}, \
                     {"name": "house", "type": "INTEGER"} ] }
                
table_schema = {"mode": "NULLABLE", "name": "empno", "type": "INTEGER"}, \
               {"mode": "NULLABLE", "name": "age",   "type": "INTEGER"}, \
               {"mode": "NULLABLE", "name": "name",  "type": "STRING"}, \
               {"mode": "REPEATED", "name": "sal", "type": "RECORD", "fields": [{"name": "mon", "type": "STRING"}, {"name": "amt", "type": "INTEGER"}, {"mode": "REPEATED", "name": "cost", "type": "RECORD"} ], "fields": [{"name": "food", "type": "INTEGER"}, {"name": "house", "type": "INTEGER"} ] }

json_data = {"empno": 123, "age": 40, "name": "Robert Hicks", \
             "sal": [{"mon":"Jan 2021","amt":500, \
                "cost": [{"food": 10},{"house":100}]}, \
              {"mon":"Feb 2021","amt":550, \
                "cost": [{"food": 15},{"house":100}]}, \
              {"mon":"Mar 2021","amt":550, \
                "cost": [{"food": 12},{"house":110}]} \
        ] \
    }

project_id = 'organic-palace-306416'
dataset_id = 'DS'
table_id   = 't2'

client   = bigquery.Client (project = project_id)
dataset  = client.dataset (dataset_id)
table    = dataset.table (table_id)

#bigquerySchema = []
#bigqueryColumns = json.loads (table_schema)
#bigquerySchema.append(bigquery.SchemaField(['name'], col['type']))

job_config = bigquery.LoadJobConfig ()
job_config.source_format = bigquery.SourceFormat.NEWLINE_DELIMITED_JSON
job_config.write_disposition = bigquery.WriteDisposition.WRITE_TRUNCATE
job_config.schema = format_schema (table_schema)
result = json.dumps (json_data)
json_data_file = io.StringIO (result)
job = client.load_table_from_file (json_data_file, table, job_config = job_config)

print (job.result ())