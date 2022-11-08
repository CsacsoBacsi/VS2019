import re
import json

pocs = b'[{"key": "\\"val1\\"", "key2": "val2"}]'
pocs2 = [{"key": '""val1""', "key2": "val2"}]
pocss = pocs.decode ('UTF-8')

print (pocss)

dd = json.loads(pocs)
print (dd)

pos = re.search (b'^\".+\\\\\"$', pocs2)
print (pos)
