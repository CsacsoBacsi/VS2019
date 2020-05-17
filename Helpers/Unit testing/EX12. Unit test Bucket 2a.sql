WITH reopen_set AS (
    SELECT complaint_id
           , reopen_date
           , pre_reopen_user_id
           , reopen_user_id
    FROM   aml_t_complaints_reopen_cr -- My test data sits in here
),
src AS (
    SELECT   c.complaint_id, c.created_date, created_date_time, c.created_by_user_id
           , LOWER (croda.job_role_description) AS cr_role_desc -- Creator role
           , croda.is_manager AS cr_is_manager, c.owned_by_user_id, c.sector_id, c.closed_date
           , c.closed_flag, c.closed_same_day_flag
           , CASE WHEN ho.complaint_id IS NOT NULL
                  THEN 'Y'
                  ELSE 'N'
             END AS hand_off_flag
           , ho.hand_off_date, ho.hand_off_user_id, ho.hand_off_from_user_id
           , NVL (ho.hand_off_from_user_id, c.owned_by_user_id) AS last_progressed_by_user_id
           , reopen_date, ro.pre_reopen_user_id, ro.reopen_user_id
           , NVL2 (reopen_user_id, 'Y', 'N') AS reopen_flag
           , LOWER (owoda.job_role_description) AS ow_role_desc -- Owner, hand off user role
           , owoda.is_manager AS ow_is_manager
           , LOWER (hooda.job_role_description) AS ho_role_desc -- Hand off from user role
           , hooda.is_manager AS ho_is_manager
           , LOWER (prooda.job_role_description) AS pro_role_desc -- Pre-reopen user role
           , prooda.is_manager AS pro_is_manager
           , LOWER (rooda.job_role_description) AS ro_role_desc -- Re-reopen user role
           , rooda.is_manager AS ro_is_manager
           , c.summary
           , c.expected_bucket
    FROM   aml_t_complaints_created_cr            c
           LEFT JOIN dim_t_oda_user_flat_cr   croda -- Creator
             ON croda.user_id = c.created_by_user_id
                AND TRUNC (c.created_date) BETWEEN croda.dw_from_date AND croda.dw_to_date
           LEFT JOIN aml_t_complaints_handoff_cr ho -- Hand-offs
             ON ho.complaint_id = c.complaint_id
           LEFT JOIN dim_t_oda_user_flat_cr   owoda -- Owner, hand off user
             ON owoda.user_id = nvl (ho.hand_off_user_id, c.owned_by_user_id)
                AND NVL (TRUNC (ho.hand_off_date), c.created_date) BETWEEN owoda.dw_from_date AND owoda.dw_to_date
           LEFT JOIN dim_t_oda_user_flat_cr   hooda -- Hand off from user
             ON hooda.user_id = ho.hand_off_from_user_id
                AND TRUNC (ho.hand_off_date) BETWEEN hooda.dw_from_date AND hooda.dw_to_date
           LEFT JOIN aml_t_complaints_reopen_cr    ro -- Reopens
             ON c.complaint_id = ro.complaint_id
           LEFT JOIN dim_t_oda_user_flat_cr   prooda -- Pre-reopen user
             ON prooda.user_id = ro.pre_reopen_user_id
                AND TRUNC (ro.reopen_date) BETWEEN prooda.dw_from_date AND prooda.dw_to_date
           LEFT JOIN dim_t_oda_user_flat_cr   rooda -- Re-open user
             ON rooda.user_id = ro.reopen_user_id
                AND TRUNC (ro.reopen_date) BETWEEN rooda.dw_from_date AND rooda.dw_to_date
    WHERE  c.dw_to_date = TO_DATE ('31/12/9999', 'DD/MM/YYYY')
           AND c.created_date BETWEEN TO_DATE ('30/07/2014', 'DD/MM/YYYY') AND SYSDATE
),
base_data AS (
    SELECT   complaint_id, created_date, created_date_time, created_by_user_id, owned_by_user_id
           , sector_id, closed_date, closed_flag, closed_same_day_flag, hand_off_date, hand_off_flag, hand_off_user_id
           , hand_off_from_user_id, last_progressed_by_user_id, reopen_date, pre_reopen_user_id, reopen_user_id
           , reopen_flag, summary, expected_bucket, cr_role_desc, ow_role_desc, ho_role_desc, pro_role_desc, ro_role_desc
           , CASE WHEN cr_role_desc LIKE '%resolution manag%' THEN 2
                  WHEN cr_role_desc LIKE '%resolution rev%'   THEN 3
                  WHEN cr_role_desc LIKE '%ombudsman%'        THEN 4
                  WHEN cr_is_manager = 'Y'                    THEN -1
                  WHEN cr_role_desc IS NULL                   THEN 0
                  ELSE 1
             END AS creator_rank
           , CASE WHEN ow_role_desc LIKE '%resolution manag%' THEN 2
                  WHEN ow_role_desc LIKE '%resolution rev%'   THEN 3
                  WHEN ow_role_desc LIKE '%ombudsman%'        THEN 4
                  WHEN ow_is_manager = 'Y'                    THEN -1
                  WHEN ow_role_desc IS NULL                   THEN 0
                  ELSE 1
              END AS owner_rank
           , CASE WHEN ho_role_desc LIKE '%resolution manag%' THEN 2
                  WHEN ho_role_desc LIKE '%resolution rev%'   THEN 3
                  WHEN ho_role_desc LIKE '%ombudsman%'        THEN 4
                  WHEN ho_is_manager = 'Y'                    THEN -1
                  WHEN ho_role_desc IS NULL                   THEN 0
                  ELSE 1
              END AS hand_off_from_rank
           , CASE WHEN pro_role_desc LIKE '%resolution manag%' THEN 2
                  WHEN pro_role_desc LIKE '%resolution rev%'   THEN 3
                  WHEN pro_role_desc LIKE '%ombudsman%'        THEN 4
                  WHEN pro_is_manager = 'Y'                    THEN -1
                  WHEN pro_role_desc IS NULL                   THEN 0
                  ELSE 1
              END AS pre_reopen_rank
           , CASE WHEN ro_role_desc LIKE '%resolution manag%'  THEN 2
                  WHEN ro_role_desc LIKE '%resolution rev%'    THEN 3
                  WHEN ro_role_desc LIKE '%ombudsman%'         THEN 4
                  WHEN ro_is_manager = 'Y'                     THEN -1
                  WHEN ro_role_desc IS NULL                    THEN 0
                  ELSE 1
              END AS reopen_rank
            , ROW_NUMBER () OVER (PARTITION BY complaint_id ORDER BY NVL (hand_off_date, created_date_time) DESC, COALESCE (reopen_date, hand_off_date, created_date_time) DESC) AS rn
    FROM   src
),
classify AS (
    SELECT   complaint_id, created_date, created_date_time, created_by_user_id, owned_by_user_id
           , sector_id, closed_date, closed_flag, closed_same_day_flag, hand_off_date, hand_off_flag, hand_off_user_id
           , hand_off_from_user_id, last_progressed_by_user_id, reopen_date, pre_reopen_user_id, reopen_user_id
           , reopen_flag, summary, cr_role_desc, ow_role_desc, ho_role_desc, pro_role_desc, ro_role_desc
           , creator_rank, owner_rank, hand_off_from_rank, pre_reopen_rank, reopen_rank
           , rn, expected_bucket
           , CASE WHEN owner_rank = 1 
                       AND hand_off_flag = 'Y' 
                       AND hand_off_from_rank = 1 
                       AND closed_flag = 'N' THEN '2a'             -- With FL, handed off to another FL (not closed, peer change)
                  ELSE '-1'                                        -- Could not classify complaint into any given bucket
           END AS bucket
    FROM   base_data
)
    SELECT   complaint_id, created_date, created_by_user_id, owned_by_user_id
           , sector_id, closed_date, closed_flag, closed_same_day_flag, hand_off_date, hand_off_flag, hand_off_user_id
           , hand_off_from_user_id, last_progressed_by_user_id, reopen_date, pre_reopen_user_id, reopen_user_id
           , reopen_flag, summary, cr_role_desc, ow_role_desc, ho_role_desc, pro_role_desc, ro_role_desc
           , creator_rank, owner_rank, hand_off_from_rank, pre_reopen_rank, reopen_rank, rn
           , expected_bucket, bucket
           , CASE WHEN expected_bucket = bucket
                  THEN 'Y'
                  ELSE 'N'
             END AS result_check
           , CASE WHEN TO_CHAR (SYSDATE, 'D') = '1' -- As if it had been run on Mondays
                  THEN TRUNC (SYSDATE)
                  ELSE NEXT_DAY (TRUNC (SYSDATE + 7), 'Monday') -7
             END AS analysis_date
    FROM   classify
    WHERE  rn = 1 -- Take the last action's result only
    ORDER BY complaint_id, hand_off_date
;
