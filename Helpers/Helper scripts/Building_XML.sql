create or replace view vw_reportingparameter_xml as
select vrc.calculation_id,
       xmlelement(
          "REPORTINGPARAMETER",
          xmlforest(
            wv.provider_id as "PROVIDER",
            vrc.weather_variable_id as "VARIABLE",
            vrc.a_f_ind as "MEASUREMENTTYPE",
            vrc.scenario_id as "SCENARIO",
            vrc.output_alias as "ALIAS"  
          )    
        ) as xml
from    variable_requirement_calc vrc,
        weather_variable wv
where   vrc.weather_variable_id = wv.weather_variable_id

create or replace view vw_reporting_uom_xml as
select vrc.calculation_id,
       xmlelement(
          "UOM",
          xmlforest(
            uom.unit_of_measure_code as "UNIT_OF_MEASURE_CODE",
            uom.unit_of_measure_name as "UNIT_OF_MEASURE_NAME",
            wv.weather_variable_type_id as "WEATHER_VARIABLE_TYPE_ID",
            wuom.default_uom as "DEFAULT_UOM" 
          )    
        ) as xml
from    variable_requirement_calc vrc,
        weather_variable wv,
        unit_of_measure uom,
        weather_variable_type_uom wuom
where   vrc.weather_variable_id = wv.weather_variable_id
        and wuom.weather_variable_type_id = wv.weather_variable_type_id
        and uom.unit_of_measure_code = wuom.unit_of_measure_code
        and vrc.unit_of_measure_code = wuom.unit_of_measure_code

create or replace view vw_reporting_area_xml as
select a.calculation_id, 
       xmlelement(
          "AREA",
          xmlforest(
            a.area_id as "AREA_ID",
            a.alias_name as "AREA_NAME",
            a.area_type_id as "AREA_TYPE_ID"
          )    
        ) as xml
from    area_requirement_calc a 

select * from vw_reporting_area_xml a
where calculation_id = 3

select xmlforest(
            a.area_id as "AREA_ID",
            a.alias_name as "AREA_NAME",
            a.area_type_id as "AREA_TYPE_ID"
          )  from area_requirement_calc
where calculation_id = 3 ;

create or replace view vw_report_definition_xml as
select c.calculation_id,
       xmlelement(
         "REPORT_DEFINITION",
         xmlagg (xmlforest(
            c.calculation_name as "CALCULATION_NAME",
            c.view_name as "VIEW_NAME",
            r.time_regime_id as "TIME_REGIME",
            r.time_resolution as "TIME_RESOLUTION",
            c.blend_id as "BLEND_ID",
            c.output_scenario_id as "OUTPUT_SCENARIO"
         )),    
         xmlelement(
           "REPORTINGPARAMETERS",
           (select xmlagg(xml) from vw_reportingparameter_xml where calculation_id = c.calculation_id)           
         ),
         xmlelement(
           "AREAS",
           (select xmlagg(xml) from vw_reporting_area_xml where calculation_id = c.calculation_id)
         ),
         xmlelement(
           "UOMS",
           (select xmlagg(xml) from vw_reporting_uom_xml where calculation_id = c.calculation_id)
         )        
       ) as xml
from   calculation c,
       report_requirement_calc r
where  c.calculation_id = r.calculation_id
group by c.calculation_id


select * from vw_report_definition_xml
where calculation_id = 3 ;
