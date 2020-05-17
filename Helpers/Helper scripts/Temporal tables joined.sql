-- Solution 1.
with
src1 as ( -- Payment method source
    select 1 as id, '1' as pmeth, to_date ('01/01/2015', 'DD/MM/YYYY') as from_date, to_date ('31/03/2016', 'DD/MM/YYYY') as to_date from dual
    union all -- Gap here!
    select 1 as id, '2' as pmeth, to_date ('01/08/2016', 'DD/MM/YYYY') as from_date, to_date ('31/10/2016', 'DD/MM/YYYY') as to_date from dual
    union all
    select 1 as id, '3' as pmeth, to_date ('01/11/2016', 'DD/MM/YYYY') as from_date, null as to_date from dual
),
src2 as ( -- Sector source
    select 1 as id, '1' as sector, to_date ('01/01/2016', 'DD/MM/YYYY') as from_date, to_date ('31/01/2016', 'DD/MM/YYYY') as to_date from dual
    union all
    select 1 as id, '2' as sector, to_date ('01/02/2016', 'DD/MM/YYYY') as from_date, to_date ('31/07/2016', 'DD/MM/YYYY') as to_date from dual
    union all
    select 1 as id, '3' as sector, to_date ('01/08/2016', 'DD/MM/YYYY') as from_date, to_date ('01/08/2016', 'DD/MM/YYYY') as to_date from dual
    union all
    select 1 as id, '4' as sector, to_date ('02/08/2016', 'DD/MM/YYYY') as from_date, null as to_date from dual
),
src3 as ( -- Developer flag source
    select 1 as id, 'N' as developer, to_date ('01/01/2014', 'DD/MM/YYYY') as from_date, to_date ('30/09/2016', 'DD/MM/YYYY') as to_date from dual
    union all
    select 1 as id, 'Y' as developer, to_date ('01/10/2016', 'DD/MM/YYYY') as from_date, to_date ('30/11/2016', 'DD/MM/YYYY') as to_date from dual
    union all
    select 1 as id, 'Y' as developer, to_date ('01/12/2016', 'DD/MM/YYYY') as from_date, null as to_date from dual
),
distinct_times as ( -- Get all from-to dates. To dates become from dates. These will mark all from-to date intervals across all source tables
    select from_date
    from   (select src1.from_date from src1 
            union
            select src2.from_date from src2
            union
            select src3.from_date from src3) -- All from dates
    union -- Eliminate rows where from date = to date (hence the +1 on to dates in the previous section)
    select nvl (to_date, to_date ('31/12/9999', 'DD/MM/YYYY')) as from_date
    from   (select src1.to_date + 1 as to_date from src1 -- Next section eliminates those to dates that are the same as a from date (hence the +1)
            union
            select src2.to_date + 1 as to_date from src2
            union
            select src3.to_date + 1 as to_date from src3) -- All to dates
),
from_to_dates as ( -- Generates a list of all from-to dates across all source tables involved
    select from_date, nvl (lead (from_date) over (order by from_date) -1, to_date ('31/12/9999', 'DD/MM/YYYY')) as to_date -- To date is next from date - 1
    from   distinct_times
    where  from_date <> to_date ('31/12/9999', 'DD/MM/YYYY') -- Get rid of the high date to date
)
select coalesce (s1.id, s2.id, s3.id) as id,
       nvl (s1.pmeth, '-') as pmeth, -- No from-to date available, so set as unknown
       nvl (s2.sector, '-') as sector, 
       nvl (s3.developer, '-') as developer,
       ftd.from_date, 
       ftd.to_date
/*       case when s1.id is null then null else s1.from_date end as pmeth_fd,
       case when s1.id is null then null else nvl (s1.to_date, to_date ('31/12/9999', 'DD/MM/YYYY')) end as pmeth_td,
       case when s2.id is null then null else s2.from_date end as sector_fd,
       case when s2.id is null then null else nvl (s2.to_date, to_date ('31/12/9999', 'DD/MM/YYYY')) end as sector_td,
       case when s3.id is null then null else s3.from_date end as developer_fd,
       case when s3.id is null then null else nvl (s3.to_date, to_date ('31/12/9999', 'DD/MM/YYYY')) end as developer_td */
