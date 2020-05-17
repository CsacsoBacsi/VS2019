select 'COMMENT ON COLUMN MDR_T_COLUMN.'
       ||column_name||' IS ''TEMPORARY COMMENT for column '
       ||COLUMN_NAME||''';' from USER_TAB_COLS
WHERE TABLE_NAME='MDR_T_COLUMN'
order by COLUMN_ID
;
