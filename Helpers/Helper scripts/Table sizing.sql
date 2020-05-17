WITH v1 AS (
SELECT   SUM(bytes) bytes
       , owner
       , segment_name
       , NVL(tp.tablespace_name,se.tablespace_name) tablespace_name
       , SUM(CASE tp.compression WHEN 'ENABLED' THEN 1 ELSE 0 END)
        ||' OUT OF '||COUNT(*)||' PARTITIONS COMPRESSED' part_compression
       , COUNT(*) num_partitions
FROM     dba_segments se
LEFT JOIN dba_tab_partitions tp
          ON se.owner = tp.table_owner
          AND se.partition_name = tp.partition_name
          AND se.segment_name = tp.table_name
   WHERE se.segment_type LIKE 'TABLE%'
     AND owner NOT IN('SYS', 'SYSTEM')
     AND segment_name NOT LIKE 'BIN$%'
GROUP BY owner
       , se.segment_name
       , se.tablespace_name
       , tp.tablespace_name 
, tp.compression
)
, v2 AS ( 
SELECT owner
     , table_name
     , compression
     , tablespace_name
     , LOGGING
     , DEGREE
     , partitioned
  FROM dba_Tables
WHERE owner NOT IN('SYS', 'SYSTEM','ORACLE')
)
SELECT v1.owner
     , table_name
     , num_partitions
     , bytes
     , TO_CHAR((BYTES / 1024), '999G999G999G999D99') || 'Kbs' "Kilobytes"
     , TO_CHAR(((BYTES / 1024) / 1024), '999G999G999G999D99') || 'Mbs' "MegaBytes"
     , TO_CHAR((((BYTES / 1024) / 1024) / 1024), '999G999G999G999D99')
       || 'Gbs' "Gigabytes"
     , created
     , last_ddl_time      
     , NVL(compression,part_compression) compression
     , v1.tablespace_name
     , LOGGING
     , DEGREE
     , partitioned
  FROM v1 JOIN v2 ON v2.table_name = v1.segment_name AND v1.owner=v2.owner
    join dba_objects  dob on v2.table_name=dob.object_name and v2.owner=dob.owner
WHERE 1=1
AND DOB.OBJECT_TYPE='TABLE'
--AND v1.TABLESPACE_NAME = 'AE_SCRATCH' --'USERS' -- LIKE ('M02%')
--AND V1.tablespace_name = 'AEPW04_SANDPIT_SUPPORT'
--and REGEXP_LIKE(UPPER(v1.owner), '^[A-Z][0-9]+')
AND table_name LIKE '%AML_T_SMI%'
and v1.owner in ('C23833')
--AND table_name IN ( 'STG_AML_T_CMMI_LIVE_DATE')
