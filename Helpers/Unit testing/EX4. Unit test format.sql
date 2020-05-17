-- ---------------------------------------------------------------------------
--                Unit test script for
-- Object Name:   stg_aml_v_complaints_hwc_det
-- Suite/Process: Complaints MI
-- Purpose:       Setup unit test data for Complaints phase II HWC to test
--                whether the code is fit for its purpose to classify complaints
--                into individual buckets that relate to their movements/status
--                through the complaint journey
--
-- Change History
-- Date          Author             Description
-- ===========   =================  ==========================================
-- 25-AUG-2014   Csaba Riedlinger   Initial Version.
-- 28-AUG-2014   Csaba Riedlinger   Added Bucket 1. test

-- ************
-- Create table
-- ************

-- Complaints core
CREATE TABLE AML_T_COMPLAINTS_CREATED_CR
  (DW_FROM_DATE         DATE NOT NULL ENABLE, 
   DW_TO_DATE           DATE NOT NULL ENABLE, 
   CREATED_DATE         DATE NOT NULL ENABLE, 
   EFFECTIVE_FROM_DATE  DATE NOT NULL ENABLE, 
   COMPLAINT_ID         NUMBER(10,0) NOT NULL ENABLE, 
   FIN_ACC_REF          VARCHAR2(20), 
   CLOSED_DATE          DATE, 
   CLOSED_FLAG          VARCHAR2(1) NOT NULL ENABLE, 
   CLOSED_SAME_DAY_FLAG VARCHAR2(1) NOT NULL ENABLE, 
   OWNED_BY_USER_ID     VARCHAR2(7) NOT NULL ENABLE, 
   SECTOR_ID            NUMBER, 
   OMBUDSMAN_COMPLAINT_INDICATOR VARCHAR2(1) NOT NULL ENABLE, 
   CREATED_DATE_TIME    DATE NOT NULL ENABLE, 
   HAND_OFF_FLAG        VARCHAR2(1) NOT NULL ENABLE, 
   REOPEN_FLAG          VARCHAR2(1) NOT NULL ENABLE, 
   CREATED_BY_USER_ID   VARCHAR2(7), 
   SUMMARY              VARCHAR2(4000), 
   EXPECTED_BUCKET      VARCHAR2(3) NOT NULL ENABLE, 
 CONSTRAINT AML_T_COMPLAINTS_CREATED_PK PRIMARY KEY (COMPLAINT_ID, FIN_ACC_REF)
 USING INDEX ENABLE
  )
;

-- Users
CREATE TABLE DIM_T_ODA_USER_FLAT_CR 
  (DW_FROM_DATE         DATE, 
   DW_TO_DATE           DATE, 
   USER_ID              VARCHAR2(40), 
   USER_NAME            VARCHAR2(4000), 
   JOB_ROLE_DESCRIPTION VARCHAR2(80), 
   IS_MANAGER           VARCHAR2(1)
  )
;

-- Hand-offs
CREATE TABLE AML_T_COMPLAINTS_HANDOFF_CR 
  (COMPLAINT_ID          NUMBER, 
   HAND_OFF_DATE         DATE NOT NULL ENABLE, 
   HAND_OFF_USER_ID      VARCHAR2(7), 
   HAND_OFF_FROM_USER_ID VARCHAR2(7)
  )
;

-- Reopens
CREATE TABLE AML_T_COMPLAINTS_REOPEN_CR 
  (COMPLAINT_ID       NUMBER, 
   REOPEN_DATE        DATE, 
   PRE_REOPEN_USER_ID VARCHAR2(7), 
   REOPEN_USER_ID     VARCHAR2(7)
  )
;


-- Data setup
-- *******
-- INSERTS
-- *******

-- Users
-- Front lines
TRUNCATE TABLE DIM_T_ODA_USER_FLAT_CR ;

INSERT INTO DIM_T_ODA_USER_FLAT_CR
       (dw_from_date, dw_to_date, 
        user_id, user_name, job_role_description, is_manager)
VALUES (TO_DATE ('01/01/2014', 'DD/MM/YYYY'), TO_DATE ('31/12/9999', 'DD/MM/YYYY'), 
        'FL0001', 'Front line 1', 'Front Line user', 'N') ;

INSERT INTO DIM_T_ODA_USER_FLAT_CR
       (dw_from_date, dw_to_date, 
        user_id, user_name, job_role_description, is_manager)
VALUES (TO_DATE ('01/01/2014', 'DD/MM/YYYY'), TO_DATE ('31/12/9999', 'DD/MM/YYYY'), 
        'FL0002', 'Front line 2', 'Front Line user', 'N') ;

INSERT INTO DIM_T_ODA_USER_FLAT_CR
       (dw_from_date, dw_to_date, 
        user_id, user_name, job_role_description, is_manager)
VALUES (TO_DATE ('01/01/2014', 'DD/MM/YYYY'), TO_DATE ('31/12/9999', 'DD/MM/YYYY'), 
        'FL0003', 'Front line 3', 'Front Line user', 'N') ;

-- Resolution Managers
INSERT INTO DIM_T_ODA_USER_FLAT_CR
       (dw_from_date, dw_to_date, 
        user_id, user_name, job_role_description, is_manager)
VALUES (TO_DATE ('01/01/2014', 'DD/MM/YYYY'), TO_DATE ('31/12/9999', 'DD/MM/YYYY'), 
        'RM0001', 'RM 1', 'Complaints Resolution Manager', 'N') ;

INSERT INTO DIM_T_ODA_USER_FLAT_CR
       (dw_from_date, dw_to_date, 
        user_id, user_name, job_role_description, is_manager)
VALUES (TO_DATE ('01/01/2014', 'DD/MM/YYYY'), TO_DATE ('31/12/9999', 'DD/MM/YYYY'), 
        'RM0002', 'RM 2', 'Complaints Resolution Manager', 'N') ;

-- Resolution Reviewers
INSERT INTO DIM_T_ODA_USER_FLAT_CR
       (dw_from_date, dw_to_date, 
        user_id, user_name, job_role_description, is_manager)
VALUES (TO_DATE ('01/01/2014', 'DD/MM/YYYY'), TO_DATE ('31/12/9999', 'DD/MM/YYYY'), 
        'RR0001', 'RR 1', 'Complaints Resolution Reviewer', 'N') ;

INSERT INTO DIM_T_ODA_USER_FLAT_CR
       (dw_from_date, dw_to_date, 
        user_id, user_name, job_role_description, is_manager)
VALUES (TO_DATE ('01/01/2014', 'DD/MM/YYYY'), TO_DATE ('31/12/9999', 'DD/MM/YYYY'), 
        'RR0002', 'RR 2', 'Complaints Resolution Reviewer', 'N') ;

-- Ombudsman Team
INSERT INTO DIM_T_ODA_USER_FLAT_CR
       (dw_from_date, dw_to_date, 
        user_id, user_name, job_role_description, is_manager)
VALUES (TO_DATE ('01/01/2014', 'DD/MM/YYYY'), TO_DATE ('31/12/9999', 'DD/MM/YYYY'), 
        'OT0001', 'OT 1', 'Ombudsman liaison', 'N') ;

INSERT INTO DIM_T_ODA_USER_FLAT_CR
       (dw_from_date, dw_to_date, 
        user_id, user_name, job_role_description, is_manager)
VALUES (TO_DATE ('01/01/2014', 'DD/MM/YYYY'), TO_DATE ('31/12/9999', 'DD/MM/YYYY'), 
        'OT0002', 'OT 2', 'Ombudsman liaison', 'N') ;
        
-- Managers
INSERT INTO DIM_T_ODA_USER_FLAT_CR
       (dw_from_date, dw_to_date, 
        user_id, user_name, job_role_description, is_manager)
VALUES (TO_DATE ('01/01/2014', 'DD/MM/YYYY'), TO_DATE ('31/12/9999', 'DD/MM/YYYY'), 
        'MG0001', 'MG 1', 'Manager', 'Y') ;

INSERT INTO DIM_T_ODA_USER_FLAT_CR
       (dw_from_date, dw_to_date, 
        user_id, user_name, job_role_description, is_manager)
VALUES (TO_DATE ('01/01/2014', 'DD/MM/YYYY'), TO_DATE ('31/12/9999', 'DD/MM/YYYY'), 
        'MG0002', 'MG 2', 'Manager', 'Y') ;

COMMIT ;

-- *******************************
-- Complaints, hand-offs, re-opens
TRUNCATE TABLE AML_T_COMPLAINTS_CREATED_CR ;
TRUNCATE TABLE AML_T_COMPLAINTS_HANDOFF_CR ;
TRUNCATE TABLE AML_T_COMPLAINTS_REOPEN_CR ;

-- Bucket 2. Not progressed by FL
INSERT INTO AML_T_COMPLAINTS_CREATED_CR
(complaint_id, fin_acc_ref, dw_from_date, dw_to_date, created_date, effective_from_date, created_date_time,
 closed_date, closed_flag, closed_same_day_flag, hand_off_flag, reopen_flag,
 created_by_user_id, owned_by_user_id, sector_id, ombudsman_complaint_indicator, summary, expected_bucket)
VALUES (1, '1', TO_DATE ('01/08/2014', 'DD/MM/YYYY'), TO_DATE ('31/12/9999', 'DD/MM/YYYY'), TO_DATE ('30/07/2014', 'DD/MM/YYYY'), TO_DATE ('30/07/2014', 'DD/MM/YYYY'), TO_DATE ('30/07/2014 10:10:10', 'DD/MM/YYYY HH24:MI:SS'),
        NULL, 'N', 'N', 'N', 'N',
        'FL0001', 'FL0001', 1, 'N',
        'Bucket 2. Not progressed by FL', '2') ;

-- Bucket 2a. FL peer change
INSERT INTO AML_T_COMPLAINTS_CREATED_CR
(complaint_id, fin_acc_ref, dw_from_date, dw_to_date, created_date, effective_from_date, created_date_time,
 closed_date, closed_flag, closed_same_day_flag, hand_off_flag, reopen_flag,
 created_by_user_id, owned_by_user_id, sector_id, ombudsman_complaint_indicator, summary, expected_bucket)
VALUES (2, '2', TO_DATE ('01/08/2014', 'DD/MM/YYYY'), TO_DATE ('31/12/9999', 'DD/MM/YYYY'), TO_DATE ('30/07/2014', 'DD/MM/YYYY'), TO_DATE ('30/07/2014', 'DD/MM/YYYY'), TO_DATE ('30/07/2014 10:10:10', 'DD/MM/YYYY HH24:MI:SS'),
        NULL, 'N', 'N', 'Y', 'N',
        'FL0001', 'FL0002', 1, 'N',
        'Bucket 2a. FL peer change', '2a') ;

INSERT INTO AML_T_COMPLAINTS_HANDOFF_CR
   (COMPLAINT_ID, HAND_OFF_DATE, HAND_OFF_USER_ID, HAND_OFF_FROM_USER_ID)
VALUES (2, TO_DATE ('02/08/2014 11:20:45', 'DD/MM/YYYY HH24:MI:SS'), 'FL0002', 'FL0001') ;

-- Bucket 3. Closed same day by FL
INSERT INTO AML_T_COMPLAINTS_CREATED_CR
(complaint_id, fin_acc_ref, dw_from_date, dw_to_date, created_date, effective_from_date, created_date_time,
 closed_date, closed_flag, closed_same_day_flag, hand_off_flag, reopen_flag,
 created_by_user_id, owned_by_user_id, sector_id, ombudsman_complaint_indicator, summary, expected_bucket)
