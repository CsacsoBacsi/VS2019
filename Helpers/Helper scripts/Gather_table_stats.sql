-- Gather table statistics
DECLARE

BEGIN
   DBMS_STATS.GATHER_TABLE_STATS (ownname => 'HDS', tabname => 'BILLING', partname => NULL,
                                  block_sample => FALSE, method_opt => 'FOR ALL COLUMNS SIZE AUTO',
                                  degree => NULL, force => TRUE, estimate_percent => NULL) ;
                                  
END ;

-- With 4 parallel slaves
DECLARE

BEGIN
   DBMS_STATS.GATHER_TABLE_STATS (ownname => 'HDS', tabname => 'BILLING', partname => NULL,
                                  block_sample => FALSE, method_opt => 'FOR ALL COLUMNS SIZE AUTO',
                                  degree => 4, force => TRUE, estimate_percent => NULL) ;
                                  
END ; -- 83 secs
   
-- Without any parallelism
DECLARE

BEGIN
   DBMS_STATS.GATHER_TABLE_STATS (ownname => 'HDS', tabname => 'BILLING', partname => NULL,
                                  block_sample => FALSE, method_opt => 'FOR ALL COLUMNS SIZE AUTO',
                                  degree => 1, force => TRUE, estimate_percent => NULL) ;
                                  
END ; -- 119 secs
