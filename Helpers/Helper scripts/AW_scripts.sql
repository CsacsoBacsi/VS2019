
-- BLOB size per object
select sum (dbms_lob.getlength(awlob)) as obj_size
from ftp_olap2.aw$rc_poc
where objname like 'XXXXXX%'

select extnum, awlob, objname, partname, dbms_lob.getlength(awlob) as obj_size
from ftp_olap2.aw$rc_poc
where objname like 'RC%'
order by objname, partname

-- Size of all AWs
select   dbal.owner "Owner", dbal.table_name "AW Table", trunc(sum(dbas.bytes)/1024/1024) as "MB"
from     dba_lobs dbal, dba_segments dbas
where    dbal.column_name = 'AWLOB' and dbal.segment_name = dbas.segment_name
group by dbal.owner, dbal.table_name order by dbal.owner, dbal.table_name;


-- Wait Events occured in the last hour
select   username||' ('||sid||','||serial#||')' as awuser,
         owner||'.'||aw_name||' ('||decode(attach_mode, 'READ WRITE', 'RW',
                                                        'READ ONLY',  'RO', attach_mode)||')' awnm,
         decode (session_state, 'WAITING', a.event, null) event,
         session_state, count(*), sum (time_waited) time_waited
from     v$active_session_history a, v$session b, v$aw_olap c, dba_aws d
where    sid=a.session_id and sid=c.session_id
and      sample_time > sysdate - (1/24)
and      c.aw_number=d.aw_number
group by username, sid, serial#, owner, aw_name, attach_mode,
         decode (session_state, 'WAITING', a.event, null), session_state;

		 
-- AW		 
select   awps.owner, syaw.owner#, awps.aw_number aw#, awps.aw_name
,        max(awps.psnumber) last_ps#, count(awps.psnumber) cnt_ps#
,        max(awps.generations) gens
from     dba_aw_ps awps, sys.aw$ syaw
where    awps.aw_number = syaw.awseq# and awps.aw_name = syaw.awname
group by awps.owner, syaw.owner#, awps.aw_number, awps.aw_name
order by awps.owner, awps.aw_name;


-- AW (LOBs)
select   a.owner||'.'||table_name name, nvl(partition_name, 'unpart') part,
         a.segment_name seg, buffer_pool
from     dba_segments a, dba_lobs b
where    (a.segment_name=b.segment_name or a.segment_name=b.index_name) and
         (table_name like 'AW$%' or b.index_name like 'SYS_IL%' and
          table_name like 'AW$%') and
         not a.owner in ('SYS','SYSTEM','OLAPSYS')
order by table_name;


-- XML_LOAD_LOG
select xml_date, xml_message, xml_loadid, xml_recordid, xml_aw
from olapsys.xml_load_log
order by xml_date desc, xml_recordid desc;

-- Tablespaces Info
SELECT d.tablespace_name name
,      substr(d.contents, 1, 4) ttype
,      a.autoextensible auto
,      NVL(o.ownr,0) ownr
,      ROUND(NVL(a.bytes/1024/1024,0), 2)  "SIZE (MB)"
,      ROUND(((NVL(a.bytes/1024/1024,0))-(NVL(NVL(f.bytes,0),0)/1024/1024)), 2) "USED (MB)"
,      NVL(g.bytes/1024/1024,0) "AWs (MB)"
,      NVL(g.awcnt,0) aws, NVL(g.segcnt,0) segs
,      d.status status
,      to_char(ROUND(NVL(NVL(f.bytes,0),0)/1024/1024, 2)) "Free (MB)"
,      ROUND(NVL((NVL(f.bytes,0))/a.bytes*100,0), 2) || ' % Free' "% Free"
,      d.status status
FROM   sys.dba_tablespaces d
,      (select tablespace_name, autoextensible, sum(bytes) bytes
        from dba_data_files group by tablespace_name, autoextensible) a
,      (select tablespace_name, sum(bytes) bytes
        from dba_free_space group by tablespace_name) f
,      (select dbas.tablespace_name, count(distinct table_name) as awcnt, count(*) as segcnt,
        sum(dbas.bytes) bytes from dba_lobs dbal, dba_segments dbas
        where dbal.column_name = 'AWLOB' and dbal.segment_name = dbas.segment_name
        group by dbas.tablespace_name) g
,      (select tablespace_name, count(distinct owner) ownr
        from dba_segments group by tablespace_name) o
