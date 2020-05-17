CREATE OR REPLACE procedure aggpartlog (partname varchar2, msg varchar2, awname varchar2) is
begin
   insert into agg_log values (systimestamp, partname, msg, awname) ;
   commit ;

   EXCEPTION
   WHEN OTHERS THEN
         insert into agg_log values (systimestamp, partname, msg, awname) ;
   commit ;
end ;
/

CREATE OR REPLACE procedure aggpart (awname varchar2, partname varchar2, dimvalue varchar2) is
emsg varchar2 (500) ;
begin
   dbms_aw.execute ('dtb attach ' || awname || ' multi') ;
   insert into agg_log values (systimestamp, partname, 'AW ' || awname || ' attached multi-writer mode, calling DML...', awname) ;
   commit ;
   dbms_aw.execute ('call _aggpart (''' || partname || '''' || '''' || dimvalue || ''')') ;
   dbms_aw.execute ('dtb detach ' || awname) ;
   insert into agg_log values (systimestamp, partname, 'AW ' || awname || ' detached.', awname) ;
   commit ;

   EXCEPTION
   WHEN OTHERS THEN
         dbms_aw.execute ('dtb detach ' || awname) ; 
         emsg := 'Error occurred during the aggregation of partition: ' || partname || ': ' || sqlerrm ;
         insert into agg_log values (systimestamp, partname, emsg, awname) ;
   commit ;
end ;

execute dbms_job.broken (9998, true) ;


select * from all_jobs ;

select * from user_jobs ;

select * from dba_jobs_running ;

call dbms_job.run (9998) ;

select * from v$session where username = 'C10879';

commit ;

call kill_session (527, 2132) ;

execute dbms_job.isubmit (9990, 'begin aggpart (''P26''); end;', sysdate, null, false) ;

select * from agg_log order by nvl (partname, 'AAAA'), time_stamp asc ;


