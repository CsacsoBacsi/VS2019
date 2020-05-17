CREATE OR REPLACE PROCEDURE sp_parse_xml (pi_xml CLOB)
-- Purpose:        To process any XML document by recursively traversing the DOM hierarchy
--                 This procedure handles the root tags: document and root
-- Argument:       CLOB containing the XML doc
-- Date:           10/05/2010
-- Change history:

IS

    -- Variables section
    doc                         dbms_xmldom.DOMDocument ;
    ddoc                        dbms_xmldom.DOMNode ;
    rootNode                    dbms_xmldom.DOMNode ;
    nodeName                    varchar2 (50) ;
    nodeValue                   varchar2 (4000) ;
    parent_nodeName             varchar2 (50) ;
    rootChildren                dbms_xmldom.DOMNodeList ;
    docChildren                 dbms_xmldom.DOMNodeList ;
    no_children                 pls_integer ;
    unique_id                   pls_integer ;
    order_id                    pls_integer ;
    attr_order_id               pls_integer ;
    parent_id                   pls_integer ;
    nodeType                    pls_integer ;
    nodeTypeText                varchar2 (30) ;
    attrs                       dbms_xmldom.DOMNamedNodeMap ;
    thisAttr                    dbms_xmldom.DOMNode ;

    pi_test_xml CLOB := '<rootelement><element1 attr1="attr1val">element1val</element1>
                                      <element2 attr2="attr2val" attr3="attr3val">
                                             <subelem1>subelem1val</subelem1>
                                             <subelem2>subelem2val</subelem2>
                                             <subelem3></subelem3>
                                      </element2>
                                      <element3 attr3="attr3val">element3val
                                             <subelem4>subelem4val</subelem4>
                                             <subelem5>subelem5val</subelem5>
                                      </element3>
                         </rootelement>' ;

BEGIN

    unique_id := 0 ;
    order_id := 1 ;
    parent_id := 0 ;

    -- Create DOMDocument handle:
    doc := dbms_xmldom.newDOMDocument (XMLTYPE (pi_test_xml)) ;

    -- Document node
    ddoc := dbms_xmldom.makeNode (doc) ;
    nodeName := dbms_xmldom.getNodeName (ddoc) ;
    nodeValue := dbms_xmldom.getNodeValue (ddoc) ;
    IF dbms_xmldom.hasChildNodes (ddoc) THEN
        docChildren := dbms_xmldom.getChildNodes (ddoc) ;
    END IF ;
    no_children := dbms_xmldom.getLength (docChildren) ;
    parent_nodeName := dbms_xmldom.getNodeName (dbms_xmldom.getParentNode (ddoc)) ;
    nodeType := dbms_xmldom.getNodeType (ddoc) ;

    -- Get textual node type
    nodeTypeText := CASE WHEN nodeType = dbms_xmldom.ELEMENT_NODE THEN 'Element'
                         WHEN nodeType = dbms_xmldom.ATTRIBUTE_NODE THEN 'Attribute'
                         WHEN nodeType = dbms_xmldom.TEXT_NODE THEN 'Text'
                         WHEN nodeType = dbms_xmldom.CDATA_SECTION_NODE THEN 'CData'
                         WHEN nodeType = dbms_xmldom.ENTITY_REFERENCE_NODE THEN 'Entity reference'
                         WHEN nodeType = dbms_xmldom.ENTITY_NODE THEN 'Entity'
                         WHEN nodeType = dbms_xmldom.PROCESSING_INSTRUCTION_NODE THEN 'Processing instruction'
                         WHEN nodeType = dbms_xmldom.COMMENT_NODE THEN 'Comment'
                         WHEN nodeType = dbms_xmldom.DOCUMENT_NODE THEN 'Document'
                         WHEN nodeType = dbms_xmldom.DOCUMENT_TYPE_NODE THEN 'Document type'
                         WHEN nodeType = dbms_xmldom.DOCUMENT_FRAGMENT_NODE THEN 'Document fragment'
                         WHEN nodeType = dbms_xmldom.NOTATION_NODE THEN 'Notation'
                         ELSE NULL END ;

--    dbms_output.put_line ('Id: ' || unique_id || ' Nodename: ' || nodeName || ' Parent id: ' || '-' || ' Parent nodename: ' || parent_nodeName ||
--                          ' Order: ' || order_id || ' Nodetype: ' || nodeTypeText || ' Node value: ' || nodeValue || ' Number of children: ' || no_children) ;
    INSERT INTO XML_PARSER_REPO ("ID", NODE_NAME, PARENT_ID, PARENT_NODE_NAME, POSITION, NODE_TYPE, NODE_VALUE, NO_CHILDREN)
           VALUES (unique_id, nodeName, NULL, parent_NodeName, order_id, nodeTypeText, nodeValue, no_children) ;

    COMMIT ;

    -- Root node
    unique_id := unique_id + 1 ;

    -- Get First Child of the doc node - this is the root node
    rootNode := dbms_xmldom.getFirstChild (ddoc) ;

    -- Get root node attributes
    nodeName := dbms_xmldom.getNodeName (rootNode) ;
    nodeValue := dbms_xmldom.getNodeValue (rootNode) ;
    IF dbms_xmldom.hasChildNodes (rootNode) THEN
        rootChildren := dbms_xmldom.getChildNodes (rootNode) ;
    END IF ;
    no_children := dbms_xmldom.getLength (rootChildren) ;
    parent_nodeName := dbms_xmldom.getNodeName (dbms_xmldom.getParentNode (rootNode)) ;
    nodeType := dbms_xmldom.getNodeType (rootNode) ;
    nodeTypeText := CASE WHEN nodeType = dbms_xmldom.ELEMENT_NODE THEN 'Element'
                         WHEN nodeType = dbms_xmldom.ATTRIBUTE_NODE THEN 'Attribute'
                         WHEN nodeType = dbms_xmldom.TEXT_NODE THEN 'Text'
                         WHEN nodeType = dbms_xmldom.CDATA_SECTION_NODE THEN 'CData'
                         WHEN nodeType = dbms_xmldom.ENTITY_REFERENCE_NODE THEN 'Entity reference'
                         WHEN nodeType = dbms_xmldom.ENTITY_NODE THEN 'Entity'
                         WHEN nodeType = dbms_xmldom.PROCESSING_INSTRUCTION_NODE THEN 'Processing instruction'
                         WHEN nodeType = dbms_xmldom.COMMENT_NODE THEN 'Comment'
                         WHEN nodeType = dbms_xmldom.DOCUMENT_NODE THEN 'Document'
                         WHEN nodeType = dbms_xmldom.DOCUMENT_TYPE_NODE THEN 'Document type'
                         WHEN nodeType = dbms_xmldom.DOCUMENT_FRAGMENT_NODE THEN 'Document fragment'
                         WHEN nodeType = dbms_xmldom.NOTATION_NODE THEN 'Notation' END ;

