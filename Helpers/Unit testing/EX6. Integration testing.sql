WITH reopen_src AS (
    SELECT   c.complaint_id
           , cst.complaint_state_type_id     AS action_type_id
           , csi.start_date                  AS state_start_date
           , TRIM (cah.user_id)              AS action_user_id
           , LAG (cst.complaint_state_type_id) OVER (PARTITION BY c.complaint_id
                  ORDER BY csi.complaint_state_instance_id) AS prev_action_type_id
    FROM   HDS_T_COMP_COMPLAINT                c,
           HDS_T_COMP_COMPL_STATE_INST         csi, -- State is used rather than action history
           HDS_T_COMP_COMPLAINT_STATE          cs,
           HDS_T_COMP_COMPL_STATE_TYPE         cst, -- Only two types: Open & Close
           HDS_T_COMP_COMPL_ACTION_HIST        cah
    WHERE  c.complaint_id                      = csi.complaint_id
           AND csi.complaint_state_id          = cs.complaint_state_id
           AND cs.complaint_state_type_id      = cst.complaint_state_type_id
           AND csi.complaint_action_history_id = cah.complaint_action_history_id
           AND c.to_date IS NULL
           AND csi.to_date IS NULL
           AND cs.to_date IS NULL
           AND cst.to_date IS NULL
           AND cah.to_date IS NULL
           AND c.complaint_id = -1 -- Remove this once view is final
),
reopens AS (
    SELECT   complaint_id
           , action_user_id
           , CASE WHEN action_type_id = 2 AND prev_action_type_id = 1
                  THEN state_start_date
                  ELSE NULL
             END AS reopen_date
           , CASE WHEN action_type_id = 2 AND prev_action_type_id = 1 -- When Open is followed by a Close
                  THEN LAG (action_user_id) OVER (PARTITION BY complaint_id ORDER BY state_start_date)
                  ELSE NULL
             END AS pre_reopen_user_id
           , CASE WHEN action_type_id = 2 AND prev_action_type_id = 1
                  THEN 'Y'
                  ELSE 'N'
             END AS reopen_flag
           , CASE WHEN action_type_id = 2 AND prev_action_type_id = 1
                  THEN action_user_id
                  ELSE NULL
             END AS reopen_user_id
    FROM   reopen_src
),
last_reopen AS (
    SELECT   complaint_id
           , reopen_date
           , pre_reopen_user_id
           , reopen_user_id
           , MAX (reopen_date) OVER (PARTITION BY complaint_id) AS latest_reopen_date
    FROM  reopens
    WHERE reopen_flag = 'Y'
),
reopen_set AS (
    SELECT complaint_id
           , reopen_date
           , pre_reopen_user_id
           , reopen_user_id
    FROM   last_reopen
    WHERE  latest_reopen_date = reopen_date
    UNION ALL
    SELECT complaint_id
           , reopen_date
           , pre_reopen_user_id
           , reopen_user_id
    FROM   aml_t_complaints_reopen_cr -- My test data sits in here
),
src AS (
    SELECT   c.complaint_id
           , c.created_date
           , created_date_time
           , c.created_by_user_id
           , LOWER (croda.job_role_description) AS cr_role_desc -- Creator role
           , croda.is_manager AS cr_is_manager
           , c.owned_by_user_id
           , c.sector_id
           , c.closed_date
           , c.closed_flag
           , c.closed_same_day_flag
           , CASE WHEN ho.complaint_id IS NOT NULL
                  THEN 'Y'
                  ELSE 'N'
             END AS hand_off_flag
           , ho.hand_off_date
           , ho.hand_off_user_id
           , ho.hand_off_from_user_id
           , NVL (ho.hand_off_from_user_id, c.owned_by_user_id) AS last_progressed_by_user_id
           , reopen_date
           , ro.pre_reopen_user_id
           , ro.reopen_user_id
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
           LEFT JOIN reopen_set                  ro -- Reopens
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
progressed AS (
    SELECT   complaint_id, created_date, created_date_time, created_by_user_id, owned_by_user_id
           , sector_id, closed_date, closed_flag, closed_same_day_flag, hand_off_date, hand_off_flag, hand_off_user_id
           , hand_off_from_user_id, last_progressed_by_user_id, reopen_date, pre_reopen_user_id, reopen_user_id
           , reopen_flag, summary, expected_bucket, cr_role_desc, ow_role_desc, ho_role_desc, pro_role_desc, ro_role_desc
           , creator_rank, owner_rank, hand_off_from_rank, pre_reopen_rank, reopen_rank, rn
           , CASE WHEN owner_rank <> -1                                    -- Did not hand off to Manager
                       AND (hand_off_from_rank = owner_rank                -- Peer change
                            OR (hand_off_from_rank = 1 AND owner_rank = 2) -- FL -> RM
                            OR (hand_off_from_rank = 1 AND owner_rank = 3) -- FL -> RR (skipping RM)
                            OR (hand_off_from_rank = 2 AND owner_rank = 3) -- RM -> RR
                            OR (hand_off_from_rank = 2 AND owner_rank = 4) -- RM -> OT (skipping RR) 
                            OR (hand_off_from_rank = 3 AND owner_rank = 4) -- RR -> OT
                            OR (hand_off_from_rank = 0)                    -- No hand off
                            OR (owner_rank - hand_off_from_rank < 0 AND owner_rank <> -1) -- Progressed backwards
                           )
                  THEN 'N'
                  ELSE 'Y'
             END AS ipf_bucket -- Incorrectly progressed forwards indicator
           , CASE WHEN owner_rank - hand_off_from_rank < 0 -- Lower ranked received it from a higher ranked one (OT -> RR, OT -> RM, OT -> FL, RR -> RM, RR -> FL, RM -> FL)
                       AND owner_rank <> -1 -- Current owner is not manager (that drops into incorrectly progressed forwards)
                  THEN 'Y'
                  ELSE 'N'
             END AS ipb_bucket -- Incorrectly progressed backwards indicator
    FROM   base_data
),
exception_users AS (
    SELECT   complaint_id, created_date, created_date_time, created_by_user_id, owned_by_user_id
           , sector_id, closed_date, closed_flag, closed_same_day_flag, hand_off_date, hand_off_flag, hand_off_user_id
           , hand_off_from_user_id, last_progressed_by_user_id, reopen_date, pre_reopen_user_id, reopen_user_id
           , reopen_flag, summary, cr_role_desc, ow_role_desc, ho_role_desc, pro_role_desc, ro_role_desc
           , creator_rank, owner_rank, hand_off_from_rank, pre_reopen_rank, reopen_rank 
           , CASE WHEN ipf_bucket = 'Y' 
                  THEN MAX (hand_off_from_rank) KEEP (DENSE_RANK FIRST ORDER BY ipf_bucket DESC, hand_off_date ASC) OVER (PARTITION BY complaint_id)
                  ELSE NULL 
             END AS ipf_exception_user_rank
           , CASE WHEN ipb_bucket = 'Y' 
                  THEN MAX (owner_rank) KEEP (DENSE_RANK FIRST ORDER BY ipb_bucket DESC, hand_off_date ASC) OVER (PARTITION BY complaint_id)
                  ELSE NULL 
             END AS ipb_exception_user_rank
           , CASE WHEN reopen_flag = 'Y' 
                  THEN MAX (pre_reopen_rank) KEEP (DENSE_RANK FIRST ORDER BY reopen_date ASC) OVER (PARTITION BY complaint_id)
                  ELSE NULL 
             END AS ro_exception_user_rank
           , rn
           , ipf_bucket, ipb_bucket, expected_bucket
    FROM   progressed
),
classify AS (
    SELECT   complaint_id, created_date, created_date_time, created_by_user_id, owned_by_user_id
           , sector_id, closed_date, closed_flag, closed_same_day_flag, hand_off_date, hand_off_flag, hand_off_user_id
           , hand_off_from_user_id, last_progressed_by_user_id, reopen_date, pre_reopen_user_id, reopen_user_id
           , reopen_flag, summary, cr_role_desc, ow_role_desc, ho_role_desc, pro_role_desc, ro_role_desc
           , creator_rank, owner_rank, hand_off_from_rank, pre_reopen_rank, reopen_rank
           , ipf_exception_user_rank, ipb_exception_user_rank, ro_exception_user_rank, rn, ipf_bucket, ipb_bucket, expected_bucket
           , CASE WHEN ipb_bucket = 'Y' THEN                       -- Incorrectly progressed backwards complaints
                  CASE WHEN ipb_exception_user_rank = 1 THEN 'X01' -- FL has it, returned by RM, RR or OT
                       WHEN ipb_exception_user_rank = 2 THEN 'X02' -- RM has it, returned by RR or OT
                       WHEN ipb_exception_user_rank = 3 THEN 'X03' -- RR has it, returned by OT
                       ELSE '-3'                                   -- Incorrectly progressed backwards but could not classified in any bucket
                  END
                  WHEN ipf_bucket = 'Y' THEN                       -- Incorrectly progressed forwards complaints
                  CASE WHEN ipf_exception_user_rank = 1 THEN '7'   -- FL progressed incorrectly
                       WHEN ipf_exception_user_rank = 2 THEN '13'  -- RM progressed incorrectly
                       WHEN ipf_exception_user_rank = 3 THEN '18'  -- RR progressed incorrectly
                       WHEN ipf_exception_user_rank = 4 THEN '22'  -- OT progressed incorrectly
                       ELSE '-2'                                   -- Incorrectly progressed forwards but could not classified in any bucket
                  END
                  WHEN ro_exception_user_rank IS NOT NULL THEN     -- Reopen occurred (first reopen counts!)
                  CASE WHEN ro_exception_user_rank = 1 THEN '4'    -- Closed by FL then reopened (by anyone)
                       WHEN ro_exception_user_rank = 2 THEN '10'   -- Closed by RM then reopened (by anyone)
                       WHEN ro_exception_user_rank = 3 THEN '16'   -- Closed by RR then reopened (by anyone)
                       WHEN ro_exception_user_rank = 4 THEN '21'   -- Closed by OT then reopened (by anyone)
                  END
                  WHEN owner_rank = 1                              -- Correctly progressed cases only
                       AND hand_off_flag = 'N' 
                       AND closed_flag = 'N' THEN '2'              -- With FL, not handed off and not closed
                  WHEN owner_rank = 1 
                       AND hand_off_flag = 'Y' 
                       AND hand_off_from_rank = 1 
                       AND closed_flag = 'N' THEN '2a'             -- With FL, handed off to another FL (not closed, peer change)
                  WHEN owner_rank = 1
                       AND closed_flag = 'Y'
                       AND TRUNC (NVL (hand_off_date, created_date_time))
                           = TRUNC (closed_date) THEN '3'          -- With FL, closed same day
                       -- AND closed_same_day_flag = 'Y' THEN '3'     -- With FL, closed same day
                  WHEN owner_rank = 1
                       AND closed_flag = 'Y'
                       AND TRUNC (NVL (hand_off_date, created_date_time)) 
                           <> TRUNC (closed_date) THEN '3a'        -- With FL, closed but not same day
                  WHEN pre_reopen_rank = 1
                       AND reopen_flag = 'Y' THEN '4'              -- Closed by FL then reopened (by anyone)
                  WHEN owner_rank = 2
                       AND hand_off_flag = 'Y'
                       AND hand_off_from_rank = 1
                       AND reopen_flag = 'N'
                       AND closed_flag = 'N' THEN '5'              -- With RM, progressed from FL
                  WHEN owner_rank = 2
                       AND hand_off_flag = 'Y'
                       AND hand_off_from_rank = 2
                       AND reopen_flag = 'N'
                       AND closed_flag = 'N' THEN '5a'             -- With RM, progressed to another RM (not closed, peer change)
                  WHEN owner_rank = 2
                       AND creator_rank = 2
                       AND hand_off_flag = 'N'
                       AND closed_flag = 'N' THEN '5b'             -- With RM, created by RM
                  WHEN owner_rank = 3
                       AND hand_off_flag = 'Y'
                       AND hand_off_from_rank = 1
                       AND closed_flag = 'N' THEN '6'              -- With RR, progressed from FL (skipping RM)
                  WHEN owner_rank = 2
                       AND closed_flag = 'Y'
                       AND TRUNC (NVL (hand_off_date, created_date_time)) -- In case there was no hand-off
                           = TRUNC (closed_date) THEN '9'          -- With RM, closed same day
                  WHEN owner_rank = 2
                       AND closed_flag = 'Y'
                       AND TRUNC (NVL (hand_off_date, created_date_time)) 
                           <> TRUNC (closed_date) THEN '9a'        -- With RM, closed but not same day
                  WHEN pre_reopen_rank = 2
                       AND reopen_flag = 'Y' 
                       AND closed_flag = 'N' THEN '10'             -- Closed by RM then reopened (by anyone)
                  WHEN owner_rank = 3
                       AND hand_off_flag = 'Y'
                       AND hand_off_from_rank = 2
                       AND reopen_flag = 'N'
                       AND closed_flag = 'N' THEN '11'             -- With RR, progressed from RM
                  WHEN owner_rank = 3
                       AND hand_off_flag = 'Y'
                       AND hand_off_from_rank = 3
                       AND reopen_flag = 'N'
                       AND closed_flag = 'N' THEN '11a'            -- With RR, progressed to another RR (peer change)
                  WHEN owner_rank = 3
                       AND creator_rank = 3
                       AND hand_off_flag = 'N'
                       AND closed_flag = 'N' THEN '11b'            -- With RR, created by RR
                  WHEN owner_rank = 3
                       AND closed_flag = 'Y'
                       AND TRUNC (NVL (hand_off_date, created_date_time)) -- In case there was no hand-off
                           = TRUNC (closed_date) THEN '15'         -- With RR, closed same day
                  WHEN owner_rank = 3
                       AND closed_flag = 'Y'
                       AND TRUNC (NVL (hand_off_date, created_date_time)) 
                           <> TRUNC (closed_date) THEN '15a'       -- With RR, closed but not same day
                  WHEN pre_reopen_rank = 3
                       AND reopen_flag = 'Y' THEN '16'             -- Closed by RR then reopened (by anyone)
                  WHEN owner_rank = 4
                       AND hand_off_flag = 'Y'
                       AND (hand_off_from_rank = 2 OR hand_off_from_rank = 3)
                       AND reopen_flag = 'N'
                       AND closed_flag = 'N' THEN '17'             -- With OT, progressed from RM or RR
                  WHEN owner_rank = 4
                       AND hand_off_flag = 'Y'
                       AND hand_off_from_rank = 4
                       AND reopen_flag = 'N'
                       AND closed_flag = 'N' THEN '17a'            -- With OT, progressed to another OT (peer change)
                  WHEN owner_rank = 4
                       AND creator_rank = 4
                       AND hand_off_flag = 'N'
                       AND closed_flag = 'N' THEN '17b'            -- With OT, created by OT
                  WHEN owner_rank = 4
                       AND closed_flag = 'Y'
                       AND TRUNC (NVL (hand_off_date, created_date_time)) 
                           = TRUNC (closed_date) THEN '20'         -- With OT, closed same day
                  WHEN owner_rank = 4
                       AND closed_flag = 'Y'
                       AND TRUNC (NVL (hand_off_date, created_date_time)) 
                           <> TRUNC (closed_date) THEN '20a'       -- With OT, closed but not same day
                  WHEN pre_reopen_rank = 4
                       AND reopen_flag = 'Y' THEN '21'             -- Closed by OT then reopened (by anyone)
                  ELSE '-1'                                        -- Could not classify complaint into any given bucket
           END AS bucket
    FROM   exception_users
)
    SELECT   complaint_id, created_date, created_by_user_id, owned_by_user_id
           , sector_id, closed_date, closed_flag, closed_same_day_flag, hand_off_date, hand_off_flag, hand_off_user_id
           , hand_off_from_user_id, last_progressed_by_user_id, reopen_date, pre_reopen_user_id, reopen_user_id
           , reopen_flag, summary, cr_role_desc, ow_role_desc, ho_role_desc, pro_role_desc, ro_role_desc
           , creator_rank, owner_rank, hand_off_from_rank, pre_reopen_rank, reopen_rank, rn
           , ipf_exception_user_rank, ipb_exception_user_rank, ro_exception_user_rank, ipf_bucket, ipb_bucket, expected_bucket, bucket
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
