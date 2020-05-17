with inp_data1 AS (
select 1 as id, 'One' as descr from dual
union
select 2 as id, 'Two' as descr from dual
union
select 3 as id, 'Three' as descr from dual)
, inp_data2 AS (
select 1 as id, 'One' as descr from dual
union
select 2 as id, 'Two' as descr from dual
union
select 4 as id, 'Four' as descr from dual
)
SELECT i1.id, i1.descr, i2.id, i2.descr
FROM   inp_data1 i1, inp_data2 i2
WHERE  i1.id = i2.id (+)
       AND i2.descr (+) = 'Two'
;

with inp_data1 AS (
select 1 as id, 'One' as descr from dual
union
select 2 as id, 'Two' as descr from dual
union
select 3 as id, 'Three' as descr from dual)
, inp_data2 AS (
select 1 as id, 'One' as descr from dual
union
select 2 as id, 'Two' as descr from dual
union
select 4 as id, 'Four' as descr from dual
)
SELECT i1.id, i1.descr, i2.id, i2.descr
FROM   inp_data1 i1
LEFT OUTER JOIN inp_data2 i2
ON i1.id = i2.id
AND i2.descr = 'Two'
;
--WHERE i2.descr = 'Two'
;

-- Another interesting thing
with src1 AS ( -- Three tables outer joined
select 1 as myid from dual
),
src2 AS (
select 2 as myid from dual
),
src3 AS (
select 3 as myid from dual
)
select src1.myid
from   src1
left outer join src2
on src1.myid = src2.myid
left outer join src3
on src2.myid = src3.myid -- No need to NVL src2.myid
; -- Fine!

with src1 AS (
select 1 as myid from dual
),
src2 AS (
select 2 as myid from dual
),
src3 AS (
select 3 as myid from dual
)
select src1.myid
from   src1, src2, src3
where  src1.myid = src2.myid (+)
--       AND NVL (src2.myid, -1) = src3.myid (+)
       AND src2.myid = src3.myid (+) -- No need for NVL either!
;

with src1 AS (
select 1 as myid, NULL as yourid from dual
union all
select 2 as myid, 2 as yourid from dual
),
src2 AS (
select 2 as yourid from dual
)
select src1.myid
from   src1, src2
where  src1.yourid = src2.yourid (+)
;

