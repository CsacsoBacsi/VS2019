select
   owner,
   type,
   name,
   referenced_owner,
   referenced_type,
   referenced_name
from
   dba_dependencies
where
   ((owner like upper ('AE_AML') and name like upper ('AML_T_B2B_OR_REPORT'))
   or
   (referenced_owner like upper ('AE_AML') and referenced_name like upper ('AML_T_B2B_OR_REPORT')))
   and referenced_owner != 'SYS'
    and referenced_type != 'NON-EXISTENT'
order by
   owner, type, name; 
   
create or replace force view v_csaba_src as select * from csaba_src ;
create or replace force view v_csaba_src2 as select * from v_csaba_src ;
create or replace force view v_csaba_src3 as select * from v_csaba_src2 ;
create or replace force view v_csaba_src4 as select * from v_csaba_src3 ;
create or replace force view v_csaba_src6 as select * from csaba_src ;
create or replace force view v_csaba_src7 as select * from v_csaba_src6 ;

select * from all_dependencies where referenced_name = 'AML_T_B2B_OR_REPORT' ;  STG_AML_V_B2B_OR_REPORT_FINAL AML_V_B2B_OR_REPORT_FINAL
;

with tables as (
    select 'C23833' as schema, 'V_CSABA_SRC2' as table_name from dual
    union all
    select 'AE_AML' as schema, 'POCSOM_XXX_YYY' as table_name from dual
--with tables as (
--    select 'C23833' as schema, 'V_CSABA_SRC3' as table_name from dual
),
dependencies as (
    select t.owner, t.name, t.type, t.referenced_owner, referenced_name, referenced_type
    from   dba_dependencies t
    where  t.referenced_type != 'NON-EXISTENT'
--      and  (t.owner like 'AE_%' or t.owner = 'C23833')
--      and  (t.referenced_owner like 'AE_%' or t.referenced_owner = 'C23833')
),
with_objects as (
    -- Top down through the hierarchy. Get the children
   select /*+ no_merge */
           connect_by_root dd.referenced_owner || '.' || connect_by_root dd.referenced_name as root_object,
           NULL as parent,
           dd.owner || '.' || dd.name as child,
           dd.type as object_type,
           dd.referenced_owner, dd.referenced_name, referenced_type,
           'TD' as dependency_type,
           level hlevel, 
           regexp_replace (sys_connect_by_path (name || ' (' || lower (dd.type) || ')', ' -> '), '^ -> ', '')  as path
    from   dependencies dd
    start with
           (dd.referenced_owner, dd.referenced_name) in (select t.schema, t.table_name from tables t)
    connect by
           dd.referenced_owner    = prior dd.owner
           and dd.referenced_name = prior name
           and dd.referenced_type = prior type
    union
    -- Bottom up through the hierarchy. Get the parents 
    select /*+ no_merge */
           connect_by_root dd.referenced_owner || '.' || connect_by_root dd.referenced_name as root_object,
           dd.referenced_owner || '.' || dd.referenced_name as parent,
           NULL as child,
           dd.referenced_type as object_type,
           dd.referenced_owner, dd.referenced_name, dd.referenced_type,
           'BU' as dependency_type,
           level hlevel, 
           regexp_replace (sys_connect_by_path (name || ' (' || lower (dd.referenced_type) || ')', ' -> '), '^ -> ', '')  as path
    from   dependencies dd
    where  dd.referenced_type != 'NON-EXISTENT'
    start with
           (dd.owner, dd.name) in (select t.schema, t.table_name from tables t)
    connect by
           dd.owner    = prior dd.referenced_owner
           and dd.name = prior dd.referenced_name
           and dd.type = prior dd.referenced_type 
),
relatives as (
    select d.root_object,
           case when d.dependency_type = 'BU' 
                then d.parent
                when d.dependency_type = 'TD'
                then d.child
                else NULL
           end as family_member,
           d.object_type as member_type,
           case when d.dependency_type = 'BU'
                then 'Ancestor'
                when d.dependency_type = 'TD'
                then 'Descendant'
                else NULL
           end relationship,
           case when d.dependency_type = 'BU'
                then lpad (' ', 6 * (d.hlevel -1), decode (d.hlevel, 1, '', 'grand-')) || 'parent' 
                when d.dependency_type = 'TD'
                then lpad (' ', 6 * (d.hlevel -1), decode (d.hlevel, 1, '', 'grand-')) || 'child'
                else NULL  
           end as relationship_desc,
           hlevel,
           dependency_type,
           path as dependency_tree
    from   with_objects d
)
select root_object, 
       family_member,
       member_type,
       relationship,
       hlevel as distance,
       upper (substr (relationship_desc, 1, 1)) || substr (relationship_desc, 2) as relationship_desc,
       dependency_tree
from   relatives
order by root_object, dependency_type, hlevel
;