WHERE   d.tablespace_name = a.tablespace_name(+) AND d.tablespace_name = f.tablespace_name(+)
AND     d.tablespace_name = g.tablespace_name(+) AND d.tablespace_name = o.tablespace_name(+)
AND NOT (d.extent_management like 'LOCAL' AND d.contents like 'TEMPORARY')
UNION ALL
SELECT d.tablespace_name name, substr(d.contents, 1, 4) ttype, a.autoextensible auto
,      NVL(o.ownr, 0) ownr, ROUND(NVL(a.bytes /1024/1024, 0), 2) "SIZE (MB)"
,      ROUND(((NVL(a.bytes/1024/1024,0))-(NVL((a.bytes-t.bytes),a.bytes)/1024/1024)), 2) "USED (MB)"
,      NVL(g.bytes/1024/1024,0) "AWs (MB)", NVL(g.awcnt,0) aws, NVL(g.segcnt,0) segs
,      d.status status
,      to_char(ROUND(NVL((a.bytes-t.bytes),a.bytes)/1024/1024, 2)) "Free (MB)"
,      ROUND(NVL((a.bytes-t.bytes)/a.bytes*100,100), 2) || ' % Free' "% Free"
,      d.status status
FROM   sys.dba_tablespaces d
,      (select tablespace_name, autoextensible, sum(bytes) bytes
        from dba_temp_files group by tablespace_name, autoextensible) a
,      (select tablespace_name, sum(bytes_cached) bytes from v$temp_extent_pool
        group by tablespace_name) t
,      (select dbas.tablespace_name, count(distinct table_name) as awcnt, count(*) as segcnt,
        sum(dbas.bytes) bytes from dba_lobs dbal, dba_segments dbas
        where dbal.column_name = 'AWLOB' and dbal.segment_name = dbas.segment_name
        group by dbas.tablespace_name) g
,      (select tablespace_name, count(distinct owner) ownr
        from dba_segments group by tablespace_name) o
WHERE  d.tablespace_name = a.tablespace_name(+) AND d.tablespace_name = t.tablespace_name(+) AND    d.tablespace_name = g.tablespace_name(+) AND d.tablespace_name = o.tablespace_name(+)
AND    d.extent_management like 'LOCAL'         AND d.contents like 'TEMPORARY'
ORDER BY ttype, name;


-- AWs attached (by Sessions)
select to_char(s.logon_time, '  DD-MON, HH24:mm:ss') "LOGIN_TIME", c.owner || '.' || c.aw_name "AW", decode(a.attach_mode, 'READ ONLY', 'RO', 'RW') "ATTCH", s.username,
       s.inst_id, s.sid, s.serial#, s.lockwait,
       s.state, s.status, s.osuser, s.machine, s.terminal, s.program, s.module
from gv$session s, gv$aw_olap a, dba_aws c
where s.inst_id = a.inst_id
  and s.sid = a.session_id
  and a.aw_number = c.aw_number
order by  c.owner || '.' || c.aw_name, status, logon_time desc;


-- AWs attached (sorted by AW Names)
select to_char(s.logon_time, '  DD-MON, HH24:mm:ss') "LOGIN_TIME", c.owner || '.' || c.aw_name "AW",  decode(a.attach_mode, 'READ ONLY', 'RO', 'RW') "ATTCH", s.username,
       s.inst_id, s.sid, s.serial#, s.lockwait,
       s.state, s.status, s.osuser, s.machine, s.terminal, s.program, s.module
from gv$session s, gv$aw_olap a, dba_aws c
where s.inst_id = a.inst_id
  and s.sid = a.session_id
  and a.aw_number = c.aw_number
order by aw, status, logon_time desc;


-- AWs attached (by UserName)
select to_char(s.logon_time, '  DD-MON, HH24:mm:ss') "LOGIN_TIME", c.owner || '.' || c.aw_name "AW",  decode(a.attach_mode, 'READ ONLY', 'RO', 'RW') "ATTCH", s.username,
       s.inst_id, s.sid, s.serial#, s.lockwait,
       s.state, s.status, s.osuser, s.machine, s.terminal, s.program, s.module
from gv$session s, gv$aw_olap a, dba_aws c
where s.inst_id = a.inst_id
  and s.sid = a.session_id
  and a.aw_number = c.aw_number
order by username desc, status, logon_time desc;

-- DB_INFO
-- Redo Buffer Allocation Entries
-- When to increase the size of log_buffer
-- If this number steadily increases, consider increasing size of log_buffer.

select name, value from v$sysstat where name = 'redo buffer allocation retries';

-- Redo Log Space Requests
-- This value should be near 0. If this value increments consistently, processes have had to wait for space in the buffer. This may be caused the checkpointing or log switching.  Improve checkpointing or archiving process. 
select name, value from v$sysstat where name = 'redo log space requests';