VALUES (3, '2', TO_DATE ('01/08/2014', 'DD/MM/YYYY'), TO_DATE ('31/12/9999', 'DD/MM/YYYY'), TO_DATE ('30/07/2014', 'DD/MM/YYYY'), TO_DATE ('30/07/2014', 'DD/MM/YYYY'), TO_DATE ('30/07/2014 10:10:10', 'DD/MM/YYYY HH24:MI:SS'),
        TO_DATE ('30/07/2014', 'DD/MM/YYYY'), 'Y', 'Y', 'Y', 'N',
        'FL0001', 'FL0002', 1, 'N',
        'Bucket 3. Closed same day by FL', '3') ;

INSERT INTO AML_T_COMPLAINTS_HANDOFF_CR
   (COMPLAINT_ID, HAND_OFF_DATE, HAND_OFF_USER_ID, HAND_OFF_FROM_USER_ID)
VALUES (3, TO_DATE ('30/07/2014 11:20:45', 'DD/MM/YYYY HH24:MI:SS'), 'FL0002', 'FL0001') ;

-- Bucket 3a. Closed but not the same day by FL
INSERT INTO AML_T_COMPLAINTS_CREATED_CR
(complaint_id, fin_acc_ref, dw_from_date, dw_to_date, created_date, effective_from_date, created_date_time,
 closed_date, closed_flag, closed_same_day_flag, hand_off_flag, reopen_flag,
 created_by_user_id, owned_by_user_id, sector_id, ombudsman_complaint_indicator, summary, expected_bucket)
VALUES (4, '4', TO_DATE ('01/08/2014', 'DD/MM/YYYY'), TO_DATE ('31/12/9999', 'DD/MM/YYYY'), TO_DATE ('30/07/2014', 'DD/MM/YYYY'), TO_DATE ('30/07/2014', 'DD/MM/YYYY'), TO_DATE ('30/07/2014 10:10:10', 'DD/MM/YYYY HH24:MI:SS'),
        TO_DATE ('03/08/2014', 'DD/MM/YYYY'), 'Y', 'N', 'Y', 'N',
        'FL0001', 'FL0002', 1, 'N',
        'Bucket 3a. Closed but not the same day by FL', '3a') ;

INSERT INTO AML_T_COMPLAINTS_HANDOFF_CR
   (COMPLAINT_ID, HAND_OFF_DATE, HAND_OFF_USER_ID, HAND_OFF_FROM_USER_ID)
VALUES (4, TO_DATE ('02/08/2014 11:20:45', 'DD/MM/YYYY HH24:MI:SS'), 'FL0002', 'FL0001') ;

-- Bucket 4. Closed (same day or not) by FL then reopened
INSERT INTO AML_T_COMPLAINTS_CREATED_CR
(complaint_id, fin_acc_ref, dw_from_date, dw_to_date, created_date, effective_from_date, created_date_time,
 closed_date, closed_flag, closed_same_day_flag, hand_off_flag, reopen_flag,
 created_by_user_id, owned_by_user_id, sector_id, ombudsman_complaint_indicator, summary, expected_bucket)
VALUES (5, '5', TO_DATE ('01/08/2014', 'DD/MM/YYYY'), TO_DATE ('31/12/9999', 'DD/MM/YYYY'), TO_DATE ('30/07/2014', 'DD/MM/YYYY'), TO_DATE ('30/07/2014', 'DD/MM/YYYY'), TO_DATE ('30/07/2014 10:10:15', 'DD/MM/YYYY HH24:MI:SS'),
        NULL, 'N', 'N', 'Y', 'Y',
        'FL0001', 'RM0001', 1, 'N',
        'Bucket 4. Closed (same day or not) by FL then reopened', '4') ;

INSERT INTO AML_T_COMPLAINTS_HANDOFF_CR
   (COMPLAINT_ID, HAND_OFF_DATE, HAND_OFF_USER_ID, HAND_OFF_FROM_USER_ID) 
VALUES (5, TO_DATE ('02/08/2014 11:30:45', 'DD/MM/YYYY HH24:MI:SS'), 'RM0001', 'FL0001') ;

INSERT INTO AML_T_COMPLAINTS_REOPEN_CR
 (complaint_id, reopen_date, pre_reopen_user_id, reopen_user_id)
 VALUES (5, TO_DATE ('05/08/2014 10:10:10', 'DD/MM/YYYY HH24:MI:SS'), 'FL0001', 'RM0001') ;

-- Bucket 5. Progressed from FL to RM
INSERT INTO AML_T_COMPLAINTS_CREATED_CR
(complaint_id, fin_acc_ref, dw_from_date, dw_to_date, created_date, effective_from_date, created_date_time,
 closed_date, closed_flag, closed_same_day_flag, hand_off_flag, reopen_flag,
 created_by_user_id, owned_by_user_id, sector_id, ombudsman_complaint_indicator, summary, expected_bucket)
VALUES (6, '6', TO_DATE ('01/08/2014', 'DD/MM/YYYY'), TO_DATE ('31/12/9999', 'DD/MM/YYYY'), TO_DATE ('30/07/2014', 'DD/MM/YYYY'), TO_DATE ('30/07/2014', 'DD/MM/YYYY'), TO_DATE ('30/07/2014 10:10:15', 'DD/MM/YYYY HH24:MI:SS'),
        NULL, 'N', 'N', 'Y', 'N',
        'FL0001', 'RM0001', 1, 'N',
        'Bucket 5. Progressed from FL to RM', '5') ;

INSERT INTO AML_T_COMPLAINTS_HANDOFF_CR
   (COMPLAINT_ID, HAND_OFF_DATE, HAND_OFF_USER_ID, HAND_OFF_FROM_USER_ID) 
VALUES (6, TO_DATE ('02/08/2014 11:30:45', 'DD/MM/YYYY HH24:MI:SS'), 'RM0001', 'FL0001') ;

-- Bucket 5a. RM peer change
INSERT INTO AML_T_COMPLAINTS_CREATED_CR
(complaint_id, fin_acc_ref, dw_from_date, dw_to_date, created_date, effective_from_date, created_date_time,
 closed_date, closed_flag, closed_same_day_flag, hand_off_flag, reopen_flag,
 created_by_user_id, owned_by_user_id, sector_id, ombudsman_complaint_indicator, summary, expected_bucket)
VALUES (7, '7', TO_DATE ('01/08/2014', 'DD/MM/YYYY'), TO_DATE ('31/12/9999', 'DD/MM/YYYY'), TO_DATE ('30/07/2014', 'DD/MM/YYYY'), TO_DATE ('30/07/2014', 'DD/MM/YYYY'), TO_DATE ('30/07/2014 10:10:15', 'DD/MM/YYYY HH24:MI:SS'),
        NULL, 'N', 'N', 'Y', 'N',
        'RM0001', 'RM0002', 1, 'N',
        'Bucket 5a. RM peer change', '5a') ;

INSERT INTO AML_T_COMPLAINTS_HANDOFF_CR
   (COMPLAINT_ID, HAND_OFF_DATE, HAND_OFF_USER_ID, HAND_OFF_FROM_USER_ID) 
VALUES (7, TO_DATE ('02/08/2014 11:30:45', 'DD/MM/YYYY HH24:MI:SS'), 'RM0002', 'RM0001') ;

-- Bucket 5b. Created by RM and sits with RM, no peer change
INSERT INTO AML_T_COMPLAINTS_CREATED_CR
(complaint_id, fin_acc_ref, dw_from_date, dw_to_date, created_date, effective_from_date, created_date_time,
 closed_date, closed_flag, closed_same_day_flag, hand_off_flag, reopen_flag,
 created_by_user_id, owned_by_user_id, sector_id, ombudsman_complaint_indicator, summary, expected_bucket)
VALUES (8, '8', TO_DATE ('01/08/2014', 'DD/MM/YYYY'), TO_DATE ('31/12/9999', 'DD/MM/YYYY'), TO_DATE ('30/07/2014', 'DD/MM/YYYY'), TO_DATE ('30/07/2014', 'DD/MM/YYYY'), TO_DATE ('30/07/2014 10:10:15', 'DD/MM/YYYY HH24:MI:SS'),
        NULL, 'N', 'N', 'N', 'N',
        'RM0001', 'RM0001', 1, 'N',
        'Bucket 5b. Created by RM and sits with RM, no peer change', '5b') ;

-- Bucket 6. Progressed by FL to RR (skipping RM)
INSERT INTO AML_T_COMPLAINTS_CREATED_CR
(complaint_id, fin_acc_ref, dw_from_date, dw_to_date, created_date, effective_from_date, created_date_time,
 closed_date, closed_flag, closed_same_day_flag, hand_off_flag, reopen_flag,
 created_by_user_id, owned_by_user_id, sector_id, ombudsman_complaint_indicator, summary, expected_bucket)
VALUES (9, '9', TO_DATE ('01/08/2014', 'DD/MM/YYYY'), TO_DATE ('31/12/9999', 'DD/MM/YYYY'), TO_DATE ('30/07/2014', 'DD/MM/YYYY'), TO_DATE ('30/07/2014', 'DD/MM/YYYY'), TO_DATE ('30/07/2014 10:10:15', 'DD/MM/YYYY HH24:MI:SS'),
        NULL, 'N', 'N', 'N', 'N',
        'FL0001', 'RR0001', 1, 'N',
        'Bucket 6. Progressed by FL to RR (skipping RM)', '6') ;

INSERT INTO AML_T_COMPLAINTS_HANDOFF_CR
   (COMPLAINT_ID, HAND_OFF_DATE, HAND_OFF_USER_ID, HAND_OFF_FROM_USER_ID) 
VALUES (9, TO_DATE ('02/08/2014 11:30:45', 'DD/MM/YYYY HH24:MI:SS'), 'RR0001', 'FL0001') ;

-- Bucket 7. Incorrectly progressed (forwards) by FL (to OT)
INSERT INTO AML_T_COMPLAINTS_CREATED_CR
(complaint_id, fin_acc_ref, dw_from_date, dw_to_date, created_date, effective_from_date, created_date_time,
 closed_date, closed_flag, closed_same_day_flag, hand_off_flag, reopen_flag,
 created_by_user_id, owned_by_user_id, sector_id, ombudsman_complaint_indicator, summary, expected_bucket)
VALUES (10, '10', TO_DATE ('01/08/2014', 'DD/MM/YYYY'), TO_DATE ('31/12/9999', 'DD/MM/YYYY'), TO_DATE ('30/07/2014', 'DD/MM/YYYY'), TO_DATE ('30/07/2014', 'DD/MM/YYYY'), TO_DATE ('30/07/2014 10:10:15', 'DD/MM/YYYY HH24:MI:SS'),
        NULL, 'N', 'N', 'Y', 'N',
        'FL0001', 'OT0001', 1, 'N',
        'Bucket 7. Incorrectly progressed (forwards) by FL (to OT)', '7') ;

INSERT INTO AML_T_COMPLAINTS_HANDOFF_CR
   (COMPLAINT_ID, HAND_OFF_DATE, HAND_OFF_USER_ID, HAND_OFF_FROM_USER_ID) 
VALUES (10, TO_DATE ('02/08/2014 11:30:45', 'DD/MM/YYYY HH24:MI:SS'), 'FL0002', 'FL0001') ;

INSERT INTO AML_T_COMPLAINTS_HANDOFF_CR
   (COMPLAINT_ID, HAND_OFF_DATE, HAND_OFF_USER_ID, HAND_OFF_FROM_USER_ID) 
VALUES (10, TO_DATE ('02/08/2014 15:23:10', 'DD/MM/YYYY HH24:MI:SS'), 'OT0001', 'FL0002') ;

-- Bucket X01. Incorrectly progressed (backwards) by RM (to FL)
INSERT INTO AML_T_COMPLAINTS_CREATED_CR
(complaint_id, fin_acc_ref, dw_from_date, dw_to_date, created_date, effective_from_date, created_date_time,
 closed_date, closed_flag, closed_same_day_flag, hand_off_flag, reopen_flag,
 created_by_user_id, owned_by_user_id, sector_id, ombudsman_complaint_indicator, summary, expected_bucket)
