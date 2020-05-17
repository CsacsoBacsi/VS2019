with src as (
   select  from_date, to_date, customer_media_id, ice_customer_id, phone_code,
           dirty_phone_code, phone_number, user_id, date_when_accurate, date_changed,
           rowid as rid -- Get row id to support the last outer join
    from   ae_hds.hds_t_ice1_customer_media
    where  media_type in (1,2,3,12)
      and  (from_date between add_months ((select ref_k_job.get_batch_date () from dual), -1) and (select ref_k_job.get_batch_date () from dual)
            or nvl (to_date, to_date ('31/12/9999', 'DD/MM/YYYY')) >= add_months ((select ref_k_job.get_batch_date() from dual), -1))
),
collapse as (
    select min (from_date) as from_date, max (nvl (to_date, to_date ('31/12/9999', 'DD/MM/YYYY'))) as to_date,
           ice_customer_id, phone_code, dirty_phone_code, 
           phone_number, user_id, date_when_accurate, date_changed
    from src
    group by ice_customer_id, phone_code, dirty_phone_code, 
             phone_number, user_id, date_when_accurate, date_changed
)
select count (*) from collapse -- 26,669,618
; -- 28,224,222

order by ice_customer_id, 
;

with src as (
    select to_date ('01/01/2015', 'DD/MM/YYYY') as from_date,
           to_date ('31/05/2015', 'DD/MM/YYYY') as to_date, 
           1 as customer_media_id, 1 as ice_customer_id, '1623' as phone_code,
           null as dirty_phone_code, '123456' as phone_number, 'C23833' as user_id,
           to_date ('30/05/2015', 'DD/MM/YYYY') as date_when_accurate,
           to_date ('30/05/2015', 'DD/MM/YYYY') as date_changed
    from   dual
    union all
    select to_date ('01/06/2015', 'DD/MM/YYYY') as from_date,
           to_date ('31/07/2015', 'DD/MM/YYYY') as to_date, 
           1 as customer_media_id, 1 as ice_customer_id, '1623' as phone_code,
           null as dirty_phone_code, '123456' as phone_number, 'C23833' as user_id,
           to_date ('30/05/2015', 'DD/MM/YYYY') as date_when_accurate,
           to_date ('30/05/2015', 'DD/MM/YYYY') as date_changed
    from   dual
    union all
    select to_date ('01/08/2015', 'DD/MM/YYYY') as from_date,
           to_date ('31/12/2015', 'DD/MM/YYYY') as to_date, 
           1 as customer_media_id, 1 as ice_customer_id, '1623' as phone_code,
           null as dirty_phone_code, '123457' as phone_number, 'C23833' as user_id,
           to_date ('30/12/2015', 'DD/MM/YYYY') as date_when_accurate,
           to_date ('30/12/2015', 'DD/MM/YYYY') as date_changed
    from   dual
    union all
    select to_date ('01/01/2016', 'DD/MM/YYYY') as from_date,
           to_date ('31/12/9999', 'DD/MM/YYYY') as to_date,
           1 as customer_media_id, 1 as ice_customer_id, '1623' as phone_code,
           null as dirty_phone_code, '123457' as phone_number, 'C23833' as user_id,
           to_date ('30/12/2015', 'DD/MM/YYYY') as date_when_accurate,
           to_date ('30/12/2015', 'DD/MM/YYYY') as date_changed
    from   dual
)
select min (from_date) over (partition by customer_media_id, ice_customer_id, phone_code, dirty_phone_code, 
                                          phone_number, user_id, date_when_accurate, date_changed) as min_from_date,
       max (to_date) over (partition by customer_media_id, ice_customer_id, phone_code, dirty_phone_code, 
                                          phone_number, user_id, date_when_accurate, date_changed) as max_to_date,
       customer_media_id, ice_customer_id, phone_code, dirty_phone_code, 
       phone_number, user_id, date_when_accurate, date_changed
from   src
;
