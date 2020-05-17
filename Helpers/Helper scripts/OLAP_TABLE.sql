drop type t_nhh_e_fc_var_rev_tab ;

CREATE OR REPLACE
TYPE t_nhh_e_fc_var_rev_row AS OBJECT
                    (
                     time_id                   VARCHAR2(20)
					,time_level                VARCHAR2(20) 
                    ,tpr_id                    VARCHAR2(20)
                    ,tpr_level                 VARCHAR2(20)
                    ,elec_product_id           VARCHAR2(20)
                    ,elec_product_level        VARCHAR2(20)
                    ,elec_product_surr         VARCHAR2(50)
                    ,ssc_id                    VARCHAR2(20)
                    ,ssc_level                 VARCHAR2(20)
                    ,llf_id                    VARCHAR2(20)
                    ,llf_level                 VARCHAR2(20)
                    ,profile_class_id          VARCHAR2(20)
                    ,profile_class_level       VARCHAR2(20)
                    ,elec_licence_id           VARCHAR2(20)
                    ,elec_licence_level        VARCHAR2(20)
                    ,gsp_group_id              VARCHAR2(20)
                    ,gsp_group_id_level        VARCHAR2(20)
                    ,business_structure_id     VARCHAR2(20)
                    ,business_structure_level  VARCHAR2(20)
                    ,business_structure_surr   VARCHAR2(50)
                    ,payment_method_id         VARCHAR2(20)
                    ,payment_method_level      VARCHAR2(20)
                    ,payment_method_surr       VARCHAR2(50)
                    ,dual_fuel_flag_id         VARCHAR2(20)
                    ,dual_fuel_flag_level      VARCHAR2(20)
                    ,half_hour_id              VARCHAR2(20)
                    ,half_hour_level           VARCHAR2(20)
                    ,e_revenue_item_id         VARCHAR2(20)
                    ,e_revenue_item_level      VARCHAR2(20)
                    ,nhh_e_fc_var_rev_ver_id   VARCHAR2(20)
                    ,nhh_e_fc_var_rev_ver_level VARCHAR2(20)
                    ,rev_temp                  NUMBER
                     ) ;
/  

CREATE OR REPLACE
TYPE t_nhh_e_fc_var_rev_tab AS TABLE OF t_nhh_e_fc_var_rev_row ;
/
  
CREATE OR REPLACE VIEW VW_NHH_E_FC_VAR_REV_WB
(TIME_ID, TPR, ELEC_PRODUCT, SSC, LLFC, 
 PROFILE_CLASS, ELEC_LICENCE, GSP, BUSINESS_STRUCTURE, PAYMENT_METHOD, 
 DUAL_FUEL_FLAG, HALF_HOUR, E_REVENUE_ITEM, VERSION_ID, REV)
