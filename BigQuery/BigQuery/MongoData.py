

tutorial1 = {
    "title": "Working With JSON Data in Python",
    "author": "Lucas",
    "contributors": [
        "Aldren",
        "Dan",
        "Joanna"
    ],
    "url": "https://realpython.com/python-json/"
}
tutorial2 = {
    "title": "Python's Requests Library (Guide)",
    "author": "Alex",
    "contributors": [
        "Aldren",
        "Brad",
        "Joanna"
    ],
    "url": "https://realpython.com/python-requests/"
}

tutorial3 = {
    "title": "Object-Oriented Programming (OOP) in Python 3",
    "author": "David",
    "contributors": [
        "Aldren",
        "Joanna",
        "Jacob"
    ],
    "url": "https://realpython.com/python3-object-oriented-programming/"
}
tutorial4 = {
    "title": "Learning chess",
    "contributors": [
        "He",
        "She",
        "It"
    ],
    "url": "https://chess.com/"
}
tutorial5 = {
    "title": "Learning cooking",
    "author": None,
    "contributors": [
        "He",
        "Me",
        "It"
    ],
    "url": "https://cooking.com/"
}
tutorial6 = {
    "title": "Learning driving",
    "author": None,
    "contributors": [
        "He",
        "Me",
        "It"
    ],
    "url": "https://driving.com/"
}

mylist = [
  { "name": "Amy", "address": "Apple st 652"},
  { "name": "Hannah", "address": "Mountain 21"},
  { "name": "Michael", "address": "Valley 345"},
  { "name": "Sandy", "address": "Ocean blvd 2"},
  { "name": "Betty", "address": "Green Grass 1"},
  { "name": "Richard", "address": "Sky st 331"},
  { "name": "Susan", "address": "One way 98"},
  { "name": "Vicky", "address": "Yellow Garden 2"},
  { "name": "Ben", "address": "Park Lane 38"},
  { "name": "William", "address": "Central st 954"},
  { "name": "Chuck", "address": "Main Road 989"},
  { "name": "Viola", "address": "Sideway 1633"}
]

mylist2 = [
  { "_id": 1, "name": "John", "address": "Highway 37"},
  { "_id": 2, "name": "Peter", "address": "Lowstreet 27"},
  { "_id": 3, "name": "Amy", "address": "Apple st 652"},
  { "_id": 4, "name": "Hannah", "address": "Mountain 21"},
  { "_id": 5, "name": "Michael", "address": "Valley 345"},
  { "_id": 6, "name": "Sandy", "address": "Ocean blvd 2"},
  { "_id": 7, "name": "Betty", "address": "Green Grass 1"},
  { "_id": 8, "name": "Richard", "address": "Sky st 331"},
  { "_id": 9, "name": "Susan", "address": "One way 98"},
  { "_id": 10, "name": "Vicky", "address": "Yellow Garden 2"},
  { "_id": 11, "name": "Ben", "address": "Park Lane 38"},
  { "_id": 12, "name": "William", "address": "Central st 954"},
  { "_id": 13, "name": "Chuck", "address": "Main Road 989"},
  { "_id": 14, "name": "Viola", "address": "Sideway 1633"}
]

persons = [
{
    "id": 0,
    "name": "Lucas",
    "dims": {
        "width": 100,
        "length": 50,
        "height": 15
    },
    "age": 25
},
{
    "id": 1,
    "name": "Ben",
    "dims": {
        "width": 80,
        "length": 30,
        "height": 30
    },
    "age": 41
},
{
    "id": 2,
    "name": "Ann",
    "dims": {
        "width": 60,
        "length": 80,
        "height": 25
    },
    "age": 33
},
{
    "id": 3,
    "name": "Baby",
    "dims": {
        "width": 20,
        "length": 30,
        "height": 55
    },
    "age": 3
},
]

org1 = {
    "_id": 0,
    "company name": "BiXtorp Ltd.",
    "owner": "Csacsi",
    "addresss": [
    {"city": "Nottingham",
     "street": "Chartwell Road",
     "house number": 36,
     "postcode": "NG17 7HZ"
    }],
    "url": "https://csacso.com/mongodb/"
}

employee1 = {
    "_id": 1,
    "name": "Csacsi",
    "age": 52,
    "profession": "IT",
    "organisation": 0
}

employee2 = {
    "_id": 2,
    "name": "Zsurni",
    "age": 33,
    "profession": "Translator",
    "organisation": 0
}

customers = [
{
    "_id": 1,
    "customer name": "Csacsi",
    "cust id": "C1234",
    "addresss": [
        {"city": "Nottingham",
        "street": "Chartwell Road",
        "house number": 36,
        "postcode": "NG17 7HZ"
        }
    ],
    "url": "https://csacso.com/mongodb/"
},
{
    "_id": 2,
    "customer name": "Zsurni",
    "cust id": "C5678",
    "addresss": [
        {"city": "Kirkby-in-Ashfield",
        "street": "Chartwell Road",
        "house number": 36,
        "postcode": "NG17 7HZ"
        }
    ],
    "url": "https://zsurni.com/mongodb/"
}]

orders = [
{
    "_id": 1,
    "order num": 1001,
    "items": [
        {"prod id": 1, "amount": 2, "unit price": 2000},
        {"prod id": 2, "amount": 1, "unit price": 5000},
        {"prod id": 3, "amount": 5, "unit price": 200}
    ],
    "cust id": "C1234",
    "status": "O"
},
{
    "_id": 2,
    "order num": 1002,
    "items": [
        {"prod id": 4, "amount": 10, "unit price": 1000},
        {"prod id": 5, "amount": 1, "unit price": 3000},
        {"prod id": 2, "amount": 2, "unit price": 5000}
    ],
    "cust id": "C1234",
    "status": "C"
},
{
    "_id": 3,
    "order num": 1003,
    "items": [
        {"prod id": 2, "amount": 2, "unit price": 5000}
    ],
    "cust id": "C1234",
    "status": "C"
},
{
    "_id": 4,
    "order num": 1004,
    "items": [
        {"prod id": 1, "amount": 1, "unit price": 2000},
        {"prod id": 2, "amount": 3, "unit price": 5000},
        {"prod id": 3, "amount": 15, "unit price": 200}
    ],
    "cust id": "C5678",
    "status": "C"
},
{
    "_id": 5,
    "order num": 1005,
    "items": [
        {"prod id": 5, "amount": 2, "unit price": 3000},
        {"prod id": 6, "amount": 1, "unit price": 7000}
    ],
    "cust id": "C5678",
    "status": "C"
}]

stackof = [
{
  "_uid": 10,
  "impressions": [
            {
                "pos": 6,
                "id": 123,
                "service": "furniture"
            },
            {
                "pos": 0,
                "id": 128,
                "service": "electronics"
            },
            {
                "pos": 2,
                "id": 127,
                "service": "furniture"
            },
            {
                "pos": 2,
                "id": 125,
                "service": "electronics"
            },
            {
                "pos": 10,
                "id": 124,
                "service": "electronics"
            }
        ]
  },
  {
  "_uid": 11,
  "impressions": [
            {
                "pos": 1,
                "id": 124,
                "service": "furniture"
            },
            {
                "pos": 10,
                "id": 124,
                "service": "electronics"
            },
            {
                "pos": 1,
                "id": 123,
                "service": "furniture"
            },
            {
                "pos": 21,
                "id": 122,
                "service": "furniture"
            },
            {
                "pos": 3,
                "id": 125,
                "service": "electronics"
            },
            {
                "pos": 10,
                "id": 121,
                "service": "electronics"
            }
       ]
}]