from   from_to_dates ftd, -- Driving table holds all possible from-to dates. Now we just need to know what was tempoarally valid in each source table
       src1           s1,
       src2           s2,
       src3           s3
where  ftd.from_date between s1.from_date (+) and nvl (s1.to_date (+), to_date ('31/12/9999', 'DD/MM/YYYY'))
  and  ftd.from_date between s2.from_date (+) and nvl (s2.to_date (+), to_date ('31/12/9999', 'DD/MM/YYYY'))
  and  ftd.from_date between s3.from_date (+) and nvl (s3.to_date (+), to_date ('31/12/9999', 'DD/MM/YYYY'))
order by ftd.from_date
;
-- Handles gaps in from-to dates but the attribute value will be unknown ('-')

-- Solution 2.
with
src1 as ( -- Payment method source
    select 1 as id, '1' as pmeth, to_date ('01/01/2015', 'DD/MM/YYYY') as from_date, to_date ('31/03/2016', 'DD/MM/YYYY') as to_date from dual
    union all -- Gap here!
    select 1 as id, '2' as pmeth, to_date ('01/08/2016', 'DD/MM/YYYY') as from_date, to_date ('31/10/2016', 'DD/MM/YYYY') as to_date from dual
    union all
    select 1 as id, '3' as pmeth, to_date ('01/11/2016', 'DD/MM/YYYY') as from_date, null as to_date from dual
),
src2 as ( -- Sector source
    select 1 as id, '1' as sector, to_date ('01/01/2016', 'DD/MM/YYYY') as from_date, to_date ('31/01/2016', 'DD/MM/YYYY') as to_date from dual
    union all
    select 1 as id, '2' as sector, to_date ('01/02/2016', 'DD/MM/YYYY') as from_date, to_date ('31/07/2016', 'DD/MM/YYYY') as to_date from dual
    union all
    select 1 as id, '3' as sector, to_date ('01/08/2016', 'DD/MM/YYYY') as from_date, to_date ('01/08/2016', 'DD/MM/YYYY') as to_date from dual
    union all
    select 1 as id, '4' as sector, to_date ('02/08/2016', 'DD/MM/YYYY') as from_date, null as to_date from dual
),
src3 as ( -- Developer flag source
    select 1 as id, 'N' as developer, to_date ('01/01/2014', 'DD/MM/YYYY') as from_date, to_date ('30/09/2016', 'DD/MM/YYYY') as to_date from dual
    union all
    select 1 as id, 'Y' as developer, to_date ('01/10/2016', 'DD/MM/YYYY') as from_date, to_date ('30/11/2016', 'DD/MM/YYYY') as to_date from dual
    union all
    select 1 as id, 'Y' as developer, to_date ('01/12/2016', 'DD/MM/YYYY') as from_date, null as to_date from dual
),
union_them as (
    select id, from_date, pmeth, null as sector, null as developer from src1 -- Same from date can occur many times as this is not a DISTINCT from date list!
    union all
    select id, from_date, null as pmeth, sector, null as developer from src2
    union all
    select id, from_date, null as pmeth, null as sector, developer from src3
),
leads as (
    select id, from_date,
           nvl (lead (from_date) over (partition by id order by from_date) -1, to_date ('31/12/9999', 'DD/MM/YYYY')) to_date,
           nvl (last_value (pmeth) ignore nulls over (partition by id order by from_date), '-') as pmeth,
           nvl (last_value (sector) ignore nulls over (partition by id order by from_date), '-') as sector,
           nvl (last_value (developer) ignore nulls over (partition by id order by from_date), '-') as developer
    from   union_them
)
select id, pmeth, sector, developer, from_date, to_date
from   leads
order by from_date
;
-- Limitations:
-- 1. The attributes pmeth. sector and developer can not be null otherwise the IGNORE NULLS clause will not work
-- 2. The last from-to date will start at from_date and run to infinity (31/12/9999). This is not valid if all 3 attributes (or the id column) are end dated

-- Results slightly different to that of solution 1 in that solution 2 derives to date from from date (from date - 1) wheras solution 1 makes to dates as from dates first
-- then derives to date from from date the same way solution 2 does
-- Does not handle correctly the cases when two or more attributes start on the same from date
-- Efficient, because the source tables are only visited once.