VALUES (11, '11', TO_DATE ('01/08/2014', 'DD/MM/YYYY'), TO_DATE ('31/12/9999', 'DD/MM/YYYY'), TO_DATE ('30/07/2014', 'DD/MM/YYYY'), TO_DATE ('30/07/2014', 'DD/MM/YYYY'), TO_DATE ('30/07/2014 10:10:15', 'DD/MM/YYYY HH24:MI:SS'),
        NULL, 'N', 'N', 'Y', 'N',
        'FL0001', 'FL0002', 1, 'N',
        'Bucket X01. Incorrectly progressed (backwards) by RM (to FL)', 'X01') ;

INSERT INTO AML_T_COMPLAINTS_HANDOFF_CR
   (COMPLAINT_ID, HAND_OFF_DATE, HAND_OFF_USER_ID, HAND_OFF_FROM_USER_ID) 
VALUES (11, TO_DATE ('02/08/2014 11:30:45', 'DD/MM/YYYY HH24:MI:SS'), 'RM0001', 'FL0001') ;

INSERT INTO AML_T_COMPLAINTS_HANDOFF_CR
   (COMPLAINT_ID, HAND_OFF_DATE, HAND_OFF_USER_ID, HAND_OFF_FROM_USER_ID) 
VALUES (11, TO_DATE ('02/08/2014 15:23:10', 'DD/MM/YYYY HH24:MI:SS'), 'FL0002', 'RM0001') ;

-- Bucket X01. Incorrectly progressed (backwards) by RR (to FL)
INSERT INTO AML_T_COMPLAINTS_CREATED_CR
(complaint_id, fin_acc_ref, dw_from_date, dw_to_date, created_date, effective_from_date, created_date_time,
 closed_date, closed_flag, closed_same_day_flag, hand_off_flag, reopen_flag,
 created_by_user_id, owned_by_user_id, sector_id, ombudsman_complaint_indicator, summary, expected_bucket)
VALUES (12, '12', TO_DATE ('01/08/2014', 'DD/MM/YYYY'), TO_DATE ('31/12/9999', 'DD/MM/YYYY'), TO_DATE ('30/07/2014', 'DD/MM/YYYY'), TO_DATE ('30/07/2014', 'DD/MM/YYYY'), TO_DATE ('30/07/2014 10:10:15', 'DD/MM/YYYY HH24:MI:SS'),
        NULL, 'N', 'N', 'Y', 'N',
        'FL0001', 'FL0002', 1, 'N',
        'Bucket X01. Incorrectly progressed (backwards) by RR (to FL)', 'X01') ;

INSERT INTO AML_T_COMPLAINTS_HANDOFF_CR
   (COMPLAINT_ID, HAND_OFF_DATE, HAND_OFF_USER_ID, HAND_OFF_FROM_USER_ID) 
VALUES (12, TO_DATE ('02/08/2014 11:30:45', 'DD/MM/YYYY HH24:MI:SS'), 'RR0001', 'FL0001') ;

INSERT INTO AML_T_COMPLAINTS_HANDOFF_CR
   (COMPLAINT_ID, HAND_OFF_DATE, HAND_OFF_USER_ID, HAND_OFF_FROM_USER_ID) 
VALUES (12, TO_DATE ('02/08/2014 15:23:10', 'DD/MM/YYYY HH24:MI:SS'), 'FL0002', 'RR0001') ;

-- Bucket X01. Incorrectly progressed (backwards) by OT (to FL)
INSERT INTO AML_T_COMPLAINTS_CREATED_CR
(complaint_id, fin_acc_ref, dw_from_date, dw_to_date, created_date, effective_from_date, created_date_time,
 closed_date, closed_flag, closed_same_day_flag, hand_off_flag, reopen_flag,
 created_by_user_id, owned_by_user_id, sector_id, ombudsman_complaint_indicator, summary, expected_bucket)
VALUES (13, '13', TO_DATE ('01/08/2014', 'DD/MM/YYYY'), TO_DATE ('31/12/9999', 'DD/MM/YYYY'), TO_DATE ('30/07/2014', 'DD/MM/YYYY'), TO_DATE ('30/07/2014', 'DD/MM/YYYY'), TO_DATE ('30/07/2014 10:10:15', 'DD/MM/YYYY HH24:MI:SS'),
        NULL, 'N', 'N', 'Y', 'N',
        'FL0001', 'FL0002', 1, 'N',
        'Bucket X01. Incorrectly progressed (backwards) by OT (to FL)', 'X01') ;

INSERT INTO AML_T_COMPLAINTS_HANDOFF_CR
   (COMPLAINT_ID, HAND_OFF_DATE, HAND_OFF_USER_ID, HAND_OFF_FROM_USER_ID) 
VALUES (13, TO_DATE ('02/08/2014 11:30:45', 'DD/MM/YYYY HH24:MI:SS'), 'RM0001', 'FL0001') ;

INSERT INTO AML_T_COMPLAINTS_HANDOFF_CR
   (COMPLAINT_ID, HAND_OFF_DATE, HAND_OFF_USER_ID, HAND_OFF_FROM_USER_ID) 
VALUES (13, TO_DATE ('02/08/2014 15:23:10', 'DD/MM/YYYY HH24:MI:SS'), 'RR0002', 'RM0001') ;

INSERT INTO AML_T_COMPLAINTS_HANDOFF_CR
   (COMPLAINT_ID, HAND_OFF_DATE, HAND_OFF_USER_ID, HAND_OFF_FROM_USER_ID) 
VALUES (13, TO_DATE ('02/08/2014 16:23:10', 'DD/MM/YYYY HH24:MI:SS'), 'OT0001', 'RR0002') ;

INSERT INTO AML_T_COMPLAINTS_HANDOFF_CR
   (COMPLAINT_ID, HAND_OFF_DATE, HAND_OFF_USER_ID, HAND_OFF_FROM_USER_ID) 
VALUES (13, TO_DATE ('02/08/2014 17:23:10', 'DD/MM/YYYY HH24:MI:SS'), 'FL0002', 'OT0001') ;

-- Bucket X02. Incorrectly progressed (backwards) by RR (to RM)
INSERT INTO AML_T_COMPLAINTS_CREATED_CR
(complaint_id, fin_acc_ref, dw_from_date, dw_to_date, created_date, effective_from_date, created_date_time,
 closed_date, closed_flag, closed_same_day_flag, hand_off_flag, reopen_flag,
 created_by_user_id, owned_by_user_id, sector_id, ombudsman_complaint_indicator, summary, expected_bucket)
VALUES (14, '14', TO_DATE ('01/08/2014', 'DD/MM/YYYY'), TO_DATE ('31/12/9999', 'DD/MM/YYYY'), TO_DATE ('30/07/2014', 'DD/MM/YYYY'), TO_DATE ('30/07/2014', 'DD/MM/YYYY'), TO_DATE ('30/07/2014 10:10:15', 'DD/MM/YYYY HH24:MI:SS'),
        NULL, 'N', 'N', 'Y', 'N',
        'FL0001', 'RM0002', 1, 'N',
        'Bucket X02. Incorrectly progressed (backwards) by RR (to RM)', 'X02') ;

INSERT INTO AML_T_COMPLAINTS_HANDOFF_CR
   (COMPLAINT_ID, HAND_OFF_DATE, HAND_OFF_USER_ID, HAND_OFF_FROM_USER_ID) 
VALUES (14, TO_DATE ('02/08/2014 11:30:45', 'DD/MM/YYYY HH24:MI:SS'), 'RM0001', 'FL0001') ;

INSERT INTO AML_T_COMPLAINTS_HANDOFF_CR
   (COMPLAINT_ID, HAND_OFF_DATE, HAND_OFF_USER_ID, HAND_OFF_FROM_USER_ID) 
VALUES (14, TO_DATE ('02/08/2014 15:23:10', 'DD/MM/YYYY HH24:MI:SS'), 'RR0002', 'RM0001') ;

INSERT INTO AML_T_COMPLAINTS_HANDOFF_CR
   (COMPLAINT_ID, HAND_OFF_DATE, HAND_OFF_USER_ID, HAND_OFF_FROM_USER_ID) 
VALUES (14, TO_DATE ('02/08/2014 16:23:10', 'DD/MM/YYYY HH24:MI:SS'), 'RM0002', 'RR0002') ;

-- Bucket X02. Incorrectly progressed (backwards) by RR (to RM)
INSERT INTO AML_T_COMPLAINTS_CREATED_CR
(complaint_id, fin_acc_ref, dw_from_date, dw_to_date, created_date, effective_from_date, created_date_time,
 closed_date, closed_flag, closed_same_day_flag, hand_off_flag, reopen_flag,
 created_by_user_id, owned_by_user_id, sector_id, ombudsman_complaint_indicator, summary, expected_bucket)
VALUES (15, '15', TO_DATE ('01/08/2014', 'DD/MM/YYYY'), TO_DATE ('31/12/9999', 'DD/MM/YYYY'), TO_DATE ('30/07/2014', 'DD/MM/YYYY'), TO_DATE ('30/07/2014', 'DD/MM/YYYY'), TO_DATE ('30/07/2014 10:10:15', 'DD/MM/YYYY HH24:MI:SS'),
        NULL, 'N', 'N', 'Y', 'N',
        'FL0001', 'RM0001', 1, 'N',
        'Bucket X02. Incorrectly progressed (backwards) by OT (to RM)', 'X02') ;

INSERT INTO AML_T_COMPLAINTS_HANDOFF_CR
   (COMPLAINT_ID, HAND_OFF_DATE, HAND_OFF_USER_ID, HAND_OFF_FROM_USER_ID) 
VALUES (15, TO_DATE ('02/08/2014 11:30:45', 'DD/MM/YYYY HH24:MI:SS'), 'RM0001', 'FL0001') ;

INSERT INTO AML_T_COMPLAINTS_HANDOFF_CR
   (COMPLAINT_ID, HAND_OFF_DATE, HAND_OFF_USER_ID, HAND_OFF_FROM_USER_ID) 
VALUES (15, TO_DATE ('02/08/2014 15:23:10', 'DD/MM/YYYY HH24:MI:SS'), 'OT0001', 'RM0001') ;

INSERT INTO AML_T_COMPLAINTS_HANDOFF_CR
   (COMPLAINT_ID, HAND_OFF_DATE, HAND_OFF_USER_ID, HAND_OFF_FROM_USER_ID) 
VALUES (15, TO_DATE ('02/08/2014 16:23:10', 'DD/MM/YYYY HH24:MI:SS'), 'RM0001', 'OT0001') ;

-- Bucket X03. Incorrectly progressed (backwards) by OT (to RR)
INSERT INTO AML_T_COMPLAINTS_CREATED_CR
(complaint_id, fin_acc_ref, dw_from_date, dw_to_date, created_date, effective_from_date, created_date_time,
 closed_date, closed_flag, closed_same_day_flag, hand_off_flag, reopen_flag,
 created_by_user_id, owned_by_user_id, sector_id, ombudsman_complaint_indicator, summary, expected_bucket)
VALUES (16, '16', TO_DATE ('01/08/2014', 'DD/MM/YYYY'), TO_DATE ('31/12/9999', 'DD/MM/YYYY'), TO_DATE ('30/07/2014', 'DD/MM/YYYY'), TO_DATE ('30/07/2014', 'DD/MM/YYYY'), TO_DATE ('30/07/2014 10:10:15', 'DD/MM/YYYY HH24:MI:SS'),
        NULL, 'N', 'N', 'Y', 'N',
        'FL0001', 'RR0001', 1, 'N',
        'Bucket X03. Incorrectly progressed (backwards) by OT (to RR)', 'X03') ;

INSERT INTO AML_T_COMPLAINTS_HANDOFF_CR
   (COMPLAINT_ID, HAND_OFF_DATE, HAND_OFF_USER_ID, HAND_OFF_FROM_USER_ID) 
