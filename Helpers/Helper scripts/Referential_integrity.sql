-- Referential integrity
SELECT a.TABLE_NAME as REFERENCED_TABLE, a.CONSTRAINT_NAME as REFERENCED_TABLE_PK,
       (SELECT c.COLUMN_NAME 
        FROM ALL_CONS_COLUMNS c 
        WHERE a.CONSTRAINT_NAME = c.CONSTRAINT_NAME) as REFERENCED_COLUMN,
       b.TABLE_NAME as REFERENCING_TABLE_NAME, 
       (SELECT c.COLUMN_NAME 
        FROM ALL_CONS_COLUMNS c 
        WHERE b.CONSTRAINT_NAME = c.CONSTRAINT_NAME) as REFERENCING_COLUMN,
       b.CONSTRAINT_NAME
FROM   ALL_CONSTRAINTS a,
       ALL_CONSTRAINTS b
WHERE  a.OWNER               = 'RPT'
       AND b.R_OWNER         = 'RPT'
       AND a.CONSTRAINT_NAME = b.R_CONSTRAINT_NAME
       AND b.CONSTRAINT_TYPE = 'R'
ORDER BY a.TABLE_NAME, b.TABLE_NAME ;
