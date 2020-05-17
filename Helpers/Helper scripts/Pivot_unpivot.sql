-- New PIVOT/UNPIVOT clauses in 11g

-- *****
-- PIVOT
-- *****
WITH base AS
(
   SELECT 1 as prod, 1 as geo, 100 as vol from dual
   UNION ALL
   SELECT 1 as prod, 2 as geo, 60 as vol from dual
   UNION ALL
   SELECT 1 as prod, 3 as geo, 20 as vol from dual
   UNION ALL
   SELECT 2 as prod, 2 as geo, 40 as vol from dual
   UNION ALL
   SELECT 2 as prod, 3 as geo, 80 as vol from dual
   UNION ALL
   SELECT 2 as prod, 4 as geo, 15 as vol from dual
   UNION ALL
   SELECT 1 as prod, 3 as geo, 25 as vol from dual
)
   SELECT *
   FROM   base
   PIVOT (SUM (vol) -- Must be a grouping function as the same prod-geo combinations can only count as one, they are not distinghuisable in the pivoted set
      FOR geo -- This will go across as columns in the result
      IN (1 as "Germany", 2 as "Hungary", 3 as "UK", 4 as "France")) ; -- IN-clause compulsory. Can't be unknown values
      
-- Instead of:
WITH base AS
(
   SELECT 1 as prod, 1 as geo, 100 as vol from dual
   UNION ALL
   SELECT 1 as prod, 2 as geo, 60 as vol from dual
   UNION ALL
   SELECT 1 as prod, 3 as geo, 20 as vol from dual
   UNION ALL
   SELECT 2 as prod, 2 as geo, 40 as vol from dual
   UNION ALL
   SELECT 2 as prod, 3 as geo, 80 as vol from dual
   UNION ALL
   SELECT 2 as prod, 4 as geo, 15 as vol from dual
   UNION ALL
   SELECT 1 as prod, 3 as geo, 25 as vol from dual
)
   SELECT prod,
          SUM (DECODE (geo, 1, vol)) AS "Germany",
          SUM (DECODE (geo, 2, vol)) AS "Hungary",
          SUM (DECODE (geo, 3, vol)) AS "UK",
          SUM (DECODE (geo, 4, vol)) AS "France"
   FROM   base
   GROUP  BY prod ; -- Performance-wise they are almost exactly the same

-- *******
-- UNPIVOT
-- *******
WITH base AS
(
   SELECT 1 as prod, 1 as geo, 100 as vol from dual
   UNION ALL
   SELECT 1 as prod, 2 as geo, 60 as vol from dual
   UNION ALL
   SELECT 1 as prod, 3 as geo, 20 as vol from dual
   UNION ALL
   SELECT 2 as prod, 2 as geo, 40 as vol from dual
   UNION ALL
   SELECT 2 as prod, 3 as geo, 80 as vol from dual
   UNION ALL
   SELECT 2 as prod, 4 as geo, 15 as vol from dual
   UNION ALL
   SELECT 1 as prod, 3 as geo, 25 as vol from dual
), pivoted AS
(
   SELECT *
   FROM   base
   PIVOT (SUM (vol)
      FOR geo
      IN (1 as "Germany", 2 as "Hungary", 3 as "UK", 4 as "France"))
)
SELECT *
FROM   pivoted
UNPIVOT INCLUDE NULLS (volume -- Measure (arbitrary name). NULLs included, default is not included
   FOR Country -- Single column name that will represent the across columns (arbitrary name)
   IN ("Germany", "Hungary", "UK", "France") -- Column names to unpivot into Country
) ;