VALUES (16, TO_DATE ('02/08/2014 11:30:45', 'DD/MM/YYYY HH24:MI:SS'), 'RM0001', 'FL0001') ;

INSERT INTO AML_T_COMPLAINTS_HANDOFF_CR
   (COMPLAINT_ID, HAND_OFF_DATE, HAND_OFF_USER_ID, HAND_OFF_FROM_USER_ID) 
VALUES (16, TO_DATE ('02/08/2014 15:23:10', 'DD/MM/YYYY HH24:MI:SS'), 'OT0001', 'RM0001') ;

INSERT INTO AML_T_COMPLAINTS_HANDOFF_CR
   (COMPLAINT_ID, HAND_OFF_DATE, HAND_OFF_USER_ID, HAND_OFF_FROM_USER_ID) 
VALUES (16, TO_DATE ('02/08/2014 16:23:10', 'DD/MM/YYYY HH24:MI:SS'), 'RR0001', 'OT0001') ;

-- Bucket 9. Closed same day by RM (same day starts from the moment it took the complaint over)
INSERT INTO AML_T_COMPLAINTS_CREATED_CR
(complaint_id, fin_acc_ref, dw_from_date, dw_to_date, created_date, effective_from_date, created_date_time,
 closed_date, closed_flag, closed_same_day_flag, hand_off_flag, reopen_flag,
 created_by_user_id, owned_by_user_id, sector_id, ombudsman_complaint_indicator, summary, expected_bucket)
VALUES (17, '17', TO_DATE ('01/08/2014', 'DD/MM/YYYY'), TO_DATE ('31/12/9999', 'DD/MM/YYYY'), TO_DATE ('30/07/2014', 'DD/MM/YYYY'), TO_DATE ('30/07/2014', 'DD/MM/YYYY'), TO_DATE ('30/07/2014 10:10:10', 'DD/MM/YYYY HH24:MI:SS'),
        TO_DATE ('03/08/2014', 'DD/MM/YYYY'), 'Y', 'Y', 'Y', 'N',
        'FL0001', 'RM0002', 1, 'N',
        'Bucket 9. Closed same day by RM', '9') ;

INSERT INTO AML_T_COMPLAINTS_HANDOFF_CR
   (COMPLAINT_ID, HAND_OFF_DATE, HAND_OFF_USER_ID, HAND_OFF_FROM_USER_ID)
VALUES (17, TO_DATE ('03/08/2014 11:20:45', 'DD/MM/YYYY HH24:MI:SS'), 'RM0002', 'FL0001') ;

-- Bucket 9a. Closed but not the same day by RM
INSERT INTO AML_T_COMPLAINTS_CREATED_CR
(complaint_id, fin_acc_ref, dw_from_date, dw_to_date, created_date, effective_from_date, created_date_time,
 closed_date, closed_flag, closed_same_day_flag, hand_off_flag, reopen_flag,
 created_by_user_id, owned_by_user_id, sector_id, ombudsman_complaint_indicator, summary, expected_bucket)
VALUES (18, '18', TO_DATE ('01/08/2014', 'DD/MM/YYYY'), TO_DATE ('31/12/9999', 'DD/MM/YYYY'), TO_DATE ('30/07/2014', 'DD/MM/YYYY'), TO_DATE ('30/07/2014', 'DD/MM/YYYY'), TO_DATE ('30/07/2014 10:10:10', 'DD/MM/YYYY HH24:MI:SS'),
        TO_DATE ('03/08/2014', 'DD/MM/YYYY'), 'Y', 'N', 'Y', 'N',
        'FL0001', 'RM0002', 1, 'N',
        'Bucket 9a. Closed but not the same day by RM', '9a') ;

INSERT INTO AML_T_COMPLAINTS_HANDOFF_CR
   (COMPLAINT_ID, HAND_OFF_DATE, HAND_OFF_USER_ID, HAND_OFF_FROM_USER_ID)
VALUES (18, TO_DATE ('02/08/2014 11:20:45', 'DD/MM/YYYY HH24:MI:SS'), 'RM0002', 'FL0001') ;

-- Bucket 10. Closed (same day or not) by RM then reopened
INSERT INTO AML_T_COMPLAINTS_CREATED_CR
(complaint_id, fin_acc_ref, dw_from_date, dw_to_date, created_date, effective_from_date, created_date_time,
 closed_date, closed_flag, closed_same_day_flag, hand_off_flag, reopen_flag,
 created_by_user_id, owned_by_user_id, sector_id, ombudsman_complaint_indicator, summary, expected_bucket)
VALUES (19, '19', TO_DATE ('01/08/2014', 'DD/MM/YYYY'), TO_DATE ('31/12/9999', 'DD/MM/YYYY'), TO_DATE ('30/07/2014', 'DD/MM/YYYY'), TO_DATE ('30/07/2014', 'DD/MM/YYYY'), TO_DATE ('30/07/2014 10:10:15', 'DD/MM/YYYY HH24:MI:SS'),
        NULL, 'N', 'N', 'Y', 'Y',
        'FL0001', 'RM0002', 1, 'N',
        'Bucket 10. Closed (same day or not) by RM then reopened', '10') ;

INSERT INTO AML_T_COMPLAINTS_HANDOFF_CR
   (COMPLAINT_ID, HAND_OFF_DATE, HAND_OFF_USER_ID, HAND_OFF_FROM_USER_ID) 
VALUES (19, TO_DATE ('02/08/2014 11:30:45', 'DD/MM/YYYY HH24:MI:SS'), 'RM0001', 'FL0001') ;

INSERT INTO AML_T_COMPLAINTS_HANDOFF_CR
   (COMPLAINT_ID, HAND_OFF_DATE, HAND_OFF_USER_ID, HAND_OFF_FROM_USER_ID) 
VALUES (19, TO_DATE ('05/08/2014 11:50:45', 'DD/MM/YYYY HH24:MI:SS'), 'RM0002', 'RM0001') ;

INSERT INTO AML_T_COMPLAINTS_REOPEN_CR
 (complaint_id, reopen_date, pre_reopen_user_id, reopen_user_id)
 VALUES (19, TO_DATE ('05/08/2014 10:10:10', 'DD/MM/YYYY HH24:MI:SS'), 'RM0001', 'RM0002') ;

-- Bucket 11. Progressed from RM to RR
INSERT INTO AML_T_COMPLAINTS_CREATED_CR
(complaint_id, fin_acc_ref, dw_from_date, dw_to_date, created_date, effective_from_date, created_date_time,
 closed_date, closed_flag, closed_same_day_flag, hand_off_flag, reopen_flag,
 created_by_user_id, owned_by_user_id, sector_id, ombudsman_complaint_indicator, summary, expected_bucket)
VALUES (20, '20', TO_DATE ('01/08/2014', 'DD/MM/YYYY'), TO_DATE ('31/12/9999', 'DD/MM/YYYY'), TO_DATE ('30/07/2014', 'DD/MM/YYYY'), TO_DATE ('30/07/2014', 'DD/MM/YYYY'), TO_DATE ('30/07/2014 10:10:15', 'DD/MM/YYYY HH24:MI:SS'),
        NULL, 'N', 'N', 'Y', 'N',
        'FL0001', 'RR0001', 1, 'N',
        'Bucket 11. Progressed from RM to RR', '11') ;

INSERT INTO AML_T_COMPLAINTS_HANDOFF_CR
   (COMPLAINT_ID, HAND_OFF_DATE, HAND_OFF_USER_ID, HAND_OFF_FROM_USER_ID) 
VALUES (20, TO_DATE ('02/08/2014 11:30:45', 'DD/MM/YYYY HH24:MI:SS'), 'RM0001', 'FL0001') ;

INSERT INTO AML_T_COMPLAINTS_HANDOFF_CR
   (COMPLAINT_ID, HAND_OFF_DATE, HAND_OFF_USER_ID, HAND_OFF_FROM_USER_ID) 
VALUES (20, TO_DATE ('02/08/2014 11:35:45', 'DD/MM/YYYY HH24:MI:SS'), 'RR0001', 'RM0001') ;

-- Bucket 11a. RR peer change
INSERT INTO AML_T_COMPLAINTS_CREATED_CR
(complaint_id, fin_acc_ref, dw_from_date, dw_to_date, created_date, effective_from_date, created_date_time,
 closed_date, closed_flag, closed_same_day_flag, hand_off_flag, reopen_flag,
 created_by_user_id, owned_by_user_id, sector_id, ombudsman_complaint_indicator, summary, expected_bucket)
VALUES (21, '21', TO_DATE ('01/08/2014', 'DD/MM/YYYY'), TO_DATE ('31/12/9999', 'DD/MM/YYYY'), TO_DATE ('30/07/2014', 'DD/MM/YYYY'), TO_DATE ('30/07/2014', 'DD/MM/YYYY'), TO_DATE ('30/07/2014 10:10:15', 'DD/MM/YYYY HH24:MI:SS'),
        NULL, 'N', 'N', 'Y', 'N',
        'FL0001', 'RR0002', 1, 'N',
        'Bucket 11a. RR peer change', '11a') ;

INSERT INTO AML_T_COMPLAINTS_HANDOFF_CR
   (COMPLAINT_ID, HAND_OFF_DATE, HAND_OFF_USER_ID, HAND_OFF_FROM_USER_ID) 
VALUES (21, TO_DATE ('02/08/2014 11:30:45', 'DD/MM/YYYY HH24:MI:SS'), 'RM0002', 'FL0001') ;

INSERT INTO AML_T_COMPLAINTS_HANDOFF_CR
   (COMPLAINT_ID, HAND_OFF_DATE, HAND_OFF_USER_ID, HAND_OFF_FROM_USER_ID) 
VALUES (21, TO_DATE ('02/08/2014 15:30:45', 'DD/MM/YYYY HH24:MI:SS'), 'RR0002', 'RM0002') ;

INSERT INTO AML_T_COMPLAINTS_HANDOFF_CR
   (COMPLAINT_ID, HAND_OFF_DATE, HAND_OFF_USER_ID, HAND_OFF_FROM_USER_ID) 
VALUES (21, TO_DATE ('02/08/2014 16:40:15', 'DD/MM/YYYY HH24:MI:SS'), 'RR0001', 'RR0002') ;

-- Bucket 11b. Created by RR and sits with RR, no peer change
INSERT INTO AML_T_COMPLAINTS_CREATED_CR
(complaint_id, fin_acc_ref, dw_from_date, dw_to_date, created_date, effective_from_date, created_date_time,
 closed_date, closed_flag, closed_same_day_flag, hand_off_flag, reopen_flag,
 created_by_user_id, owned_by_user_id, sector_id, ombudsman_complaint_indicator, summary, expected_bucket)
VALUES (22, '22', TO_DATE ('01/08/2014', 'DD/MM/YYYY'), TO_DATE ('31/12/9999', 'DD/MM/YYYY'), TO_DATE ('30/07/2014', 'DD/MM/YYYY'), TO_DATE ('30/07/2014', 'DD/MM/YYYY'), TO_DATE ('30/07/2014 10:10:15', 'DD/MM/YYYY HH24:MI:SS'),
        NULL, 'N', 'N', 'N', 'N',
        'RR0001', 'RR0001', 1, 'N',
        'Bucket 11b. Created by RR and sits with RR, no peer change', '11b') ;

-- Bucket 13. Incorrectly progressed (forwards) by RM (to Manager)
INSERT INTO AML_T_COMPLAINTS_CREATED_CR
(complaint_id, fin_acc_ref, dw_from_date, dw_to_date, created_date, effective_from_date, created_date_time,
 closed_date, closed_flag, closed_same_day_flag, hand_off_flag, reopen_flag,
 created_by_user_id, owned_by_user_id, sector_id, ombudsman_complaint_indicator, summary, expected_bucket)
