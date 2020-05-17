merge
/*+ USE_HASH (tt aaa) APPEND */
into csaba_trg t using
    (with update_set as (select col1, col2, col3, vol, -- Rows that exist in the target (have a ROWID)
                        rowid ri
                 from   csaba_trg t
                 where  to_date is null
                 union all
                 select col1, col2, col3, vol, -- Rows that in the source
                        null ri
                 from   csaba_src s
    ) select col1, col2, col3, vol,
             max (ri) ri,
             trunc (sysdate) batch_from_date,
             trunc (sysdate - 1) batch_to_date -- Runs on yesterday's data so from_date - 1
      from   update_set us
      group by col1, col2, col3, vol
      having count (*) = 1) us -- If exists in both that means they are identical so we do not need to bother
on (t.rowid = us.ri)
when matched then update 
set  to_date                = us.batch_to_date,
     updated_batch_run_date = us.batch_from_date  -- We update on rowid as it exists for the existing row
WHERE TO_DATE IS NULL -- This is needed because if a row changes once then changes again later but it goes back to a previous value/status, this will not work correctly!
when not matched then insert (col1, col2, col3, vol, -- We insert the source row with no rowid as it does not exist yet
                              from_date,
                              to_date,
                              created_batch_run_date,
                              updated_batch_run_date)
                      VALUES (us.col1, us.col2, us.col3, us.vol,
                              us.batch_from_date,
                              NULL,
                              us.batch_from_date,
                              us.batch_from_date) ;                             
                             
                             
MERGE
/*+ USE_HASH(tt aaa) APPEND  */
INTO $$target_table_owner$$.$$target_view_name$$ tt USING 
    ( WITH ua AS ( SELECT $$xx_field_list$$
                        , xx.rowid ri
                   FROM   $$target_table_owner$$.$$target_table_name$$ xx
                   WHERE  TO_DATE IS NULL $$merge_where$$
                   UNION ALL
                   SELECT $$xx_field_list$$
                        , NULL ri
                   FROM   $$source_table_owner$$.$$source_table_name$$$$source_db$$ xx
                   WHERE 1=1 $$merge_where$$
                 )
      SELECT $$xx_field_list$$
           , MAX(ri) ri
           , TO_DATE('$$batch_from_date$$','dd-mon-yyyy') batch_from_date
           , TO_DATE('$$batch_to_date$$', 'dd-mon-yyyy')   batch_to_date
      FROM   ua xx
      GROUP BY $$xx_field_list$$
      HAVING count(*) = 1) aaa
ON (tt.rowid = aaa.ri  )
WHEN MATCHED THEN UPDATE 
set  TO_DATE                = batch_to_date 
   , updated_batch_run_date = batch_from_date  
WHERE TO_DATE IS NULL
WHEN NOT MATCHED THEN INSERT ( $$field_list$$
                             , from_date 
                             , TO_DATE
                             , created_batch_run_date
                             , updated_batch_run_date
                             )
                      VALUES ( $$aaa_field_list$$
                             , CASE WHEN ri is not null THEN batch_to_date 
                                                        ELSE batch_from_date
                               END --from_date
                             , CASE WHEN ri is not null THEN batch_to_date
                                                        ELSE NULL  
                               END --to_date 
                             , batch_from_date --created_batch_run_date
                             , CASE WHEN ri is not null THEN batch_from_date                
                                                        ELSE NULL
                               END --updated_batch_run_date 
                             );
