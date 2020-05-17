with src1 AS (
    SELECT 1 as myid, '1' as mydesc FROM DUAL
    UNION ALL
    SELECT 2 as myid, '2' as mydesc FROM DUAL
    UNION ALL
    SELECT NULL as myid, '3' as mydesc FROM DUAL
),
src2 AS (
    SELECT 1 as myid, '1' as mydesc FROM DUAL
    UNION ALL
    SELECT 2 as myid, '2' as mydesc FROM DUAL
    UNION ALL
    SELECT 3 as myid, '3' as mydesc FROM DUAL
)
SELECT src1.*, src2.*
FROM   src1, src2
WHERE  src1.myid = src2.myid (+) ;