VALUES (23, '23', TO_DATE ('01/08/2014', 'DD/MM/YYYY'), TO_DATE ('31/12/9999', 'DD/MM/YYYY'), TO_DATE ('30/07/2014', 'DD/MM/YYYY'), TO_DATE ('30/07/2014', 'DD/MM/YYYY'), TO_DATE ('30/07/2014 10:10:15', 'DD/MM/YYYY HH24:MI:SS'),
        NULL, 'N', 'N', 'Y', 'N',
        'FL0001', 'MG0001', 1, 'N',
        'Bucket 13. Incorrectly progressed (forwards) by RM (to Manager)', '13') ;

INSERT INTO AML_T_COMPLAINTS_HANDOFF_CR
   (COMPLAINT_ID, HAND_OFF_DATE, HAND_OFF_USER_ID, HAND_OFF_FROM_USER_ID) 
VALUES (23, TO_DATE ('02/08/2014 11:30:45', 'DD/MM/YYYY HH24:MI:SS'), 'RM0002', 'FL0001') ;

INSERT INTO AML_T_COMPLAINTS_HANDOFF_CR
   (COMPLAINT_ID, HAND_OFF_DATE, HAND_OFF_USER_ID, HAND_OFF_FROM_USER_ID) 
VALUES (23, TO_DATE ('02/08/2014 15:23:10', 'DD/MM/YYYY HH24:MI:SS'), 'MG0001', 'RM0002') ;

-- Bucket 15. Closed same day by RR (same day starts from the moment it took the complaint over)
INSERT INTO AML_T_COMPLAINTS_CREATED_CR
(complaint_id, fin_acc_ref, dw_from_date, dw_to_date, created_date, effective_from_date, created_date_time,
 closed_date, closed_flag, closed_same_day_flag, hand_off_flag, reopen_flag,
 created_by_user_id, owned_by_user_id, sector_id, ombudsman_complaint_indicator, summary, expected_bucket)
VALUES (24, '24', TO_DATE ('01/08/2014', 'DD/MM/YYYY'), TO_DATE ('31/12/9999', 'DD/MM/YYYY'), TO_DATE ('30/07/2014', 'DD/MM/YYYY'), TO_DATE ('30/07/2014', 'DD/MM/YYYY'), TO_DATE ('30/07/2014 10:10:10', 'DD/MM/YYYY HH24:MI:SS'),
        TO_DATE ('03/08/2014', 'DD/MM/YYYY'), 'Y', 'Y', 'Y', 'N',
        'FL0001', 'RR0001', 1, 'N',
        'Bucket 15. Closed same day by RR', '15') ;

INSERT INTO AML_T_COMPLAINTS_HANDOFF_CR
   (COMPLAINT_ID, HAND_OFF_DATE, HAND_OFF_USER_ID, HAND_OFF_FROM_USER_ID)
VALUES (24, TO_DATE ('02/08/2014 11:20:45', 'DD/MM/YYYY HH24:MI:SS'), 'RM0002', 'FL0001') ;

INSERT INTO AML_T_COMPLAINTS_HANDOFF_CR
   (COMPLAINT_ID, HAND_OFF_DATE, HAND_OFF_USER_ID, HAND_OFF_FROM_USER_ID)
VALUES (24, TO_DATE ('03/08/2014 11:20:45', 'DD/MM/YYYY HH24:MI:SS'), 'RR0001', 'RM0002') ;

-- Bucket 15a. Closed but not the same day by RR
INSERT INTO AML_T_COMPLAINTS_CREATED_CR
(complaint_id, fin_acc_ref, dw_from_date, dw_to_date, created_date, effective_from_date, created_date_time,
 closed_date, closed_flag, closed_same_day_flag, hand_off_flag, reopen_flag,
 created_by_user_id, owned_by_user_id, sector_id, ombudsman_complaint_indicator, summary, expected_bucket)
VALUES (25, '25', TO_DATE ('01/08/2014', 'DD/MM/YYYY'), TO_DATE ('31/12/9999', 'DD/MM/YYYY'), TO_DATE ('30/07/2014', 'DD/MM/YYYY'), TO_DATE ('30/07/2014', 'DD/MM/YYYY'), TO_DATE ('30/07/2014 10:10:10', 'DD/MM/YYYY HH24:MI:SS'),
        TO_DATE ('03/08/2014', 'DD/MM/YYYY'), 'Y', 'N', 'Y', 'N',
        'FL0001', 'RR0002', 1, 'N',
        'Bucket 15a. Closed but not the same day by RR', '15a') ;

INSERT INTO AML_T_COMPLAINTS_HANDOFF_CR
   (COMPLAINT_ID, HAND_OFF_DATE, HAND_OFF_USER_ID, HAND_OFF_FROM_USER_ID)
VALUES (25, TO_DATE ('02/08/2014 11:20:45', 'DD/MM/YYYY HH24:MI:SS'), 'RM0002', 'FL0001') ;

INSERT INTO AML_T_COMPLAINTS_HANDOFF_CR
   (COMPLAINT_ID, HAND_OFF_DATE, HAND_OFF_USER_ID, HAND_OFF_FROM_USER_ID)
VALUES (25, TO_DATE ('02/08/2014 11:30:45', 'DD/MM/YYYY HH24:MI:SS'), 'RR0002', 'RM0002') ;

-- Bucket 16. Closed (same day or not) by RR then reopened
INSERT INTO AML_T_COMPLAINTS_CREATED_CR
(complaint_id, fin_acc_ref, dw_from_date, dw_to_date, created_date, effective_from_date, created_date_time,
 closed_date, closed_flag, closed_same_day_flag, hand_off_flag, reopen_flag,
 created_by_user_id, owned_by_user_id, sector_id, ombudsman_complaint_indicator, summary, expected_bucket)
VALUES (26, '26', TO_DATE ('01/08/2014', 'DD/MM/YYYY'), TO_DATE ('31/12/9999', 'DD/MM/YYYY'), TO_DATE ('30/07/2014', 'DD/MM/YYYY'), TO_DATE ('30/07/2014', 'DD/MM/YYYY'), TO_DATE ('30/07/2014 10:10:15', 'DD/MM/YYYY HH24:MI:SS'),
        NULL, 'N', 'N', 'Y', 'Y',
        'FL0001', 'OT0002', 1, 'N',
        'Bucket 16. Closed (same day or not) by RR then reopened', '16') ;

INSERT INTO AML_T_COMPLAINTS_HANDOFF_CR
   (COMPLAINT_ID, HAND_OFF_DATE, HAND_OFF_USER_ID, HAND_OFF_FROM_USER_ID) 
VALUES (26, TO_DATE ('02/08/2014 11:30:45', 'DD/MM/YYYY HH24:MI:SS'), 'RM0001', 'FL0001') ;

INSERT INTO AML_T_COMPLAINTS_HANDOFF_CR
   (COMPLAINT_ID, HAND_OFF_DATE, HAND_OFF_USER_ID, HAND_OFF_FROM_USER_ID) 
VALUES (26, TO_DATE ('05/08/2014 11:50:45', 'DD/MM/YYYY HH24:MI:SS'), 'RR0002', 'RM0001') ;

INSERT INTO AML_T_COMPLAINTS_HANDOFF_CR
   (COMPLAINT_ID, HAND_OFF_DATE, HAND_OFF_USER_ID, HAND_OFF_FROM_USER_ID) 
VALUES (26, TO_DATE ('06/08/2014 11:55:45', 'DD/MM/YYYY HH24:MI:SS'), 'OT0002', 'RR0002') ;

INSERT INTO AML_T_COMPLAINTS_REOPEN_CR
 (complaint_id, reopen_date, pre_reopen_user_id, reopen_user_id)
 VALUES (26, TO_DATE ('06/08/2014 10:10:10', 'DD/MM/YYYY HH24:MI:SS'), 'RR0002', 'OT0002') ;

-- Bucket 17. Progressed from RM or RR to OT
INSERT INTO AML_T_COMPLAINTS_CREATED_CR
(complaint_id, fin_acc_ref, dw_from_date, dw_to_date, created_date, effective_from_date, created_date_time,
 closed_date, closed_flag, closed_same_day_flag, hand_off_flag, reopen_flag,
 created_by_user_id, owned_by_user_id, sector_id, ombudsman_complaint_indicator, summary, expected_bucket)
VALUES (27, '27', TO_DATE ('01/08/2014', 'DD/MM/YYYY'), TO_DATE ('31/12/9999', 'DD/MM/YYYY'), TO_DATE ('30/07/2014', 'DD/MM/YYYY'), TO_DATE ('30/07/2014', 'DD/MM/YYYY'), TO_DATE ('30/07/2014 10:10:15', 'DD/MM/YYYY HH24:MI:SS'),
        NULL, 'N', 'N', 'Y', 'N',
        'FL0001', 'OT0001', 1, 'N',
        'Bucket 17. Progressed from RM or RR to OT', '17') ;

INSERT INTO AML_T_COMPLAINTS_HANDOFF_CR
   (COMPLAINT_ID, HAND_OFF_DATE, HAND_OFF_USER_ID, HAND_OFF_FROM_USER_ID) 
VALUES (27, TO_DATE ('02/08/2014 11:30:45', 'DD/MM/YYYY HH24:MI:SS'), 'RM0001', 'FL0001') ;

INSERT INTO AML_T_COMPLAINTS_HANDOFF_CR
   (COMPLAINT_ID, HAND_OFF_DATE, HAND_OFF_USER_ID, HAND_OFF_FROM_USER_ID) 
VALUES (27, TO_DATE ('02/08/2014 11:35:45', 'DD/MM/YYYY HH24:MI:SS'), 'RR0001', 'RM0001') ;

INSERT INTO AML_T_COMPLAINTS_HANDOFF_CR
   (COMPLAINT_ID, HAND_OFF_DATE, HAND_OFF_USER_ID, HAND_OFF_FROM_USER_ID) 
VALUES (27, TO_DATE ('02/08/2014 12:35:45', 'DD/MM/YYYY HH24:MI:SS'), 'OT0001', 'RR0001') ;

-- Bucket 17a. OT peer change
INSERT INTO AML_T_COMPLAINTS_CREATED_CR
(complaint_id, fin_acc_ref, dw_from_date, dw_to_date, created_date, effective_from_date, created_date_time,
 closed_date, closed_flag, closed_same_day_flag, hand_off_flag, reopen_flag,
 created_by_user_id, owned_by_user_id, sector_id, ombudsman_complaint_indicator, summary, expected_bucket)
VALUES (28, '28', TO_DATE ('01/08/2014', 'DD/MM/YYYY'), TO_DATE ('31/12/9999', 'DD/MM/YYYY'), TO_DATE ('30/07/2014', 'DD/MM/YYYY'), TO_DATE ('30/07/2014', 'DD/MM/YYYY'), TO_DATE ('30/07/2014 10:10:15', 'DD/MM/YYYY HH24:MI:SS'),
        NULL, 'N', 'N', 'Y', 'N',
        'FL0001', 'OT0002', 1, 'N',
        'Bucket 17a. OT peer change', '17a') ;

INSERT INTO AML_T_COMPLAINTS_HANDOFF_CR
   (COMPLAINT_ID, HAND_OFF_DATE, HAND_OFF_USER_ID, HAND_OFF_FROM_USER_ID) 
VALUES (28, TO_DATE ('02/08/2014 11:30:45', 'DD/MM/YYYY HH24:MI:SS'), 'RM0002', 'FL0001') ;

INSERT INTO AML_T_COMPLAINTS_HANDOFF_CR
   (COMPLAINT_ID, HAND_OFF_DATE, HAND_OFF_USER_ID, HAND_OFF_FROM_USER_ID) 
VALUES (28, TO_DATE ('02/08/2014 15:30:45', 'DD/MM/YYYY HH24:MI:SS'), 'RR0002', 'RM0002') ;

INSERT INTO AML_T_COMPLAINTS_HANDOFF_CR
   (COMPLAINT_ID, HAND_OFF_DATE, HAND_OFF_USER_ID, HAND_OFF_FROM_USER_ID) 
