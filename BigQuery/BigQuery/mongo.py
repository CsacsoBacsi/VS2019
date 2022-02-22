# --------------------------------------------------------------------

# Package imports
import os
import sys
import pymongo
from pymongo import InsertOne, DeleteOne, ReplaceOne
from MongoData import customers, orders, mylist, mylist2, tutorial1, tutorial2, tutorial3, tutorial4, tutorial5, \
                      tutorial6, persons, org1, employee1, employee2, stackof, arr, students, students2
from pprint import pprint
import json

# --------------------------------------------------------------------

# ***** MongDb connection *****
# Create connection client 
myclient = pymongo.MongoClient ("mongodb://localhost:27017/") # Local db on my laptop
print (myclient.list_database_names ()) # List of dbs available via this client

#myclient = pymongo.MongoClient("mongodb+srv://dbAdmin:Fat1ma72@cluster0.fy6b8.mongodb.net/test") # Mongo Atlas Cloud Db name is 'test' pwd:Mongo68!
db = myclient ["test"] # Dict or . (dot) notation
col_tutorial = db.tutorial # Collection definition. Delayed -> has to have documents added to it

# Delete many documents
print ('--- Delete collections ---')
result = col_tutorial.delete_many ({'author': "Alex"})
print (result.deleted_count)
result = col_tutorial.delete_many ({'author': "David"})
print (result.deleted_count)
result = col_tutorial.delete_many ({'author': "Lucas"})
print (result.deleted_count)
result = col_tutorial.delete_many ({'author': None})
print (result.deleted_count)
result = col_tutorial.delete_many ({}) # Delete all documents
print (result.deleted_count)

mycol = db ["customers"] # Creates new collection. Does not exist until populated 
mycol.drop () # Drops the collection
mycol = db ["customers"] 
print (db.list_collection_names ()) # Lists of collections in database

# --------------------------------------------------------------------

# ***** Populate collections *****
# Insert 1 document
result = col_tutorial.insert_one(tutorial1)
print (f"One tutorial: {result.inserted_id}")

# Insert 5 (many) documents
new_result = col_tutorial.insert_many ([tutorial2, tutorial3, tutorial4, tutorial5, tutorial6])
print (f"Multiple tutorials: {new_result.inserted_ids}")

# Insert without ids
mydict = { "name": "John", "address": "Highway 37" }

result = mycol.insert_one (mydict)
print (result) # Prints the generated Id

print ('Inserted document ids:')
result = mycol.insert_many (mylist)
print (result.inserted_ids)
print ('--------')

# Insert with IDs
result = mycol.insert_many (mylist2)
print (result.inserted_ids)
print ('--------')

# --------------------------------------------------------------------

# ***** Find (SELECT) documents (rows) *****
# Find all documents in collection 'tutorial'
for doc in col_tutorial.find ():
    print (doc)

# Find documents satisfying filter criteria
alex_tutorial = col_tutorial.find_one ({"author": "Alex"})
print (alex_tutorial)

# Null check
# Does field exist?
print ('--- Exists? ---')
query = {"author": {"$exists": True}} # Checks if field author exists
for doc in col_tutorial.find (query):
    print (doc)

# Type 10 (null) check
print ('--- Of type null? ---')
query = {"author": {"$type": 10}} # BSON type null which is 10
for doc in col_tutorial.find (query):
    print (doc)

# None check
print ('--- Is it None? ---')
query = {"author": {"$eq": None}} # None check
for doc in col_tutorial.find (query):
    print (doc)
print ('--------')

result = mycol.find_one () # Finds first occurence
print (result)
print ('--------')

for doc in mycol.find({},{ "_id": 0, "name": 1, "address": 1 }): # Like SELECT  name, address FROM collection, not the _id
    print (doc)
print ('--------')

# Equal
for doc in mycol.find ({},{ "address": 0 }):
    print (doc)
print ('--------')

myquery = { "address": "Park Lane 38" } # Filter
mydoc = mycol.find (myquery)

for doc in mydoc:
  print (doc)
print ('--------')

# Greater than
myquery = { "address": { "$gt": "S" } } # Starts with S or higher
mydoc = mycol.find (myquery)

for doc in mydoc:
    print (doc)
print ('--------')

# Regex
myquery = { "address": { "$regex": "^S" } } # Regex start with S
mydoc = mycol.find (myquery)

for doc in mydoc:
    print (doc)
print ('--------')

# Array match
mydoc = db.tutorial.find ( { "contributors": ["Aldren", "Joanna", "Jacob"] } )
for doc in mydoc:
    print (doc)
