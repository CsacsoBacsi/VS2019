Select a.* from v$sql a 

Select sid, serial#, username, machine, 
       a.seconds_in_wait, a.wait_class, a.osuser, a.event, a.program,
	   b.user_io_wait_time, b.sql_text
from v$session a,
     v$sql b
where a.TADDR = b.address (+) 
      AND wait_class <> 'Idle'

Select sid, serial#, username, machine, 
       a.seconds_in_wait, a.wait_class, a.osuser, a.event, a.program,
	   b.user_io_wait_time, b.sql_text 
from v$session a,
     v$sql b
where a.TADDR = b.address (+) 
      AND wait_class <> 'Idle'
	  AND osuser = 'c10879'
	  
	  
select * from v$session_longops where time_remaining <> 0 ;

