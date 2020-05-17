CREATE OR REPLACE PROCEDURE C10879.sp_read_xml (p_cfr_file_id NUMBER) IS
-- Purpose:        To process any XML document by recursively traversing the DOM hierarchy
--                 The XML doc must be a MSExcel XML document. 
--                 This procedure handles the root tags: document and root
-- Argument:       ID of loaded file
-- Target table:   XML_XLS
-- Created by:     Csaba Riedlinger
-- Date:           09/09/2008
-- Change history: 

    -- Cursor to loop over XML Lobs containing loaded XML docs
    CURSOR  c_main IS
    SELECT  a.cfr_file_id
            ,a.cfr_filetype
            ,a.cfr_filename
            ,a.cfr_host
            ,a.cfr_env
            ,a.cfr_username
            ,a.cfr_xml
            ,a.cfr_date_received
            ,a.cfr_comments
    FROM    finance.cfl_files_received a
    WHERE   a.cfr_file_id = p_cfr_file_id ;

    r_main c_main%ROWTYPE ;

    -- Variables section
    doc                         dbms_xmldom.DOMDocument ;
    ddoc                        dbms_xmldom.DOMNode ;
    rootNode                    dbms_xmldom.DOMNode ;
    nodeName                    varchar2 (50) ;
    nodeValue                   varchar2 (50) ;
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
    thisNode                    dbms_xmldom.DOMNode ;
    allChildren                 dbms_xmldom.DOMNodeList ;
    attrs                       dbms_xmldom.DOMNamedNodeMap ;    
    thisAttr                    dbms_xmldom.DOMNode ;    
    curr_wks                    pls_integer ;
    curr_row                    pls_integer ;
    curr_col                    pls_integer ;              

BEGIN

    -- Get the XML stuff from the CLOB
    OPEN    c_main;
    FETCH   c_main INTO r_main;
    CLOSE   c_main;

    -- Erase previous content
    EXECUTE IMMEDIATE 'TRUNCATE TABLE XML_XLS' ;

    unique_id := 0 ;
    order_id := 1 ;
    parent_id := 0 ;

    -- Create DOMDocument handle:
    doc := dbms_xmldom.newDOMDocument (r_main.cfr_xml) ;
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

    INSERT INTO xml_xls
    (NODE_ID, NODE_NAME, PARENT_NODE_ID, PARENT_NODE_NAME, ORDER_ID, NODE_TYPE, VALUE, NR_OF_CHILDREN, XLS_WKS, XLS_ROW, XLS_COL)
    VALUES (unique_id, nodeName, null, parent_nodeName, order_id, nodeTypeText, nodeValue, no_children, null, null, null) ;

    -- Root node
    unique_id := unique_id + 1 ;
    -- Get First Child of the node - this is the root node
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
    nodeTypeText := CASE WHEN nodeType = dbms_xmldom.ELEMENT_NODE THEN 'Element' WHEN nodeType = dbms_xmldom.ATTRIBUTE_NODE THEN 'Attribute' WHEN nodeType = dbms_xmldom.TEXT_NODE THEN 'Text' WHEN nodeType = dbms_xmldom.CDATA_SECTION_NODE THEN 'CData' WHEN nodeType = dbms_xmldom.ENTITY_REFERENCE_NODE THEN 'Entity reference' WHEN nodeType = dbms_xmldom.ENTITY_NODE THEN 'Entity' WHEN nodeType = dbms_xmldom.PROCESSING_INSTRUCTION_NODE THEN 'Processing instruction' WHEN nodeType = dbms_xmldom.COMMENT_NODE THEN 'Comment' WHEN nodeType = dbms_xmldom.DOCUMENT_NODE THEN 'Document' WHEN nodeType = dbms_xmldom.DOCUMENT_TYPE_NODE THEN 'Document type' WHEN nodeType = dbms_xmldom.DOCUMENT_FRAGMENT_NODE THEN 'Document fragment'WHEN nodeType = dbms_xmldom.NOTATION_NODE THEN 'Notation' END ;    

    INSERT INTO xml_xls
    (NODE_ID, NODE_NAME, PARENT_NODE_ID, PARENT_NODE_NAME, ORDER_ID, NODE_TYPE, VALUE, NR_OF_CHILDREN, XLS_WKS, XLS_ROW, XLS_COL)
    VALUES (unique_id, nodeName, parent_id, parent_nodeName, order_id, nodeTypeText, nodeValue, no_children, null, null, null) ;
    
    -- Process attributes if any
    attr_order_id := 1 ;
    parent_id := parent_id + 1 ;
    attrs := dbms_xmldom.getAttributes (rootNode) ;
    FOR i IN 0..dbms_xmldom.getLength (attrs) - 1 LOOP
        thisAttr := dbms_xmldom.item (attrs, i) ;
        nodeName := dbms_xmldom.getNodeName (thisAttr) ;
        nodeValue := dbms_xmldom.getNodeValue (thisAttr) ;
        parent_nodeName := dbms_xmldom.getNodeName (dbms_xmldom.getParentNode (thisAttr)) ;
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
        parent_id := 1 ;

        INSERT INTO xml_xls
        (NODE_ID, NODE_NAME, PARENT_NODE_ID, PARENT_NODE_NAME, ORDER_ID, NODE_TYPE, VALUE, NR_OF_CHILDREN, XLS_WKS, XLS_ROW, XLS_COL)
        VALUES (unique_id, nodeName, parent_id, parent_nodeName, attr_order_id, nodeTypeText, nodeValue, 0, null, null ,null) ;

        attr_order_id := attr_order_id + 1 ;
    END LOOP ;     

    -- Call recursive procedure to traverse the XML tree
    IF no_children > 0 THEN
        sp_read_xml_recursive (rootNode, unique_id, parent_id, curr_wks, curr_row, curr_col) ;
    END IF ;
    
    COMMIT ; 
    
    -- Release document
    dbms_xmldom.freeDocument (doc) ;  

