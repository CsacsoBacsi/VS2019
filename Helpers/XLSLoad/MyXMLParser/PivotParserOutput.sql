select * from XML_PARSER_REPO t
order by "ID" ;

UPDATE XML_PARSER_REPO SET CELL_VALUE = NULL, CELL_TYPE = NULL ;
     
SELECT (SELECT TO_NUMBER (REGEXP_SUBSTR (NODE_VALUE, '[0-9]+'))
        FROM   XML_PARSER_REPO r1
        WHERE  NODE_NAME = 'r'
               AND PARENT_NODE_NAME = 'c'
               AND PARENT_ID = r2."ID") as "ROW",
       (SELECT REGEXP_SUBSTR (r1.NODE_VALUE, '[A-Z]+')
        FROM   XML_PARSER_REPO r1
        WHERE  NODE_NAME = 'r'
               AND PARENT_NODE_NAME = 'c'
               AND PARENT_ID = r2."ID") as "COL",
       (SELECT r1.CELL_VALUE
        FROM   XML_PARSER_REPO r1
        WHERE  NODE_NAME = 'r'
               AND PARENT_NODE_NAME = 'c'
               AND PARENT_ID = r2."ID") as "VALUE"
FROM   XML_PARSER_REPO r2
WHERE  r2.NODE_NAME = 'c' 
       AND r2.PARENT_NODE_NAME = 'row' 
ORDER BY "ROW", "COL" ;
       
select ooxml_util_pkg.get_xlsx_column_number ('AB15') from dual ;

SELECT REGEXP_SUBSTR ('AB1', '[A-Z]+') from dual ;

SELECT REGEXP_SUBSTR ('AB143', '[0-9]+') from dual ;
