-- Gap filling with LAST_VALUE
WITH DATA AS (
   SELECT 1 as ID, NULL as VALUE
   FROM DUAL
   UNION ALL
   SELECT 2 as ID, 1 as VALUE
   FROM DUAL
   UNION ALL
   SELECT 3 as ID, NULL as VALUE
   FROM DUAL
   UNION ALL
   SELECT 4 as ID, 5 as VALUE
   FROM DUAL
   UNION ALL
   SELECT 5 as ID, NULL as VALUE
   FROM DUAL
   UNION ALL
   SELECT 6 as ID, 2 as VALUE
   FROM DUAL
   UNION ALL
   SELECT 7 as ID, NULL as VALUE
   FROM DUAL
), interim AS (
   SELECT ID,
   VALUE,
   LAST_VALUE (VALUE IGNORE NULLS) OVER (ORDER BY ID ASC) prev_val,
   LAST_VALUE (VALUE IGNORE NULLS) OVER (ORDER BY ID DESC) next_val
   FROM DATA
)  SELECT ID, VALUE, COALESCE (VALUE, NVL (prev_val, next_val), NVL (next_val, prev_val)) AS FILLED_VALUE
   FROM interim
   ORDER BY ID ;
