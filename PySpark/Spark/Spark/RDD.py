from pyspark import StorageLevel
import shutil
from Spark import sc

helloFile = "file:///home/tut/hello.cpp" # On Ubuntu
helloFile = "D:\Git\PySpark\Spark\Spark\hello.cpp" # On Windows
data = [1,2,3,4,5,6,7,8,9,10,11,12]

rdd = sc.parallelize (data)
rdd3 = sc.wholeTextFiles ("D:\Git\PySpark\Spark\Spark") # Read all text files in directory
#print (rdd3.collect ())


# RDD partitioning
print("initial partition count:" + str (rdd.getNumPartitions ()))
reparRdd = rdd.repartition (4)
print("re-partition count:" + str (reparRdd.getNumPartitions ()))
coalRdd = reparRdd.coalesce (2)
print("coalesced count:" + str (coalRdd.getNumPartitions ()))

# RDD transformations
rdd = sc.textFile ("test.txt")
rdd2 = rdd.map (lambda x: x.split (" ")) # Map returns same element
#print (rdd2.collect ())
rdd22 = rdd.flatMap (lambda x: x.split (" ")) # Map returns more elements. 1 to many transform
#print (rdd22.collect ())
rdd3 = rdd22.map (lambda x: (x,1))
#print (rdd3.collect ())
rdd5 = rdd3.reduceByKey (lambda a,b: a+b) # Input is K, V pairs. a = accumulator value, b = current value
#print (rdd5.collect ())
rdd6 = rdd5.map (lambda x: (x[1],x[0])).sortByKey (False) # Swaps fields then orders in descending order
#print (rdd6.collect ())
rdd4 = rdd6.filter (lambda x : 'an' in x[1])
#print (rdd4.collect ())
rdd2 = sc.textFile (helloFile).cache ()
numAs = rdd2.filter (lambda s: 'a' in s).count ()
numBs = rdd2.filter (lambda s: 'b' in s).count ()
print ("Lines with a: %i, lines with b: %i" % (numAs, numBs))
print ()

# RDD actions
'''
[(27, 'This'), (27, 'eBook'), (27, 'is'), (27, 'for'), (27, 'the'), (27, 'use'), (27, 'of'), (27, 'anyone'), (27, 'anywhere'), 
(27, 'at'), (27, 'no'), (27, 'cost'), (27, 'and'), (27, 'with'), (18, 'Alice's'), (18, 'Adventures'), (18, 'in'), (18, 'Wonderland'),
(18, 'by'), (18, 'Lewis'), (18, 'Carroll'), (9, 'Project'), (9, 'Gutenberg's')]
'''

print ("Count : "+str (rdd6.count ()))
firstRec = rdd6.first () # firstRec	(27, 'This') tuple
print ("First Record : " + str (firstRec[0]) + "," + firstRec[1])
datMax = rdd6.max ()
print ("Max Record : " + str (datMax[0]) + "," + datMax[1])
totalWordCount = rdd6.reduce (lambda a,b: (a[0] + b[0], b[1])) # a = first row, b = next row, a[1] = first row tuple's second elememt
print ("dataReduce Record : " + str (totalWordCount[0]))
totalWordCount2 = rdd6.reduce (lambda a,b: (a[0] + b[0], "Sum")) # a = first row, b = next row
print ("dataReduce2 Record : " + str (totalWordCount2))
data3 = rdd6.take(3) # Takes the first 3 rows
for f in data3:
    print ("data3 Key:"+ str (f[0]) +", Value:" + f[1])
data = rdd6.collect ()
for f in data:
    print ("Key:"+ str (f[0]) + ", Value:" + f[1])

dir_path = 'wordcount'
try:
    shutil.rmtree (dir_path)
except OSError as e:
    print ("Error: %s : %s" % (dir_path, e.strerror))

rdd6.saveAsTextFile ("wordCount")

# RDD storage
cachedRdd = rdd.cache () # Default, memory only. Calls persist command
rddPersist = rdd.persist (StorageLevel.MEMORY_ONLY)
'''
MEMORY_ONLY,MEMORY_AND_DISK, MEMORY_ONLY_SER, MEMORY_AND_DISK_SER, DISK_ONLY, 
MEMORY_ONLY_2,MEMORY_AND_DISK_2
'''
rddPersist2 = rddPersist.unpersist ()

# Shared variables
broadcastVar = sc.broadcast ([0, 1, 2, 3]) # Data pushed to all nodes to be joined with hefty dataset
print (broadcastVar.value)
# Accumulators
num = sc.accumulator (1)
def f (x):
  global num
  num +=x
rdd = sc.parallelize ([2,3,4,5])
rdd.foreach (f)
final = num.value
print ("Accumulated value is -> %i" % (final))

# Empty RDD
emptyRDD = sc.emptyRDD ()
print (emptyRDD)
emptyRDD2 = sc.parallelize ([])
print (emptyRDD2)

print ()