-- Instead of:
WITH base AS
(
   SELECT 1 as prod, 1 as geo, 100 as vol from dual
   UNION ALL
   SELECT 1 as prod, 2 as geo, 60 as vol from dual
   UNION ALL
   SELECT 1 as prod, 3 as geo, 20 as vol from dual
   UNION ALL
   SELECT 2 as prod, 2 as geo, 40 as vol from dual
   UNION ALL
   SELECT 2 as prod, 3 as geo, 80 as vol from dual
   UNION ALL
   SELECT 2 as prod, 4 as geo, 15 as vol from dual
   UNION ALL
   SELECT 1 as prod, 3 as geo, 25 as vol from dual
), pivoted AS
(
   SELECT *
   FROM   base
   PIVOT (SUM (vol)
      FOR geo
      IN (1 as "Germany", 2 as "Hungary", 3 as "UK", 4 as "France"))
)
SELECT prod, DECODE (l.rn, 1, 'Germany', -- Single quote: string literal
                     2, 'Hungary', 3, 'UK', 4, 'France') AS geo,
       CASE l.rn WHEN 1 THEN "Germany" -- Double quote: column name
                 WHEN 2 THEN "Hungary"
                 WHEN 3 THEN "UK"
                 WHEN 4 THEN "France"
       END AS volume
FROM   pivoted p,
       (SELECT level as rn -- Generates 4 rows. Cartesian join to pivoted
        FROM   dual
        CONNECT BY level < 5) l ;

-- Multi-column UnPivot

-- Table columns that needs UnPivoting:
OUTBOUND_ID,
OUTBOUND_AGENT,
CUPS,
OUTBOUND_CONTACT_DATE,

COMMUNICATION_CODE_1, -- Communication
COMMUNICATION_NAME_1,
COMMUNICATION_CODE_2,
COMMUNICATION_NAME_2,
COMMUNICATION_CODE_3,
COMMUNICATION_NAME_3,
COMMUNICATION_CODE_4,
COMMUNICATION_NAME_4,
COMMUNICATION_CODE_5,
COMMUNICATION_NAME_5

RESPONSE_CODE_1, -- Response
OUTBOUND_RESULT_1,
RESPONSE_CODE_2,
OUTBOUND_RESULT_2,
RESPONSE_CODE_3,
OUTBOUND_RESULT_3,
RESPONSE_CODE_4,
OUTBOUND_RESULT_4,
RESPONSE_CODE_5,
OUTBOUND_RESULT_5

-- Target columns: COMMUNICATION_CODE, COMMUNICATION_NAME, RESPONSE_CODE, RESPONSE_NAME

WITH PIVOT_DATA AS (
SELECT OUTBOUND_ID
,      CUPS
,      OUTBOUND_AGENT
,      OUTBOUND_CONTACT_DATE
,      RESPONSE_CODE -- Must explicitly select target columns
,      RESPONSE_NAME
,      COMMUNICATION_CODE
,      COMMUNICATION_NAME
FROM   (SELECT OUTBOUND_ID -- Source data
        ,      CUPS
        ,      OUTBOUND_AGENT
        ,      TO_DATE (TO_CHAR (OUTBOUND_CONTACT_DATE, 'DDMMYYYYHH24:MI:SS'), 'DDMMYYYYHH24:MI:SS') AS OUTBOUND_CONTACT_DATE
        ,      RESPONSE_CODE_1, OUTBOUND_RESULT_1, COMMUNICATION_CODE_1, COMMUNICATION_NAME_1
        ,      RESPONSE_CODE_2, OUTBOUND_RESULT_2, COMMUNICATION_CODE_2, COMMUNICATION_NAME_2
        ,      RESPONSE_CODE_3, OUTBOUND_RESULT_3, COMMUNICATION_CODE_3, COMMUNICATION_NAME_3
        ,      RESPONSE_CODE_4, OUTBOUND_RESULT_4, COMMUNICATION_CODE_4, COMMUNICATION_NAME_4
        ,      RESPONSE_CODE_5, OUTBOUND_RESULT_5, COMMUNICATION_CODE_5, COMMUNICATION_NAME_5
        FROM WESP_HDS.OUTBOUND_CONTACT 
        WHERE  EFFECTIVE_TO_DATE IS NULL)
UNPIVOT ((RESPONSE_CODE, RESPONSE_NAME, COMMUNICATION_CODE, COMMUNICATION_NAME) -- Target columns, exclude whole NULL rows
        FOR (WHATEVER_COLUMN) IN
            ((RESPONSE_CODE_1, OUTBOUND_RESULT_1, COMMUNICATION_CODE_1, COMMUNICATION_NAME_1), -- Columns of groups of four to match target
            (RESPONSE_CODE_2, OUTBOUND_RESULT_2, COMMUNICATION_CODE_2, COMMUNICATION_NAME_2),
            (RESPONSE_CODE_3, OUTBOUND_RESULT_3, COMMUNICATION_CODE_3, COMMUNICATION_NAME_3),
            (RESPONSE_CODE_4, OUTBOUND_RESULT_4, COMMUNICATION_CODE_4, COMMUNICATION_NAME_4),
            (RESPONSE_CODE_5, OUTBOUND_RESULT_5, COMMUNICATION_CODE_5, COMMUNICATION_NAME_5))) OC
WHERE   RESPONSE_CODE IS NOT NULL -- Eliminate rows where either column is NULL
        AND COMMUNICATION_CODE IS NOT NULL
)

