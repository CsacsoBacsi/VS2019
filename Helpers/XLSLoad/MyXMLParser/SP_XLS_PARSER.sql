CREATE OR REPLACE PROCEDURE SP_XLS_PARSER IS

l_blob       blob ;
l_clob       clob ;
l_strings    t_str_array := t_str_array ();
i            INTEGER ;

-- For SharedStrings to be loaded into an array
CURSOR C1 IS SELECT NODE_VALUE
             FROM   XML_PARSER_REPO2 -- Holds the sharedstrings parsed from the XML
             WHERE  NODE_NAME = '#text'
             ORDER BY "ID" ;

-- For SharedStrings to appear in the CELL_VALUE column
CURSOR C2 IS SELECT "ID", NODE_NAME, PARENT_ID, 
                    PARENT_NODE_NAME, NODE_TYPE, NODE_VALUE,
                    (SELECT (SELECT NODE_VALUE + 1 -- The index is 1 based but it is 0-based in the XML
                             FROM   XML_PARSER_REPO r3
                             WHERE  r3.PARENT_ID = r2.ID 
                                    AND r3.NODE_NAME = '#text') AS INDEX_VAL
                     FROM XML_PARSER_REPO r2 
                     WHERE r2.PARENT_ID = r1.PARENT_ID
                           AND NODE_NAME = 'v') as INDEX_VAL
             FROM XML_PARSER_REPO r1
             WHERE NODE_NAME = 't' AND NODE_VALUE = 's' -- Type: 's'haredstrings
             ORDER BY "ID" 
             FOR UPDATE OF CELL_VALUE;

-- For Boolean values to appear in the CELL_VALUE column
CURSOR C3 IS SELECT "ID", NODE_NAME, PARENT_ID, 
                    PARENT_NODE_NAME, NODE_TYPE, NODE_VALUE,
                    (SELECT (SELECT NODE_VALUE
                             FROM   XML_PARSER_REPO r3
                             WHERE  r3.PARENT_ID = r2.ID 
                                    AND r3.NODE_NAME = '#text') AS BOOL_VAL
                     FROM XML_PARSER_REPO r2 
                     WHERE r2.PARENT_ID = r1.PARENT_ID
                           AND NODE_NAME = 'v') as BOOL_VAL
             FROM XML_PARSER_REPO r1
             WHERE NODE_NAME = 't' AND NODE_VALUE = 'b' -- Type: 'b'oolean
             ORDER BY "ID" 
             FOR UPDATE OF CELL_VALUE;

-- For Number values to appear in the CELL_VALUE column
CURSOR C4 IS SELECT "ID", NODE_NAME, PARENT_ID, 
                    PARENT_NODE_NAME, NODE_TYPE, NODE_VALUE,
                    (SELECT (SELECT NODE_VALUE
                             FROM   XML_PARSER_REPO r3
                             WHERE  r3.PARENT_ID = r2.ID 
                                    AND r3.NODE_NAME = '#text') AS NUM_VAL
                     FROM XML_PARSER_REPO r2 
                     WHERE r2.PARENT_ID = r1.PARENT_ID
                           AND NODE_NAME = 'v') as NUM_VAL
             FROM XML_PARSER_REPO r1
             WHERE NODE_NAME = 'r'
                   AND (SELECT NODE_VALUE 
                        FROM   XML_PARSER_REPO r5 
                        WHERE  r5.PARENT_ID = r1.PARENT_ID
                               AND NODE_NAME = 's') = 4 -- Style: Number, No type!
                   AND NOT EXISTS (SELECT NULL 
                                   FROM XML_PARSER_REPO r4
                                   WHERE r4.PARENT_ID = r1.PARENT_ID
                                         AND r4.NODE_NAME = 't')
             ORDER BY "ID" 
             FOR UPDATE OF CELL_VALUE;