-- Solution 3. Combines 1 and 2
with
src1 as ( -- Payment method source
    select 1 as id, '1' as pmeth, to_date ('01/01/2015', 'DD/MM/YYYY') as from_date, to_date ('31/03/2016', 'DD/MM/YYYY') as to_date from dual
    union all -- Gap here!
    select 1 as id, '2' as pmeth, to_date ('01/08/2016', 'DD/MM/YYYY') as from_date, to_date ('31/10/2016', 'DD/MM/YYYY') as to_date from dual
    union all
    select 1 as id, '3' as pmeth, to_date ('01/11/2016', 'DD/MM/YYYY') as from_date, null as to_date from dual
),
src2 as ( -- Sector source
    select 1 as id, '1' as sector, to_date ('01/01/2016', 'DD/MM/YYYY') as from_date, to_date ('31/01/2016', 'DD/MM/YYYY') as to_date from dual
    union all
    select 1 as id, '2' as sector, to_date ('01/02/2016', 'DD/MM/YYYY') as from_date, to_date ('31/07/2016', 'DD/MM/YYYY') as to_date from dual
    union all
    select 1 as id, '3' as sector, to_date ('01/08/2016', 'DD/MM/YYYY') as from_date, to_date ('01/08/2016', 'DD/MM/YYYY') as to_date from dual
    union all
    select 1 as id, '4' as sector, to_date ('02/08/2016', 'DD/MM/YYYY') as from_date, null as to_date from dual
),
src3 as ( -- Developer flag source
    select 1 as id, 'N' as developer, to_date ('01/01/2014', 'DD/MM/YYYY') as from_date, to_date ('01/08/2016', 'DD/MM/YYYY') as to_date from dual
    union all
    select 1 as id, 'X' as developer, to_date ('02/08/2016', 'DD/MM/YYYY') as from_date, to_date ('02/08/2016', 'DD/MM/YYYY') as to_date from dual
    union all
    select 1 as id, 'Y' as developer, to_date ('03/08/2016', 'DD/MM/YYYY') as from_date, to_date ('30/11/2016', 'DD/MM/YYYY') as to_date from dual
    union all
    select 1 as id, 'Y' as developer, to_date ('01/12/2016', 'DD/MM/YYYY') as from_date, null as to_date from dual
),
distinct_times as ( -- Get all from-to dates. To dates become from dates. These will mark all from-to date intervals across all source tables
    select from_date
    from   (select src1.from_date from src1 
            union
            select src2.from_date from src2
            union
            select src3.from_date from src3) -- All from dates
    union -- Eliminate rows where from date = to date (hence the +1 on to dates in the previous section)
    select nvl (to_date, to_date ('31/12/9999', 'DD/MM/YYYY')) as from_date
    from   (select src1.to_date + 1 as to_date from src1 -- Next section eliminates those to dates that are the same as a from date (hence the +1)
            union
            select src2.to_date + 1 as to_date from src2
            union
            select src3.to_date + 1 as to_date from src3) -- All to dates
),
from_to_dates as ( -- Generates a list of all from-to dates across all source tables involved
    select from_date, nvl (lead (from_date) over (order by from_date) -1, to_date ('31/12/9999', 'DD/MM/YYYY')) as to_date -- To date is derived from from date as next from date - 1
    from   distinct_times
    where  from_date <> to_date ('31/12/9999', 'DD/MM/YYYY') -- Get rid of the high date to date
)
select coalesce (s1.id, s2.id, s3.id) as id,
       nvl (nvl (s1.pmeth, last_value (s1.pmeth)         ignore nulls over (partition by coalesce (s1.id, s2.id, s3.id) order by ftd.from_date)), '-') as pmeth,
       nvl (nvl (s2.sector, last_value (s2.sector)       ignore nulls over (partition by coalesce (s1.id, s2.id, s3.id) order by ftd.from_date)), '-') as sector, 
       nvl (nvl (s3.developer, last_value (s3.developer) ignore nulls over (partition by coalesce (s1.id, s2.id, s3.id) order by ftd.from_date)), '-') as developer,
       ftd.from_date, 
       ftd.to_date