print ('--------')

mydoc = db.tutorial.find ( { "contributors": "Aldren" } )
for doc in mydoc:
    print (doc)
print ('--------')

# In
qtest = db.qtest
query = {"id": {"$in": [0, 1, 2, 3, 4, 5]}} 
qtest.delete_many (query) # Delete docs that match query criteria

# Logical AND
qtest.insert_many (persons)
mydoc = db.qtest.find ({"$and": [{"age": 33},
                                {"name": {"$ne": "Annx"}}, # Not equal
                                {"dims.height": 25}]
                      }) 
for doc in mydoc:
    print (doc)
print ('--------')

# Logical OR
mydoc = db.qtest.find ({"$or": [{"age": 33},
                                {"name": {"$eq": "Ben"}},
                                {"dims.length": 50}]
                      }) 
for doc in mydoc:
    print (doc)
print ('--------')

# Count
result_int = qtest.count_documents( { "age": { "$gt": 25 } } )
print (result_int) # Singleton value
results = qtest.find ({ "age": { "$gt": 25 } })
result_int = results.count (True) # Deprecated
print (result_int)
print ('--------')

# Average across whole document not group by a column
results = qtest.aggregate([
  {"$group": {"_id": None, "avg_age": { "$avg": "$age" } } } 
])
for doc in results:
    print (doc)
print ('--------')

# Select from array using index
mydoc = db.tutorial.find ({"$or": [{"author": "David"}, {"author": "Alex"}]}, { "contributors": {"$slice": [1,1] } }) # Second position in the array
for doc in mydoc:
    print (doc)
print ('--------')

mydoc = db.tutorial.find ({"$or": [{"author": "David"}, {"author": "Alex"}]}, { "contributors": {"$slice": [1,2] } })
for doc in mydoc:
    print (doc)
print ('--------')

# Sort
mydoc = mycol.find().sort("name", -1) # Descending order
for x in mydoc:
  print(x)
print ('--------')

# Limit
myresult = mycol.find ().limit (5) # First five rows
for doc in myresult:
    print (doc)

# Elem match
col_ord = db.order
print ('--- Elem match ---')
docs = col_ord.find ( { "items" : { "$elemMatch" : { "amount" : 2, "unit price" : 5000 } } } )
for doc in docs:
    pprint (doc)

# Distinct
print ('--- Distinct ---')
docs = col_ord.distinct ( "items.prod id"  )
for doc in docs:
    pprint (doc)

# --------------------------------------------------------------------

# ***** Update *****
# Update rows that satisfy query
myquery = { "address": "Valley 345" }
newvalues = { "$set": { "address": "Canyon 123" } }
mycol.update_one (myquery, newvalues)
for doc in mycol.find():
    print (doc)
print ('--------')

myquery = { "address": { "$regex": "^S" } }
newvalues = { "$set": { "name": "Minnie" } }
result = mycol.update_many (myquery, newvalues)
for doc in mycol.find():
    print (doc)
print ('--------')
print (result.modified_count, "documents updated.")

# Update, add nested array of ints
myquery = { "name": {"$eq": "Ann" } }
newvalues = { "$set": { "ints":[1, 5, 10, 3, 8]} }
result = qtest.update_many (myquery, newvalues)
for doc in qtest.find():
  print (doc)
print ('--------')

# Rename fields
result = qtest.update_many ({"id": 1}, {"$rename": {"age": "aged", "name": "named"}})
for doc in qtest.find():
  print (doc)
print ('--------')

# Max, min
result = qtest.update_many ({"id": 1}, {"$max": {"aged": 60}}) # Updates age to 60 if current value is less than that
for doc in qtest.find():
  print (doc)
print ('--------')
result = qtest.update_many ({"id": 1}, {"$rename": {"aged": "age", "named": "name"}}) # Restore field names

# --------------------------------------------------------------------

# ***** Delete *****
cons = db.list_collection_names ()
result = mycol.delete_many({}) # Delete all documents in a collection
print (result.deleted_count, " documents deleted.")

print (db.list_collection_names ())
print ('--------')

mycol.drop () # Drop the whole collection. Does not return anything!!!
print (db.list_collection_names ())
print ('--------')

# --------------------------------------------------------------------

# ***** Join via foreign key *****
col_org = db.org

result = col_org.update_one ({"_id":org1["_id"]}, {"$set": org1}, upsert=True) # Checks org1 _id and if it is different to the filter, raises an exception!
print (f"Collection organisation (company) matched: {result.matched_count}, modified: {result.modified_count}")

