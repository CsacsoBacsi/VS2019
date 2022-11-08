
#cd $SPARK_HOME or cd /home/spark-3.1.1-bin-hadoop3.2/bin
#./sbin/start-master.sh
#bin/pyspark --master spark://CsacsiLaptop.localdomain:7077 --executor-memory 1500mb
#sudo service ssh start
# WinSCP
# ./spark-submit --master spark://CsacsiLaptop.localdomain:7077 Spark.py

from pyspark.sql import SparkSession

# Create SparkSession and context
spark = SparkSession.builder.master ("local[1]").appName ("Spark By Examples tutorial").getOrCreate ()
sc = spark.sparkContext
sc.setLogLevel ("WARN")
