# --------------------------------------------------------------------

import datetime
import threading
from time import sleep
from google.cloud import firestore_v1
import firebase_admin
from firebase_admin import credentials
import sys
import os

# --------------------------------------------------------------------

cred = credentials.Certificate("D:/Google/organic-palace-306416-firebase-adminsdk-23tbh-ded810a1c3.json")
firebase_admin.initialize_app(cred)

# First attempt
# Add a new document: GOOGLE_APPLICATION_CREDENTIALS=D:\Google\My First Project-cadc535bd037.json
db = firestore_v1.Client(project='organic-palace-306416')

doc_ref = db.collection(u'users').document(u'alovelace')
doc_ref.set({
    u'first': u'Ada',
    u'last': u'Lovelace',
    u'born': 1815,
    u'age': 15,
    u'favorites': {
        u'food': u'Steak',
        u'color': u'Blue',
        u'subject': u'Recess'
    },
    u'department': u'FIN'
})

# Then query for documents
users_ref = db.collection(u'users')

for doc in users_ref.stream():
    print(u'{} => {}'.format(doc.id, doc.to_dict()))

# --------------------------------------------------------------------

# Tutorial
# *** Adding data ***
data = {
    u'name': u'Los Angeles',
    u'state': u'CA',
    u'country': u'USA'
}

# Add a new doc in collection 'cities' with ID 'LA'
db.collection(u'cities').document(u'LA').set(data)

city_ref = db.collection(u'cities').document(u'LA')

city_ref.set({
    u'capital': True,
    u'population': 150000
}, merge=True) # Adds capital to existing 3 fields

city_ref = db.collection(u'cities').document(u'BJ') # Creates new document, nothing to merge

city_ref.set({
    u'capital': True
}, merge=True) # Adds new field 'capital' to existing doc

city_ref = db.collection(u'cities').document(u'LA')

city_ref.set({
    u'capital': True
}) # Overwrites fields instead of expanding

# Data types
data = {
    u'stringExample': u'Hello, World!',
    u'booleanExample': True,
    u'numberExample': 3.14159265,
    u'dateExample': datetime.datetime.now(),
    u'arrayExample': [5, True, u'hello'],
    u'nullExample': None,
    u'objectExample': {
        u'a': 5,
        u'b': True
    }
}

db.collection(u'data').document(u'one').set(data)

# From a Class
class City(object):
    def __init__(self, name, state, country, capital=False, population=0,
                 regions=[]):
        self.name = name
        self.state = state
        self.country = country
        self.capital = capital
        self.population = population
        self.regions = regions

    @staticmethod # Reference members without self.
    def from_dict(source):
        city = City(source[u'name'], source[u'state'], source[u'country']) # Create new City instance
        if u'capital' in source:
            city.capital = source[u'capital']
        if u'population' in source:
            city.population = source[u'population']
        if u'regions' in source:
            city.regions = source[u'regions']

        return city

    def to_dict(self): # Creates a dict structure from instance members ready to be added to document
        dest = {u'name': self.name, u'state': self.state, u'country': self.country}

        if self.capital:
            dest[u'capital'] = self.capital
        if self.population:
            dest[u'population'] = self.population
        if self.regions:
            dest[u'regions'] = self.regions

        return dest

city = City(name=u'Los Angeles', state=u'CA', country=u'USA', population=500000)
db.collection(u'cities').document(u'CA').set(city.to_dict())

city = City(name=u'Tokyo', state=None, country=u'Japan')
# db.collection(u'cities').add(city.to_dict()) # Auto generates a document ID
''' Each time it runs, it creates a new unique doc with same content (city.to_dict()). Difficult to update as doc ID is random
You 'set' on known document ref and 'add' new unique ID to Collection first
'''

# Add Collection to existing Document as field
db.collection(u'cities').document(u'CA').collection(u'cinemas').document(u'Miskolc').set ({u'name':[u'Kossuth',u'Ady']})

# --------------------------------------------------------------------

# *** Updating data ***
city_ref = db.collection(u'cities').document(u'BJ')
city_ref.update({u'capital': False})

city_ref = db.collection(u'cities').document(u'CA')
city_ref.set({
    u'timestamp': None
}, merge=True)
city_ref.update({
    u'timestamp': firestore_v1.SERVER_TIMESTAMP
})

 # Update a nested field
frank_ref = db.collection(u'users').document(u'frank')
frank_ref.set({
    u'name': u'Frank',
    u'favorites': {
        u'food': u'Pizza',
        u'color': u'Blue',
        u'subject': u'Recess'
    },
    u'age': 12,
    u'department': u'HR'
})

