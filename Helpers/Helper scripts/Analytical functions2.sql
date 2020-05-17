with src as (
    select 1 as id, 10 as val, 1 as groupi from dual
    union all
    select 2 as id, 14 as val, 1 as groupi from dual
    union all    
    select 3 as id, 22 as val, 1 as groupi from dual
    union all
    select 4 as id, 30 as val, 1 as groupi from dual
    union all
    select 5 as id, 11 as val, 1 as groupi from dual
    union all
    select 6 as id, 6 as val, 2 as groupi from dual
    union all
    select 7 as id, 1 as val, 2 as groupi from dual
    union all
    select 8 as id, 5 as val, 2 as groupi from dual
    union all
    select 9 as id, 18 as val, 2 as groupi from dual
    union all
    select 10 as id, 18 as val, 2 as groupi from dual
),
abc as (
select id, val, groupi,
       count (*) over (partition by groupi) as group_sum,
       count (distinct val) over (partition by groupi) as dist_group_val,
       sum (val) over (order by val range between 5 preceding and 5 following) as sum_val,
       avg (val) over (order by val rows between 2 preceding and current row) as three_avg,
       avg (val) over (order by val rows between unbounded preceding and current row) as run_avg,
       sum (val) over (partition by groupi order by val rows between 1 preceding and 1 following) as groupi1_sum,
       dense_rank () over (order by val desc) as ranking,
       min (id) keep (dense_rank first order by val desc) over (partition by groupi) as min_value,
       first_value (id) over (partition by groupi order by val desc) as highest_in_group  
from   src
)
select *
from   abc
where ranking <= 10
order by val
;