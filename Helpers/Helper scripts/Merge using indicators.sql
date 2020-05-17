drop table csaba_src ;
drop table csaba_trg ;

create table csaba_src (
col1 varchar2 (10),
col2 varchar2 (10),
col3 varchar2 (10),
val number
) ;

create table csaba_trg (
col1 varchar2 (10),
col2 varchar2 (10),
col3 varchar2 (10),
val number,
start_date date,
end_date date
) ;

-- ***************************************************************************************************************************
-- Full source updating target
-- ***************************************************************************************************************************

truncate table csaba_src ;
truncate table csaba_trg ;

insert into csaba_trg (col1, col2, col3, val, start_date, end_date)
values ('1','1','1',1, to_date ('01/01/2019', 'DD/MM/YYYY'), NULL) ;
insert into csaba_trg (col1, col2, col3, val, start_date, end_date)
values ('2','1','1',1, to_date ('01/01/2019', 'DD/MM/YYYY'), NULL) ;
insert into csaba_trg (col1, col2, col3, val, start_date, end_date)
values ('3','1','1',1, to_date ('01/01/2019', 'DD/MM/YYYY'), NULL) ;
insert into csaba_trg (col1, col2, col3, val, start_date, end_date)
values ('4','1','1',1, to_date ('01/01/2019', 'DD/MM/YYYY'), NULL) ;
insert into csaba_trg (col1, col2, col3, val, start_date, end_date)
values ('5','1','1',1, to_date ('01/01/2019', 'DD/MM/YYYY'), NULL) ;

commit ;

-- 1 is deleted, so Update
insert into csaba_src (col1, col2, col3, val)
values ('6','1','1',1) ; -- New row, INSERT
insert into csaba_src (col1, col2, col3, val)
values ('2','1','1',2) ; -- Update val
insert into csaba_src (col1, col2, col3, val)
values ('3','1','1',1) ; -- Nothing here
insert into csaba_src (col1, col2, col3, val)
values ('4','1','1',1) ; -- Nothing here
-- 5 is deleted, so Update
insert into csaba_src (col1, col2, col3, val) -- Duplicate. Must be ignored
values ('10','1','1',1) ;
insert into csaba_src (col1, col2, col3, val)
values ('10','1','1',1) ;
commit ;

WITH ua AS ( 
        SELECT col1, col2, col3, val,
               1 AS ind1, -- Exists in source
               TO_NUMBER (NULL) AS ind2
        FROM   csaba_src 
        WHERE  1=1  
        UNION ALL 
        SELECT col1, col2, col3, val, 
               TO_NUMBER (NULL) AS ind1,
               1 AS ind2 -- Exists in target
        FROM   csaba_trg 
        WHERE  end_date IS NULL  
    )
    SELECT ua.col1, ua.col2, ua.col3, ua.val, 
           CASE WHEN COUNT (ua.ind2) = 0 AND COUNT (ua.ind1) = 1 THEN 'I' -- Row in source nothing in target (needs inserting)
                WHEN COUNT (ua.ind1) = 0 AND COUNT (ua.ind2) = 1 THEN 'U' -- Row in target nothing in source (needs end dating)
                ELSE                                                  'Q' -- Could be 2 on one side and 1 on the other if there are dupes (eliminate these)
            END AS transaction_type, 
            COUNT (ua.ind1) count_ind1, -- For testing purposes only
            COUNT (ua.ind2) count_ind2,
            trunc (sysdate) as start_date,
            trunc (sysdate - 1) as end_date 
      FROM  ua 
      GROUP BY ua.col1, ua.col2, ua.col3, ua.val 
      HAVING COUNT (ua.ind1) != COUNT (ua.ind2)
;

MERGE /*+ APPEND  */ 
INTO csaba_trg t USING  
    (WITH ua AS ( 
        SELECT col1, col2, col3, val,
               1 AS ind1, -- Exists in source
               TO_NUMBER (NULL) AS ind2
        FROM   csaba_src 
        WHERE  1=1  
        UNION ALL 
        SELECT col1, col2, col3, val, 
               TO_NUMBER (NULL) AS ind1,
               1 AS ind2 -- Exists in target
        FROM   csaba_trg 
        WHERE  end_date IS NULL  
    )
    SELECT ua.col1, ua.col2, ua.col3, ua.val, 
           CASE WHEN COUNT (ua.ind2) = 0 AND COUNT (ua.ind1) = 1 THEN 'I' -- Row in source nothing in target (needs inserting)
                WHEN COUNT (ua.ind1) = 0 AND COUNT (ua.ind2) = 1 THEN 'U' -- Row in target nothing in source (needs end dating)
                ELSE                                                  'Q' -- Could be 2 on one side and 1 on the other if there are dupes (eliminate these)
            END AS transaction_type, 
            COUNT (ua.ind1) count_ind1, -- For testing purposes only
            COUNT (ua.ind2) count_ind2,
            trunc (sysdate) as start_date,
            trunc (sysdate - 1) as end_date 
      FROM  ua 
      GROUP BY ua.col1, ua.col2, ua.col3, ua.val 
      HAVING COUNT (ua.ind1) != COUNT (ua.ind2)) src 
ON (t.col1 || '||' || t.col2 || '||' || t.col3 || '||' || 'U' = 
    src.col1 || '||' || src.col2 || '||' || src.col3 || '||' || src.transaction_type) 
WHEN MATCHED THEN UPDATE  
    SET t.end_date = src.end_date
    WHERE t.end_date IS NULL 
WHEN NOT MATCHED THEN INSERT (col1, col2, col3, val, 
                              start_date, end_date) 
                      VALUES (src.col1, src.col2, src.col3, src.val, 
                              src.start_date,
                              NULL) 
                      WHERE  transaction_type = 'I' -- To eliminate 'Q's
