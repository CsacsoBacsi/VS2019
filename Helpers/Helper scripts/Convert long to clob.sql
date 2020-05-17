-- Convert LONG to CLOB to enable string search
create table t2 (view_name varchar2(30), text clob);

-- Views
declare
begin
execute immediate 'insert into t2 select view_name, to_lob (text) from (SELECT view_name, text FROM  all_views v WHERE owner in (''AE_STG_AML''))' ;
commit ;
end ;

select * from t2
where upper (text) like '%AML_T_SMART_TECHNICIAN_EVENT%'
;

aml_t_smart_technician_event

ae_stg_aml.STG_AML_V_SMART_TECHNCN_EVENT 

SELECT view_name, text FROM  dba_views v WHERE owner in ('AE_STG_MEASURES') ;

-- Packages
select owner, name, type, text from all_source 
where owner in ('AE_STG_AML', 'AE_STG_MEASURES', 'AE_AML', 'AE_MEASURES')
and upper (text) like '%AML_T_SMART_TECHNICIAN_EVENT%'
;
