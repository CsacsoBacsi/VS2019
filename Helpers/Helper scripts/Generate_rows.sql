-- How to generate some test data
create table test_data (
   "ID" number,
   "VALUE" number,
   "DESC" varchar2 (100),
   "GROUP_VAL" number)
;

insert into test_data
select rownum as id,
       1000-rownum as value,
       CASE WHEN length (to_char (rownum)) > 1 and substr (to_char (rownum), length (to_char (rownum)) - 1, 2) = '11'
            THEN to_char (rownum) || 'th row'
            WHEN length (to_char (rownum)) > 1 and substr (to_char (rownum), length (to_char (rownum)) - 1, 2) = '12'
            THEN to_char (rownum) || 'th row'
            WHEN length (to_char (rownum)) > 1 and substr (to_char (rownum), length (to_char (rownum)) - 1, 2) = '13'
            THEN to_char (rownum) || 'th row'
            WHEN substr (to_char (rownum), length (to_char (rownum)), 1) = '1'
            THEN to_char (rownum) || 'st row'
            WHEN substr (to_char (rownum), length (to_char (rownum)), 1) = '2'
            THEN to_char (rownum) || 'nd row'
            WHEN substr (to_char (rownum), length (to_char (rownum)), 1) = '3'
            THEN to_char (rownum) || 'rd row'
            ELSE to_char (rownum) || 'th row'
       END "DESC",
       to_number (substr (to_char (rownum), length (to_char (rownum)), 1)) as GROUP_VAL
from   dual
connect by level <= 1000 ;

