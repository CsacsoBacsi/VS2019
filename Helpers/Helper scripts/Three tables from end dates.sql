with cust as (
select 1 as ice_customer_id, 1 as attr, date '2016-01-01' as from_date, date '2016-01-31' as to_date from dual
union all
select 1 as ice_customer_id, 1 as attr, date '2016-02-01' as from_date, date '2016-02-29' as to_date from dual
union all
select 1 as ice_customer_id, 1 as attr, date '2016-03-01' as from_date, date '2016-03-31' as to_date from dual
union all
select 1 as ice_customer_id, 1 as attr, date '2016-04-01' as from_date, date '9999-12-31' as to_date from dual
),
dev as (
select 1 as ice_customer_id, 2 as dev_type, date '2015-01-01' as from_date, date '2016-01-15' as to_date from dual
union all
select 1 as ice_customer_id, 2 as dev_type, date '2016-01-16' as from_date, date '2016-01-25' as to_date from dual
union all
select 1 as ice_customer_id, 2 as dev_type, date '2016-01-26' as from_date, date '2016-02-15' as to_date from dual
union all
select 1 as ice_customer_id, 2 as dev_type, date '2016-02-16' as from_date, date '2016-04-15' as to_date from dual
union all
select 1 as ice_customer_id, 2 as dev_type, date '2016-04-16' as from_date, date '9999-12-31' as to_date from dual
),
third as (
select 1 as ice_customer_id, 2 as third, date '2015-01-05' as from_date, date '2015-08-15' as to_date from dual
union all
select 1 as ice_customer_id, 2 as third, date '2015-08-16' as from_date, date '2016-01-01' as to_date from dual
union all
select 1 as ice_customer_id, 2 as third, date '2016-01-02' as from_date, date '2016-01-15' as to_date from dual
union all
select 1 as ice_customer_id, 2 as third, date '2016-01-16' as from_date, date '2016-03-25' as to_date from dual
union all
select 1 as ice_customer_id, 2 as third, date '2016-03-26' as from_date, date '2016-06-15' as to_date from dual
union all
select 1 as ice_customer_id, 2 as third, date '2016-06-16' as from_date, date '9999-12-31' as to_date from dual
),
days as (
select date '2015-12-31' + level as thisdate
from   dual
connect by level <= 1000
),
finally as (
select c.ice_customer_id, c.attr, d.dev_type, c.from_date, c.to_date, d.from_date as dfrom_date, d.to_date as dto_date, t.from_date as tfrom_date, t.to_date as tto_date
from   cust c,
       dev d,
       third t
where d.ice_customer_id = c.ice_customer_id
AND   d.ice_customer_id = t.ice_customer_id
AND c.from_date <= nvl (d.to_date, TO_DATE('31-DEC-9999','DD-MON-YYYY'))
AND d.from_date <= nvl (c.to_date, TO_DATE('31-DEC-9999','DD-MON-YYYY'))
AND c.from_date <= nvl (t.to_date, TO_DATE('31-DEC-9999','DD-MON-YYYY'))
AND t.from_date <= nvl (c.to_date, TO_DATE('31-DEC-9999','DD-MON-YYYY'))
)
select * from finally,
      days d
where d.thisdate between from_date and to_date
  and d.thisdate between dfrom_date and dto_date
  and d.thisdate between tfrom_date and tto_date
order by thisdate, from_date, dfrom_date, tfrom_date
;  -- Returns exactly 1000 rows so the query with the temporal WHERE-clauses is working!!!!
