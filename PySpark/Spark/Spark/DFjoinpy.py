from Spark import sc, spark
from pyspark.sql.functions import col, struct, when, lit
from pyspark.sql.types import StructType, StructField, StringType, IntegerType, DoubleType, BooleanType, ArrayType, MapType

emp = [(1,"Smith",-1,"2018","10","M",3000), (2,"Rose",1,"2010","20","M",4000), (3,"Williams",1,"2010","10","M",1000), (4,"Jones",2,"2005","10","F",2000), \
       (5,"Brown",2,"2010","40","",-1), (6,"Brown",2,"2010","50","",-1)]
empColumns = ["emp_id", "name", "superior_emp_id", "year_joined", "emp_dept_id", "gender", "salary"]
dept = [("Finance",10), ("Marketing",20), ("Sales",30), ("IT",40)]
deptColumns = ["dept_name", "dept_id"]
empDF  = spark.createDataFrame (data = emp, schema = empColumns)
deptDF = spark.createDataFrame (data = dept, schema = deptColumns)

# Inner
empDF.join (deptDF, empDF.emp_dept_id == deptDF.dept_id, "inner").show (truncate = False)
# Full outer
empDF.join (deptDF, empDF.emp_dept_id == deptDF.dept_id, "fullouter").show (truncate = False)
# Left outer
empDF.join (deptDF, empDF.emp_dept_id == deptDF.dept_id, "leftouter").show (truncate = False)
# Left semi (only rows from left table where inner join to right table is satisfied)
empDF.join (deptDF, empDF.emp_dept_id == deptDF.dept_id, "leftsemi").show (truncate = False)
# Left anti (opposite of Left semi)
empDF.join (deptDF, empDF.emp_dept_id ==  deptDF.dept_id, "leftanti").show (truncate = False)
# Self
empDF.alias ("emp1").join (empDF.alias ("emp2"), col ("emp1.superior_emp_id") == col ("emp2.emp_id"), "inner") \
                    .select (col ("emp1.emp_id"), col ("emp1.name"), col ("emp2.emp_id").alias ("superior_emp_id"), col ("emp2.name").alias ("superior_emp_name")) \
                    .show (truncate = False) # Col object is needed!

# Free hand
empDF.createOrReplaceTempView ("EMP")
deptDF.createOrReplaceTempView ("DEPT")
joinDF = spark.sql ("select * from EMP e, DEPT d where e.emp_dept_id == d.dept_id").show (truncate = False)
joinDF2 = spark.sql("select * from EMP e INNER JOIN DEPT d ON e.emp_dept_id == d.dept_id").show (truncate = False)
# Multi
#df1.join (df2,df1.id1 == df2.id2, "inner").join(df3,df1.id1 == df3.id3, "inner")