-- Exception handling
EXCEPTION
  WHEN OTHERS THEN

      ROLLBACK ;
      dbms_output.put_line (sqlerrm) ;
      RAISE ;          

END ;
/


CREATE OR REPLACE PROCEDURE C10879.sp_read_xml_recursive (parentNode IN dbms_xmldom.DOMNode, curr_unique_id IN OUT NUMBER, parent_id NUMBER, xls_wks IN OUT NUMBER, xls_row IN OUT NUMBER, xls_col IN OUT NUMBER) IS
-- Purpose:        To process any XML document by recursively traversing the DOM hierarchy
--                 The XML doc must be a MSExcel XML document. 
--                 This procedure handles the worksheets, rows and cells
-- Arguments:      Node whose children to be processed, system incremented unique id, Node id whose children to be processed, current worksheet id, current row, current column 
-- Target table:   XML_XLS
-- Created by:     Csaba Riedlinger
-- Date:           09/09/2008
-- Change history: 

    -- Variables section
    nodeName                    varchar2 (50) ;
    nodeValue                   varchar2 (50) ;
    parent_nodeName             varchar2 (50) ;    
    no_children                 pls_integer ;
    order_id                    pls_integer ;
    attr_order_id               pls_integer ;
    unique_id                   pls_integer ;    
    nodeType                    pls_integer ;
    nodeTypeText                varchar2 (30) ;
    thisNode                    dbms_xmldom.DOMNode ;
    allChildren                 dbms_xmldom.DOMNodeList ;
    attrs                       dbms_xmldom.DOMNamedNodeMap ;    
    thisAttr                    dbms_xmldom.DOMNode ;
    attrParentID                pls_integer ;
    curr_wks                    pls_integer ;
    curr_row                    pls_integer ;
    curr_col                    pls_integer ;           
    