/*       case when s1.id is null then null else s1.from_date end as pmeth_fd,
       case when s1.id is null then null else nvl (s1.to_date, to_date ('31/12/9999', 'DD/MM/YYYY')) end as pmeth_td,
       case when s2.id is null then null else s2.from_date end as sector_fd,
       case when s2.id is null then null else nvl (s2.to_date, to_date ('31/12/9999', 'DD/MM/YYYY')) end as sector_td,
       case when s3.id is null then null else s3.from_date end as developer_fd,
       case when s3.id is null then null else nvl (s3.to_date, to_date ('31/12/9999', 'DD/MM/YYYY')) end as developer_td */
from   from_to_dates ftd, -- Driving table holds all possible from-to dates. Now we just need to know what was tempoarally valid in each source table
       src1           s1,
       src2           s2,
       src3           s3
where  ftd.from_date between s1.from_date (+) and nvl (s1.to_date (+), to_date ('31/12/9999', 'DD/MM/YYYY'))
  and  ftd.from_date between s2.from_date (+) and nvl (s2.to_date (+), to_date ('31/12/9999', 'DD/MM/YYYY'))
  and  ftd.from_date between s3.from_date (+) and nvl (s3.to_date (+), to_date ('31/12/9999', 'DD/MM/YYYY'))
order by ftd.from_date
;

-- No limitation. LAST_VALUE grabs the last not null (IGNORE NULLS) value of a given attribute in an ordered list of rows (order by from date)
-- Fills the gaps in from-to dates. Question is whether the gap is filled in using the next value or extrapolating the previous one
-- Less efficient as the query must visit the source tables twice. First for the from-to dates then for the attributes we are after