-- ***** Old technique *****
-- Crosstab or Pivot Queries

-- A crosstab query, sometimes known as a pivot query, groups your data in a slightly different way 
-- from those we have seen hitherto. A crosstab query can be used to get a result with three rows 
-- (one for each project), with each row having three columns (the first listing the projects and 
-- then one column for each year) -- like this:

Project        2001        2002
     ID         CHF         CHF
-------------------------------
    100      123.00      234.50
    200      543.00      230.00
    300      238.00      120.50

-- Example

-- Let's say you want to show the top 3 salary earners in each department as columns. 
-- The query needs to return exactly 1 row per department and the row would have 4 columns. 
-- The DEPTNO, the name of the highest paid employee in the department, the name of the next highest paid,
-- and so on. Using analytic functions this almost easy, without analytic functions this was virtually impossible.

SELECT deptno,
  MAX(DECODE(seq,1,ename,null)) first,
  MAX(DECODE(seq,2,ename,null)) second,
  MAX(DECODE(seq,3,ename,null)) third
FROM (SELECT deptno, ename,
       row_number()
       OVER (PARTITION BY deptno
             ORDER BY sal desc NULLS LAST) seq
       FROM emp)
WHERE seq <= 3
GROUP BY deptno
/

    DEPTNO FIRST      SECOND     THIRD
---------- ---------- ---------- ----------
        10 KING       CLARK      MILLER
        20 SCOTT      FORD       JONES
        30 BLAKE      ALLEN      TURNER

-- Note the inner query, that assigned a sequence (RowNr) to each employee by department number in order of salary.

SELECT deptno, ename, sal,
   row_number()
   OVER (PARTITION BY deptno ORDER BY sal desc NULLS LAST) RowNr
FROM emp;

    DEPTNO ENAME             SAL      ROWNR
---------- ---------- ---------- ----------
        10 KING             5000          1
        10 CLARK            2450          2
        10 MILLER           1300          3
        20 SCOTT            3000          1
        20 FORD             3000          2
        20 JONES            2975          3
        20 ADAMS            1100          4
        20 SMITH             800          5
        30 BLAKE            2850          1
        30 ALLEN            1600          2
        30 TURNER           1500          3
        30 WARD             1250          4
        30 MARTIN           1250          5
        30 JAMES             950          6

-- The DECODE in the outer query keeps only rows with sequences 1, 2 or 3 and assigns them to the correct "column". 
-- The GROUP BY gets rid of the redundant rows and we are left with our collapsed result. 
-- It may be easier to understand if you see the resultset without the aggregate function MAX grouped by deptno.

SELECT deptno,
   DECODE(seq,1,ename,null) first,
   DECODE(seq,2,ename,null) second,
   DECODE(seq,3,ename,null) third
FROM (SELECT deptno, ename,
      row_number () OVER (PARTITION BY deptno ORDER BY sal desc NULLS LAST) seq
      FROM emp)
WHERE seq <= 3
/

    DEPTNO FIRST      SECOND     THIRD
---------- ---------- ---------- ----------
        10 KING
        10            CLARK
        10                       MILLER
        20 SCOTT
        20            FORD
        20                       JONES
        30 BLAKE
        30            ALLEN
        30                       TURNER

-- The MAX aggregate function will be applied by the GROUP BY column DEPTNO. In any given DEPTNO above only 
-- one row will have a non-null value for FIRST, the remaining rows in that group will always be NULL. 
-- The MAX function will pick out the non-null row and keep that for us. Hence, the group by and MAX will
-- collapse our resultset, removing the NULL values from it and giving us what we want.
