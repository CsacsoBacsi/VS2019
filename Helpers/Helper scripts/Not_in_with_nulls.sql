with dep as (
    select 1 as dept from dual
    union all
    select 2 as dept from dual
    union all
    select 3 as dept from dual
),
emp as (
    select 1 as emp, 1 as dept from dual
    union all
    select 2 as emp, NULL as dept from dual -- No rows returned because of the NULL value!
    union all
    select 3 as emp, 3 as dept from dual
)
select dep.dept
from   dep
where  dept not in (select emp.dept
                    from   emp)
;   

-- Solution: nvl (emp.dept, -9999999)
