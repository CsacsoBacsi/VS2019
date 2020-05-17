# --------------------------------------------------------------------

import os
from xml.dom.minidom import parse
import xml.dom.minidom

# --------------------------------------------------------------------

# Open XML document using minidom parser
DOMTree = xml.dom.minidom.parse ("movies.xml")
collection = DOMTree.documentElement
if collection.hasAttribute ("shelf"):
    print ("Root element : %s" % collection.getAttribute ("shelf"))

# Get all the movies in the collection
movies = collection.getElementsByTagName ("movie")

# Print detail of each movie.
for movie in movies:
    print ("*****Movie*****")
    if movie.hasAttribute ("title"):
        print ("Title: %s" % (movie.getAttribute ("title")))

    type = movie.getElementsByTagName('type')[0]
    print ("Type: %s" % (type.childNodes[0].data))
    format = movie.getElementsByTagName('format')[0]
    print ("Format: %s" % (format.childNodes[0].data))
    rating = movie.getElementsByTagName('rating')[0]
    print ("Rating: %s" % (rating.childNodes[0].data))
    description = movie.getElementsByTagName('description')[0]
    print ("Description: %s" % (description.childNodes[0].data))

print ("")
print (collection.attributes.keys, collection.attributes.values)
print (len (collection.attributes))
for attr in collection.attributes.items ():
    print (attr)

# --------------------------------------------------------------------

# Recursive parsing
print ("Complete parsing of the XML")

unique_id = 0
order_id = 1
parent_id = 0

# Top level node
doc = xml.dom.minidom.parse ("movies.xml")
def remove_blanks (node):
    _childNodes = node.childNodes[:] # Copy the list, not just its reference
    for x in _childNodes: # The original list of childNodes is changing during the for loop, hence the shallow copy
        if x.nodeType == xml.dom.minidom.Node.TEXT_NODE:
            if x.nodeValue[0] == '\n':
                node.removeChild (x) # Get rid of the CR-LF node
        elif x.nodeType == xml.dom.minidom.Node.ELEMENT_NODE:
            remove_blanks (x) # Call recursively

#doc = DOMTree.documentElement

remove_blanks (doc) # Get rid of CR-LF nodes as they count as a child
nodeType = doc.nodeType
nodeValue = doc.nodeValue
nodeName = doc.nodeName
noChildren = len (doc.childNodes)

def getNodeTypeText (nodeType):
    if nodeType ==  xml.dom.minidom.Node.ELEMENT_NODE:
        nodeTypeText = 'Element'
    elif nodeType == xml.dom.minidom.Node.ATTRIBUTE_NODE:
        nodeTypeText = 'Attribute'
    elif nodeType == xml.dom.minidom.Node.TEXT_NODE:
        nodeTypeText = 'Text'
    elif nodeType == xml.dom.minidom.Node.CDATA_SECTION_NODE:
        nodeTypeText = 'CData'
    elif nodeType == xml.dom.minidom.Node.ENTITY_REFERENCE_NODE:
        nodeTypeText = 'Entity reference'
    elif nodeType == xml.dom.minidom.Node.ENTITY_NODE:
        nodeTypeText = 'Entity'
    elif nodeType == xml.dom.minidom.Node.PROCESSING_INSTRUCTION_NODE:
        nodeTypeText = 'Processing instruction'
    elif nodeType == xml.dom.minidom.Node.COMMENT_NODE:
        nodeTypeText = 'Comment'
    elif nodeType == xml.dom.minidom.Node.DOCUMENT_NODE:
        nodeTypeText = 'Document'
    elif nodeType == xml.dom.minidom.Node.DOCUMENT_TYPE_NODE:
        nodeTypeText = 'Document type'
    elif nodeType == xml.dom.minidom.Node.DOCUMENT_FRAGMENT_NODE:
        nodeTypeText = 'Document fragment'
    elif nodeType == xml.dom.minidom.Node.NOTATION_NODE:
        nodeTypeText = 'Notation'
    else:
        nodeTypeText = ""
    return nodeTypeText

