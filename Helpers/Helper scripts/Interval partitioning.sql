-- Oracle creates new partitions automatically having checked the highest partition value, it creates them above that line
-- No need to add the AML to the DBA partitioning routine
-- Caveats:
-- Cannot be used for index organized tables
-- Must use only one partitioning key column and it must be a DATE or NUMBER
-- Are not supported at the sub-partition level

create table try (
   try_id     number not null,
   try_date   date,
   try_grade  number(3)
)
partition by range (try_date)
interval (numtoyminterval(1,'MONTH')) -- Can be 3 monthly: (3, 'MONTH'). Converts INTERVAL YEAR TO MONTH literal. Second parameter can only be either 'MONTH' or 'YEAR'
subpartition by range (try_grade)
subpartition template
(
  subpartition s1 values less than (101),
  subpartition s2 values less than (201),
  subpartition s3 values less than (301),
  subpartition s4 values less than (401),
  subpartition sm values less than (maxvalue)
)
(
   partition p1 values less than (to_date('01-FEB-2016','DD-MON-YYYY'))
);
-- SYSDATE = 08/02/2016 (ran on that day)
insert into try values(1,sysdate-365,305);  -- Does not create new partition because less than 01/02/2016
insert into try values(1,sysdate-30,505);   -- Does not create new partition
insert into try values(1,sysdate,99);       -- Creates a new partition
insert into try values(1,sysdate+1,105);    -- Creates a new partition
insert into try values(1,sysdate+30,205);   -- Creates a new partition

commit;

select * from try partition(p1);
--305, 505
select * from try partition(SYS_P31747493); -- The generated system partition name may vary on different databases
--99, 105
select * from try partition(SYS_P31747499);
--205

-- Day intervals
)
partition by range (analysis_date)
interval (numtodsinterval (1, 'DAY'))
          (partition P0 values less than (to_date ('01/04/2017', 'DD/MM/YYYY')))
;