VALUES (28, TO_DATE ('02/08/2014 16:40:15', 'DD/MM/YYYY HH24:MI:SS'), 'OT0001', 'RR0002') ;

INSERT INTO AML_T_COMPLAINTS_HANDOFF_CR
   (COMPLAINT_ID, HAND_OFF_DATE, HAND_OFF_USER_ID, HAND_OFF_FROM_USER_ID) 
VALUES (28, TO_DATE ('02/08/2014 17:40:15', 'DD/MM/YYYY HH24:MI:SS'), 'OT0002', 'OT0001') ;

-- Bucket 17b. Created by OT and sits with OT, no peer change
INSERT INTO AML_T_COMPLAINTS_CREATED_CR
(complaint_id, fin_acc_ref, dw_from_date, dw_to_date, created_date, effective_from_date, created_date_time,
 closed_date, closed_flag, closed_same_day_flag, hand_off_flag, reopen_flag,
 created_by_user_id, owned_by_user_id, sector_id, ombudsman_complaint_indicator, summary, expected_bucket)
VALUES (29, '29', TO_DATE ('01/08/2014', 'DD/MM/YYYY'), TO_DATE ('31/12/9999', 'DD/MM/YYYY'), TO_DATE ('30/07/2014', 'DD/MM/YYYY'), TO_DATE ('30/07/2014', 'DD/MM/YYYY'), TO_DATE ('30/07/2014 10:10:15', 'DD/MM/YYYY HH24:MI:SS'),
        NULL, 'N', 'N', 'N', 'N',
        'OT0001', 'OT0001', 1, 'N',
        'Bucket 17b. Created by OT and sits with OT, no peer change', '17b') ;

-- Bucket 18. Incorrectly progressed (forwards) by RR (to Manager)
INSERT INTO AML_T_COMPLAINTS_CREATED_CR
(complaint_id, fin_acc_ref, dw_from_date, dw_to_date, created_date, effective_from_date, created_date_time,
 closed_date, closed_flag, closed_same_day_flag, hand_off_flag, reopen_flag,
 created_by_user_id, owned_by_user_id, sector_id, ombudsman_complaint_indicator, summary, expected_bucket)
VALUES (30, '30', TO_DATE ('01/08/2014', 'DD/MM/YYYY'), TO_DATE ('31/12/9999', 'DD/MM/YYYY'), TO_DATE ('30/07/2014', 'DD/MM/YYYY'), TO_DATE ('30/07/2014', 'DD/MM/YYYY'), TO_DATE ('30/07/2014 10:10:15', 'DD/MM/YYYY HH24:MI:SS'),
        NULL, 'N', 'N', 'Y', 'N',
        'FL0001', 'MG0002', 1, 'N',
        'Bucket 18. Incorrectly progressed (forwards) by RR (to Manager)', '18') ;

INSERT INTO AML_T_COMPLAINTS_HANDOFF_CR
   (COMPLAINT_ID, HAND_OFF_DATE, HAND_OFF_USER_ID, HAND_OFF_FROM_USER_ID) 
VALUES (30, TO_DATE ('02/08/2014 11:30:45', 'DD/MM/YYYY HH24:MI:SS'), 'RM0002', 'FL0001') ;

INSERT INTO AML_T_COMPLAINTS_HANDOFF_CR
   (COMPLAINT_ID, HAND_OFF_DATE, HAND_OFF_USER_ID, HAND_OFF_FROM_USER_ID) 
VALUES (30, TO_DATE ('02/08/2014 15:23:10', 'DD/MM/YYYY HH24:MI:SS'), 'RR0001', 'RM0002') ;

INSERT INTO AML_T_COMPLAINTS_HANDOFF_CR
   (COMPLAINT_ID, HAND_OFF_DATE, HAND_OFF_USER_ID, HAND_OFF_FROM_USER_ID) 
VALUES (30, TO_DATE ('03/08/2014 15:23:10', 'DD/MM/YYYY HH24:MI:SS'), 'MG0002', 'RR0001') ;

-- Bucket 20. Closed same day by OT (same day starts from the moment it took the complaint over)
INSERT INTO AML_T_COMPLAINTS_CREATED_CR
(complaint_id, fin_acc_ref, dw_from_date, dw_to_date, created_date, effective_from_date, created_date_time,
 closed_date, closed_flag, closed_same_day_flag, hand_off_flag, reopen_flag,
 created_by_user_id, owned_by_user_id, sector_id, ombudsman_complaint_indicator, summary, expected_bucket)
VALUES (31, '31', TO_DATE ('01/08/2014', 'DD/MM/YYYY'), TO_DATE ('31/12/9999', 'DD/MM/YYYY'), TO_DATE ('30/07/2014', 'DD/MM/YYYY'), TO_DATE ('30/07/2014', 'DD/MM/YYYY'), TO_DATE ('30/07/2014 10:10:10', 'DD/MM/YYYY HH24:MI:SS'),
        TO_DATE ('03/08/2014', 'DD/MM/YYYY'), 'Y', 'Y', 'Y', 'N',
        'FL0001', 'OT0001', 1, 'N',
        'Bucket 20. Closed same day by OT', '20') ;

INSERT INTO AML_T_COMPLAINTS_HANDOFF_CR
   (COMPLAINT_ID, HAND_OFF_DATE, HAND_OFF_USER_ID, HAND_OFF_FROM_USER_ID)
VALUES (31, TO_DATE ('02/08/2014 11:20:45', 'DD/MM/YYYY HH24:MI:SS'), 'RM0002', 'FL0001') ;

INSERT INTO AML_T_COMPLAINTS_HANDOFF_CR
   (COMPLAINT_ID, HAND_OFF_DATE, HAND_OFF_USER_ID, HAND_OFF_FROM_USER_ID)
VALUES (31, TO_DATE ('03/08/2014 11:20:45', 'DD/MM/YYYY HH24:MI:SS'), 'RR0001', 'RM0002') ;

INSERT INTO AML_T_COMPLAINTS_HANDOFF_CR
   (COMPLAINT_ID, HAND_OFF_DATE, HAND_OFF_USER_ID, HAND_OFF_FROM_USER_ID)
VALUES (31, TO_DATE ('03/08/2014 15:25:45', 'DD/MM/YYYY HH24:MI:SS'), 'OT0001', 'RR0001') ;

-- Bucket 20a. Closed but not the same day by OT
INSERT INTO AML_T_COMPLAINTS_CREATED_CR
(complaint_id, fin_acc_ref, dw_from_date, dw_to_date, created_date, effective_from_date, created_date_time,
 closed_date, closed_flag, closed_same_day_flag, hand_off_flag, reopen_flag,
 created_by_user_id, owned_by_user_id, sector_id, ombudsman_complaint_indicator, summary, expected_bucket)
VALUES (32, '32', TO_DATE ('01/08/2014', 'DD/MM/YYYY'), TO_DATE ('31/12/9999', 'DD/MM/YYYY'), TO_DATE ('30/07/2014', 'DD/MM/YYYY'), TO_DATE ('30/07/2014', 'DD/MM/YYYY'), TO_DATE ('30/07/2014 10:10:10', 'DD/MM/YYYY HH24:MI:SS'),
        TO_DATE ('03/08/2014', 'DD/MM/YYYY'), 'Y', 'N', 'Y', 'N',
        'FL0001', 'OT0002', 1, 'N',
        'Bucket 20a. Closed but not the same day by OT', '20a') ;

INSERT INTO AML_T_COMPLAINTS_HANDOFF_CR
   (COMPLAINT_ID, HAND_OFF_DATE, HAND_OFF_USER_ID, HAND_OFF_FROM_USER_ID)
VALUES (32, TO_DATE ('02/08/2014 11:20:45', 'DD/MM/YYYY HH24:MI:SS'), 'RM0002', 'FL0001') ;

INSERT INTO AML_T_COMPLAINTS_HANDOFF_CR
   (COMPLAINT_ID, HAND_OFF_DATE, HAND_OFF_USER_ID, HAND_OFF_FROM_USER_ID)
VALUES (32, TO_DATE ('02/08/2014 11:30:45', 'DD/MM/YYYY HH24:MI:SS'), 'RR0002', 'RM0002') ;

INSERT INTO AML_T_COMPLAINTS_HANDOFF_CR
   (COMPLAINT_ID, HAND_OFF_DATE, HAND_OFF_USER_ID, HAND_OFF_FROM_USER_ID)
VALUES (32, TO_DATE ('02/08/2014 14:20:45', 'DD/MM/YYYY HH24:MI:SS'), 'OT0002', 'RR0002') ;

-- Bucket 21. Closed (same day or not) by OT then reopened
INSERT INTO AML_T_COMPLAINTS_CREATED_CR
(complaint_id, fin_acc_ref, dw_from_date, dw_to_date, created_date, effective_from_date, created_date_time,
 closed_date, closed_flag, closed_same_day_flag, hand_off_flag, reopen_flag,
 created_by_user_id, owned_by_user_id, sector_id, ombudsman_complaint_indicator, summary, expected_bucket)
VALUES (33, '33', TO_DATE ('01/08/2014', 'DD/MM/YYYY'), TO_DATE ('31/12/9999', 'DD/MM/YYYY'), TO_DATE ('30/07/2014', 'DD/MM/YYYY'), TO_DATE ('30/07/2014', 'DD/MM/YYYY'), TO_DATE ('30/07/2014 10:10:15', 'DD/MM/YYYY HH24:MI:SS'),
        NULL, 'N', 'N', 'Y', 'Y',
        'FL0001', 'OT0002', 1, 'N',
        'Bucket 21. Closed (same day or not) by OT then reopened', '21') ;

INSERT INTO AML_T_COMPLAINTS_HANDOFF_CR
   (COMPLAINT_ID, HAND_OFF_DATE, HAND_OFF_USER_ID, HAND_OFF_FROM_USER_ID) 
VALUES (33, TO_DATE ('02/08/2014 11:30:45', 'DD/MM/YYYY HH24:MI:SS'), 'RM0001', 'FL0001') ;

INSERT INTO AML_T_COMPLAINTS_HANDOFF_CR
   (COMPLAINT_ID, HAND_OFF_DATE, HAND_OFF_USER_ID, HAND_OFF_FROM_USER_ID) 
VALUES (33, TO_DATE ('05/08/2014 11:50:45', 'DD/MM/YYYY HH24:MI:SS'), 'RR0002', 'RM0001') ;

INSERT INTO AML_T_COMPLAINTS_HANDOFF_CR
   (COMPLAINT_ID, HAND_OFF_DATE, HAND_OFF_USER_ID, HAND_OFF_FROM_USER_ID) 
VALUES (33, TO_DATE ('06/08/2014 11:55:45', 'DD/MM/YYYY HH24:MI:SS'), 'OT0002', 'RR0002') ;

INSERT INTO AML_T_COMPLAINTS_REOPEN_CR
 (complaint_id, reopen_date, pre_reopen_user_id, reopen_user_id)
 VALUES (33, TO_DATE ('07/08/2014 10:10:10', 'DD/MM/YYYY HH24:MI:SS'), 'OT0001', 'OT0002') ;

-- Bucket 22. Incorrectly progressed (forwards) by OT (to Manager)
INSERT INTO AML_T_COMPLAINTS_CREATED_CR
(complaint_id, fin_acc_ref, dw_from_date, dw_to_date, created_date, effective_from_date, created_date_time,
 closed_date, closed_flag, closed_same_day_flag, hand_off_flag, reopen_flag,
 created_by_user_id, owned_by_user_id, sector_id, ombudsman_complaint_indicator, summary, expected_bucket)
