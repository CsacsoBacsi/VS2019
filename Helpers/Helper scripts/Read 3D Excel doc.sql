CREATE OR REPLACE PROCEDURE C10879.sp_read_xml_3d (p_cfr_file_id NUMBER) IS
-- Purpose:        To process an XML document of pre-defined format generated by SP_GEN_XML_4D.
--                 User filled data cells and fileloader loaded file.
--                 Target table: EDF_NHH_FACTORS_FACT_4D
-- Created by:     Csaba Riedlinger
-- Date:           02/09/2008
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

    -- Cursors used to populate associative arrays (tables)
    -- Elec product (propositions)
    CURSOR pc IS
    SELECT xid as pid, xdesc as pdesc
    FROM  TABLE (CAST (OLAP_TABLE ('EDF_NHH_AW.EDF_NHH DURATION SESSION', 'ID_DESC_TAB', '' 
                                  ,' DIMENSION xid FROM elec_product ' ||
                                   ' WITH ATTRIBUTE xdesc FROM elec_product_long_description '
                ) AS ID_DESC_TAB)) ;

    TYPE prop_type IS TABLE OF VARCHAR2 (50) INDEX BY VARCHAR2 (50) ;
    prop_lookup prop_type ;

    -- Business structure
    CURSOR bsc IS
    SELECT distinct xid as sid, xdesc as sdesc
    FROM TABLE (CAST (OLAP_TABLE ('EDF_NHH_AW.EDF_NHH DURATION SESSION', 'ID_DESC_TAB', '' 
                                 ,' DIMENSION xid FROM business_structure ' ||
                                  ' WITH ATTRIBUTE xdesc FROM business_structure_long_description '
               ) AS ID_DESC_TAB)) ;

    TYPE bs_type IS TABLE OF VARCHAR2 (50) INDEX BY VARCHAR2 (50) ;
    bs_lookup bs_type ;

    -- Variables section
    doc                         dbms_xmldom.DOMDocument ;
    ddoc                        dbms_xmldom.DOMNode ;
    rnode                       dbms_xmldom.DOMNode ;
    WSList                      dbms_xmldom.DOMNodeList ;
    thisWSNode                  dbms_xmldom.DOMNode ;
    RowList                     dbms_xmldom.DOMNodeList ;
    thisRow                     dbms_xmldom.DOMNode ;    
    thisRowId                   varchar2 (10) ;
    thisCell                    dbms_xmldom.DOMNode ;
    thisCellVal                 varchar2 (20) ;
    PropList                    dbms_xmldom.DOMNodeList ;
    thisProp                    varchar2 (50) ;
    DataList                    dbms_xmldom.DOMNodeList ;
    thisTime                    varchar2 (10) ;
    thisBS                      varchar2 (50) ;
    thisBSID                    varchar2 (20) ;
    thisPropID                  varchar2 (20) ;
    attached                    boolean := FALSE ;
    versionID                   pls_integer ;