-- Log Buffer and Latch Contention
-- If the ratio of MISSES to GETS exceeds 1%, or the ratio of IMMEDIATE_MISSES to (IMMEDIATE_GETS + IMMEDIATE_MISSES) exceeds 1%, there is latch contention.
select substr(ln.name, 1, 17) "name", gets "gets", misses "misses",
       round((1-((gets-misses)/gets))*100,4) "ratio",
       immediate_gets "imm gets", immediate_misses "imm misses",
       round((1-((immediate_gets-immediate_misses)/immediate_gets))*100,4) "ratio"
from   v$latch l, v$latchname ln
where  ln.name in ('redo allocation', 'redo copy') and ln.latch# = l.latch#;

-- Tablespaces (by Reads)
select   tablespace_name tablespace,
         sum(phyrds) reads,
         sum(phywrts) writes
from     dba_data_files,
         v$filestat
where    file_id = file#
group by tablespace_name
order by reads desc;

-- Tablespaces (by writes)
select   tablespace_name tablespace,
         sum(phyrds) reads,
         sum(phywrts) writes
from     dba_data_files,
         v$filestat
where    file_id = file#
group by tablespace_name
order by writes desc;

-- PGA_INUSE and OLAP_PAGE
SELECT      'OLAP Pages Occupying: '
                       ||   ROUND ((  ((SELECT SUM (NVL (pool_size, 1))
                                          FROM v$aw_calc))
                                    / (SELECT VALUE
                                         FROM v$pgastat
                                        WHERE NAME = 'total PGA inuse')
                                   ),
                                   2
                                  )
                         * 100
                      || '%' info
                 FROM DUAL
             UNION
             SELECT   'Total PGA Inuse Size: ' || VALUE / 1024 || ' KB' info
                 FROM v$pgastat
                WHERE NAME = 'total PGA inuse'
             UNION
             SELECT      'Total OLAP Page Size: '
                      || ROUND (SUM (NVL (pool_size, 1)) / 1024, 0)
                      || ' KB' info
                 FROM v$aw_calc
             ORDER BY info DESC;

-- OLAP Page Pool Ratio (by User)
SELECT vs.username,
       vs.SID,
       ROUND (pga_used_mem / 1024 / 1024, 2) || ' MB' "pga_used (mb)",
       ROUND (pga_max_mem / 1024 / 1024, 2)  || ' MB' "pga_max (mb)",
       ROUND (pool_size / 1024 / 1024, 2)    || ' MB' "olap_page_pool (mb)",
       ROUND (100 * (pool_hits - pool_misses) / pool_hits, 2) || ' %' "olap_ratio"
FROM v$process vp, v$session vs, v$aw_calc va
WHERE session_id = vs.SID AND addr = paddr;

-- OLAP Sessions
select to_char(s.logon_time, '  DD-MON, HH24:mm:ss') "LOGIN_TIME", s.inst_id, s.sid, s.serial#, s.username,
       a.curr_dml_command, a.prev_dml_command, s.lockwait,
       s.state, s.status, s.osuser, s.machine, s.terminal, s.program, s.module
from gv$session s, gv$aw_calc a
where s.inst_id = a.inst_id
  and s.sid = a.session_id
order by status, logon_time desc;


-- ASM_DISK
select name, failgroup, path, mount_status, mode_status, total_mb, free_mb, state,
group_number, disk_number, reads, writes, read_errs, write_errs, read_time, write_time, bytes_read, bytes_written
from v$asm_disk;

-- ASM_DISKGROUP
select * from v$asm_diskgroup;
-- OWB
-- OWB Executions
select a.updated_on, execution_name, task_name, object_name, return_result, return_code, execution_audit_status, elapse_time,
       number_task_errors, message_severity, message_line_number, message_text
from  peismt2.all_rt_audit_executions a, peismt2.all_rt_audit_exec_messages b
where a.execution_audit_id = b.execution_audit_id(+)
  and object_type = 'PLSQLMap'
order by a.updated_on desc;

-- OWB Runtime Errors
select CREATION_DATE, LAST_UPDATE_DATE, RTE_DEST_TABLE, RTE_STATEMENT, RTE_SQLERR, RTE_SQLERRM, CREATED_BY, LAST_UPDATED_BY, RTE_IID, RTA_IID, RTA_STEP, RTD_IID, RTO_IID, RTE_ROWKEY, RTE_ROWID,  RTE_DEST_COLUMN, RTE_VALUE, RTE_CORRECTION
from peismt2.wb_rt_errors order by last_update_date desc;