AS 
SELECT 
        time_id 
        ,tpr 
        ,elec_product 
        ,ssc 
        ,llfc 
        ,profile_class 
        ,elec_licence 
        ,gsp 
        ,business_structure 
        ,payment_method 
        ,dual_fuel_flag 
        ,half_hour 
        ,e_revenue_item 
        ,version_id 
        ,rev_temp as rev 
  FROM (SELECT 
               time_id 
              ,tpr_id                      AS tpr 
              ,elec_product_surr           AS elec_product 
              ,ssc_id                      AS ssc 
              ,llf_id                      AS llfc 
              ,profile_class_id            AS profile_class 
              ,elec_licence_id             AS elec_licence 
              ,gsp_group_id                AS gsp 
              ,business_structure_surr     AS business_structure 
              ,payment_method_surr         AS payment_method 
              ,dual_fuel_flag_id           AS dual_fuel_flag 
              ,half_hour_id                AS half_hour 
              ,e_revenue_item_id           AS e_revenue_item 
              ,nhh_e_fc_var_rev_ver_id     AS version_id 
              ,rev_temp 
        FROM TABLE (OLAP_TABLE('C10879.GBP DURATION SESSION' 
            ,'' 
            ,'call rewrite_olaptable(''NHH_E_FC_VAR_REV_COMPOSITE'')'
            ,'DIMENSION time_id as varchar2(20) FROM time ' || 
             ' WITH HIERARCHY time_parentrel ' ||
             ' (time_hierlist ''CAL_MONTH_YEAR'')' ||
             '  ATTRIBUTE time_level as varchar2(20) from time_levelrel ' ||
             'DIMENSION tpr_id as varchar2(20) FROM tpr ' || 
             '  WITH ATTRIBUTE tpr_level as varchar2(20) FROM tpr_levelrel ' || 
             'DIMENSION elec_product_id as varchar2(20) FROM elec_product ' || 
             '  WITH ATTRIBUTE elec_product_level as varchar2(20) FROM elec_product_levelrel ' || 
             '       ATTRIBUTE elec_product_surr as varchar2(20) FROM elec_product_version_surr ' || 
             'DIMENSION ssc_id as varchar2(20) FROM ssc ' || 
             '  WITH ATTRIBUTE ssc_level as varchar2(20) FROM ssc_levelrel ' || 
             'DIMENSION llf_id as varchar2(20) FROM llf ' || 
             '  WITH ATTRIBUTE llf_level as varchar2(20) FROM llf_levelrel ' || 
             'DIMENSION profile_class_id as varchar2(20) FROM profile_class ' || 
             '  WITH ATTRIBUTE profile_class_level as varchar2(20) FROM profile_class_levelrel ' || 
             'DIMENSION elec_licence_id as varchar2(20) FROM elec_licence ' || 
             '  WITH ATTRIBUTE elec_licence_level as varchar2(20) FROM elec_licence_levelrel ' || 
             'DIMENSION gsp_group_id as varchar2(20) FROM gsp_group_id ' || 
             '  WITH ATTRIBUTE gsp_group_id_level as varchar2(20) FROM gsp_group_id_levelrel ' || 
             'DIMENSION business_structure_id as varchar2(20) FROM business_structure ' || 
             '  WITH ATTRIBUTE business_structure_level as varchar2(20) FROM business_structure_levelrel ' || 
             '       ATTRIBUTE business_structure_surr as varchar2(20) FROM business_structure_segment_surr ' || 
             'DIMENSION payment_method_id as varchar2(20) FROM payment_method ' || 
             '  WITH ATTRIBUTE payment_method_level as varchar2(20) FROM payment_method_levelrel ' || 
             '       ATTRIBUTE payment_method_surr as varchar2(20) FROM payment_method_base_surr ' || 
             'DIMENSION dual_fuel_flag_id as varchar2(20) FROM dual_fuel_flag ' || 
             '  WITH ATTRIBUTE dual_fuel_flag_level as varchar2(20) FROM dual_fuel_flag_levelrel ' || 
             'DIMENSION half_hour_id as varchar2(20) FROM half_hour ' || 
             '  WITH ATTRIBUTE half_hour_level as varchar2(20) FROM half_hour_levelrel ' || 
             'DIMENSION e_revenue_item_id as varchar2(20) FROM e_revenue_item ' || 
             '  WITH ATTRIBUTE e_revenue_item_level as varchar2(20) FROM e_revenue_item_levelrel ' || 
             'DIMENSION nhh_e_fc_var_rev_ver_id as varchar2(20) FROM nhh_e_fc_var_rev_ver ' || 
             '  WITH ATTRIBUTE nhh_e_fc_var_rev_ver_level as varchar2(20) FROM nhh_e_fc_var_rev_ver_levelrel ' || 
             'MEASURE rev_temp as number FROM nhh_e_fc_var_rev_rev_temp_stored ' || 
			 'ROW2CELL olap_calc ' ||
             'LOOP NHH_E_FC_VAR_REV_COMPOSITE ' 
            ))
		WHERE TIME_ID = 'JAN-06'
        MODEL 
          DIMENSION BY ( 
                        time_id 
                       ,tpr_id 
                       ,elec_product_surr 
                       ,ssc_id 
                       ,llf_id 
                       ,profile_class_id 
                       ,elec_licence_id 
                       ,gsp_group_id 
                       ,business_structure_surr 
                       ,payment_method_surr 
                       ,dual_fuel_flag_id 
                       ,half_hour_id 
                       ,e_revenue_item_id 
                       ,nhh_e_fc_var_rev_ver_id 
                        ) 
          MEASURES ( 
                   rev_temp,
				   olap_calc 
                    ) 
        RULES UPDATE SEQUENTIAL ORDER() 
        )
/

select count (*) from VW_NHH_E_FC_VAR_REV_WB

create or replace view vw_nhh_e_fc_var_rev_sett
as
select sum (rev) as rev, time_id, tpr, ssc, llfc, profile_class, elec_licence,
       gsp, e_revenue_item, version_id
from VW_NHH_E_FC_VAR_REV_WB
group by time_id, tpr, ssc, llfc, profile_class, elec_licence,
       gsp, e_revenue_item, version_id

create view vw_nhh_e_fc_var_rev_bill
as
select sum (rev) as rev, time_id, elec_product, business_structure, payment_method, dual_fuel_flag,
       e_revenue_item, version_id
from VW_NHH_E_FC_VAR_REV_WB
group by time_id, elec_product, business_structure, payment_method, dual_fuel_flag,
       e_revenue_item, version_id
	   

        WHERE time_level                    = 'MONTH' 
		AND   tpr_level                     = 'BASE' 
		AND   elec_product_level            = 'VERSION' 
        AND   ssc_level                     = 'BASE' 
        AND   llf_level                     = 'BASE' 
        AND   profile_class_level           = 'BASE' 
        AND   elec_licence_level            = 'BASE' 
        AND   gsp_group_id_level            = 'BASE' 
        AND   business_structure_level      = 'SEGMENT' 
        AND   payment_method_level          = 'BASE' 
        AND   dual_fuel_flag_level          = 'BASE' 
        AND   half_hour_level               = 'BASE' 
        AND   e_revenue_item_level          = 'BASE' 
        AND   nhh_e_fc_var_rev_ver_level    = 'BASE'


select * from vw_nhh_e_fc_var_rev_bill
order by elec_product

grant select on vw_nhh_e_fc_var_rev_sett to public ;

grant select on vw_gmf_nhh_edf_mpan_pub to public ;