BEGIN

     -- Detach AW if it was attached. If not, we'll have an exception but we just ignore it
     BEGIN
     
         dbms_aw.execute ('aw detach edf_nhh_aw.edf_nhh') ;
     
     EXCEPTION
         WHEN OTHERS THEN
             NULL ;     
     END ;

    -- Attach AW and impose limits
    dbms_aw.execute ('aw attach edf_nhh_aw.edf_nhh ro') ;
    attached := TRUE ;
    dbms_aw.execute ('lmt elec_product to elec_product_levelrel ''PROPOSITION''') ;
    dbms_aw.execute ('lmt business_structure to business_structure_levelrel ''SECTOR''') ;    

    -- Populate associative arrays
    FOR pc_rec IN pc LOOP
        prop_lookup (pc_rec.pdesc) := pc_rec.pid ;    
    END LOOP ; 

    FOR bs_rec IN bsc LOOP
        bs_lookup (bs_rec.sdesc) := bs_rec.sid ;    
    END LOOP ; 

    -- Get the XML stuff from the CLOB
    OPEN    c_main;
    FETCH   c_main INTO r_main;
    CLOSE   c_main;

    -- Create DOMDocument handle:
    doc := dbms_xmldom.newDOMDocument (r_main.cfr_xml) ;
    ddoc := dbms_xmldom.makeNode (doc) ;

    -- Get First Child of the node - must be the root node
    rnode := dbms_xmldom.getFirstChild (ddoc) ;

    -- Get worksheets
    WSList := dbms_xmldom.getChildrenByTagName (dbms_xmldom.makeElement(rnode), 'worksheet') ;

    -- Add new partition to header table    
    SELECT EDF_FACTOR_3D_VER_SEQ.NEXTVAL INTO versionID FROM DUAL ; 
    sp_add_partition ('C10879', 'EDF_NHH_FACTORS_FACT_3D', versionID) ;

    -- Loop over each sheet
    FOR i IN 0..dbms_xmldom.getLength (WSList) - 1 LOOP
    
        thisWSNode := dbms_xmldom.item (WSList, i) ;
        thisBS     := dbms_xmldom.getAttribute (dbms_xmldom.makeElement (thisWSNode), 'name') ;     
        ROWList    := dbms_xmldom.getChildrenByTagName (dbms_xmldom.makeElement (thisWSNode), 'row') ;
    
        -- Loop over each row
        FOR j IN 0..dbms_xmldom.getLength (ROWList) - 1 LOOP
          
            thisRowId := dbms_xmldom.getAttribute (dbms_xmldom.makeElement (dbms_xmldom.item (RowList, j)), 'id') ;
            thisRow   := dbms_xmldom.item (RowList, j) ;

            -- Process rows one by one. Data is stored from row 5 onwards            
            CASE thisRowId
                WHEN 1 THEN -- Contains the sector in the first cell only. We have that already from the worksheet node 
                    NULL ; 
                WHEN 2 THEN -- Blank row
                    NULL ;
                WHEN 3 THEN -- First cell is empty. Second cell contains the word: Proposition
                    NULL ;
                WHEN 4 THEN -- Contains all Propositions. First cell holds the word 'Day'
                    PropList := dbms_xmldom.getChildrenByTagName (dbms_xmldom.makeElement (thisRow), 'cell') ;
                ELSE -- Data area starts here
                    DataList := dbms_xmldom.getChildrenByTagName (dbms_xmldom.makeElement (thisRow), 'cell') ;
                    -- Loop over each cell
                    FOR k IN 0..dbms_xmldom.getLength (DataList) - 1 LOOP

                        IF k = 0 THEN -- The date is stored here 
                            thisTime := dbms_xmldom.getAttribute (dbms_xmldom.makeElement (dbms_xmldom.item (DataList, k)), 'val') ;
                        ELSE  -- The actual figures are stored here
                            thisCellVal := dbms_xmldom.getAttribute (dbms_xmldom.makeElement (dbms_xmldom.item (DataList, k)), 'val') ;
                            thisProp := dbms_xmldom.getAttribute (dbms_xmldom.makeElement (dbms_xmldom.item (PropList, k)), 'val') ;

                            -- Use index-by tables to lookup ids
                            thisPropID := prop_lookup (thisProp) ;
                            thisBSID   := bs_lookup (thisBS) ;

                            INSERT INTO EDF_NHH_FACTORS_FACT_3D
                            VALUES (versionID, thisBSID, thisPropID, to_date (thisTime, 'DD/MM/YYYY'), thisCellVal) ;                                                         

                        END IF ;

                    END LOOP ;
                
            END CASE ;

        END LOOP ;  
        
    END LOOP ;
    
    -- Release document and AW
    dbms_xmldom.freeDocument (doc) ;
    dbms_aw.execute ('aw detach edf_nhh_aw.edf_nhh') ;    

    -- Create entry in header table
    INSERT INTO EDF_NHH_FACTORS_HEADER_3D
    (VERSION_ID, CFR_FILE_ID, USER_ID, CREATED_DATE, USER_COMMENT)    
    SELECT  versionID, a.cfr_file_id, a.cfr_username, a.cfr_date_received, a.cfr_comments
    FROM    finance.cfl_files_received a
    WHERE   a.cfr_file_id = p_cfr_file_id ;

    -- Commit all changes at once    
    COMMIT ;

-- Exception handling
EXCEPTION
  WHEN OTHERS THEN

      ROLLBACK ;
      dbms_output.put_line (sqlerrm) ;
      IF attached THEN
         dbms_aw.execute ('aw detach edf_nhh_aw.edf_nhh') ;
      END IF ; 
      
      RAISE ;          

END ;
/