-- Solution 3 with health check
with
src1 as ( -- Payment method source
    select 1 as id, '1' as pmeth, to_date ('01/01/2015', 'DD/MM/YYYY') as from_date, to_date ('31/03/2016', 'DD/MM/YYYY') as to_date from dual
    union all -- Gap here!
    select 1 as id, '2' as pmeth, to_date ('01/08/2016', 'DD/MM/YYYY') as from_date, to_date ('31/10/2016', 'DD/MM/YYYY') as to_date from dual
    union all
    select 1 as id, '3' as pmeth, to_date ('01/11/2016', 'DD/MM/YYYY') as from_date, null as to_date from dual
),
src2 as ( -- Sector source
    select 1 as id, '1' as sector, to_date ('01/01/2016', 'DD/MM/YYYY') as from_date, to_date ('31/01/2016', 'DD/MM/YYYY') as to_date from dual
    union all
    select 1 as id, '2' as sector, to_date ('01/02/2016', 'DD/MM/YYYY') as from_date, to_date ('31/07/2016', 'DD/MM/YYYY') as to_date from dual
    union all
    select 1 as id, '3' as sector, to_date ('01/08/2016', 'DD/MM/YYYY') as from_date, to_date ('01/08/2016', 'DD/MM/YYYY') as to_date from dual
    union all
    select 1 as id, '4' as sector, to_date ('02/08/2016', 'DD/MM/YYYY') as from_date, null as to_date from dual
),
src3 as ( -- Developer flag source
    select 1 as id, 'N' as developer, to_date ('01/01/2014', 'DD/MM/YYYY') as from_date, to_date ('01/08/2016', 'DD/MM/YYYY') as to_date from dual
    union all
    select 1 as id, 'X' as developer, to_date ('02/08/2016', 'DD/MM/YYYY') as from_date, to_date ('02/08/2016', 'DD/MM/YYYY') as to_date from dual
    union all
    select 1 as id, 'Y' as developer, to_date ('03/08/2016', 'DD/MM/YYYY') as from_date, to_date ('30/11/2016', 'DD/MM/YYYY') as to_date from dual
    union all
    select 1 as id, 'Y' as developer, to_date ('01/12/2016', 'DD/MM/YYYY') as from_date, null as to_date from dual
),
distinct_times as ( -- Get all from-to dates. To dates become from dates. These will mark all from-to date intervals across all source tables
    select from_date
    from   (select src1.from_date from src1 
            union
            select src2.from_date from src2
            union
            select src3.from_date from src3) -- All from dates
    union -- Eliminate rows where from date = to date (hence the +1 on to dates in the previous section)
    select nvl (to_date, to_date ('31/12/9999', 'DD/MM/YYYY')) as from_date
    from   (select src1.to_date + 1 as to_date from src1 -- Next section eliminates those to dates that are the same as a from date (hence the +1)
            union
            select src2.to_date + 1 as to_date from src2
            union
            select src3.to_date + 1 as to_date from src3) -- All to dates
),
from_to_dates as ( -- Generates a list of all from-to dates across all source tables involved
    select from_date, nvl (lead (from_date) over (order by from_date) -1, to_date ('31/12/9999', 'DD/MM/YYYY')) as to_date -- To date is derived from from date as next from date - 1
    from   distinct_times
    where  from_date <> to_date ('31/12/9999', 'DD/MM/YYYY') -- Get rid of the high date to date
),
finally as (
    select coalesce (s1.id, s2.id, s3.id) as id,
           nvl (nvl (s1.pmeth, last_value (s1.pmeth)         ignore nulls over (partition by coalesce (s1.id, s2.id, s3.id) order by ftd.from_date)), '-') as pmeth,
           nvl (nvl (s2.sector, last_value (s2.sector)       ignore nulls over (partition by coalesce (s1.id, s2.id, s3.id) order by ftd.from_date)), '-') as sector, 
           nvl (nvl (s3.developer, last_value (s3.developer) ignore nulls over (partition by coalesce (s1.id, s2.id, s3.id) order by ftd.from_date)), '-') as developer,
           ftd.from_date, 
           ftd.to_date
    /*       case when s1.id is null then null else s1.from_date end as pmeth_fd,
           case when s1.id is null then null else nvl (s1.to_date, to_date ('31/12/9999', 'DD/MM/YYYY')) end as pmeth_td,
           case when s2.id is null then null else s2.from_date end as sector_fd,
           case when s2.id is null then null else nvl (s2.to_date, to_date ('31/12/9999', 'DD/MM/YYYY')) end as sector_td,
           case when s3.id is null then null else s3.from_date end as developer_fd,
           case when s3.id is null then null else nvl (s3.to_date, to_date ('31/12/9999', 'DD/MM/YYYY')) end as developer_td */
    from   from_to_dates ftd, -- Driving table holds all possible from-to dates. Now we just need to know what was tempoarally valid in each source table
           src1           s1,
           src2           s2,
           src3           s3
    where  ftd.from_date between s1.from_date (+) and nvl (s1.to_date (+), to_date ('31/12/9999', 'DD/MM/YYYY'))
      and  ftd.from_date between s2.from_date (+) and nvl (s2.to_date (+), to_date ('31/12/9999', 'DD/MM/YYYY'))
      and  ftd.from_date between s3.from_date (+) and nvl (s3.to_date (+), to_date ('31/12/9999', 'DD/MM/YYYY'))
),
lag_lead as ( 
    select id, pmeth, sector, developer, from_date, to_date,
           lead (from_date) over (partition by id order by from_date) as lead_from_date,
           lead (to_date) over (partition by id order by to_date) as lead_to_date,
           lag (from_date) over (partition by id order by from_date) as lag_from_date,
           lag (to_date) over (partition by id order by to_date) as lag_to_date
    from   finally
)
select id, pmeth, sector, developer, from_date, to_date,
       case when from_date < lead_from_date or lead_from_date is null then 'OK' else 'FAIL' end as from_date_ok,
       case when to_date < lead_to_date or lead_to_date is null then 'OK' else 'FAIL' end as to_date_ok,
       case when to_date >= from_date then 'OK' else 'FAIL' end as from_to_date_ok
from   lag_lead
order by from_date
;