for employee in [employee1, employee2]:
    result = col_org.update_one ({"_id": employee["_id"]}, {"$set": employee}, upsert=True)
    print (f"Collection organisation (employee) matched: {result.matched_count}, modified: {result.modified_count}")

employees = col_org.find ({"age": {"$lt": 53}}, { "_id": 0, "name": 1, "age": 1, "organisation": 1 })
for employee in employees:
    print (employee)
    # Find organisation(s) of employees
    organisation = col_org.find ({"_id": employee["organisation"]}, { "_id": 0, "company name": 1, "owner": 1 })
    for this_org in organisation:
        employee.update (this_org) # Add organisation to employee JSOM
        print (employee)

# --------------------------------------------------------------------

# ***** Transactions *****
# Only runs on instances with replication copies. MongoDb Atlas
'''
def callback (session):
    col_pers = db.qtest
    col_org = db.org

    result = col_pers.update_one ({"name": "Lucas"}, {"$inc": {"age": 10}}, session=session)
    result = col_org.update_one ({"_id":0}, {"$set": org1}, upsert=True, session=session) # If this fails, the transaction fails. Lucas does not get updated

with myclient.start_session() as session:
    session.with_transaction (callback)
'''

# --------------------------------------------------------------------

# ***** Aggregations *****
col_cust = db.customer
col_cust.delete_many ({})
col_ord.delete_many ({})

col_cust.insert_many (customers)
col_ord.insert_many (orders)

# Match, sum, groupby, multiply
docs = col_ord.aggregate ([{"$match": {"status": "C"}}, {"$group" : {"_id": "$cust id",  "num_orders" : {"$sum" : 1} }} ])
for doc in doc:
    print (doc)

# Needs double sum: per array and per group
docs = col_ord.aggregate ([{"$match": {"status": "C"}}, {"$group" : {"_id": "$cust id",  "num_orders" : {"$sum": {"$sum": "$items.amount"}} }} ])
for doc in docs:
    print (doc)

# Unwind flattens the array
print ('-------')
docs = col_ord.aggregate ([{"$match": {"status": "C"}}, {"$unwind": "$items"},{"$group" : {"_id": "$cust id",  "num_orders" : {"$sum": "$items.amount"} }} ])
for doc in docs:
    print (doc)

# Unwind only
print ('--- Unwind items ---')
docs = col_ord.aggregate ([
    {"$match": {"status": "C"}},
    {"$unwind": "$items"},
    {"$match": {"items.unit price": {"$in": [5000, 2000, 1000] } } }
])
for doc in docs:
    print (doc)

# Amount * unit price summed
print ('-------')
docs = col_ord.aggregate ([{"$match": {"status": "C"}}, {"$unwind": "$items"},{"$group" : {"_id": "$cust id",  "num_orders" : {"$sum": {"$multiply": ["$items.amount", "$items.unit price"]} }}} ])
for doc in docs:
    print (doc)

# Match, and, or
print ('-------')
docs = col_ord.aggregate ([
    {"$match": {"$and": [{"status": "C"}, 
                         {"$or": [{"items.unit price": 5000}, {"items.unit price": 2000} ] } ]
    }          }
])
for doc in docs:
    print (doc)

# Complete aggregate pipeline
print ('-------')
docs = col_ord.aggregate([
  { '$match' : { 'status' : 'C' } },
  #{ '$unwind' : '$items' },
  { "$group" : {"_id": "$cust id",  "num_orders" : {"$sum": {"$sum": "$items.amount"} } } }, # Double sum notation - does not require unwind
  { '$project' : { 'order num' : 1, 'cust id' : 1, 'num_orders': 1, "items": 1} },
                  # "items": {"$filter": {"input": "$items", "as": "csacsi", "cond": {"$gt": ["$$csacsi.amount", 1]} } } } },
  { '$addFields' : { 'company' : 'BiXtorp' } },
  { '$sort' : { 'items.amount' : -1 } }
])
for doc in docs:
    print (doc)

# Filter output columns (array filter)
print ('-------')
docs = col_ord.aggregate([
  { '$match' : { 'status' : 'C' } },
  { '$project' : { "_id": 0,'order num' : 1, 'cust id' : 1, 'num_orders': 1,
                  "items": {"$filter": {"input": "$items", "as": "csacsi", "cond": {"$gt": ["$$csacsi.amount", 2]} } } } },
  { '$addFields' : { 'company' : 'BiXtorp' } },
  { '$sort' : { 'items.amount' : -1 } }
])
for doc in docs:
    pprint (doc)