;

select * from csaba_trg ;

-- ***************************************************************************************************************************
-- Incremental source updating target
-- ***************************************************************************************************************************

truncate table csaba_src ;
truncate table csaba_trg ;

insert into csaba_trg (col1, col2, col3, val, start_date, end_date)
values ('1','1','1',1, to_date ('01/01/2019', 'DD/MM/YYYY'), NULL) ;
insert into csaba_trg (col1, col2, col3, val, start_date, end_date)
values ('2','1','1',1, to_date ('01/01/2019', 'DD/MM/YYYY'), NULL) ;
insert into csaba_trg (col1, col2, col3, val, start_date, end_date)
values ('3','1','1',1, to_date ('01/01/2019', 'DD/MM/YYYY'), NULL) ;
insert into csaba_trg (col1, col2, col3, val, start_date, end_date)
values ('4','1','1',1, to_date ('01/01/2019', 'DD/MM/YYYY'), NULL) ;
insert into csaba_trg (col1, col2, col3, val, start_date, end_date)
values ('5','1','1',1, to_date ('01/01/2019', 'DD/MM/YYYY'), NULL) ;

commit ;

insert into csaba_src (col1, col2, col3, val)
values ('6','1','1',1) ; -- New row, INSERT
insert into csaba_src (col1, col2, col3, val)
values ('2','1','1',2) ; -- Update val
insert into csaba_src (col1, col2, col3, val) -- Duplicate. Must be ignored
values ('10','1','1',1) ;
insert into csaba_src (col1, col2, col3, val)
values ('10','1','1',1) ;
commit ;

WITH ua AS ( 
        SELECT col1, col2, col3, val,
               1 AS ind1, -- Exists in source
               TO_NUMBER (NULL) AS ind2
        FROM   csaba_src 
        WHERE  1=1  
        UNION ALL 
        SELECT col1, col2, col3, val, 
               TO_NUMBER (NULL) AS ind1,
               1 AS ind2 -- Exists in target
        FROM   csaba_trg 
        WHERE  end_date IS NULL  
    )
    SELECT ua.col1, ua.col2, ua.col3, ua.val, 
           CASE WHEN COUNT (ua.ind2) = 0 AND COUNT (ua.ind1) = 1 THEN 'I' -- Row in source nothing in target (needs inserting)
                WHEN COUNT (ua.ind1) = 0 AND COUNT (ua.ind2) = 1 THEN 'U' -- Row in target nothing in source (needs end dating)
                ELSE                                                  'Q' -- Could be 2 on one side and 1 on the other if there are dupes (eliminate these)
            END AS transaction_type, 
            COUNT (ua.ind1) count_ind1, -- For testing purposes only
            COUNT (ua.ind2) count_ind2,
            trunc (sysdate) as start_date,
            trunc (sysdate - 1) as end_date,
            CASE WHEN COUNT (*) OVER (PARTITION BY ua.col1 || '||' || ua.col2 || '||' || ua.col3) > 1 THEN 'Y' ELSE 'N' END as true_upd
      FROM  ua 
      GROUP BY ua.col1, ua.col2, ua.col3, ua.val 
      HAVING COUNT (ua.ind1) != COUNT (ua.ind2)
;

MERGE /*+ APPEND  */ 
INTO csaba_trg t USING  
    (WITH ua AS (
        SELECT col1, col2, col3, val,
               1 AS ind1, -- Exists in source
               TO_NUMBER (NULL) AS ind2
        FROM   csaba_src 
        WHERE  1=1  
        UNION ALL 
        SELECT col1, col2, col3, val, 
               TO_NUMBER (NULL) AS ind1,
               1 AS ind2 -- Exists in target
        FROM   csaba_trg 
        WHERE  end_date IS NULL  
    )
    SELECT ua.col1, ua.col2, ua.col3, ua.val, 
           CASE WHEN COUNT (ua.ind2) = 0 AND COUNT (ua.ind1) = 1 THEN 'I' -- Row in source nothing in target (needs inserting)
                WHEN COUNT (ua.ind1) = 0 AND COUNT (ua.ind2) = 1 THEN 'U' -- Row in target nothing in source (needs end dating)
                ELSE                                                  'Q' -- Could be 2 on one side and 1 on the other if there are dupes (eliminate these)
            END AS transaction_type, 
            COUNT (ua.ind1) count_ind1, -- For testing purposes only
            COUNT (ua.ind2) count_ind2,
            trunc (sysdate) as start_date,
            trunc (sysdate - 1) as end_date,
            CASE WHEN COUNT (*) OVER (PARTITION BY ua.col1 || '||' || ua.col2 || '||' || ua.col3) > 1 THEN 'Y' ELSE 'N' END as true_upd -- Eliminates false updates where target row treated as deleted
      FROM  ua 
      GROUP BY ua.col1, ua.col2, ua.col3, ua.val 
      HAVING COUNT (ua.ind1) != COUNT (ua.ind2)) src 
ON (t.col1 || '||' || t.col2 || '||' || t.col3 || '||' || 'U' = 
    src.col1 || '||' || src.col2 || '||' || src.col3 || '||' || src.transaction_type) 
WHEN MATCHED THEN UPDATE 
    SET t.end_date = src.end_date
    WHERE t.end_date IS NULL AND src.true_upd = 'Y' 
WHEN NOT MATCHED THEN INSERT (col1, col2, col3, val, 
                              start_date, end_date) 
                      VALUES (src.col1, src.col2, src.col3, src.val, 
                              src.start_date,
                              NULL) 
                      WHERE  transaction_type = 'I' -- To eliminate 'Q's
;

select * from csaba_trg ;
