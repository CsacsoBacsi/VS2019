-- Test data examples
-- SELECT FROM DUAL (example 1)
-- Prior complaint 120 test
with src AS (
    SELECT 0 as complaint_id, 1 as ici, 1 as fin_acc_ref, TO_DATE ('01/02/2014', 'DD/MM/YYYY') as eff_date from dual
    union all
    SELECT 1 as complaint_id, 1 as ici, 1 as fin_acc_ref, TO_DATE ('01/04/2014', 'DD/MM/YYYY') as eff_date from dual
    union all
    SELECT 1 as complaint_id, 1 as ici, 2 as fin_acc_ref, TO_DATE ('01/04/2014', 'DD/MM/YYYY') as eff_date from dual 
    union all
    SELECT 1 as complaint_id, 1 as ici, 3 as fin_acc_ref, TO_DATE ('01/04/2014', 'DD/MM/YYYY') as eff_date from dual
    union all
    SELECT 2 as complaint_id, 1 as ici, 1 as fin_acc_ref, TO_DATE ('01/06/2014', 'DD/MM/YYYY') as eff_date from dual
),
with_rn AS (
    SELECT   complaint_id
           , ici
           , eff_date
           , fin_acc_ref
           , CASE WHEN ROW_NUMBER () OVER (PARTITION BY ici, complaint_id order by fin_acc_ref) = 1
                  THEN 1
                  ELSE 0
             END AS distinct_complaint_id
    FROM   src
), 
distinct_cid AS (
    SELECT   complaint_id
           , ici
           , eff_date
           , fin_acc_ref
           , SUM (distinct_complaint_id) OVER (PARTITION BY ici ORDER BY eff_date
                                               RANGE INTERVAL '120' DAY(3) PRECEDING) - 1 AS prior_complaint_count_120
    FROM   with_rn
)
  SELECT   complaint_id
         , ici
         , eff_date
         , fin_acc_ref
         , CASE WHEN prior_complaint_count_120 > 0 
                THEN 'Y'
                ELSE 'N'
           END AS prior_complaint_120_ind
         , prior_complaint_count_120
  FROM   distinct_cid ;