-- Richard's code
WITH combined 
AS
(
-- combine both table datasets so that we capture all change (from_date) dates. Any nulls are found in the other table… eg date_of_birth is in table 2, ice)customer_id is in table 1.
  SELECT   from_date
  ,        entity_id
  ,        ice_customer_id
  ,        account_reference financial_account_reference
  ,        CAST(NULL AS DATE) date_of_birth
  ,        CAST(NULL AS VARCHAR2(30)) last_updated_by  
  FROM     ae_hds.hds_t_ice1_entity_relationship --first table
  WHERE    entity_role_id = 1
  AND      (from_date BETWEEN ADD_MONTHS((SELECT ref_k_job.get_batch_date () FROM dual), -36)
                          AND (SELECT ref_k_job.get_batch_date () FROM dual)
           OR NVL(to_date, TO_DATE('9999-12-31', 'YYYY-MM-DD')) >= ADD_MONTHS((SELECT ref_k_job.get_batch_date() FROM dual), -36))
  UNION ALL
  SELECT   from_date
  ,        entity_id
  ,        NULL
  ,        NULL
  ,        date_of_birth
  ,        last_updated_by
  FROM     ae_hds.hds_t_ice1_individual --second table
  WHERE    (from_date BETWEEN ADD_MONTHS((SELECT ref_k_job.get_batch_date () FROM dual), -36)
                            AND (SELECT ref_k_job.get_batch_date () FROM dual)
           OR NVL(to_date, TO_DATE('9999-12-31', 'YYYY-MM-DD')) >= ADD_MONTHS((SELECT ref_k_job.get_batch_date() FROM dual), -36))
)
, windowed
AS
(
-- Overlay all data to get the correct attributes for each change date – this is the clever bit. The partition is the key of the output
  SELECT   from_date dw_from_date
  ,        LEAD(from_date - 1, 1, TO_DATE('9999-12-31', 'YYYY-MM-DD')) OVER(PARTITION BY entity_id, ice_customer_id, financial_account_reference ORDER BY from_date ASC) dw_to_date
  ,        entity_id 
  ,        LAST_VALUE(ice_customer_id IGNORE NULLS) OVER(PARTITION BY entity_id, ice_customer_id, financial_account_reference ORDER BY from_date ASC) ice_customer_id
  ,        LAST_VALUE(financial_account_reference IGNORE NULLS) OVER(PARTITION BY entity_id, ice_customer_id, financial_account_reference ORDER BY from_date ASC) financial_account_reference
  ,        LAST_VALUE(date_of_birth IGNORE NULLS) OVER(PARTITION BY entity_id, ice_customer_id, financial_account_reference ORDER BY from_date ASC) date_of_birth
  ,        LAST_VALUE(last_updated_by IGNORE NULLS) OVER(PARTITION BY entity_id, ice_customer_id, financial_account_reference ORDER BY from_date ASC) last_updated_by
  FROM     combined
)
SELECT   (SELECT ref_k_job.get_batch_date() FROM dual) analysis_date
,        dw_from_date
,        dw_to_date
,        entity_id
,        ice_customer_id
,        financial_account_reference
,        date_of_birth
,        NVL(last_updated_by, '-') last_updated_by
,        CASE WHEN date_of_birth IS NULL THEN 'N' -- NULL DOB is invalid
              WHEN date_of_birth >= (SELECT ADD_MONTHS(ref_k_job.get_batch_date(), -(16 * 12)) FROM dual) THEN 'N' --DOB less than 16 years ago is invalid
              WHEN date_of_birth < (SELECT ADD_MONTHS(ref_k_job.get_batch_date(), -(120 * 12)) FROM dual) THEN 'N' --DOB older than 120 years ago is invalid
              ELSE 'Y'
         END valid_flag
FROM     windowed
WHERE    1 = 1
AND      dw_from_date <= dw_to_date -- get rid of open and close on same day
-- some changes will be tracked before batch 36 months due to the open record from each source table starting at different times. This removes changes not needed.
AND      dw_to_date >= ADD_MONTHS((SELECT ref_k_job.get_batch_date() FROM dual), -36) 
/

-- Another example

drop table account_status ;
drop table account_type ;
drop table funding_currency ;

create table account_status (
  account_id number,
  status_id varchar2 (1),
  start_date date,
  end_date date)
;

create table account_type (
  account_id number,
  account_type varchar2 (10),
  start_date date,
  end_date date)
;

create table funding_currency (
  account_id number,
  currency_id varchar2 (3),
  start_date date,
  end_date date)
;

insert into account_status (account_id, status_id, start_date, end_date)
values (1, 'L', to_date ('01/01/2019', 'DD/MM/YYYY'), to_date ('14/03/2019', 'DD/MM/YYYY')) ;
insert into account_status (account_id, status_id, start_date, end_date)
values (1, 'S', to_date ('15/03/2019', 'DD/MM/YYYY'), to_date ('31/05/2019', 'DD/MM/YYYY')) ;
insert into account_status (account_id, status_id, start_date, end_date)
values (1, 'C', to_date ('01/06/2019', 'DD/MM/YYYY'), NULL) ;

