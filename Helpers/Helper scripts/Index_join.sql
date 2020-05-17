SELECT  /*+ INDEX_JOIN (HIST INV_DATA_STAT_HIST_INVID_IDX BILLING_II_IDX) */ 
       HIST.INVOICE_ID
FROM   RPT.INVOICE_DATA_STATUS_HIST HIST
WHERE  EXISTS (SELECT NULL
               FROM   HDS.BILLING BILL
               WHERE  BILL.INVOICE_ID = HIST.INVOICE_ID)
;
                                                        
-- Index join can be done if the target columns in both the joins and the select columns are in the index
-- Two fast full index scans hash joined - the result

SELECT  /*+ INDEX_JOIN (HIST INV_DATA_STAT_HIST_INVID_IDX BILLING_II_IDX) */ 
       HIST.INVOICE_ID,
       HIST.EFFECTIVE_FROM_DATE
FROM   RPT.INVOICE_DATA_STATUS_HIST HIST
WHERE  EXISTS (SELECT NULL
               FROM   HDS.BILLING BILL
               WHERE  BILL.INVOICE_ID = HIST.INVOICE_ID)
;

-- Still OK, because the primary key contains EFD (it is INVOICE_ID, EFFECTIVE_FROM_DATE)

SELECT  /*+ INDEX_JOIN (HIST INV_DATA_STAT_HIST_INVID_IDX BILLING_II_IDX) */ 
       HIST.INVOICE_ID,
       HIST.EFFECTIVE_TO_DATE
FROM   RPT.INVOICE_DATA_STATUS_HIST HIST
WHERE  EXISTS (SELECT NULL
               FROM   HDS.BILLING BILL
               WHERE  BILL.INVOICE_ID = HIST.INVOICE_ID)
;

-- HIST must be a full table scan for the ETD column. BILL is still and index fast full scan