-- For Date values to appear in the CELL_VALUE column
CURSOR C5 IS SELECT "ID", NODE_NAME, PARENT_ID, 
                    PARENT_NODE_NAME, NODE_TYPE, NODE_VALUE,
                    (SELECT (SELECT NODE_VALUE
                             FROM   XML_PARSER_REPO r3
                             WHERE  r3.PARENT_ID = r2.ID 
                                    AND r3.NODE_NAME = '#text') AS NUM_VAL
                     FROM XML_PARSER_REPO r2 
                     WHERE r2.PARENT_ID = r1.PARENT_ID
                           AND NODE_NAME = 'v') as NUM_VAL
             FROM XML_PARSER_REPO r1
             WHERE NODE_NAME = 'r'
                   AND (SELECT NODE_VALUE 
                        FROM   XML_PARSER_REPO r5 
                        WHERE  r5.PARENT_ID = r1.PARENT_ID
                               AND NODE_NAME = 's') = 3 -- Style: Date, No type
                   AND NOT EXISTS (SELECT NULL 
                                   FROM XML_PARSER_REPO r4
                                   WHERE r4.PARENT_ID = r1.PARENT_ID
                                         AND r4.NODE_NAME = 't')
             ORDER BY "ID" 
             FOR UPDATE OF CELL_VALUE;


BEGIN

    l_blob := file_util_pkg.get_blob_from_file ('C23833_DIR', 'CompComp.xlsx') ;

--    l_blob := zip_util_pkg.get_file (l_blob, 'xl/sharedStrings.xml'); -- Put sharedstrings into blob
    l_blob := zip_util_pkg.get_file (l_blob, 'xl/worksheets/sheet1.xml') ; -- Put worksheet data into blob
  
    l_clob := sql_util_pkg.blob_to_clob (l_blob); -- Convert to clob

    sp_parse_xml (l_clob) ; -- Call the recursive parser to traverse the XML tree

    -- Build a string array with all the sharedstrings
    i := 1 ;
    FOR c1_rec IN C1 LOOP
        
        l_strings.extend();    
        l_strings (i) := c1_rec.NODE_VALUE ;
        i := i + 1 ;
    
    END LOOP ;
    
    -- Populate the cell value column with sharedstrings
    FOR c2_rec IN C2 LOOP
    
        UPDATE XML_PARSER_REPO
               SET CELL_VALUE = l_strings (c2_rec.INDEX_VAL),
                   CELL_TYPE = 'S' -- String
        WHERE  PARENT_ID = c2_rec.PARENT_ID AND NODE_NAME = 'r' ;
    
    END LOOP ;

    COMMIT ; 
    
    -- Populate the cell value column with boolean values
    FOR c3_rec IN C3 LOOP
    
        UPDATE XML_PARSER_REPO
               SET CELL_VALUE = CASE WHEN c3_rec.BOOL_VAL = 0 THEN 'Y' ELSE 'N' END,
                   CELL_TYPE = 'B' -- Boolean
        WHERE  PARENT_ID = c3_rec.PARENT_ID AND NODE_NAME = 'r' ;
    
    END LOOP ;

    COMMIT ;

    -- Populate the cell value column with numbers
    FOR c4_rec IN C4 LOOP
    
        UPDATE XML_PARSER_REPO
               SET CELL_VALUE = TO_NUMBER (c4_rec.NUM_VAL),
                   CELL_TYPE = 'N' -- Number
        WHERE  PARENT_ID = c4_rec.PARENT_ID AND NODE_NAME = 'r' ;
    
    END LOOP ;

    COMMIT ;

    -- Populate the cell value column with dates 
    FOR c5_rec IN C5 LOOP
    
        UPDATE XML_PARSER_REPO
               SET CELL_VALUE = TO_CHAR (TO_DATE ('01/01/1900', 'DD/MM/YYYY') + c5_rec.NUM_VAL -2, 'DD/MM/YYYY'),
                   CELL_TYPE = 'D' -- Date
        WHERE  PARENT_ID = c5_rec.PARENT_ID AND NODE_NAME = 'r' ;
    
    END LOOP ;

    COMMIT ;

END SP_XLS_PARSER ;