insert into account_type (account_id, account_type, start_date, end_date)
values (1, 'Client', to_date ('01/01/2019', 'DD/MM/YYYY'), to_date ('31/01/2019', 'DD/MM/YYYY')) ;
insert into account_type (account_id, account_type, start_date, end_date)
values (1, 'Customer', to_date ('01/02/2019', 'DD/MM/YYYY'), NULL) ;

insert into funding_currency (account_id, currency_id, start_date, end_date)
values (1, 'PLN', to_date ('01/01/2019', 'DD/MM/YYYY'), to_date ('01/03/2019', 'DD/MM/YYYY')) ;
insert into funding_currency (account_id, currency_id, start_date, end_date)
values (1, 'GBP', to_date ('02/03/2019', 'DD/MM/YYYY'), to_date ('31/03/2019', 'DD/MM/YYYY')) ;
insert into funding_currency (account_id, currency_id, start_date, end_date)
values (1, 'EUR', to_date ('01/04/2019', 'DD/MM/YYYY'), NULL) ;

WITH distinct_times AS (
    SELECT start_date
    FROM   (SELECT start_date
            FROM   account_status
            UNION
            SELECT start_date
            FROM   account_type
            UNION
            SELECT start_date
            FROM   funding_currency)
    UNION -- Eliminates rows where start_date = end_date
    SELECT NVL (end_date, to_date ('31/12/2999', 'DD/MM/YYYY')) as start_date
    FROM   (SELECT end_date + 1 as end_date
            FROM   account_status
            UNION
            SELECT end_date + 1 as end_date
            FROM   account_type
            UNION
            SELECT end_date + 1 as end_date
            FROM   funding_currency)
),
start_end_dates AS (
    SELECT start_date,
           NVL (LEAD (start_date) OVER (ORDER BY start_date) - 1, to_date ('31/12/2999', 'DD/MM/YYYY')) AS end_date -- Derived as next start_date - 1
    FROM   distinct_times
    WHERE  start_date <> to_date ('31/12/2999', 'DD/MM/YYYY') -- Get rid of high date
),
finally AS (
    SELECT COALESCE (s.account_id, t.account_id, f.account_id) as account_id,
           NVL (NVL (s.status_id, LAST_VALUE (s.status_id) IGNORE NULLS OVER (PARTITION BY COALESCE (s.account_id, t.account_id, f.account_id) ORDER BY sed.start_date)), '-') as status_id,
           NVL (NVL (t.account_type, LAST_VALUE (t.account_type) IGNORE NULLS OVER (PARTITION BY COALESCE (s.account_id, t.account_id, f.account_id) ORDER BY sed.start_date)), '-') as account_type,
           NVL (NVL (f.currency_id, LAST_VALUE (f.currency_id) IGNORE NULLS OVER (PARTITION BY COALESCE (s.account_id, t.account_id, f.account_id) ORDER BY sed.start_date)), '-') as currency_id,
           sed.start_date,
           sed.end_date
    FROM   start_end_dates sed -- Driving table that holds all possible start-end-dates
    LEFT OUTER JOIN account_status s
    ON     sed.start_date between s.start_date and NVL (s.end_date, to_date ('31/12/2999', 'DD/MM/YYYY'))
    LEFT OUTER JOIN account_type t
    ON     sed.start_date between t.start_date and NVL (t.end_date, to_date ('31/12/2999', 'DD/MM/YYYY'))
    LEFT OUTER JOIN funding_currency f
    ON     sed.start_date between f.start_date and NVL (f.end_date, to_date ('31/12/2999', 'DD/MM/YYYY'))
)
),
lag_lead as ( 
    select account_id, status_id, account_type, currency_id, start_date, end_date,
           lead (start_date) over (partition by account_id order by start_date) as lead_start_date,
           lead (end_date) over (partition by account_id order by end_date) as lead_end_date,
           lag (start_date) over (partition by account_id order by start_date) as lag_start_date,
           lag (end_date) over (partition by account_id order by end_date) as lag_end_date
    from   finally
)
select account_id, status_id, account_type, currency_id, start_date, end_date,
       case when start_date < lead_start_date or lead_start_date is null then 'OK' else 'FAIL' end as start_date_ok,
       case when end_date < lead_end_date or lead_end_date is null then 'OK' else 'FAIL' end as end_date_ok,
       case when end_date >= start_date then 'OK' else 'FAIL' end as start_end_date_ok
from   lag_lead
order by start_date