VALUES (34, '34', TO_DATE ('01/08/2014', 'DD/MM/YYYY'), TO_DATE ('31/12/9999', 'DD/MM/YYYY'), TO_DATE ('30/07/2014', 'DD/MM/YYYY'), TO_DATE ('30/07/2014', 'DD/MM/YYYY'), TO_DATE ('30/07/2014 10:10:15', 'DD/MM/YYYY HH24:MI:SS'),
        NULL, 'N', 'N', 'Y', 'N',
        'FL0001', 'MG0002', 1, 'N',
        'Bucket 22. Incorrectly progressed (forwards) by OT (to Manager)', '22') ;

INSERT INTO AML_T_COMPLAINTS_HANDOFF_CR
   (COMPLAINT_ID, HAND_OFF_DATE, HAND_OFF_USER_ID, HAND_OFF_FROM_USER_ID) 
VALUES (34, TO_DATE ('02/08/2014 11:30:45', 'DD/MM/YYYY HH24:MI:SS'), 'RM0002', 'FL0001') ;

INSERT INTO AML_T_COMPLAINTS_HANDOFF_CR
   (COMPLAINT_ID, HAND_OFF_DATE, HAND_OFF_USER_ID, HAND_OFF_FROM_USER_ID) 
VALUES (34, TO_DATE ('02/08/2014 15:23:10', 'DD/MM/YYYY HH24:MI:SS'), 'RR0001', 'RM0002') ;

INSERT INTO AML_T_COMPLAINTS_HANDOFF_CR
   (COMPLAINT_ID, HAND_OFF_DATE, HAND_OFF_USER_ID, HAND_OFF_FROM_USER_ID) 
VALUES (34, TO_DATE ('03/08/2014 15:23:10', 'DD/MM/YYYY HH24:MI:SS'), 'OT0002', 'RR0001') ;

INSERT INTO AML_T_COMPLAINTS_HANDOFF_CR
   (COMPLAINT_ID, HAND_OFF_DATE, HAND_OFF_USER_ID, HAND_OFF_FROM_USER_ID) 
VALUES (34, TO_DATE ('03/08/2014 16:40:19', 'DD/MM/YYYY HH24:MI:SS'), 'MG0002', 'OT0002') ;

-- *******************************************
-- Duplicates - on financial account reference
-- *******************************************
INSERT INTO AML_T_COMPLAINTS_CREATED_CR
(complaint_id, fin_acc_ref, dw_from_date, dw_to_date, created_date, effective_from_date, created_date_time,
 closed_date, closed_flag, closed_same_day_flag, hand_off_flag, reopen_flag,
 created_by_user_id, owned_by_user_id, sector_id, ombudsman_complaint_indicator, summary, expected_bucket)
VALUES (1, 'D1', TO_DATE ('01/08/2014', 'DD/MM/YYYY'), TO_DATE ('31/12/9999', 'DD/MM/YYYY'), TO_DATE ('30/07/2014', 'DD/MM/YYYY'), TO_DATE ('30/07/2014', 'DD/MM/YYYY'), TO_DATE ('30/07/2014 10:10:10', 'DD/MM/YYYY HH24:MI:SS'),
        NULL, 'N', 'N', 'N', 'N',
        'FL0001', 'FL0001', 1, 'N',
        'Bucket 2. Not progressed by FL', '2') ;

INSERT INTO AML_T_COMPLAINTS_CREATED_CR
(complaint_id, fin_acc_ref, dw_from_date, dw_to_date, created_date, effective_from_date, created_date_time,
 closed_date, closed_flag, closed_same_day_flag, hand_off_flag, reopen_flag,
 created_by_user_id, owned_by_user_id, sector_id, ombudsman_complaint_indicator, summary, expected_bucket)
VALUES (2, 'D2', TO_DATE ('01/08/2014', 'DD/MM/YYYY'), TO_DATE ('31/12/9999', 'DD/MM/YYYY'), TO_DATE ('30/07/2014', 'DD/MM/YYYY'), TO_DATE ('30/07/2014', 'DD/MM/YYYY'), TO_DATE ('30/07/2014 10:10:10', 'DD/MM/YYYY HH24:MI:SS'),
        NULL, 'N', 'N', 'N', 'N',
        'FL0001', 'FL0002', 1, 'N',
        'Bucket 2a. FL peer change', '2a') ;

-- Mixed cases
-- Incorrectly progressed (forwards) by FL (to Manager) then back to RM
INSERT INTO AML_T_COMPLAINTS_CREATED_CR
(complaint_id, fin_acc_ref, dw_from_date, dw_to_date, created_date, effective_from_date, created_date_time,
 closed_date, closed_flag, closed_same_day_flag, hand_off_flag, reopen_flag,
 created_by_user_id, owned_by_user_id, sector_id, ombudsman_complaint_indicator, summary, expected_bucket)
VALUES (40, '40', TO_DATE ('01/08/2014', 'DD/MM/YYYY'), TO_DATE ('31/12/9999', 'DD/MM/YYYY'), TO_DATE ('30/07/2014', 'DD/MM/YYYY'), TO_DATE ('30/07/2014', 'DD/MM/YYYY'), TO_DATE ('30/07/2014 10:10:15', 'DD/MM/YYYY HH24:MI:SS'),
        NULL, 'N', 'N', 'Y', 'N',
        'FL0001', 'RM0002', 1, 'N',
        'Bucket 7. Incorrectly progressed (forwards) by FL (to Manager) then back to RM', '7') ;

INSERT INTO AML_T_COMPLAINTS_HANDOFF_CR
   (COMPLAINT_ID, HAND_OFF_DATE, HAND_OFF_USER_ID, HAND_OFF_FROM_USER_ID) 
VALUES (40, TO_DATE ('05/08/2014 11:50:45', 'DD/MM/YYYY HH24:MI:SS'), 'MG0002', 'FL0001') ;

INSERT INTO AML_T_COMPLAINTS_HANDOFF_CR
   (COMPLAINT_ID, HAND_OFF_DATE, HAND_OFF_USER_ID, HAND_OFF_FROM_USER_ID) 
VALUES (40, TO_DATE ('06/08/2014 11:50:45', 'DD/MM/YYYY HH24:MI:SS'), 'RM0002', 'MG0002') ;

-- Bucket 9. Created by RM, closed same day by RM
INSERT INTO AML_T_COMPLAINTS_CREATED_CR
(complaint_id, fin_acc_ref, dw_from_date, dw_to_date, created_date, effective_from_date, created_date_time,
 closed_date, closed_flag, closed_same_day_flag, hand_off_flag, reopen_flag,
 created_by_user_id, owned_by_user_id, sector_id, ombudsman_complaint_indicator, summary, expected_bucket)
VALUES (41, '41', TO_DATE ('01/08/2014', 'DD/MM/YYYY'), TO_DATE ('31/12/9999', 'DD/MM/YYYY'), TO_DATE ('30/07/2014', 'DD/MM/YYYY'), TO_DATE ('30/07/2014', 'DD/MM/YYYY'), TO_DATE ('30/07/2014 10:10:15', 'DD/MM/YYYY HH24:MI:SS'),
        TO_DATE ('30/07/2014', 'DD/MM/YYYY'), 'Y', 'Y', 'N', 'N',
        'RM0002', 'RM0002', 1, 'N',
        'Bucket 9. Created by RM, closed same day by RM', '9') ;

-- Long journey
-- Bucket 16. Closed by OT then reopened by another OT after FL -> RM, RM -> RM, RM -> RR, Closed, RR -> OT Reopened, Closed, OT -> OT Reopened
INSERT INTO AML_T_COMPLAINTS_CREATED_CR
(complaint_id, fin_acc_ref, dw_from_date, dw_to_date, created_date, effective_from_date, created_date_time,
 closed_date, closed_flag, closed_same_day_flag, hand_off_flag, reopen_flag,
 created_by_user_id, owned_by_user_id, sector_id, ombudsman_complaint_indicator, summary, expected_bucket)
VALUES (50, '50', TO_DATE ('01/08/2014', 'DD/MM/YYYY'), TO_DATE ('31/12/9999', 'DD/MM/YYYY'), TO_DATE ('30/07/2014', 'DD/MM/YYYY'), TO_DATE ('30/07/2014', 'DD/MM/YYYY'), TO_DATE ('30/07/2014 10:10:15', 'DD/MM/YYYY HH24:MI:SS'),
        NULL, 'N', 'N', 'Y', 'Y',
        'FL0001', 'OT0002', 1, 'N',
        'Bucket 16. Closed by OT then reopened by another OT after FL -> RM, RM -> RM, RM -> RR, Closed, RR -> OT Reopened, Closed, OT -> OT Reopened', '16') ;

INSERT INTO AML_T_COMPLAINTS_HANDOFF_CR
   (COMPLAINT_ID, HAND_OFF_DATE, HAND_OFF_USER_ID, HAND_OFF_FROM_USER_ID) 
VALUES (50, TO_DATE ('01/08/2014 11:50:45', 'DD/MM/YYYY HH24:MI:SS'), 'RM0001', 'FL0001') ;

INSERT INTO AML_T_COMPLAINTS_HANDOFF_CR
   (COMPLAINT_ID, HAND_OFF_DATE, HAND_OFF_USER_ID, HAND_OFF_FROM_USER_ID) 
VALUES (50, TO_DATE ('01/08/2014 14:50:45', 'DD/MM/YYYY HH24:MI:SS'), 'RM0002', 'RM0001') ;

INSERT INTO AML_T_COMPLAINTS_HANDOFF_CR
   (COMPLAINT_ID, HAND_OFF_DATE, HAND_OFF_USER_ID, HAND_OFF_FROM_USER_ID) 
VALUES (50, TO_DATE ('01/08/2014 15:50:45', 'DD/MM/YYYY HH24:MI:SS'), 'RR0001', 'RM0002') ; -- Closed

INSERT INTO AML_T_COMPLAINTS_HANDOFF_CR
   (COMPLAINT_ID, HAND_OFF_DATE, HAND_OFF_USER_ID, HAND_OFF_FROM_USER_ID) 
VALUES (50, TO_DATE ('02/08/2014 13:50:45', 'DD/MM/YYYY HH24:MI:SS'), 'OT0001', 'RR0001') ;

INSERT INTO AML_T_COMPLAINTS_REOPEN_CR
 (complaint_id, reopen_date, pre_reopen_user_id, reopen_user_id)
 VALUES (50, TO_DATE ('02/08/2014 10:10:10', 'DD/MM/YYYY HH24:MI:SS'), 'RR0001', 'OT0001') ; -- Reopened

INSERT INTO AML_T_COMPLAINTS_HANDOFF_CR
   (COMPLAINT_ID, HAND_OFF_DATE, HAND_OFF_USER_ID, HAND_OFF_FROM_USER_ID) 
VALUES (50, TO_DATE ('03/08/2014 13:50:45', 'DD/MM/YYYY HH24:MI:SS'), 'OT0002', 'OT0001') ;

INSERT INTO AML_T_COMPLAINTS_REOPEN_CR
 (complaint_id, reopen_date, pre_reopen_user_id, reopen_user_id)
 VALUES (50, TO_DATE ('03/08/2014 10:10:10', 'DD/MM/YYYY HH24:MI:SS'), 'OT0001', 'OT0002') ; -- Reopened

-- Bucket 16. Closed by RR then reopened by another RR, Closed, Reopened by OT after FL -> RM, RM -> RR
INSERT INTO AML_T_COMPLAINTS_CREATED_CR
(complaint_id, fin_acc_ref, dw_from_date, dw_to_date, created_date, effective_from_date, created_date_time,
 closed_date, closed_flag, closed_same_day_flag, hand_off_flag, reopen_flag,
 created_by_user_id, owned_by_user_id, sector_id, ombudsman_complaint_indicator, summary, expected_bucket)