frank_ref.update({
    u'age': 13,
    u'favorites.color': u'Red'
})
frank_ref.update ({u'misc':'anything'}) # Non-existent new field added by update

# Add some unknown ids
'''
db.collection ('users').add ({
    u'age': 60,
    u'department': u'ACC',
    u'name': u'Susy',
    u'born': 1958
}) '''

# Update array (list) elements
city_ref = db.collection(u'cities').document(u'CA')
city_ref.update({u'regions': firestore_v1.ArrayUnion([u'greater_virginia', u'lesser_poland', u'mid-dakota'])}) # Add array
city_ref.update({u'regions': firestore_v1.ArrayRemove([u'east_coast', u'lesser_poland'])}) # Remove element from the array

city_ref = db.collection(u'cities').document(u'BU')
city_ref.set ({u'population': 100})
city_ref.update({'population': firestore_v1.Increment (50)})

# Update unknown documents
docs = db.collection ('users').get ()
for doc in docs:
    if doc.to_dict ()['age'] >= 30:
        db.collection('users').document (doc.id).update ({"to_be_vaccinated": True})

# Alternatively
docs = db.collection ('users').where ("age", ">=", 30).get () # This is running on a smaller set

# --------------------------------------------------------------------

# Deleting data
#db.collection ('users').document ('frank').delete () # Delete entire doc
#db.collection ('users').document ('ryan').update ({"favorites":firestore_v1.DELETE_FIELD}) # Delete field

for doc in docs:
    if doc.to_dict ()['age'] >= 30:
        db.collection('users').document (doc.id).delete ()

# Alternatively
docs = db.collection ('users').where ("age", ">=", 30).get () # This is running on a smaller set
for doc in docs:
    db.collection('users').document (doc.id).delete ()

# --------------------------------------------------------------------

# Queries
print ('Queries:')
result = db.collection(u'cities').document(u'CA').get () # Get fields except embedded collections
if result.exists:
    print (result.to_dict())

result = db.collection(u'cities').get () # Get fields for all docs
for doc in result:
    print (doc.to_dict ())

# Where-clause
print ('Where-clause:')
result = db.collection(u'users').where ("age", "<=", 15).get () # No error if collection = cities as it has no age field
for doc in result:
    print(u'{} => {}'.format(doc.id, doc.to_dict()))
result = db.collection(u'users').where ("age", "<=", 15).where ("department", "==", "HR").get () # Compoud Where-clause. AND operator
# Needs composite index: (department, age)
for doc in result:
    print(u'{} => {}'.format(doc.id, doc.to_dict()))

# Array select
print ('Array:')
result = db.collection(u'users').where ("favorites", "array_contains", 'Pizza').get () # No error if collection = cities as it has no age field
for doc in result:
    print(u'{} => {}'.format(doc.id, doc.to_dict())) # Array has no named fields. Just a sequence like 0, 1, 2, ...

result = db.collection(u'users').where ("favorites.food", "==", 'Pizza').get () # No error if collection = cities as it has no age field
for doc in result:
    print(u'{} => {}'.format(doc.id, doc.to_dict())) # This is a map query rather than array

print ('In:')
result = db.collection(u'users').where ("department", "in", ["IT", "HR"]).get () # No error if collection = cities as it has no age field
for doc in result:
    print(u'{} => {}'.format(doc.id, doc.to_dict())) # Array has no named fields. Just a sequence like 0, 1, 2, ...

# --------------------------------------------------------------------

# Transactions
# Used for both read and write. If state changes after read but before write, it gets restarted
transaction = db.transaction ()
city_ref = db.collection (u'cities').document(u'CA')

@firestore_v1.transactional
def update_in_transaction(transaction, city_ref):
    snapshot = city_ref.get(transaction=transaction)
    new_population = snapshot.get(u'population') + 1

    if new_population < 1000000:
        transaction.update(city_ref, {
            u'population': new_population
        })
        return True
    else:
        return False

result = update_in_transaction(transaction, city_ref)
if result:
    print(u'Population updated')
else:
    print(u'Sorry! Population is too big.')

# Batch transaction
# Writes only
batch = db.batch ()

ca_ref = db.collection(u'cities').document(u'CA')
batch.set (ca_ref, {u'name': u'New York City'})

bu_ref = db.collection(u'cities').document(u'BU')
batch.update(bu_ref, {u'population': 1000000})

# Delete DEN
bj_ref = db.collection(u'cities').document(u'BJ')
batch.delete(bj_ref)

# Commit the batch
batch.commit()


# --------------------------------------------------------------------

os.system ("pause")