from Spark import sc, spark
from pyspark.sql import Row
from pyspark.sql.functions import col, struct, when, lit, array_contains, expr, explode
from pyspark.sql.types import StructType, StructField, StringType, IntegerType, DoubleType, BooleanType, ArrayType, MapType
from pyspark.sql.functions import sum, avg, max, min, mean, count

# Show
columns = ["Index","Quote"]
data = [("1", "Be the change that you wish to see in the world"), ("2", "Everyone thinks of changing the world, but no one thinks of changing himself."),
        ("3", "The purpose of our lives is to be happy."), ("4", "Be cool.")]
df = spark.createDataFrame (data, columns)
print ("Select 2 rows only trunced each at 25th char.")
df.show (2, truncate = 25) # two rows truncated each at 25th char

# Select
data = [("James","Smith","USA","CA"),
    ("Michael","Rose","USA","NY"),
    ("Robert","Williams","USA","CA"),
    ("Maria","Jones","USA","FL")
  ]
columns = ["firstname","lastname","country","state"]
df = spark.createDataFrame(data = data, schema = columns)

print ("Select firstname and lastname")
df.select ("firstname","lastname").show ()
df.select (df.firstname,df.state).show ()
df.select (df["firstname"],df["lastname"]).show ()
print ("Select firstname and country using col object")
df.select (col("firstname"), col("country")).show ()
print ("Select regexp: ^.*name*")
df.select (df.colRegex("`^.*name*`")).show ()

print ("Select all columns")
df.select (*columns).show ()
df.select ([col for col in df.columns]).show ()
df.select ("*").show ()
print ("Select 3 rows only")
df.select (df.columns[:3]).show (3) # 3 rows only
df.select (df.columns[2:4]).show (3)

data = [(("James",None,"Smith"),"OH","M"),
        (("Anna","Rose",""),"NY","F"),
        (("Julia","","Williams"),"OH","F"),
        (("Maria","Anne","Jones"),"NY","M"),
        (("Jen","Mary","Brown"),"NY","M"),
        (("Mike","Mary","Williams"),"OH","M")]

schema = StructType([StructField ('name', StructType([StructField('firstname', StringType(), True),
                                                      StructField('middlename', StringType(), True),
                                                      StructField('lastname', StringType(), True)])),
                    StructField('state', StringType(), True), 
                    StructField('gender', StringType(), True)
                    ])
df2 = spark.createDataFrame(data = data, schema = schema)
print ("Select name struct")
df2.select ("name").show (truncate = False)
print ("Select struct firstname and lastname plus gender")
df2.select ("name.firstname", "name.lastname", "gender").show (truncate = False)
print ("Select all in name struct")
df2.select ("name.*").show (truncate = False)

# Collect
# select() is a transformation that returns a new DataFrame and holds the columns that are selected 
# whereas collect() is an action that returns the entire data set in an Array to the driver.
dept = [("Finance",10), ("Marketing",20), ("Sales",30), ("IT",40)]
deptColumns = ["dept_name", "dept_id"]
deptDF = spark.createDataFrame (data = dept, schema = deptColumns)
dataCollect = deptDF.collect ()
print ("Collect all data")
print (dataCollect)

for row in dataCollect:
    print (row['dept_name'] + "," + str (row['dept_id']))

d2 = deptDF.collect()[0][0] # First row and col
print ("Collect first row and column")
print (d2)
print ("Collect dept_name only")
dataCollect = deptDF.select ("dept_name").collect () # Collect only certain elements
print (dataCollect)

# WithColumn
# Runtime changes only. They create a new DF that has the changes
data = [('James','','Smith','1991-04-01','M',3000),
  ('Michael','Rose','','2000-05-19','M',4000),
  ('Robert','','Williams','1978-09-05','M',4000),
  ('Maria','Anne','Jones','1967-12-01','F',4000),
  ('Jen','Mary','Brown','1980-02-17','F',-1)
]

