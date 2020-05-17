CREATE OR REPLACE PROCEDURE sp_parse_xml_recursive (parentNode IN dbms_xmldom.DOMNode, unique_id IN OUT NUMBER, parent_id NUMBER) IS
-- Purpose:        To process any XML document by recursively traversing the DOM hierarchy
-- Arguments:      Node whose children to be processed, system incremented unique id, Node id whose children to be processed
-- Created by:     Csaba Riedlinger
-- Date:           10/05/2010
-- Change history:

    -- Variables section
    nodeName                    varchar2 (50) ;
    nodeValue                   varchar2 (4000) ;
    parent_nodeName             varchar2 (50) ;
    no_children                 pls_integer ;
    order_id                    pls_integer ;
    attr_order_id               pls_integer ;
    nodeType                    pls_integer ;
    nodeTypeText                varchar2 (30) ;
    thisNode                    dbms_xmldom.DOMNode ;
    allChildren                 dbms_xmldom.DOMNodeList ;
    attrs                       dbms_xmldom.DOMNamedNodeMap ;
    thisAttr                    dbms_xmldom.DOMNode ;
    attrParentID                pls_integer ;

BEGIN

    order_id := 1 ;

    IF dbms_xmldom.hasChildNodes (parentNode) THEN
        allChildren := dbms_xmldom.getChildNodes (parentNode) ;
    ELSE
        RETURN ; -- No children, so return
    END IF ;

    -- Process all children
    FOR i IN 0..dbms_xmldom.getLength (allChildren) - 1 LOOP

        unique_id := unique_id + 1 ;
        attrParentID := unique_id ; -- If this node has attributes, the attributes' parent id

        thisNode := dbms_xmldom.item (allChildren, i) ; -- Take a childnode one by one
        nodeName := dbms_xmldom.getNodeName (thisNode) ;
        nodeValue := dbms_xmldom.getNodeValue (thisNode) ;
        no_children := dbms_xmldom.getLength (dbms_xmldom.getChildNodes (thisNode)) ;
        parent_nodeName := dbms_xmldom.getNodeName (dbms_xmldom.getParentNode (thisNode)) ;
        nodeType := dbms_xmldom.getNodeType (thisNode) ;

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

--        dbms_output.put_line ('Id: ' || unique_id || ' Nodename: ' || nodeName || ' Parent id: ' || parent_id || ' Parent nodename: ' || parent_nodeName ||
--                              ' Order: ' || order_id || ' Nodetype: ' || nodeTypeText || ' Node value: ' || nodeValue || ' Number of children: ' || no_children) ;

        INSERT INTO XML_PARSER_REPO ("ID", NODE_NAME, PARENT_ID, PARENT_NODE_NAME, POSITION, NODE_TYPE, NODE_VALUE, NO_CHILDREN)
               VALUES (unique_id, nodeName, parent_id, parent_NodeName, order_id, nodeTypeText, nodeValue, no_children) ;

        COMMIT ;

        -- Process attributes if any
        order_id := order_id + 1 ;
        attr_order_id := 1 ;
        attrs := dbms_xmldom.getAttributes (thisNode) ;
        parent_NodeName := nodeName ;

        FOR i IN 0..dbms_xmldom.getLength (attrs) - 1 LOOP

            thisAttr := dbms_xmldom.item (attrs, i) ;
            nodeName := dbms_xmldom.getNodeName (thisAttr) ;
            nodeValue := dbms_xmldom.getNodeValue (thisAttr) ;
            nodeType := dbms_xmldom.getNodeType (thisAttr) ;
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

              unique_id := unique_id + 1 ;

--            dbms_output.put_line ('Id: ' || unique_id || ' Nodename: ' || nodeName || ' Parent id: ' || attrParentID || ' Parent nodename: ' || parent_nodeName ||
--                                  ' Order: ' || attr_order_id || ' Nodetype: ' || nodeTypeText || ' Node value: ' || nodeValue || ' Number of children: ' || '0') ;
            INSERT INTO XML_PARSER_REPO ("ID", NODE_NAME, PARENT_ID, PARENT_NODE_NAME, POSITION, NODE_TYPE, NODE_VALUE, NO_CHILDREN)
                   VALUES (unique_id, nodeName, attrParentID, parent_NodeName, attr_order_id, nodeTypeText, nodeValue, 0) ;

            COMMIT ;

            attr_order_id := attr_order_id + 1 ;
        END LOOP ;

        -- Call recursive procedure (itself) to process the next level (children of this node) of the XML hierarchy
        sp_parse_xml_recursive (thisNode, unique_id, attrParentID) ;

    END LOOP ;

    RETURN ;

-- Exception handling
EXCEPTION
  WHEN OTHERS THEN

      ROLLBACK ;
      dbms_output.put_line (sqlerrm) ;
      RAISE ;

END sp_parse_xml_recursive ;