nodeTypeText = getNodeTypeText (nodeType)

print ('Id: ', unique_id, ' Nodename: ', nodeName, ' Parent id: ', "-", ' Parent nodename: ', '-', ' Order: ', order_id, ' Nodetype: ', nodeTypeText, ' Node value: ', nodeValue, ' Number of children: ', noChildren)

# Root node
unique_id += 1
rootNode = doc.firstChild
nodeType = rootNode.nodeType
nodeValue = rootNode.nodeValue
nodeName = rootNode.nodeName
parentNode = rootNode.parentNode
parent_nodeName = parentNode.nodeName
noChildren = len (rootNode.childNodes)

nodeTypeText = getNodeTypeText (nodeType)

print ('Id: ', unique_id, ' Nodename: ', nodeName, ' Parent id: ', parent_id, ' Parent nodename: ', parent_nodeName, ' Order: ', order_id, ' Nodetype: ', nodeTypeText, ' Node value: ', nodeValue, ' Number of children: ', noChildren)

# Process attributes if any
attr_order_id = 1
parent_id = unique_id
attrs = rootNode.attributes # Returuns a NamedNodeMap
parent_nodeName = nodeName

if attrs == None:
    range_end = 0
else:
    range_end = len (attrs)

for i in range (0, range_end):
    thisAttr = attrs.item(i)
    nodeName = thisAttr.nodeName
    nodeValue = thisAttr.nodeValue
    nodeType = thisAttr.nodeType

    unique_id += 1

    nodeTypeText = getNodeTypeText (nodeType)

    print ('Id: ', unique_id, ' Nodename: ', nodeName, ' Parent id: ', parent_id, ' Parent nodename: ', parent_nodeName, ' Order: ', attr_order_id, ' Nodetype: ', nodeTypeText, ' Node value: ', nodeValue, ' Number of children: ', '0')
    attr_order_id += 1
 
# Call recursive function to traverse the XML tree
def sp_parse_xml_recursive (parentNode, parent_id):
    order_id = 1 ;

    if len (parentNode.childNodes) > 0:
        allChildren = parentNode.childNodes
    else:
        return
    # Process all children
    for i in range (0, len (allChildren)):

        global unique_id
        unique_id += 1
        attr_parent_id = unique_id # This element is the parent of its attributes

        thisNode = allChildren[i]
        nodeName = thisNode.nodeName
        nodeValue = thisNode.nodeValue
        noChildren = len (thisNode.childNodes)
        parent_nodeName = thisNode.parentNode.nodeName
        nodeType = thisNode.nodeType
        nodeTypeText = getNodeTypeText (nodeType)

        print ('Id: ', unique_id, ' Nodename: ', nodeName, ' Parent id: ', parent_id, ' Parent nodename: ', parent_nodeName, ' Order: ', order_id, ' Nodetype: ', nodeTypeText, ' Node value: ', nodeValue, ' Number of children: ', noChildren)

        order_id = order_id + 1
        attr_order_id = 1
        attrs = thisNode.attributes
        parent_nodeName = nodeName

        if attrs == None:
            range_end = 0
        else:
            range_end = len (attrs)

        for i in range (0, range_end):

            thisAttr = attrs.item (i)
            nodeName = thisAttr.nodeName
            nodeValue = thisAttr.nodeValue
            nodeType = thisAttr.nodeType
            nodeTypeText = getNodeTypeText (nodeType)

            unique_id += 1

            print ('Id: ', unique_id, ' Nodename: ', nodeName, ' Parent id: ', attr_parent_id, ' Parent nodename: ', parent_nodeName, ' Order: ', attr_order_id, ' Nodetype: ', nodeTypeText, ' Node value: ', nodeValue, ' Number of children: ', '0')
            attr_order_id += 1

        # Call recursive function (itself) to process the next level (children of this node) of the XML hierarchy
        sp_parse_xml_recursive (thisNode, attr_parent_id)

    return

if noChildren > 0:
    sp_parse_xml_recursive (rootNode, parent_id)

# --------------------------------------------------------------------

os.system ("pause")