--    dbms_output.put_line ('Id: ' || unique_id || ' Nodename: ' || nodeName || ' Parent id: ' || parent_id || ' Parent nodename: ' || parent_nodeName ||
--                          ' Order: ' || order_id || ' Nodetype: ' || nodeTypeText || ' Node value: ' || nodeValue || ' Number of children: ' || no_children) ;
    INSERT INTO XML_PARSER_REPO ("ID", NODE_NAME, PARENT_ID, PARENT_NODE_NAME, POSITION, NODE_TYPE, NODE_VALUE, NO_CHILDREN)
           VALUES (unique_id, nodeName, parent_id, parent_NodeName, order_id, nodeTypeText, nodeValue, no_children) ;

    COMMIT ;

    -- Process attributes if any
    attr_order_id := 1 ;
    parent_id := unique_id ;
    attrs := dbms_xmldom.getAttributes (rootNode) ;
    parent_nodeName := nodeName ;

    FOR i IN 0..dbms_xmldom.getLength (attrs) - 1 LOOP

        thisAttr := dbms_xmldom.item (attrs, i) ;
        nodeName := dbms_xmldom.getNodeName (thisAttr) ;
        nodeValue := dbms_xmldom.getNodeValue (thisAttr) ;
        nodeType := dbms_xmldom.getNodeType (thisAttr) ;
        -- Get textual node type
        nodeTypeText := CASE WHEN nodeType = dbms_xmldom.ELEMENT_NODE THEN 'Element'
                             WHEN nodeType = dbms_xmldom.ATTRIBUTE_NODE THEN 'Attribute'
                             WHEN nodeType = dbms_xmldom.TEXT_NODE THEN 'Text'
                             WHEN nodeType = dbms_xmldom.CDATA_SECTION_NODE THEN 'CData'
                             WHEN nodeType = dbms_xmldom.ENTITY_REFERENCE_NODE THEN 'Entity reference'
                             WHEN nodeType = dbms_xmldom.ENTITY_NODE THEN 'Entity'
                             WHEN nodeType = dbms_xmldom.PROCESSING_INSTRUCTION_NODE THEN 'Processing instruction'
                             WHEN nodeType = dbms_xmldom.COMMENT_NODE THEN 'Comment'
                             WHEN nodeType = dbms_xmldom.DOCUMENT_NODE THEN 'Document'
                             WHEN nodeType = dbms_xmldom.DOCUMENT_TYPE_NODE THEN 'Document type'
                             WHEN nodeType = dbms_xmldom.DOCUMENT_FRAGMENT_NODE THEN 'Document fragment'
                             WHEN nodeType = dbms_xmldom.NOTATION_NODE THEN 'Notation'
                             ELSE NULL END ;
        unique_id := unique_id + 1 ;

--        dbms_output.put_line ('Id: ' || unique_id || ' Nodename: ' || nodeName || ' Parent id: ' || parent_id || ' Parent nodename: ' || parent_nodeName ||
--                              ' Order: ' || attr_order_id || ' Nodetype: ' || nodeTypeText || ' Node value: ' || nodeValue || ' Number of children: ' || '0') ;
        INSERT INTO XML_PARSER_REPO ("ID", NODE_NAME, PARENT_ID, PARENT_NODE_NAME, POSITION, NODE_TYPE, NODE_VALUE, NO_CHILDREN)
               VALUES (unique_id, nodeName, parent_id, parent_NodeName, attr_order_id, nodeTypeText, nodeValue, 0) ;

        COMMIT ;

        attr_order_id := attr_order_id + 1 ;
    END LOOP ;

    -- Call recursive procedure to traverse the XML tree
    IF no_children > 0 THEN
        sp_parse_xml_recursive (rootNode, unique_id, parent_id) ;
    END IF ;

    -- Release document
    dbms_xmldom.freeDocument (doc) ;

-- Exception handling
EXCEPTION
  WHEN OTHERS THEN

      ROLLBACK ;
      dbms_output.put_line (sqlerrm) ;
      RAISE ;

/*
truncate table XML_PARSER_REPO ;
select * from XML_PARSER_REPO t
;

  select id, node_name, parent_id, parent_node_name, node_type, node_value,
          level, 
          REGEXP_REPLACE (sys_connect_by_path (node_name, ' -> '), '^ -> ', '')  as path,
          connect_by_root node_name "#document"
   from   XML_PARSER_REPO
   start with id = 0
   connect by nocycle prior id = parent_id
   order by id ;
*/


END sp_parse_xml ;
