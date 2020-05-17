MERGE  
/*+ APPEND  */ 
INTO csaba_trg tt USING  
    ( WITH ua AS ( SELECT col1, col2, col3, vol,
                          1 as ind1,
                          TO_NUMBER (NULL) as ind2,
                          NULL as ri
                   FROM   csaba_src xx 
                   where 1=1  
                   UNION ALL 
                   SELECT col1, col2, col3, vol, 
                          TO_NUMBER (NULL) as ind1,
                          1 as ind2,
                          rowid as ri
                   FROM   csaba_trg xx 
                   WHERE  TO_DATE IS NULL  
                 ) 
      SELECT col1, col2, col3, vol, 
             CASE WHEN COUNT(ind2) = 0 AND COUNT(ind1) = 1 THEN 'I' 
                  WHEN COUNT(ind1) = 0 AND COUNT(ind2) = 1 THEN 'U' 
                  ELSE                                          'Q' -- Could be 2 on one side and 1 on the other
             END as transaction_type_xx, 
             COUNT(xx.ind1) count_ind1,
             COUNT(xx.ind2) count_ind2,
             to_date('31-mar-2014','dd-mon-yyyy') as batch_from_date,
             to_date('30-mar-2014', 'dd-mon-yyyy') as batch_to_date,
             MAX (ri) as ri
      FROM   ua xx 
      GROUP BY col1, col2, col3, vol 
      HAVING COUNT (xx.ind1) != COUNT (xx.ind2)) aaa 
ON (tt.rowid = aaa.ri)
--ON (tt.col1||'||'||tt.col2||'||'||tt.col3||'||'||tt.vol||'||'||'U' = 
--    aaa.col1||'||'||aaa.col2||'||'||aaa.col3||'||'||aaa.vol||'||'||aaa.transaction_type_xx) 
WHEN MATCHED THEN UPDATE  
set  TO_DATE                = batch_to_date,
     updated_batch_run_date = batch_from_date   
WHERE to_date is NULL 
WHEN NOT MATCHED THEN INSERT (col1, col2, col3, vol, 
                              from_date, TO_DATE,
                              created_batch_run_date,
                              updated_batch_run_date) 
                      VALUES (aaa.col1,aaa.col2,aaa.col3,aaa.vol, 
                              CASE WHEN transaction_type_xx = 'U' THEN batch_to_date  
                                                                  ELSE batch_from_date 
                              END, --from_date 
                              CASE WHEN transaction_type_xx = 'U' THEN batch_to_date 
                                                                  ELSE NULL   
                              END, --to_date  
                              batch_from_date, --created_batch_run_date 
                              CASE WHEN transaction_type_xx = 'U' THEN batch_from_date                 
                                                                  ELSE NULL 
                              END --updated_batch_run_date  
                             ) 
                   WHERE transaction_type_xx = 'I' ; -- Q not used anywhere!
                   
                   