columns = ["firstname", "middlename", "lastname", "dob", "gender", "salary"]
df = spark.createDataFrame (data = data, schema = columns)
print ("Change salary datatype")
df.withColumn ("salary", col ("salary").cast ("Integer")).show () # Change datatype
print ("Salary * 100")
df.withColumn ("salary", col ("salary") * 100).show () # Update column value
print ("New column: salary * -1")
df.withColumn ("CopiedColumn", col ("salary") * -1).show ()
print ("Select all. Original DF has not changed")
df.select ("*").show (truncate = False) # Temporary, run-time change only!
print ("New column: coutry with USA literal value")
df.withColumn ("Country", lit ("USA")).withColumn ("anotherColumn",lit ("anotherValue")).show () # Add literal as value to the column
print ("Rename gender to sex")
df.withColumnRenamed ("gender", "sex").show (truncate = False)
print ("Drop salary")
df.drop ("salary").show ()

# Where, filter (they are the same
data = [(("James","","Smith"),["Java","Scala","C++"],"OH","M"), (("Anna","Rose",""),["Spark","Java","C++"],"NY","F"), (("Julia","","Williams"),["CSharp","VB"],"OH","F"),
        (("Maria","Anne","Jones"),["CSharp","VB"],"NY","M"), (("Jen","Mary","Brown"),["CSharp","VB"],"NY","M"), (("Mike","Mary","Williams"),["Python","VB"],"OH","M")]
        
schema = StructType([StructField ('name', StructType ([
                                          StructField('firstname', StringType(), True),
                                          StructField('middlename', StringType(), True),
                                          StructField('lastname', StringType(), True)
                                 ])),
     StructField('languages', ArrayType(StringType()), True), StructField('state', StringType(), True), StructField('gender', StringType(), True)])
df = spark.createDataFrame (data = data, schema = schema)
print ("Filter state = OH")
df.filter (df.state == "OH").show (truncate = False)
print ("Filter state not = OH")
df.filter (df.state != "OH").show (truncate = False) 
print ("Filter state = OH and gender = M")
df.filter ((df.state  == "OH") & (df.gender  == "M")).show (truncate = False)
li = ["OH","CA","DE"]
print ("Filter state in OH, CA, DE")
df.filter (df.state.isin (li)).show ()
print ("Filter starts with N")
df.filter (df.state.startswith ("N")).show ()
print ("Filter ends with H")
df.filter (df.state.endswith ("H")).show ()
print ("Filter contains H")
df.filter (df.state.contains ("H")).show ()
data2 = [(2,"Michael Rose"),(3,"Robert Williams"), (4,"Rames Rose"),(5,"Rames rose")]
df2 = spark.createDataFrame (data = data2, schema = ["id", "name"])
print ("Filter name like rose")
df2.filter(df2.name.like ("%rose%")).show ()
print ("Filter name like regexp (?i)^*rose$")
df2.filter(df2.name.rlike ("(?i)^*rose$")).show () # Regexp
print ("Filter array contains Java as language")
df.filter (array_contains (df.languages,"Java")).show (truncate = False) # Array
print ("Filter struct name.lastname = Williams")
df.filter (df.name.lastname == "Williams").show (truncate = False) # Struct

# Duplicates, distinct, drop
data = [("James", "Sales", 3000), ("Michael", "Sales", 4600), ("Robert", "Sales", 4100), ("Maria", "Finance", 3000), ("James", "Sales", 3000), \
        ("Scott", "Finance", 3300), ("Jen", "Finance", 3900), ("Jeff", "Marketing", 3000), ("Kumar", "Marketing", 2000), ("Saif", "Sales", 4100)]