# First, last
print ('First, last-------')
docs = col_ord.aggregate([
  {'$sort': {'order num': 1}},
        {'$group': {'_id': None, 'first': {'$first': '$order num'}, 'last': {'$last': '$order num'}}}
])
for doc in docs:
    pprint (doc['last'])

# ROW_NUMBER

#SELECT SubSet.* 
#FROM (SELECT T.cust id as customer, T.order num, T.status 
#      ROW_NUMBER () OVER ( PARTITION BY T.cust id ORDER BY T.cust id ) AS rn 
#      FROM col_ord e T ) SubSet
#WHERE SubSet.rn = 1

docs = col_ord.aggregate ([
    { "$sort": {"cust id": 1}},
    { "$group": {
        "_id": "$cust id",
        "order num": { "$first": "$order num" },
        "status": { "$first": "$status" },
        "customer": { "$first": "$cust id" }
    }},
    { "$project": {"_id": 0, "customer": 1, "order num": 1, "status": 1}}
])
for doc in docs:
    pprint (doc)

# Switch, condition
docs = qtest.aggregate([
  { "$project": {"name": "$name", "age": "$age",
    "age group": {"$switch": {"branches": [
          { "case": { "$gt": ["$age", 50] }, "then": "Hakf century" },
          { "case": { "$gt": ["$age", 40] }, "then": "Nice age" },
          { "case": { "$gt": ["$age", 30] }, "then": "Strong" },
          { "case": { "$gt": ["$age", 20] }, "then": "Young" },
        ],
        "default": "Child"
      }},
    "Adult": {'$cond':[{'$gt':['$age', 20]}, True, False]}
     }
  }
])
for doc in docs:
    print (doc)

# --------------------------------------------------------------------

# ***** Misc *****
# Bulk write
print ('Bulk write----------')
for doc in qtest.find ({}):
    print (doc)

requests = [InsertOne ({
    "id": 4,
    "name": "Ben",
    "dims": {
        "width": 80,
        "length": 30,
        "height": 30
    },
    "age": 40
}), DeleteOne ({
    "id": 1,
    "name": "Ben",
    "dims": {
        "width": 80,
        "length": 30,
        "height": 30
    },
    "age": 40
}), ReplaceOne ({
    "id": 2,
    "name": "Ann",
    "dims": {
        "width": 60,
        "length": 80,
        "height": 25
    },
    "age": 33
}, {
    "id": 2,
    "name": "Annie",
    "dims": {
        "width": 70,
        "length": 50,
        "height": 25
    },
    "age": 41
}, upsert=True)]
result = qtest.bulk_write (requests)
result.inserted_count
result.deleted_count
result.modified_count
result.upserted_ids

print ('After:')
for doc in qtest.find ({}):
    print (doc)

# --------------------------------------------------------------------

# Indices
qtest.drop_indexes ()
'''
qtest.drop_index ("query order attributes")
qtest.drop_index ("query order items")
qtest.drop_index ("query order items amount")
'''

qtest.create_index ([("order num", pymongo.DESCENDING), ("cust id", pymongo.DESCENDING)], name = "query order attributes") # Sorting supports sort_order
qtest.create_index ([("items", pymongo.DESCENDING)], name = "query order items" ) # Multi key index
qtest.create_index ([("items.amount", pymongo.ASCENDING)], name = "query order items amount" ) # Single key index on embedded field


# --------------------------------------------------------------------

# Joins
# Lookup
print ('Lookup-------')
x = col_ord.aggregate ([
    {
     "$lookup":
       {
         "from": "customer",
         "localField": "cust id",
         "foreignField": "cust id",
         "as": "customer details"
       }
  }    
])
for doc in x:
    print ('-')
    pprint (doc)

# --------------------------------------------------------------------

# Map/reduce
col_imp = db.impressions
col_imp.delete_many({})

col_imp.insert_many (stackof)

print ('--- MapReduce ---')
docs = col_imp.aggregate([{'$unwind': '$impressions'},
   # {'$match': {'impressions.service': 'furniture'}}
   {'$addFields' : { 'cnt' : 1 } }, # Map  1 to each row
   {'$group': {'_id': {"id": "$impressions.id","service": '$impressions.service'}, 'impressions_count': {'$sum': '$cnt'}}}, # Map reduce
   {'$project' : {'_id': 1, 'impressions_count': 1}}
    ])

for doc in docs:
    print (doc)

# --------------------------------------------------------------------

