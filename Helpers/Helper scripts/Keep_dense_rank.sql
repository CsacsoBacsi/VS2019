SELECT depid,
       MAX (NAME) KEEP (DENSE_RANK FIRST ORDER BY pct) AS NAME,
       MAX (sal) KEEP (DENSE_RANK FIRST ORDER BY pct ASC) AS sal_for_min_pct,
       max (sal) KEEP (DENSE_RANK LAST ORDER BY pct ASC) AS sal_for_max_pct
FROM
(SELECT 10 AS depid, 'AAA' AS NAME, 10000 AS sal, 50 AS pct FROM dual
 UNION
 SELECT 10 AS depid, 'XXXX' AS NAME, 10000 AS sal, 40 AS pct FROM dual
 UNION
 SELECT 10 AS depid, 'BBB' AS NAME, 21000 AS sal, 30 AS pct FROM dual
 UNION
 SELECT 10 AS depid, 'CCC' AS NAME, 15000 AS sal, 20 AS pct FROM dual
 UNION
 SELECT 10 AS depid, 'YYY' AS NAME, 1000 AS sal, 20 AS pct FROM dual
 UNION
 SELECT 20 AS depid, 'DDD' AS NAME, 11000 AS sal, 10 AS pct FROM dual
 UNION
 SELECT 20 AS depid, 'EEE' AS NAME, 13000 AS sal, 90 AS pct FROM dual) a
 GROUP BY depid

-- GROUP BY depid, NAME

with src as
(
 SELECT 10 AS depid, 'AAA' AS NAME, 10000 AS sal, 50 AS pct FROM dual
 UNION
 SELECT 10 AS depid, 'XXXX' AS NAME, 10000 AS sal, 40 AS pct FROM dual
 UNION
 SELECT 10 AS depid, 'BBB' AS NAME, 21000 AS sal, 30 AS pct FROM dual
 UNION
 SELECT 10 AS depid, 'CCC' AS NAME, 15000 AS sal, 20 AS pct FROM dual
 UNION
 SELECT 10 AS depid, 'YYY' AS NAME, 1000 AS sal, 20 AS pct FROM dual
 UNION
 SELECT 20 AS depid, 'DDD' AS NAME, 11000 AS sal, 10 AS pct FROM dual
 UNION
 SELECT 20 AS depid, 'EEE' AS NAME, 13000 AS sal, 90 AS pct FROM dual
)
SELECT depid, name, sal, pct,
       max (NAME) KEEP (DENSE_RANK FIRST ORDER BY pct) over (partition by depid) AS max_NAME,
       max (sal) KEEP (DENSE_RANK FIRST ORDER BY pct ASC) over (partition by depid) AS sal_for_min_pct,
       max (sal) KEEP (DENSE_RANK LAST ORDER BY pct ASC) over (partition by depid) AS sal_for_max_pct,
       LISTAGG (name, ',') WITHIN GROUP (ORDER BY name) over (partition by depid) AS names
FROM   src
order by depid, pct, name
;
-- Pick an arbitrary row if pcts are equal (20) and get the MAX name. Query picks YYY


-- Versus FIRST_VALUE, LAST_VALUE
with src as
(
 SELECT 10 AS depid, 'AAA' AS NAME, 10000 AS sal, 50 AS pct FROM dual
 UNION
 SELECT 10 AS depid, 'XXXX' AS NAME, 10000 AS sal, 40 AS pct FROM dual
 UNION
 SELECT 10 AS depid, 'BBB' AS NAME, 21000 AS sal, 30 AS pct FROM dual
 UNION
 SELECT 10 AS depid, 'CCC' AS NAME, 15000 AS sal, 20 AS pct FROM dual
 UNION
 SELECT 10 AS depid, 'YYY' AS NAME, 1000 AS sal, 20 AS pct FROM dual
 UNION
 SELECT 20 AS depid, 'DDD' AS NAME, 11000 AS sal, 10 AS pct FROM dual
 UNION
 SELECT 20 AS depid, 'EEE' AS NAME, 13000 AS sal, 90 AS pct FROM dual
)
SELECT depid, name, sal, pct,
       FIRST_VALUE (NAME) over (partition by depid ORDER BY pct ASC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS max_NAME,
       FIRST_VALUE (sal) over (partition by depid ORDER BY pct ASC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)  AS sal_for_min_pct,
       LAST_VALUE (sal)  over (partition by depid ORDER BY pct ASC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS sal_for_max_pct,
       LISTAGG (name, ',') WITHIN GROUP (ORDER BY name) over (partition by depid) AS names
FROM   src
order by depid, pct, name
;
-- Pick an arbitrary row if pcts are equal (20) and get the name. Query picks CCC
