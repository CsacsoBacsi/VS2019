-- Generate 1 month worth of dates
select /*+ materialize */
       to_date ('01/01/2013', 'DD/MM/YYYY') + level - 1 cal_date,
       level
from   dual   
connect by
       level <= to_date ('01/02/2013', 'DD/MM/YYYY') - to_date ('01/01/2013', 'DD/MM/YYYY') ;

-- Generate infinite numbers
select level
from   dual 
connect by level = level ;

-- Hiearchical query - all features
with data as (
   select 1 as emp_id, 'A' as name, 10 as man_id from dual
   union
   select 10 as emp_id, 'AA' as name, 100 as man_id from dual
   union
   select 2 as emp_id, 'B' as name, 20 as man_id from dual
   union
   select 20 as emp_id, 'BB' as name, 100 as man_id from dual
   union
   select 3 as emp_id, 'C' as name, 20 as man_id from dual
   union
   select 100 as emp_id, 'TOTAL' as nam, 1000 as man_id from dual
   union
   select 1000 as emp_id, 'GRANDTOTAL' as nam, null as man_id from dual
)
   select emp_id, name, man_id as manager_id,
          level, 
          REGEXP_REPLACE (sys_connect_by_path (name, ' -> '), '^ -> ', '')  as path,
          connect_by_root name "ROOT"
   from   data
   start with emp_id = 1000
   connect by nocycle prior emp_id = man_id
   order siblings by name desc ;


