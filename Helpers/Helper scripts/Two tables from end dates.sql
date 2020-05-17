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
days as (
select date '2015-12-31' + level as thisdate
from   dual
connect by level <= 1000
),
finally as (
select c.ice_customer_id, c.attr, d.dev_type, c.from_date, c.to_date, d.from_date as dfrom_date, d.to_date as dto_date
from   cust c,
       dev d
where d.ice_customer_id = c.ice_customer_id
AND c.from_date <= nvl (d.to_date, TO_DATE('31-DEC-9999','DD-MON-YYYY'))
AND d.from_date <= nvl (c.to_date, TO_DATE('31-DEC-9999','DD-MON-YYYY'))
)
select * from finally,
      days d
where d.thisdate between from_date and to_date
  and d.thisdate between dfrom_date and dto_date -- Returns exactly 1000 rows so the query with the temporal WHERE-clause is brill!
order by thisdate, from_date, dfrom_date
;

-- Better this one!

with cust as (
select 1 as ice_customer_id, 1 as attr, date '2016-01-01' as from_date, date '2016-01-31' as to_date from dual
union all
select 1 as ice_customer_id, 2 as attr, date '2016-02-01' as from_date, date '2016-02-29' as to_date from dual
union all
select 1 as ice_customer_id, 3 as attr, date '2016-03-01' as from_date, date '2016-03-31' as to_date from dual
union all
select 1 as ice_customer_id, 4 as attr, date '2016-04-01' as from_date, date '9999-12-31' as to_date from dual
),
dev as (
select 1 as ice_customer_id, 5 as dev_type, date '2015-01-01' as from_date, date '2016-01-15' as to_date from dual
union all
select 1 as ice_customer_id, 6 as dev_type, date '2016-01-16' as from_date, date '2016-01-25' as to_date from dual
union all
select 1 as ice_customer_id, 7 as dev_type, date '2016-01-26' as from_date, date '2016-02-15' as to_date from dual
union all
select 1 as ice_customer_id, 8 as dev_type, date '2016-02-16' as from_date, date '2016-03-15' as to_date from dual
union all
select 1 as ice_customer_id, 9 as dev_type, date '2016-03-16' as from_date, date '2016-03-17' as to_date from dual
),
vw1 as (
select c.ice_customer_id,
       c.attr,
       c.from_date,
       c.to_date,
       d.dev_type
from   cust c
left join dev d
  on   c.ice_customer_id = d.ice_customer_id
 and   c.from_date between d.from_date and d.to_date
union all
select d.ice_customer_id,
       c.attr,
       d.from_date,
       d.to_date,
       d.dev_type
from   dev d
left join cust c
  on   c.ice_customer_id = d.ice_customer_id
 and   d.from_date between c.from_date and c.to_date
),
vw2 as (
select min (from_date) as from_date,
       ice_customer_id,
       attr,
       dev_type
from   vw1
group by ice_customer_id,
         attr,
         dev_type
),
vw3 as (
select from_date,
       nvl (lead(from_date, 1) over (partition by ice_customer_id order by from_date ) - 1, date '9999-12-31') to_date,
       ice_customer_id,
       attr,
       dev_type
from   vw2
)
select from_date,
       case to_date 
            when date '9999-12-31' then null 
            else to_date
       end as to_date,
       ice_customer_id,
       attr,
       dev_type
from   vw3
where  from_date <= to_date
  and  ice_customer_id is not null
/
