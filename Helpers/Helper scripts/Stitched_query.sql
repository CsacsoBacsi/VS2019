-- Stitch query that uses an outer join to return all rows from both tables joined.

-- Solution 1.
-- Outer join the two fact tables then inner join to dimension tables. The key here is to either inner join
-- to fact 1 OR to fact 2. either of them must have a non-NULL foreign key id to join to the dimension

WITH inv AS
(
   SELECT 1 as prod, to_date ('01/01/2013', 'DD/MM/YYYY') as time, 100 as vol from dual
   union all
   SELECT 2 as prod, to_date ('01/01/2013', 'DD/MM/YYYY') as time, 40 as vol from dual
   union all
   SELECT 3 as prod, to_date ('01/01/2013', 'DD/MM/YYYY') as time, 70 as vol from dual
   union all
   SELECT 4 as prod, to_date ('01/01/2013', 'DD/MM/YYYY') as time, 30 as vol from dual
   union all
   SELECT 1 as prod, to_date ('02/01/2013', 'DD/MM/YYYY') as time, 60 as vol from dual
   union all
   SELECT 3 as prod, to_date ('02/01/2013', 'DD/MM/YYYY') as time, 50 as vol from dual
), sales AS
(
   SELECT 1 as prod, to_date ('01/01/2013', 'DD/MM/YYYY') as time, 40 as svol from dual
   union all
   SELECT 3 as prod, to_date ('03/01/2013', 'DD/MM/YYYY') as time, 20 as svol from dual
), prod_dim AS
(
   SELECT 1 as prod, 'Prod one' as descr from dual
   union all
   SELECT 2 as prod, 'Prod two' as descr from dual
   union all
   SELECT 3 as prod, 'Prod three' as descr from dual
   union all
   SELECT 4 as prod, 'Prod four' as descr from dual
), time_dim AS
(
   SELECT to_date ('01/01/2013', 'DD/MM/YYYY') as time, 'Jan 01, 2013' as descr from dual
   union all
   SELECT to_date ('02/01/2013', 'DD/MM/YYYY') as time, 'Jan 02, 2013' as descr from dual  
   union all
   SELECT to_date ('03/01/2013', 'DD/MM/YYYY') as time, 'Jan 03, 2013' as descr from dual
)
   SELECT prod_dim.descr, time_dim.descr, inv.vol, sales.svol
   FROM   inv
   FULL OUTER JOIN sales
   ON (inv.prod     = sales.prod
       AND inv.time = sales.time)
   INNER JOIN prod_dim
   ON (inv.prod = prod_dim.prod OR sales.prod = prod_dim.prod)
   INNER JOIN time_dim
   ON (inv.time = time_dim.time OR sales.time = time_dim.time) ;
 
-- Solution 2.  
-- Inner join each fact to all dimension tables then outer join the fact tables. Description fields may be NULL
-- so use COALESCE to return a non-NULL description

WITH inv AS
(
   SELECT 1 as prod, to_date ('01/01/2013', 'DD/MM/YYYY') as time, 100 as vol from dual
   union all
   SELECT 2 as prod, to_date ('01/01/2013', 'DD/MM/YYYY') as time, 40 as vol from dual
   union all
   SELECT 3 as prod, to_date ('01/01/2013', 'DD/MM/YYYY') as time, 70 as vol from dual
   union all
   SELECT 4 as prod, to_date ('01/01/2013', 'DD/MM/YYYY') as time, 30 as vol from dual
   union all
   SELECT 1 as prod, to_date ('02/01/2013', 'DD/MM/YYYY') as time, 60 as vol from dual
   union all
   SELECT 3 as prod, to_date ('02/01/2013', 'DD/MM/YYYY') as time, 50 as vol from dual
), sales AS
(
   SELECT 1 as prod, to_date ('01/01/2013', 'DD/MM/YYYY') as time, 40 as svol from dual
   union all
   SELECT 3 as prod, to_date ('03/01/2013', 'DD/MM/YYYY') as time, 20 as svol from dual
), prod_dim AS
(
   SELECT 1 as prod, 'Prod one' as descr from dual
   union all
   SELECT 2 as prod, 'Prod two' as descr from dual
   union all
   SELECT 3 as prod, 'Prod three' as descr from dual
   union all
   SELECT 4 as prod, 'Prod four' as descr from dual
), time_dim AS
(
   SELECT to_date ('01/01/2013', 'DD/MM/YYYY') as time, 'Jan 01, 2013' as descr from dual
   union all
   SELECT to_date ('02/01/2013', 'DD/MM/YYYY') as time, 'Jan 02, 2013' as descr from dual  
   union all
   SELECT to_date ('03/01/2013', 'DD/MM/YYYY') as time, 'Jan 03, 2013' as descr from dual
), inv_with_dims AS
(
   SELECT inv.prod, inv.time, prod_dim.descr as prod_desc, time_dim.descr as time_desc, inv.vol
   FROM   inv, prod_dim, time_dim
   WHERE  inv.prod = prod_dim.prod
          AND inv.time = time_dim.time
), sales_with_dims AS
(
   SELECT sales.prod, sales.time, prod_dim.descr as prod_desc, time_dim.descr as time_desc, sales.svol
   FROM   sales, prod_dim, time_dim
   WHERE  sales.prod = prod_dim.prod
          AND sales.time = time_dim.time
)
   SELECT COALESCE (inv_with_dims.prod_desc, sales_with_dims.prod_desc) as prod_desc,
          COALESCE (inv_with_dims.time_desc, sales_with_dims.time_desc) as time_desc,
          inv_with_dims.prod_desc inv_prod_desc,
          inv_with_dims.time_desc inv_time_desc,
          sales_with_dims.prod_desc sales_prod_desc,
          sales_with_dims.time_desc sales_time_desc,
          inv_with_dims.vol as inventory_vol,
          sales_with_dims.svol as sales_vol
   FROM   inv_with_dims
   FULL OUTER JOIN sales_with_dims
   ON (inv_with_dims.prod     = sales_with_dims.prod
       AND inv_with_dims.time = sales_with_dims.time) ;

-- Asymmetric query
WITH t1 AS
(
   SELECT 1 as id, 'One' as descr FROM DUAL
   UNION ALL
   SELECT 2 as id, 'Two' as descr FROM DUAL
   UNION ALL
   SELECT 3 as id, 'Three' as descr FROM DUAL
   UNION ALL   
   SELECT 4 as id, 'Four' as descr FROM DUAL
   UNION ALL
   SELECT 5 as id, 'Five' as descr FROM DUAL
), t2 AS
(
   SELECT 11 as id, 'One 1' as descr FROM DUAL
   UNION ALL
   SELECT 12 as id, 'Two 2' as descr FROM DUAL
   UNION ALL
   SELECT 13 as id, 'Three 3' as descr FROM DUAL
), t1_rn AS
(
   SELECT ROW_NUMBER () OVER (ORDER BY id) as rn, id, descr
   FROM   t1
), t2_rn AS
(
   SELECT ROW_NUMBER () OVER (ORDER BY id) as rn, id, descr
   FROM   t2
)
   SELECT t1_rn.descr as t1_desc,
          t2_rn.descr as t2_desc
   FROM   t1_rn
   FULL OUTER JOIN t2_rn
   ON (t1_rn.rn = t2_rn.rn) ;
   
