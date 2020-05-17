
--  Creator only
    SELECT   c.complaint_id, c.created_date, created_date_time
           , c.created_by_user_id
           , LOWER (croda.job_role_description) AS cr_role_desc -- Creator role
           , croda.is_manager AS cr_is_manager, c.owned_by_user_id, c.sector_id, c.closed_date
           , c.closed_flag, c.closed_same_day_flag
    FROM   aml_t_complaints_created_cr            c
           LEFT JOIN dim_t_oda_user_flat_cr   croda -- Creator
             ON croda.user_id = c.created_by_user_id
                AND TRUNC (c.created_date) BETWEEN croda.dw_from_date AND croda.dw_to_date
    WHERE  c.dw_to_date = TO_DATE ('31/12/9999', 'DD/MM/YYYY')
           AND c.created_date BETWEEN TO_DATE ('30/07/2014', 'DD/MM/YYYY') AND SYSDATE


-- Creator, owner, hand-off user
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
           , LOWER (owoda.job_role_description) AS ow_role_desc -- Owner, hand off user role
           , owoda.is_manager AS ow_is_manager
           , LOWER (hooda.job_role_description) AS ho_role_desc -- Hand off from user role
           , hooda.is_manager AS ho_is_manager
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
    WHERE  c.dw_to_date = TO_DATE ('31/12/9999', 'DD/MM/YYYY')
           AND c.created_date BETWEEN TO_DATE ('30/07/2014', 'DD/MM/YYYY') AND SYSDATE


-- Creator, owner, hand-off user, reopen user
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