BEGIN

    order_id := 1 ;
    unique_id := curr_unique_id ;
    curr_wks := xls_wks ;
    curr_row := xls_row ;
    curr_col := xls_col ;

    IF dbms_xmldom.hasChildNodes (parentNode) THEN
        allChildren := dbms_xmldom.getChildNodes (parentNode) ;
    ELSE
        RETURN ;
    END IF ;

    -- Process all siblings
    FOR i IN 0..dbms_xmldom.getLength (allChildren) - 1 LOOP
        thisNode := dbms_xmldom.item (allChildren, i) ;
        unique_id := unique_id + 1 ;
        attrParentID := unique_id ;
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

        -- Record "coordinates" of the cell
        IF nodeName = 'worksheet' THEN
            curr_wks := dbms_xmldom.getAttribute (dbms_xmldom.makeElement (thisNode), 'id') ;
        END IF ;
        IF nodeName = 'row' THEN
            curr_row := dbms_xmldom.getAttribute (dbms_xmldom.makeElement (thisNode), 'id') ;
            curr_col := null ;
        END IF ;
        IF nodeName = 'cell' THEN
            curr_col := nvl (curr_col, 0) + 1 ;
        END IF ;

        INSERT INTO xml_xls
        (NODE_ID, NODE_NAME, PARENT_NODE_ID, PARENT_NODE_NAME, ORDER_ID, NODE_TYPE, VALUE, NR_OF_CHILDREN, XLS_WKS, XLS_ROW, XLS_COL)
        VALUES (unique_id, nodeName, parent_id, parent_nodeName, order_id, nodeTypeText, nodeValue, no_children, curr_wks, curr_row, curr_col) ;
        
        -- Process attributes if any              
        order_id := order_id + 1 ;   
        attr_order_id := 1 ;   
        attrs := dbms_xmldom.getAttributes (thisNode) ;
        parent_nodeName := nodeName ;
        FOR i IN 0..dbms_xmldom.getLength (attrs) - 1 LOOP
            thisAttr := dbms_xmldom.item (attrs, i) ;
            nodeName := dbms_xmldom.getNodeName (thisAttr) ;
            nodeValue := dbms_xmldom.getNodeValue (thisAttr) ;
            nodeType := dbms_xmldom.getNodeType (thisAttr) ;
            nodeTypeText := CASE WHEN nodeType = dbms_xmldom.ELEMENT_NODE THEN 'Element' WHEN nodeType = dbms_xmldom.ATTRIBUTE_NODE THEN 'Attribute' WHEN nodeType = dbms_xmldom.TEXT_NODE THEN 'Text' WHEN nodeType = dbms_xmldom.CDATA_SECTION_NODE THEN 'CData' WHEN nodeType = dbms_xmldom.ENTITY_REFERENCE_NODE THEN 'Entity reference' WHEN nodeType = dbms_xmldom.ENTITY_NODE THEN 'Entity' WHEN nodeType = dbms_xmldom.PROCESSING_INSTRUCTION_NODE THEN 'Processing instruction' WHEN nodeType = dbms_xmldom.COMMENT_NODE THEN 'Comment' WHEN nodeType = dbms_xmldom.DOCUMENT_NODE THEN 'Document' WHEN nodeType = dbms_xmldom.DOCUMENT_TYPE_NODE THEN 'Document type' WHEN nodeType = dbms_xmldom.DOCUMENT_FRAGMENT_NODE THEN 'Document fragment'WHEN nodeType = dbms_xmldom.NOTATION_NODE THEN 'Notation' END ;
            unique_id := unique_id + 1 ;

            INSERT INTO xml_xls
            (NODE_ID, NODE_NAME, PARENT_NODE_ID, PARENT_NODE_NAME, ORDER_ID, NODE_TYPE, VALUE, NR_OF_CHILDREN, XLS_WKS, XLS_ROW, XLS_COL)
            VALUES (unique_id, nodeName, attrParentID, parent_nodeName, attr_order_id, nodeTypeText, nodeValue, 0, curr_wks, curr_row, curr_col) ;
            
            attr_order_id := attr_order_id + 1 ;
        END LOOP ;     
        
        -- Call recursive procedure (itself) to process the next level (children of this node) of the XML hierarchy
        sp_read_xml_recursive (thisNode, unique_id, attrParentID, curr_wks, curr_row, curr_col) ;
    
    END LOOP ; 
    
    curr_unique_id := unique_id ;
    
    COMMIT ;
    
    RETURN ;
    
-- Exception handling
EXCEPTION
  WHEN OTHERS THEN

      ROLLBACK ;
      dbms_output.put_line (sqlerrm) ;
      RAISE ; 
    
END sp_read_xml_recursive ;
/