columns= ["employee_name",  "department", "salary"]
df = spark.createDataFrame (data = data, schema = columns)
distinctDF = df.distinct ()
print ("Distinct count: " + str (distinctDF.count ()))
df2 = df.dropDuplicates ()
print ("Count after drop duplicates: "+str (df2.count ()))
dropDisDF = df.dropDuplicates (["department","salary"]) # List of distinct columns
print ("Distinct count of department & salary : " + str (dropDisDF.count ()))

# Sort, order by
simpleData = [("James","Sales","NY",90000,34,10000), ("Michael","Sales","NY",86000,56,20000), ("Robert","Sales","CA",81000,30,23000), ("Maria","Finance","CA",90000,24,23000), \
              ("Raman","Finance","CA",99000,40,24000), ("Scott","Finance","NY",83000,36,19000), ("Jen","Finance","NY",79000,53,15000), ("Jeff","Marketing","CA",80000,25,18000), \
              ("Kumar","Marketing","NY",91000,50,21000)]
columns = ["employee_name", "department", "state", "salary", "age", "bonus"]
df = spark.createDataFrame (data = simpleData, schema = columns)
print ("Sorted by department then state")
df.sort ("department", "state").show (truncate = False)
print ("Order by department, state asc, salary desc")
df.orderBy (col("department").asc (), col("state").asc (), col("salary").desc()).show (truncate = False)
print ("Free hand sorting")
df.createOrReplaceTempView ("EMP")
spark.sql ("select employee_name, department,state,salary,age,bonus from EMP ORDER BY department asc, salary desc").show (truncate = False)

# Row, Col objects
row = Row ("James",40)
print ("Row object construct")
print(row[0] + "," + str (row[1]))
Person = Row ("name", "age")
p1=Person ("James", 40)
p2=Person ("Alice", 35)
print (p1.name + "," + p2.name)
print ("Nested Row strucure")
data=[Row(name="James",prop=Row(hair="black",eye="blue")), Row(name="Ann",prop=Row(hair="grey",eye="black"))]
df=spark.createDataFrame(data)
df.printSchema()

# Col operators
data=[("James","Bond","100",None), ("Ann","Varsa","200","F"), ("Tom", "Cruise","400","M"), ("Tom", "Brand","400", "M"), ("Csacso", "Bacsi","100", "M")]
columns=["fname", "lname", "id", "gender"]
df=spark.createDataFrame (data, columns)
print ("Concat")
df.select (expr (" fname ||','|| lname").alias ("fullName")).show ()
print ("Cast id to int")
df.select (df.fname,df.id.cast ("int")).printSchema ()
print ("Between")
df.filter (df.id.between (100, 300)).show ()
print ("is null?")
df.filter (df.gender.isNotNull ()).show ()
df.filter (df.lname.isNotNull ()).show ()
print ("Substring")
df.select (df.fname.substr (1,2).alias ("substr")).show ()

# Group by
simpleData = [("James","Sales","NY",90000,34,10000), ("Michael","Sales","NY",86000,56,20000), ("Robert","Sales","CA",81000,30,23000), ("Maria","Finance","CA",90000,24,23000),
              ("Raman","Finance","CA",99000,40,24000), ("Scott","Finance","NY",83000,36,19000), ("Jen","Finance","NY",79000,53,15000), ("Jeff","Marketing","CA",80000,25,18000),
              ("Kumar","Marketing","NY",91000,50,21000)]
schema = ["employee_name", "department", "state", "salary", "age", "bonus"]
df = spark.createDataFrame (data = simpleData, schema = schema)
print ("Sum by dept")
df.groupBy ("department").sum ("salary").show (truncate = False)
print ("Count by dept")
df.groupBy ("department").count ().show () 
print ("Min salary by dept")
df.groupBy ("department").min ("salary").show ()
print ("Avg salary by dept")
df.groupBy ("department").avg ( "salary").show ()
print ("Sum salary, bonus by dept and state")
df.groupBy("department","state").sum ("salary","bonus").show ()
print ("Multiple aggregates")
df.groupBy ("department").agg (sum ("salary").alias ("sum_salary"), \
   avg ("salary").alias ("avg_salary"), sum ("bonus").alias ("sum_bonus"), max ("bonus").alias ("max_bonus")).show (truncate = False)
