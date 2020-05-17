select SID, SERIAL#, OPNAME, TARGET, 
       SOFAR, TOTALWORK, START_TIME, TIME_REMAINING
from v$session_longops 
where username = 'RPT' AND time_remaining > 0
      -- and sql_id = 'fyz9yvnnvsa69'
      -- and trunc (SQL_EXEC_START) = TO_DATE ('06/09/2013', 'DD/MM/YYYY')
ORDER BY start_time DESC ;

select * 
from   v$session v
where  v.username = 'WESP_RPT' ;

select nvl (v2.sid, v.sid) AS SID, nvl (v2.serial#, v.serial#) AS SERIAL,
       CASE WHEN v.blocking_session = v2.sid 
            THEN v2.blocking_session
            ELSE v.blocking_session
       END AS blocking_session,
       CASE WHEN v.blocking_session = v2.sid
            THEN v2.event
            ELSE v.event
       END AS event,
       s.sql_id, s.sql_text 
from   v$session v
       JOIN
       v$session v2
       ON  ((v.sid = v2.sid
            AND v.SERIAL# = v2.serial#)
            OR (v.blocking_session = v2.sid))
       LEFT OUTER JOIN 
       v$sql s
       ON v.sql_id = s.sql_id
          AND v2.sql_id = s.sql_id
where  v.username = 'RPT' 
       ;
