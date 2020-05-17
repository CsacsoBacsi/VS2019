-- Number of entries in AW table
select count (*) from
(select a.PS#, extnum, a.gen#, awlob, objname, partname, dbms_lob.getlength(awlob) as obj_size
from gdf_b2b_aw.aw$csaba a)

-- AW table object and sizes
select a.PS#, extnum, a.gen#, awlob, objname, partname, dbms_lob.getlength(awlob) as obj_size
from gdf_b2b_aw.aw$csaba a
order by objname, partname

-- LOB segments (must be 8 of them by definition)
select   dbas.*
from     dba_lobs dbal, dba_segments dbas
where    dbal.column_name = 'AWLOB' and dbal.segment_name = dbas.segment_name
         AND dbal.table_name = 'AW$CSABA'
order by dbas.bytes desc ; 

-- Health check query
with act_size as (
     select sum (dbms_lob.getlength (awlob)) / (1024 * 1024) as col1
     from   gdf_b2b_aw.aw$gdf_b2b 
),
lob_size as (
     select sum (dbas.bytes) / (1024 * 1024) as col2
     from   dba_lobs dbal, dba_segments dbas
     where  dbal.column_name = 'AWLOB' and dbal.segment_name = dbas.segment_name
            AND dbal.table_name = 'AW$GDF_B2B'
)
select a.col1 as actual_obj_size, b.col2 as lob_segment_size, (1 - (a.col1 / b.col2)) * 100 as pct_space_wasted
from   act_size a,
       lob_size b

-- Compact/shrink space
alter table gdf_b2b_aw.aw$GDF_B2B modify lob (awlob) (shrink space) ;

alter table aw$csaba modify lob (awlob) (compact space) ;

-- *** Findings summary *** ---
-- 0. Cube data changes, new versions, scenarios' data always get appended to LOB above HWM (like direct path insert)
-- 1. DDL to defrag space below HWM can not be used in parallel (because of the LOB column)
-- 2. An object of type cube must be changed, upd, cmm, in order the partition drop or deletion to have any affect. For multiple gens, the exercise must be repeated.
-- 3. Shrinking process can not be split into two for LOB columns. COMPACT syntax does not seem to be supported
-- 4. Since cube might be spread across multiple LOB segment sub-partitions, no point in shrinking selected partitions only
-- 5. Populating cube then upd and cmm the AW while DDL taking place is possible. Result is still a fully compacted AW!
-- 6. No downtime associated with the process. AW can be attached even in rw, queried, updated, committed while DDL running
-- *** Findings end *** --- 

