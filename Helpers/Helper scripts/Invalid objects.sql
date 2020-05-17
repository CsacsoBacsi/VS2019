select
   owner,
   object_type,
   object_name
from
   dba_objects
where
   status != 'VALID'
   and owner = 'AML'
--   and object_type = 'VIEW'
order by
   owner,
   object_type; 
