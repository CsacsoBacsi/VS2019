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
        'MG0001', 'MG 1', '-', 'Y') ;

INSERT INTO DIM_T_ODA_USER_FLAT_CR
       (dw_from_date, dw_to_date, 
        user_id, user_name, job_role_description, is_manager)
VALUES (TO_DATE ('01/01/2014', 'DD/MM/YYYY'), TO_DATE ('31/12/9999', 'DD/MM/YYYY'), 
        'MG0002', 'MG 2', '-', 'Y') ;

COMMIT ;

-- *******************************
-- Complaints, hando-ffs, re-opens
-- Bucket 2. Not progressed by FL
TRUNCATE TABLE AML_T_COMPLAINTS_CREATED_CR ;
TRUNCATE TABLE AML_T_COMPLAINTS_HANDOFF_CR ;
TRUNCATE TABLE AML_T_COMPLAINTS_REOPEN_CR ;

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
        NULL, 'N', 'N', 'N', 'N',
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
 VALUES (5, TO_DATE ('05/08/2014', 'DD/MM/YYYY'), 'FL0001', 'RM0001') ;

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
        'Bucket X02. Incorrectly progressed (backwards) by OT (to RR)', 'X03') ;

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
 VALUES (19, TO_DATE ('05/08/2014', 'DD/MM/YYYY'), 'RM0001', 'RM0002') ;

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
 VALUES (26, TO_DATE ('06/08/2014', 'DD/MM/YYYY'), 'RR0002', 'OT0002') ;

-- Bucket 17. Progressed from RR to OT
INSERT INTO AML_T_COMPLAINTS_CREATED_CR
(complaint_id, fin_acc_ref, dw_from_date, dw_to_date, created_date, effective_from_date, created_date_time,
 closed_date, closed_flag, closed_same_day_flag, hand_off_flag, reopen_flag,
 created_by_user_id, owned_by_user_id, sector_id, ombudsman_complaint_indicator, summary, expected_bucket)
VALUES (27, '27', TO_DATE ('01/08/2014', 'DD/MM/YYYY'), TO_DATE ('31/12/9999', 'DD/MM/YYYY'), TO_DATE ('30/07/2014', 'DD/MM/YYYY'), TO_DATE ('30/07/2014', 'DD/MM/YYYY'), TO_DATE ('30/07/2014 10:10:15', 'DD/MM/YYYY HH24:MI:SS'),
        NULL, 'N', 'N', 'Y', 'N',
        'FL0001', 'OT0001', 1, 'N',
        'Bucket 17. Progressed from RR to OT', '17') ;

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
 VALUES (33, TO_DATE ('07/08/2014', 'DD/MM/YYYY'), 'OT0001', 'OT0002') ;

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

-- Duplicates - on financial account reference
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
        'Bucket -2. Incorrectly progressed (forwards) by OT (to Manager) then back to RM', '-2') ;

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
-- Busket 21. Closed by OT then reopened another OT after FL -> RM, RM -> RM, RM -> RR, Closed, RR -> OT Reopened, Closed, OT -> OT Reopened
INSERT INTO AML_T_COMPLAINTS_CREATED_CR
(complaint_id, fin_acc_ref, dw_from_date, dw_to_date, created_date, effective_from_date, created_date_time,
 closed_date, closed_flag, closed_same_day_flag, hand_off_flag, reopen_flag,
 created_by_user_id, owned_by_user_id, sector_id, ombudsman_complaint_indicator, summary, expected_bucket)
VALUES (50, '50', TO_DATE ('01/08/2014', 'DD/MM/YYYY'), TO_DATE ('31/12/9999', 'DD/MM/YYYY'), TO_DATE ('30/07/2014', 'DD/MM/YYYY'), TO_DATE ('30/07/2014', 'DD/MM/YYYY'), TO_DATE ('30/07/2014 10:10:15', 'DD/MM/YYYY HH24:MI:SS'),
        NULL, 'N', 'N', 'Y', 'Y',
        'FL0001', 'OT0002', 1, 'N',
        'Busket 21. Closed by OT then reopened another OT after FL -> RM, RM -> RM, RM -> RR, Closed, RR -> OT Reopened, Closed, OT -> OT Reopened', '21') ;

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
 VALUES (50, TO_DATE ('02/08/2014', 'DD/MM/YYYY'), 'RR0001', 'OT0001') ; -- Reopened

INSERT INTO AML_T_COMPLAINTS_HANDOFF_CR
   (COMPLAINT_ID, HAND_OFF_DATE, HAND_OFF_USER_ID, HAND_OFF_FROM_USER_ID) 
VALUES (50, TO_DATE ('03/08/2014 13:50:45', 'DD/MM/YYYY HH24:MI:SS'), 'OT0002', 'OT0001') ;

INSERT INTO AML_T_COMPLAINTS_REOPEN_CR
 (complaint_id, reopen_date, pre_reopen_user_id, reopen_user_id)
 VALUES (50, TO_DATE ('02/08/2014', 'DD/MM/YYYY'), 'OT0001', 'OT0002') ; -- Reopened

COMMIT ;