# *** Array operations ***
# Push, pop, pull, each
col_arr = db.arrays
col_arr.delete_many({})

col_arr.insert_many (arr)

print ('--- Array ops ---')
col_arr.update_many(
   { "id": 1 },
   { "$push": { "scores": 89 } } # Add a single item to the array
)
for doc in col_arr.find ({}):
    print (doc)

print ('--- Push ---')
col_arr.update_many (
   { "id": 0 },
   { "$push": { "scores": {
       "$each": [51, 55, 59, 42] , # Add multiple items to the array
       "$sort": { "scores": -1 } } } }
)
for doc in col_arr.find ({}):
    print (doc)

print ('--- Push at position ---')
col_arr.update_many (
   { "id": 0 },
   { "$push": { "scores": {
       "$each": [99, 999], # Add multiple items to the array
       "$position": 3, # at position 3. Use negative position to count from the end of the array
       "$sort": { "scores": -1 } } } }
)
for doc in col_arr.find ({}):
    print (doc)

print ('--- Pop ---') # Removes first or last item from array
col_arr.update_many (
   { "id": 0 },
   { "$pop": { "scores": 1}} # Removes last item from the array
)
for doc in col_arr.find ({}):
    print (doc)

print ('--- Pull ---')
col_arr.update_many (
   { }, # All documents
   { "$pull": { "scores": {"$gt": 50}}} # Removes items greater than 50 from the array
)
for doc in col_arr.find ({}):
    print (doc)

col_stu = db.students
col_stu.delete_many ({})
col_stu.insert_many (students)
col_stu2 = db.students2
col_stu2.delete_many ({})
col_stu2.insert_many (students2)

# Array element modifications
print ('--- $ ---')
col_stu.update_one (
   { "id": 1, "grades": 92 },
   { "$set": { "grades.$": 82 } } # Updates first occurence of 92 to 82. $ is the position not known before the query filter. $ is the query result's first matched element
)
for doc in col_stu.find ({}):
    print (doc)
print ('---------')

col_stu2.update_one (
   { "id": 1, "grades.grade": 95 },
   { "$set": { "grades.$.mean" : 105 } } # Updates array element's mean value that satisfies the query
)
for doc in col_stu2.find ({}):
    print (doc)
print ('---------')

print ('--- $[] ---')
col_stu.update_many (
   { }, # Updates all elements in the array
   { "$inc": { "grades.$[]": 10 } },
   upsert = True
)
for doc in col_stu.find ({}):
    print (doc)
print ('---------')

col_stu2.update_many (
   { }, # Updates all documents in the array
   { "$inc": { "grades.$[].mean" : -2 } },
   upsert = True
)
for doc in col_stu2.find ({}):
    print (doc)
print ('---------')

col_stu.update_many (
   { }, # Updates all elements in the array based on the array filter
   { "$set": { "grades.$[elem]": 99 } },
     array_filters = [ { "elem": {"$gt": 100 }} ],
     upsert = True 
)
for doc in col_stu.find ({}):
    print (doc)
print ('---------')

col_stu2.update_many (
   { }, # Updates all documents in the array based on the array filter
   { "$set": { "grades.$[elem].grade": 99 } },
     array_filters = [ { "elem.grade": 100 } ],
     upsert = True 
)
for doc in col_stu2.find ({}):
    print (doc)
print ('---------')

# --------------------------------------------------------------------

# *** Value in a document less than the collection average (trying ti find a solution) ***
# Needs two query!
qtest.delete_many (query) # Delete docs that match query criteria
qtest.insert_many (persons)

# Value greater than average
result = qtest.find( {"$expr": {"$gt": [ { "$avg": "$dims.length" }, "$dims.length" ] } }, { "average_length": { "$avg": "$dims.length" } })
for doc in result:
    print (doc)
print ('---------')

result = qtest.aggregate([
  {"$group": {
    "_id": None, 
    "avg_length": { "$avg": "$dims.length" }, 
    "avg_height": { "$avg": "$dims.height" },
    "ind_length": { "$addToSet": "$dims.length"}, # Individual lengths that belong to the group that was averaged. In this case: all of them
    "ind_name": { "$addToSet": "$name"}
  }},
  { "$project": {"average length":"$avg_length", "individual length": {"$filter": {"input": "$ind_length", "as": "ind_length", "cond": {"$lt": ["$$ind_length", "$avg_length"]}}},
                 
    "individual name":"$ind_name"}}
])
for doc in result:
    print (doc)
print ('---------')


# --------------------------------------------------------------------

os.system ("pause")