VALUES (51, '51', TO_DATE ('01/08/2014', 'DD/MM/YYYY'), TO_DATE ('31/12/9999', 'DD/MM/YYYY'), TO_DATE ('30/07/2014', 'DD/MM/YYYY'), TO_DATE ('30/07/2014', 'DD/MM/YYYY'), TO_DATE ('30/07/2014 10:10:15', 'DD/MM/YYYY HH24:MI:SS'),
        NULL, 'N', 'N', 'Y', 'Y',
        'FL0001', 'OT0002', 1, 'N',
        'Bucket 16. Closed by RR then reopened by another RR, Closed, Reopened by OT after FL -> RM, RM -> RR', '16') ;

INSERT INTO AML_T_COMPLAINTS_HANDOFF_CR
   (COMPLAINT_ID, HAND_OFF_DATE, HAND_OFF_USER_ID, HAND_OFF_FROM_USER_ID) 
VALUES (51, TO_DATE ('01/08/2014 11:50:45', 'DD/MM/YYYY HH24:MI:SS'), 'RM0001', 'FL0001') ;

INSERT INTO AML_T_COMPLAINTS_HANDOFF_CR
   (COMPLAINT_ID, HAND_OFF_DATE, HAND_OFF_USER_ID, HAND_OFF_FROM_USER_ID) 
VALUES (51, TO_DATE ('01/08/2014 15:50:45', 'DD/MM/YYYY HH24:MI:SS'), 'RR0001', 'RM0001') ; -- Closed

INSERT INTO AML_T_COMPLAINTS_HANDOFF_CR
   (COMPLAINT_ID, HAND_OFF_DATE, HAND_OFF_USER_ID, HAND_OFF_FROM_USER_ID) 
VALUES (51, TO_DATE ('02/08/2014 13:50:45', 'DD/MM/YYYY HH24:MI:SS'), 'RR0002', 'RR0001') ;

INSERT INTO AML_T_COMPLAINTS_REOPEN_CR
 (complaint_id, reopen_date, pre_reopen_user_id, reopen_user_id)
 VALUES (51, TO_DATE ('02/08/2014 10:10:10', 'DD/MM/YYYY HH24:MI:SS'), 'RR0001', 'RR0002') ; -- Reopened

INSERT INTO AML_T_COMPLAINTS_HANDOFF_CR
   (COMPLAINT_ID, HAND_OFF_DATE, HAND_OFF_USER_ID, HAND_OFF_FROM_USER_ID) 
VALUES (51, TO_DATE ('03/08/2014 13:50:45', 'DD/MM/YYYY HH24:MI:SS'), 'OT0002', 'RR0002') ;

INSERT INTO AML_T_COMPLAINTS_REOPEN_CR
 (complaint_id, reopen_date, pre_reopen_user_id, reopen_user_id)
 VALUES (51, TO_DATE ('03/08/2014 10:10:10', 'DD/MM/YYYY HH24:MI:SS'), 'OT0002', 'RR0002') ; -- Reopened

COMMIT ;

-- *********************************************************************************************************
-- *******************
-- INCREMENTAL INSERTS
-- *******************
-- Run on next analysis date

-- From bucket 5a to 17 - RM -> OT
UPDATE AML_T_COMPLAINTS_CREATED_CR
       SET dw_to_date = TO_DATE ('02/08/2014', 'DD/MM/YYYY')
WHERE  complaint_id = 7
       AND dw_to_date = TO_DATE ('31/12/9999', 'DD/MM/YYYY')
;
       
INSERT INTO AML_T_COMPLAINTS_CREATED_CR
(complaint_id, fin_acc_ref, dw_from_date, dw_to_date, created_date, effective_from_date, created_date_time,
 closed_date, closed_flag, closed_same_day_flag, hand_off_flag, reopen_flag,
 created_by_user_id, owned_by_user_id, sector_id, ombudsman_complaint_indicator, summary, expected_bucket)
VALUES (7, '7', TO_DATE ('03/08/2014', 'DD/MM/YYYY'), TO_DATE ('31/12/9999', 'DD/MM/YYYY'), TO_DATE ('30/07/2014', 'DD/MM/YYYY'), TO_DATE ('30/07/2014', 'DD/MM/YYYY'), TO_DATE ('30/07/2014 10:10:10', 'DD/MM/YYYY HH24:MI:SS'),
        NULL, 'N', 'N', 'Y', 'N',
        'RM0001', 'OT0001', 1, 'N',
        'Bucket 17. Progressed from RM to OT', '17') ;

INSERT INTO AML_T_COMPLAINTS_HANDOFF_CR
   (COMPLAINT_ID, HAND_OFF_DATE, HAND_OFF_USER_ID, HAND_OFF_FROM_USER_ID)
VALUES (7, TO_DATE ('03/08/2014 16:20:45', 'DD/MM/YYYY HH24:MI:SS'), 'OT0001', 'RM0001') ;

COMMIT ;

-- Closed same day flag = If currently closed and trunc (created date) (not opened date, as does not handle reopens!) = trunc (closed date)
-- Reopen = If ever a closed status followed by an open status
-- Closed = If current status = closed
-- Hand off = If ever, previous owner <> current one

-- **************************************************************************************************
-- Query
-- **************************************************************************************************
DROP TABLE AML_T_HWC_BUCKETS ;

DELETE FROM AML_T_HWC_BUCKETS ;

INSERT INTO AML_T_HWC_BUCKETS
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

COMMIT ;

-- Bucket 1. Complaints created
-- INSERT INTO AML_T_HWC_BUCKETS
WITH src AS (
    SELECT   c.complaint_id
           , c.created_date
           , c.created_date_time
           , c.created_by_user_id
           , c.owned_by_user_id
           , NVL (ho.hand_off_from_user_id, c.owned_by_user_id) AS last_progressed_by_user_id
           , c.sector_id
           , c.summary
           , '1' AS expected_bucket
           , ROW_NUMBER () OVER (PARTITION BY c.complaint_id ORDER BY fin_acc_ref ASC, hand_off_date DESC) AS rn
    FROM   aml_t_complaints_created_cr     c
    LEFT JOIN aml_t_complaints_handoff_cr ho -- Hand-offs
           ON ho.complaint_id = c.complaint_id
)
    SELECT   complaint_id
           , created_date
           , created_by_user_id
           , owned_by_user_id
           , sector_id
           , NULL AS closed_date, 'N' closed_flag, 'N' closed_same_day_flag, NULL AS hand_off_date, NULL AS hand_off_flag, NULL AS hand_off_user_id
           , NULL AS hand_off_from_user_id
           , last_progressed_by_user_id
           , NULL AS reopen_date, NULL AS pre_reopen_user_id, NULL AS reopen_user_id
           , NULL AS reopen_flag
           , summary
           , NULL AS cr_role_desc, NULL AS ow_role_desc, NULL AS ho_role_desc, NULL AS pro_role_desc, NULL AS ro_role_desc
           , NULL AS creator_rank, NULL AS owner_rank, NULL AS hand_off_from_rank, NULL AS pre_reopen_rank, NULL AS reopen_rank, NULL AS rn
           , NULL AS ipf_exception_user_rank, NULL AS ipb_exception_user_rank, NULL AS ro_exception_user_rank, NULL AS ipf_bucket, NULL AS ipb_bucket
           , expected_bucket
           , '1' AS bucket
           , 'Y' result_check
           , CASE WHEN TO_CHAR (SYSDATE, 'D') = '1' -- As if it had been run on Mondays
                  THEN TRUNC (SYSDATE)
                  ELSE NEXT_DAY (TRUNC (SYSDATE + 7), 'Monday') -7
             END AS analysis_date
     FROM src
     WHERE rn = 1
     ORDER BY complaint_id
;

-- ***************
-- Summary queries
-- ***************

DELETE FROM AML_T_HWC_BUCKETS
WHERE analysis_date = NEXT_DAY (TRUNC (SYSDATE + 7), 'Monday') -7 ;

SELECT t2.analysis_date, t2.bucket, 
       COUNT (distinct t1.complaint_id) AS bucket_cnt
FROM   AML_T_HWC_BUCKETS t1,
       (SELECT bucket, analysis_date FROM (SELECT distinct bucket FROM AML_T_HWC_BUCKETS),
                                                   (SELECT distinct analysis_date FROM AML_T_HWC_BUCKETS)) t2
WHERE  t1.bucket (+) = t2.bucket
       AND t1.analysis_date (+) = t2.analysis_date
GROUP BY t2.analysis_date, t2.bucket
ORDER BY t2.bucket, t2.analysis_date
;

-- ***************************************
-- Unit test log
-- ***************************************
-- Ran on 30/08/2014
-- By Csaba Riedlinger

-- Features, scenarios tested:

-- 1. Bucket 2. Not progressed by FL
-- 2. Bucket 2a. FL peer change
-- 3. Bucket 3. Closed same day by FL
-- 4. Bucket 3a. Closed but not the same day by FL
-- 5. Bucket 4. Closed (same day or not) by FL then reopened - Exception test
-- 6. Bucket 5. Progressed from FL to RM
-- 7. Bucket 5a. RM peer change
-- 8. Bucket 5b. Created by RM and sits with RM, no peer change
-- 9. Bucket 6. Progressed by FL to RR (skipping RM)
-- 10. Bucket 7. Incorrectly progressed (forwards) by FL (to OT)
-- 11. Bucket X01. Incorrectly progressed (backwards) by RM (to FL) - Exception test
-- 12. Bucket X01. Incorrectly progressed (backwards) by RR (to FL) - Exception test
-- 13. Bucket X01. Incorrectly progressed (backwards) by OT (to FL) - Exception test
-- 14. Bucket X02. Incorrectly progressed (backwards) by RR (to RM) - Exception test
-- 15. Bucket X02. Incorrectly progressed (backwards) by RR (to RM) - Exception test
-- 16. Bucket X03. Incorrectly progressed (backwards) by OT (to RR) - Exception test
-- 17. Bucket 9. Closed same day by RM (same day starts from the moment it took the complaint over)
-- 18. Bucket 9a. Closed but not the same day by RM
-- 19. Bucket 10. Closed (same day or not) by RM then reopened - Exception test
-- 20. Bucket 11. Progressed from RM to RR
-- 21. Bucket 11a. RR peer change
-- 22. Bucket 11b. Created by RR and sits with RR, no peer change
-- 23. Bucket 13. Incorrectly progressed (forwards) by RM (to Manager) - Exception test
-- 24. Bucket 15. Closed same day by RR (same day starts from the moment it took the complaint over)
-- 25. Bucket 15a. Closed but not the same day by RR
-- 26. Bucket 16. Closed (same day or not) by RR then reopened - Exception test
-- 27. Bucket 17. Progressed from RM or RR to OT
-- 28. Bucket 17a. OT peer change
-- 29. Bucket 17b. Created by OT and sits with OT, no peer change
-- 30. Bucket 18. Incorrectly progressed (forwards) by RR (to Manager) - Exception test
-- 31. Bucket 20. Closed same day by OT (same day starts from the moment it took the complaint over)
-- 32. Bucket 20a. Closed but not the same day by OT
-- 33. Bucket 21. Closed (same day or not) by OT then reopened - Exception test
-- 34. Bucket 22. Incorrectly progressed (forwards) by OT (to Manager) - Exception test
-- 35. Duplicates test - on financial account reference
-- 36. Mixed cases: -- Incorrectly progressed (forwards) by FL (to Manager) then back to RM
-- 37. Bucket 9. Created by RM, closed same day by RM
-- 38. Long journey: Bucket 16. Closed by OT then reopened by another OT after FL -> RM, RM -> RM, RM -> RR, Closed, RR -> OT Reopened, Closed, OT -> OT Reopened
-- 39. Bucket 16. Closed by RR then reopened by another RR, Closed, Reopened by OT after FL -> RM, RM -> RR
-- 40. Incremental update, simulating a re-run of classification on a different analysis date
-- 41. Bucket 1. Complaints created test - reconcialiation of bucket total and created total
-- 42. Monthly aggregate query test
-- 43. Explain plan checked: CBO uses hash joins, no carthesian joins
