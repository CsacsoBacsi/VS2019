import shutil
from Spark import sc, spark
from pyspark.sql import Row
from pyspark.sql.types import StructType, StructField, StringType, IntegerType, DoubleType, BooleanType, ArrayType, MapType
from pyspark.sql.functions import col, struct, when

# Create Dataframes
columns = ["language","users_count"]
data = [("Java", "20000"), ("Python", "100000"), ("Scala", "3000")]

# From RDD
rdd = sc.parallelize (data)
columns = ["language","users_count"]
dfFromRDD = rdd.toDF (columns)
dfFromRDD.printSchema ()

# From Spark session
dfFromRDD2 = spark.createDataFrame (rdd).toDF (*columns) # Params passed as a list (*)
dfFromRDD2.printSchema ()

# From ROW type
row = Row (data[0])
rowData = map (lambda x: Row (*x), data) 
dfFromData = spark.createDataFrame (rowData, columns)
dfFromData.printSchema ()

# From data and column names
data2 = [("James","","Smith","36636","M",3000),
    ("Michael","Rose","","40288","M",4000),
    ("Robert","","Williams","42114","M",4000),
    ("Maria","Anne","Jones","39192","F",4000),
    ("Jen","Mary","Brown","","F",-1)
  ]
schema = StructType([ \
    StructField("firstname",StringType(),True), \
    StructField("middlename",StringType(),True), \
    StructField("lastname",StringType(),True), \
    StructField("id", StringType(), True), \
    StructField("gender", StringType(), True), \
    StructField("salary", IntegerType(), True) \
  ])
 
df = spark.createDataFrame (data = data2, schema = schema)
df.printSchema ()
df.show (truncate = False)

print ()

# From files (csv, txt, json)
df = spark.read.csv ("postcodes.csv")
df.printSchema ()
df.show ()

df = spark.read.option ("header", True).options (delimiter = ',').options (inferSchema = 'True').csv ("postcodes.csv")
df.printSchema ()
df.show ()

# df = spark.read.csv ("Folder path") # Read all files in a folder

# Define schema by user
schema = StructType () \
      .add("RecordNumber",IntegerType(),True) \
      .add("Zipcode",IntegerType(),True) \
      .add("ZipCodeType",StringType(),True) \
      .add("City",StringType(),True) \
      .add("State",StringType(),True) \
      .add("LocationType",StringType(),True) \
      .add("Lat",DoubleType(),True) \
      .add("Long",DoubleType(),True) \
      .add("Xaxis",IntegerType(),True) \
      .add("Yaxis",DoubleType(),True) \
      .add("Zaxis",DoubleType(),True) \
      .add("WorldRegion",StringType(),True) \
      .add("Country",StringType(),True) \
      .add("LocationText",StringType(),True) \
      .add("Location",StringType(),True) \
      .add("Decommisioned",BooleanType(),True) \
      .add("TaxReturnsFiled",StringType(),True) \
      .add("EstimatedPopulation",IntegerType(),True) \
      .add("TotalWages",IntegerType(),True) \
      .add("Notes",StringType(),True)
      
df_with_schema = spark.read.format ("csv").option ("header", True).schema (schema).load("postcodes.csv")
df_with_schema.show ()
dir_path = "zipcodes"
try:
    shutil.rmtree (dir_path)
except OSError as e:
    print ("Error: %s : %s" % (dir_path, e.strerror))
df_with_schema.write.option ("header", True).csv ("zipcodes")
# Or use:
df_with_schema.write.mode ('overwrite').csv ("zipcodes")
df_with_schema.write.mode ('overwrite').csv ("zipcodes")

# Empty Dataframe. Like empty table
schema = StructType ([
  StructField('firstname', StringType(), True),
  StructField('middlename', StringType(), True),
  StructField('lastname', StringType(), True)
  ])
emptyRDD = sc.emptyRDD ()
df = spark.createDataFrame (emptyRDD, schema)
df.printSchema ()
df1 = emptyRDD.toDF (schema) # Another way
df1.printSchema ()
df2 = spark.createDataFrame ([], schema) # Without RDD
df2.printSchema ()
df3 = spark.createDataFrame ([], StructType ([])) # No data nor column
df3.printSchema ()

# Creating, altering, updating DF schemas
structureData = [(("James","","Smith"),"36636","M",3100), (("Michael","Rose",""),"40288","M",4300), (("Robert","","Williams"),"42114","M",1400),
                 (("Maria","Anne","Jones"),"39192","F",5500), (("Jen","Mary","Brown"),"","F",-1)]
structureSchema = StructType ([StructField ('name',
                               StructType ([StructField('firstname', StringType(), True), StructField('middlename', StringType(), True), StructField('lastname', StringType(), True)])
                             ),
                             StructField('id', StringType(), True),
                             StructField('gender', StringType(), True),
                             StructField('salary', IntegerType(), True)
                             ])

df2 = spark.createDataFrame (data = structureData, schema = structureSchema)
df2.printSchema ()
df2.show (truncate = False)

updatedDF = df2.withColumn ("OtherInfo", struct (col ("id").alias ("identifier"), col ("gender").alias ("gender"), col ("salary").alias ("salary"),
                                                 when (col("salary").cast (IntegerType ()) < 2000,"Low")
                                                .when (col("salary").cast (IntegerType ()) < 4000,"Medium")
                                                .otherwise ("High").alias ("Salary_Grade")
                                                )
                           )
updatedDF = updatedDF.drop ("id", "gender", "salary")
print ("*")
updatedDF.printSchema ()
updatedDF.show (truncate = False)

# Arrays and dict as columns
arrayStructureSchema = StructType([StructField('name', StructType([StructField('firstname', StringType(), True),
                                                                   StructField('middlename', StringType(), True),
                                                                   StructField('lastname', StringType(), True)
                                                                  ])
                                               ),
                                   StructField('hobbies', ArrayType(StringType()), True),
                                   StructField('properties', MapType(StringType(),StringType()), True)
                                  ])
arrayData = [(("James","","Smith"),["Movies", "Gardening", "Running"], {"Eye":"Brown","Height":"Small","IQ":"100"}), (("John","White","Clover"),["Music", "Whistling", "Hiking"], {"Eye":"Blue","Height":"Tall","Education":"University"})]
df3 = spark.createDataFrame (data = arrayData, schema = arrayStructureSchema)
df3.printSchema ()
df3.show (truncate = False)

# Check if column exists
listColumns = df1.columns
if "firstname" in listColumns:
    print ("Exists")
else:
    print ("Nope")

print ()
exit (0)