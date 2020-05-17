with src as (
   select 1 as wid from dual
   union all
   select 2 as wid from dual
   union all
   select 3 as wid from dual
),
outtbl as (
   select 1 as wid, '1x' as ds, date '2016-01-01' as to_date from dual
   union all
   select 3 as wid, '3x' as ds, null as to_date from dual
)
select s.wid, o.to_date, ds
from   src s,
       outtbl o
where  s.wid = o.wid (+)
and    o.to_date is null -- 2 and 3. 2 because it is an outer join and 2 does not exist in the other set therefore to_date is null. 3 is joined and to_date is null
;

with src as (
   select 1 as wid from dual
   union all
   select 2 as wid from dual
   union all
   select 3 as wid from dual
),
outtbl as (
   select 1 as wid, '1x' as ds, date '2016-01-01' as to_date from dual
   union all
   select 3 as wid, '3x' as ds, null as to_date from dual
)
select s.wid, o.to_date, o.ds
from   src s,
       outtbl o
where  s.wid = o.wid (+)
and    o.to_date (+) is null -- 1, 2 and 3. ds is only shown for matched rows. 1 is included, despite not having to_date as null. 
;

with src as (
   select 1 as wid from dual
   union all
   select 2 as wid from dual
   union all
   select 3 as wid from dual
),
outtbl as (
   select 1 as wid, '1x' as ds, date '2016-01-01' as to_date from dual
   union all
   select 3 as wid, '3x' as ds, null as to_date from dual
)
select s.wid, o.to_date, o.ds
from   src s,
       outtbl o
where  s.wid = o.wid
and    o.to_date (+) is null -- 3 only. It is null
;

with src as (
   select 1 as wid from dual
   union all
   select 2 as wid from dual
   union all
   select 3 as wid from dual
)
select s.wid
from   src s
where  s.wid (+) = 5 ; -- No rows. There is no table to outer join the other table
;

-- ANSI join
with src as (
   select 1 as wid from dual
   union all
   select 2 as wid from dual
   union all
   select 3 as wid from dual
),
outtbl as (
   select 1 as wid, date '2016-01-01' as to_date from dual
   union all
   select 3 as wid, null as to_date from dual
)
select s.wid, o.to_date
from   src s
left outer join
       outtbl o
on     s.wid = o.wid
and    o.to_date is null -- 1, 2, 3
;

with src as (
   select 1 as wid from dual
   union all
   select 2 as wid from dual
   union all
   select 3 as wid from dual
),
outtbl as (
   select 1 as wid, date '2016-01-01' as to_date from dual
   union all
   select 3 as wid, null as to_date from dual
)
select s.wid, o.to_date
from   src s
left outer join
       outtbl o
on     s.wid = o.wid
where  o.to_date is null -- 2, 3. It is a filter rathere than part of the outer join
;


-- Scenario 1.
with src as (
    select 1 as id, 1 as val from dual
    union all
    select 2 as id, 2 as val from dual
),
out1 as (
    select 1 as id, 1 as val1 from dual
    union all
    select 3 as id, 3 as val1 from dual
),
out2 as (
    select 1 as id, 1 as val2 from dual
    union all
    select 3 as id, 2 as val2 from dual
)
select s.id, s.val, o1.id, o1.val1, o2.id, o2.val2
from   src s,
       out1 o1,
       out2 o2
where  s.id = o1.id (+)
  and  o1.id = o2.id
; -- Returns only 1 row as s.id = 2 is paired with o1.id = null which is then paired with o2.id

-- Scenario 2.
with src as (
    select 1 as id, 1 as val from dual
    union all
    select 2 as id, 2 as val from dual
),
out1 as (
    select 1 as id, 1 as val1 from dual
    union all
    select 3 as id, 3 as val1 from dual
),
out2 as (
    select 1 as id, 1 as val2 from dual
    union all
    select 3 as id, 2 as val2 from dual
)
select s.id, s.val, o1.id, o1.val1, o2.id, o2.val2
from   src s,
       out1 o1,
       out2 o2
where  s.id = o1.id (+)
  and  o1.id = o2.id (+)
; -- Returns 2 rows because s.id = 2 is outer joined to o1 then o1.id = null is outer joined to to o2.id

-- Scenario 3.
with src as (
    select 1 as id, 1 as val from dual
    union all
    select 2 as id, 2 as val from dual
),
out1 as (
    select 1 as id, 1 as val1 from dual
    union all
    select 3 as id, 3 as val1 from dual
),
out2 as (
    select 1 as id, 1 as val2 from dual
    union all
    select 3 as id, 2 as val2 from dual
),
out1_out2 as (
    select o1.id, o1.val1, o2.val2
    from   out1 o1,
           out2 o2
    where  o1.id = o2.id
)
select s.id, s.val, o12.id, o12.val1, o12.val2
from   src s,
       out1_out2 o12
where  s.id = o12.id (+)
; -- Returns 2 rows as first the inner join bit is resolved then the outer join
