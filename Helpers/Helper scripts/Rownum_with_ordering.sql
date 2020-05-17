-- Row number when sorting the set

select id, value, "DESC", rownum as row_number -- Rownum is assigned prior to ordering
from test_data
order by "DESC" desc ;

with sorted as (
select id, value, "DESC"
from test_data
order by "DESC" desc
)
select id, value, "DESC", rownum as row_number -- The correct version of the query
from sorted ;