df.groupBy ("department").agg (sum ("salary").alias ("sum_salary"), \
   avg ("salary").alias("avg_salary"), sum ("bonus").alias ("sum_bonus"), max ("bonus").alias ("max_bonus")) \
   .where (col ("sum_bonus") >= 50000).show (truncate = False)

# Union
simpleData = [("James","Sales","NY",90000,34,10000), ("Michael","Sales","NY",86000,56,20000), ("Robert","Sales","CA",81000,30,23000), ("Maria","Finance","CA",90000,24,23000)]
columns= ["employee_name", "department", "state", "salary", "age", "bonus"]
df = spark.createDataFrame (data = simpleData, schema = columns)
simpleData2 = [("James","Sales","NY",90000,34,10000), ("Maria","Finance","CA",90000,24,23000), ("Jen","Finance","NY",79000,53,15000), ("Jeff","Marketing","CA",80000,25,18000), \
               ("Kumar","Marketing","NY",91000,50,21000)]
columns2= ["employee_name", "department", "state", "salary", "age", "bonus"]
df2 = spark.createDataFrame (data = simpleData2, schema = columns2)
print ("Union of two DFs")
unionDF = df.union (df2)
unionDF.show (truncate = False)
print ("Union without duplicates")
disDF = df.union (df2).distinct ()
disDF.show (truncate = False)

# Map, flat map
print ("Map with RDD")
data = ["Project","Gutenberg's","Alice's","Adventures", "in","Wonderland","Project","Gutenberg's","Adventures", "in","Wonderland","Project","Gutenberg's"]
rdd = sc.parallelize (data)
rdd2 = rdd.map (lambda x: (x,1))
print ("Map elements")
for element in rdd2.collect ():
    print (element)

print ("Map with DF")
data = [('James','Smith','M',30), ('Anna','Rose','F',41), ('Robert','Williams','M',62),]
columns = ["firstname","lastname","gender","salary"]
df = spark.createDataFrame(data = data, schema = columns)

rdd2 = df.rdd.map (lambda x: (x[0]+","+x[1],x[2],x[3]*2)) # RDD has map () only
df2 = rdd2.toDF (["name","gender","new_salary"]) # Convert to DF
df2.show ()
rdd2 = df.rdd.map (lambda x: (x.firstname+","+x.lastname,x.gender,x.salary*2)) # Referring with column names
rdd2 = df.rdd.map (lambda x: (x["firstname"]+","+x["lastname"],x["gender"],x["salary"]*2)) 

print ("Flat map")
data = ["Project Gutenberg's", "Alice's Adventures in Wonderland", "Project Gutenberg's", "Adventures in Wonderland", "Project Gutenberg's"]
rdd = spark.sparkContext.parallelize (data)
rdd2 = rdd.map (lambda x: x.split (" ")) # Creates a list after split ["Project", "Gutenberg's"]
print ("Map:")
for element in rdd2.collect ():
    print (element)
print ("Flat map:")
rdd2 = rdd.flatMap (lambda x: x.split (" ")) # Flattens the list after split ["Project"], ["Gutenberg's"]
for element in rdd2.collect ():
    print (element)

arrayData = [('James',['Java','Scala'],{'hair':'black','eye':'brown'}), ('Michael',['Spark','Java',None],{'hair':'brown','eye':None}),
             ('Robert',['CSharp',''],{'hair':'red','eye':''}), ('Washington',None,None), ('Jefferson',['1','2'],{})]
df = spark.createDataFrame (data = arrayData, schema = ['name','knownLanguages','properties'])
df2 = df.select (df.name,explode(df.knownLanguages))
df2.printSchema ()
df2.show ()