-- SELECT FROM DUAL (example 2)
-- Reopens (open - close sessions)
WITH src AS (
    SELECT 1 AS COMPLAINT_ID, TO_DATE ('01/05/2014', ' DD/MM/YYYY') AS COMPL_CREATED_DATE,
           TO_DATE ('02/05/2014', ' DD/MM/YYYY') COMPL_EFF_FROM_DATE, 1 AS CSI_ID,
           'Open cmp' AS STATE_DESC, 2 AS ACTION_TYPE_ID, 'Open' AS STATE_TYPE_DESC,
           TO_DATE ('02/05/2014', ' DD/MM/YYYY') AS STATE_START_DATE,
           TO_DATE ('04/05/2014', ' DD/MM/YYYY') AS STATE_END_DATE,
           'C23833' AS ACTION_USER_ID,
           NULL AS PREV_ACTION_TYPE_ID
    FROM DUAL
    UNION ALL
    SELECT 1 AS COMPLAINT_ID, TO_DATE ('01/05/2014', ' DD/MM/YYYY') AS COMPL_CREATED_DATE,
           TO_DATE ('02/05/2014', ' DD/MM/YYYY') COMPL_EFF_FROM_DATE, 2 AS CSI_ID,
           'Update cmp' AS STATE_DESC, 2 AS ACTION_TYPE_ID, 'Open' AS STATE_TYPE_DESC,
           TO_DATE ('05/05/2014', ' DD/MM/YYYY') AS STATE_START_DATE,
           TO_DATE ('09/05/2014', ' DD/MM/YYYY') AS STATE_END_DATE,
           'C23833' AS ACTION_USER_ID,
           2 AS PREV_ACTION_TYPE_ID
    FROM DUAL
    UNION ALL
    SELECT 1 AS COMPLAINT_ID, TO_DATE ('01/05/2014', ' DD/MM/YYYY') AS COMPL_CREATED_DATE,
           TO_DATE ('02/05/2014', ' DD/MM/YYYY') COMPL_EFF_FROM_DATE, 3 AS CSI_ID,
           'Handover cmp' AS STATE_DESC, 2 AS ACTION_TYPE_ID, 'Open' AS STATE_TYPE_DESC,
           TO_DATE ('10/05/2014', ' DD/MM/YYYY') AS STATE_START_DATE,
           TO_DATE ('15/05/2014', ' DD/MM/YYYY') AS STATE_END_DATE,
           'C55555' AS ACTION_USER_ID,
           2 AS PREV_ACTION_TYPE_ID
    FROM DUAL
    UNION ALL
    SELECT 1 AS COMPLAINT_ID, TO_DATE ('01/05/2014', ' DD/MM/YYYY') AS COMPL_CREATED_DATE,
           TO_DATE ('02/05/2014', ' DD/MM/YYYY') COMPL_EFF_FROM_DATE, 4 AS CSI_ID,
           'Close cmp 1' AS STATE_DESC, 1 AS ACTION_TYPE_ID, 'Closed' AS STATE_TYPE_DESC,
           TO_DATE ('16/05/2014', ' DD/MM/YYYY') AS STATE_START_DATE,
           TO_DATE ('18/05/2014', ' DD/MM/YYYY') AS STATE_END_DATE,
           'C55555' AS ACTION_USER_ID,
           2 AS PREV_ACTION_TYPE_ID
    FROM DUAL
    UNION ALL
    SELECT 1 AS COMPLAINT_ID, TO_DATE ('01/05/2014', ' DD/MM/YYYY') AS COMPL_CREATED_DATE,
           TO_DATE ('02/05/2014', ' DD/MM/YYYY') COMPL_EFF_FROM_DATE, 5 AS CSI_ID,
           'Reopen cmp' AS STATE_DESC, 2 AS ACTION_TYPE_ID, 'Open' AS STATE_TYPE_DESC,
           TO_DATE ('19/05/2014', ' DD/MM/YYYY') AS STATE_START_DATE,
           TO_DATE ('22/05/2014', ' DD/MM/YYYY') AS STATE_END_DATE,
           'C88888' AS ACTION_USER_ID,
           1 AS PREV_ACTION_TYPE_ID
    FROM DUAL
    UNION ALL
    SELECT 1 AS COMPLAINT_ID, TO_DATE ('01/05/2014', ' DD/MM/YYYY') AS COMPL_CREATED_DATE,
           TO_DATE ('02/05/2014', ' DD/MM/YYYY') COMPL_EFF_FROM_DATE, 6 AS CSI_ID,
           'Update cmp' AS STATE_DESC, 2 AS ACTION_TYPE_ID, 'Open' AS STATE_TYPE_DESC,
           TO_DATE ('23/05/2014', ' DD/MM/YYYY') AS STATE_START_DATE,
           TO_DATE ('25/05/2014', ' DD/MM/YYYY') AS STATE_END_DATE,
           'C88888' AS ACTION_USER_ID,
           2 AS PREV_ACTION_TYPE_ID
    FROM DUAL
    UNION ALL
    SELECT 1 AS COMPLAINT_ID, TO_DATE ('01/05/2014', ' DD/MM/YYYY') AS COMPL_CREATED_DATE,
           TO_DATE ('02/05/2014', ' DD/MM/YYYY') COMPL_EFF_FROM_DATE, 7 AS CSI_ID,
           'Close cmp' AS STATE_DESC, 1 AS ACTION_TYPE_ID, 'Closed' AS STATE_TYPE_DESC,
           TO_DATE ('26/05/2014', ' DD/MM/YYYY') AS STATE_START_DATE,
           TO_DATE ('31/12/2999', ' DD/MM/YYYY') AS STATE_END_DATE,
           'C88888' AS ACTION_USER_ID,
           2 AS PREV_ACTION_TYPE_ID
    FROM DUAL
    UNION ALL
    SELECT 2 AS COMPLAINT_ID, TO_DATE ('01/05/2014', ' DD/MM/YYYY') AS COMPL_CREATED_DATE,
           TO_DATE ('02/05/2014', ' DD/MM/YYYY') COMPL_EFF_FROM_DATE, 1 AS CSI_ID,
           'Open cmp' AS STATE_DESC, 2 AS ACTION_TYPE_ID, 'Open' AS STATE_TYPE_DESC,
           TO_DATE ('02/05/2014', ' DD/MM/YYYY') AS STATE_START_DATE,
           TO_DATE ('04/05/2014', ' DD/MM/YYYY') AS STATE_END_DATE,
           'C11111' AS ACTION_USER_ID,
           NULL AS PREV_ACTION_TYPE_ID
    FROM DUAL
    UNION ALL
    SELECT 1 AS COMPLAINT_ID, TO_DATE ('01/05/2014', ' DD/MM/YYYY') AS COMPL_CREATED_DATE,
           TO_DATE ('02/05/2014', ' DD/MM/YYYY') COMPL_EFF_FROM_DATE, 2 AS CSI_ID,
           'Update cmp' AS STATE_DESC, 2 AS ACTION_TYPE_ID, 'Open' AS STATE_TYPE_DESC,
           TO_DATE ('05/05/2014', ' DD/MM/YYYY') AS STATE_START_DATE,
           TO_DATE ('09/05/2014', ' DD/MM/YYYY') AS STATE_END_DATE,
           'C11111' AS ACTION_USER_ID,
           2 AS PREV_ACTION_TYPE_ID
    FROM DUAL
    UNION ALL
    SELECT 2 AS COMPLAINT_ID, TO_DATE ('01/05/2014', ' DD/MM/YYYY') AS COMPL_CREATED_DATE,
           TO_DATE ('02/05/2014', ' DD/MM/YYYY') COMPL_EFF_FROM_DATE, 4 AS CSI_ID,
           'Close cmp 1' AS STATE_DESC, 1 AS ACTION_TYPE_ID, 'Closed' AS STATE_TYPE_DESC,
           TO_DATE ('16/05/2014', ' DD/MM/YYYY') AS STATE_START_DATE,
           TO_DATE ('18/05/2014', ' DD/MM/YYYY') AS STATE_END_DATE,
           'C77777' AS ACTION_USER_ID,
           2 AS PREV_ACTION_TYPE_ID
    FROM DUAL
    UNION ALL
    SELECT 2 AS COMPLAINT_ID, TO_DATE ('01/05/2014', ' DD/MM/YYYY') AS COMPL_CREATED_DATE,
           TO_DATE ('02/05/2014', ' DD/MM/YYYY') COMPL_EFF_FROM_DATE, 5 AS CSI_ID,
           'Reopen cmp 1' AS STATE_DESC, 2 AS ACTION_TYPE_ID, 'Open' AS STATE_TYPE_DESC,
           TO_DATE ('19/05/2014', ' DD/MM/YYYY') AS STATE_START_DATE,
           TO_DATE ('22/05/2014', ' DD/MM/YYYY') AS STATE_END_DATE,
           'C88888' AS ACTION_USER_ID,
           1 AS PREV_ACTION_TYPE_ID
    FROM DUAL
    UNION ALL
    SELECT 2 AS COMPLAINT_ID, TO_DATE ('01/05/2014', ' DD/MM/YYYY') AS COMPL_CREATED_DATE,
           TO_DATE ('02/05/2014', ' DD/MM/YYYY') COMPL_EFF_FROM_DATE, 4 AS CSI_ID,
           'Close cmp 2' AS STATE_DESC, 1 AS ACTION_TYPE_ID, 'Closed' AS STATE_TYPE_DESC,
           TO_DATE ('24/05/2014', ' DD/MM/YYYY') AS STATE_START_DATE,
           TO_DATE ('25/05/2014', ' DD/MM/YYYY') AS STATE_END_DATE,
           'C55555' AS ACTION_USER_ID,
           2 AS PREV_ACTION_TYPE_ID
    FROM DUAL
    UNION ALL
    SELECT 2 AS COMPLAINT_ID, TO_DATE ('01/05/2014', ' DD/MM/YYYY') AS COMPL_CREATED_DATE,
           TO_DATE ('02/05/2014', ' DD/MM/YYYY') COMPL_EFF_FROM_DATE, 5 AS CSI_ID,
           'Reopen cmp 2' AS STATE_DESC, 2 AS ACTION_TYPE_ID, 'Open' AS STATE_TYPE_DESC,
           TO_DATE ('27/05/2014', ' DD/MM/YYYY') AS STATE_START_DATE,
           TO_DATE ('31/12/2999', ' DD/MM/YYYY') AS STATE_END_DATE,
           'C88888' AS ACTION_USER_ID,
           1 AS PREV_ACTION_TYPE_ID
    FROM DUAL
),
),
analytics AS (
    SELECT COMPLAINT_ID
           , ACTION_USER_ID
           , CASE WHEN ACTION_TYPE_ID = 2 AND PREV_ACTION_TYPE_ID = 1 -- When Open is followed by a Close
                  THEN LAG (ACTION_USER_ID) OVER (PARTITION BY COMPLAINT_ID ORDER BY STATE_START_DATE)
                  ELSE NULL
             END AS PRE_REOPEN_OWNER_ID
           , CASE WHEN ACTION_TYPE_ID = 2 AND PREV_ACTION_TYPE_ID = 1
                  THEN STATE_START_DATE
                  ELSE NULL
             END AS REOPEN_DATE
           , CASE WHEN ACTION_TYPE_ID = 2 AND PREV_ACTION_TYPE_ID = 1
                  THEN 'Y'
                  ELSE 'N'
             END AS REOPEN_FLAG
           , CASE WHEN ACTION_TYPE_ID = 2 AND PREV_ACTION_TYPE_ID = 1
                  THEN ACTION_USER_ID
                  ELSE NULL
             END AS REOPEN_USER_ID
           , SUM (CASE WHEN ACTION_TYPE_ID = 1 -- Close
                       THEN 1 -- Cummulative sum
                       ELSE 0 
                  END) -- Close point is incremented each time a new Closed state is detected
                  OVER (PARTITION BY COMPLAINT_ID ORDER BY CSI_ID) AS CLOSE_POINTS
           , ACTION_TYPE_ID -- 1 = Close, 2 = Open
           , STATE_TYPE_DESC
           , STATE_START_DATE
           , STATE_END_DATE
           , CSI_ID
           , STATE_DESC
           , COMPL_CREATED_DATE
           , COMPL_EFF_FROM_DATE
    FROM   src
), 
sessions AS (
    SELECT COMPLAINT_ID
           , REOPEN_DATE
           , REOPEN_FLAG
           , REOPEN_USER_ID
           , PRE_REOPEN_OWNER_ID
           , STATE_START_DATE
           , STATE_END_DATE
           , ACTION_TYPE_ID
           , CASE WHEN ACTION_TYPE_ID <> 1 -- Creating "sessions" - [open - close] intervals 
                  THEN CLOSE_POINTS + 1 
                  ELSE CLOSE_POINTS 
             END AS SESSION_ID
           , CSI_ID
           , MAX (CSI_ID) OVER (PARTITION BY COMPLAINT_ID) AS LAST_CSI_ID -- Used to identify the last action
           , STATE_DESC
           , COMPL_CREATED_DATE -- Creation date and time of the complaint in ICE
           , COMPL_EFF_FROM_DATE -- Raised date and time of the complaint. Both used for duration calc for the first session
    FROM analytics
), 
trunc_dates AS (
    SELECT COMPLAINT_ID
           , TRUNC (REOPEN_DATE) AS REOPEN_DATE
           , REOPEN_FLAG
           , REOPEN_USER_ID
           , PRE_REOPEN_OWNER_ID
           , TRUNC (STATE_START_DATE) AS STATE_START_DATE
           , TRUNC (STATE_END_DATE) AS STATE_END_DATE
           , TRUNC (COMPL_CREATED_DATE) AS COMPL_CREATED_DATE
           , TRUNC (COMPL_EFF_FROM_DATE) AS COMPL_EFF_FROM_DATE
           , ACTION_TYPE_ID
           , SESSION_ID
           , STATE_DESC
           , FIRST_VALUE (TRUNC (STATE_START_DATE)) OVER (PARTITION BY COMPLAINT_ID, SESSION_ID ORDER BY CSI_ID 
                                            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS SESS_START_DATE -- Start date of the session
           , CASE WHEN STATE_END_DATE = TO_DATE ('31/12/2999', 'DD/MM/YYYY') AND ACTION_TYPE_ID = 2
                  THEN TRUNC (SYSDATE - 1)
                  ELSE LAST_VALUE (TRUNC (STATE_START_DATE)) OVER (PARTITION BY COMPLAINT_ID, SESSION_ID ORDER BY CSI_ID
                                            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
             END AS SESS_END_DATE -- End date of the session. Readjust the end date if it is the high date
           , CSI_ID
           , LAST_CSI_ID
    FROM   sessions
),
duration AS (
    SELECT COMPLAINT_ID
           , REOPEN_DATE
           , REOPEN_FLAG
           , REOPEN_USER_ID
           , PRE_REOPEN_OWNER_ID
           , SESS_START_DATE
           , SESS_END_DATE
           , MAX (SESS_END_DATE) OVER (PARTITION BY COMPLAINT_ID) AS LAST_SESS_END_DATE
           , STATE_START_DATE
           , CASE WHEN ACTION_TYPE_ID = 1 
                  THEN CASE WHEN SESSION_ID > 1 -- For the first session use CREATED_DATE
                            THEN SESS_END_DATE - SESS_START_DATE
                            ELSE SESS_END_DATE - COMPL_CREATED_DATE
                       END
                  WHEN ACTION_TYPE_ID <> 1 AND STATE_END_DATE = TO_DATE ('31/12/2999', 'DD/MM/YYYY') -- For the last state, convert high date to sysdate - 1
                  THEN CASE WHEN SESSION_ID > 1 
                            THEN (SYSDATE - 1) - SESS_START_DATE
                            ELSE (SYSDATE - 1) - COMPL_CREATED_DATE -- The last state is also the first one (single state situation)
                       END
                  ELSE 0  
             END  AS CREATION_DURATION_DAYS
           , CASE WHEN ACTION_TYPE_ID = 1 
                  THEN CASE WHEN SESSION_ID > 1 -- For the first session use EFFECTIVE_FROM_DATE
                            THEN SESS_END_DATE - SESS_START_DATE
                            ELSE SESS_END_DATE - COMPL_EFF_FROM_DATE
                       END
                  WHEN ACTION_TYPE_ID <> 1 AND STATE_END_DATE = TO_DATE ('31/12/2999', 'DD/MM/YYYY') -- For the last state, convert high date to sysdate - 1
                  THEN CASE WHEN SESSION_ID > 1 
                            THEN (SYSDATE - 1) - SESS_START_DATE
                            ELSE (SYSDATE - 1) - COMPL_EFF_FROM_DATE -- The last state is also the first one (single state situation)
                       END
                  ELSE 0  
             END  AS EFFECTIVE_DURATION_DAYS
           , ACTION_TYPE_ID
           , SESSION_ID
           , CSI_ID
           , LAST_CSI_ID
           , STATE_DESC
           , COMPL_CREATED_DATE
           , COMPL_EFF_FROM_DATE
    FROM   trunc_dates
),
adjusted AS (
    SELECT COMPLAINT_ID
           , REOPEN_DATE
           , REOPEN_FLAG
           , REOPEN_USER_ID
           , PRE_REOPEN_OWNER_ID
           , SESS_START_DATE
           , SESS_END_DATE
           , LAST_SESS_END_DATE
           , STATE_START_DATE
           , CREATION_DURATION_DAYS
           , CASE WHEN EFFECTIVE_DURATION_DAYS < 0
                  THEN CREATION_DURATION_DAYS
                  ELSE EFFECTIVE_DURATION_DAYS
             END AS EFFECTIVE_DURATION_DAYS
           , ACTION_TYPE_ID
           , SESSION_ID
           , CSI_ID
           , LAST_CSI_ID
           , STATE_DESC
           , COMPL_CREATED_DATE
           , COMPL_EFF_FROM_DATE
    FROM   duration
),
duration2 AS (
    SELECT COMPLAINT_ID
           , REOPEN_DATE
           , REOPEN_FLAG
           , REOPEN_USER_ID
           , PRE_REOPEN_OWNER_ID
           , SUM (CREATION_DURATION_DAYS) OVER (PARTITION BY COMPLAINT_ID) AS CREATION_DURATION_DAYS
           , SUM (EFFECTIVE_DURATION_DAYS) OVER (PARTITION BY COMPLAINT_ID) AS EFFECTIVE_DURATION_DAYS
           , CASE WHEN CSI_ID = LAST_CSI_ID   -- Duration days are only calculated on Close action and for the last action
                  THEN CREATION_DURATION_DAYS -- We also need it on Reopens, hence the LAG function
                  ELSE LAG (CREATION_DURATION_DAYS) OVER (PARTITION BY COMPLAINT_ID ORDER BY CSI_ID)
             END AS SESS_CRE_DURATION_DAYS
           , CASE WHEN CSI_ID = LAST_CSI_ID
                  THEN EFFECTIVE_DURATION_DAYS
                  ELSE LAG (EFFECTIVE_DURATION_DAYS) OVER (PARTITION BY COMPLAINT_ID ORDER BY CSI_ID) 
             END AS SESS_EFF_DURATION_DAYS
           , LAST_SESS_END_DATE
           , LAST_SESS_END_DATE - COMPL_CREATED_DATE AS GROSS_CRE_DURATION_DAYS
           , LAST_SESS_END_DATE - COMPL_EFF_FROM_DATE AS GROSS_EFF_DURATION_DAYS
    FROM   adjusted
),
resultset AS (
    SELECT COMPLAINT_ID
           , REOPEN_DATE
           , REOPEN_FLAG
           , REOPEN_USER_ID
           , PRE_REOPEN_OWNER_ID
           , CREATION_DURATION_DAYS
           , EFFECTIVE_DURATION_DAYS
           , SESS_CRE_DURATION_DAYS -- Columns hereafter are for additional info only
           , SESS_EFF_DURATION_DAYS
           , GROSS_CRE_DURATION_DAYS
           , GROSS_EFF_DURATION_DAYS
    FROM   duration2
    WHERE  REOPEN_FLAG = 'Y'
)
  SELECT COMPLAINT_ID
         , REOPEN_DATE
         , REOPEN_FLAG
         , REOPEN_USER_ID
         , PRE_REOPEN_OWNER_ID
         , CREATION_DURATION_DAYS
         , EFFECTIVE_DURATION_DAYS
  FROM   duration2
  ORDER BY COMPLAINT_ID
;

-- SELECT FROM HDS tables
src AS (
    SELECT c.COMPLAINT_ID
           , c.CREATED_DATE         AS COMPL_CREATED_DATE
           , c.RAISED_DATE          AS COMPL_EFF_FROM_DATE
           , co.COMPLAINT_OWNER_ID  AS CO_ID
           , co.START_DATE          AS OWNER_START_DATE
           , co.END_DATE            AS OWNER_END_DATE
           , co.USER_ID
           , LAG (USER_ID) OVER (PARTITION BY c.COMPLAINT_ID ORDER BY co.COMPLAINT_OWNER_ID) AS PREV_USER_ID
           , cc.CLOSED_DATE         AS COMPL_CLOSED_DATE
           , cc.CLOSED_FLAG
           , cc.CLOSED_SAME_DAY_FLAG
           , cc.OMBUDSMAN_COMPLAINT_INDICATOR
    FROM   HDS_T_COMP_COMPLAINT       c,
           HDS_T_COMP_COMPLAINT_OWNER co,
           AML_T_COMPLAINTS_CREATED   cc
    WHERE  c.COMPLAINT_ID     = co.COMPLAINT_ID
           AND c.COMPLAINT_ID = cc.COMPLAINT_ID
           AND cc.DW_TO_DATE > SYSDATE
),
analytics AS (

-- SELECT FROM original Source tables (run on ICE1T11)
src AS (
    SELECT c.COMPLAINT_ID
           , c.CREATED_DATE                  AS COMPL_CREATED_DATE
           , c.RAISED_DATE                   AS COMPL_EFF_FROM_DATE
           , csi.COMPLAINT_STATE_INSTANCE_ID AS CSI_ID
           , cs.DESCRIPTION                  AS STATE_DESC
           , cst.COMPLAINT_STATE_TYPE_ID     AS ACTION_TYPE_ID
           , cst.DESCRIPTION                 AS STATE_TYPE_DESC
           , csi.START_DATE                  AS STATE_START_DATE
           , csi.END_DATE                    AS STATE_END_DATE
           , TRIM (cah.USER_ID)              AS ACTION_USER_ID
           , LAG (cst.COMPLAINT_STATE_TYPE_ID) OVER (PARTITION BY c.COMPLAINT_ID 
                  ORDER BY csi.COMPLAINT_STATE_INSTANCE_ID) AS PREV_ACTION_TYPE_ID
/*    FROM   HDS_T_COMP_COMPLAINT                c,
           HDS_T_COMP_COMPL_STATE_INST         csi, -- State is used rather than action history
           HDS_T_COMP_COMPLAINT_STATE          cs,
           HDS_T_COMP_COMPL_STATE_TYPE         cst, -- Only two types: Open & Close
           HDS_T_COMP_COMPL_ACTION_HIST        cah */
    FROM   complaints.COMPLAINT                c,
           complaints.COMPLAINT_STATE_INSTANCE csi, -- State is used rather than action history
           complaints.COMPLAINT_STATE          cs, 
           complaints.COMPLAINT_STATE_TYPE     cst, -- Only two types: Open & Close
           complaints.COMPLAINT_ACTION_HISTORY cah
    WHERE  c.COMPLAINT_ID                      = csi.COMPLAINT_ID
           AND csi.COMPLAINT_STATE_ID          = cs.COMPLAINT_STATE_ID
           AND cs.COMPLAINT_STATE_TYPE_ID      = cst.COMPLAINT_STATE_TYPE_ID
           AND csi.COMPLAINT_ACTION_HISTORY_ID = cah.COMPLAINT_ACTION_HISTORY_ID
),
reopens AS (
