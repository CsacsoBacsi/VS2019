-- Works even in brand new session as well
MERGE INTO TEST_DATA t
USING (SELECT NULL as ID, 10 as value , 'Hi' as "DESC", 1 as group_val from dual) a
ON (t.VALUE = a.VALUE)
WHEN NOT MATCHED THEN
INSERT (id, value, "DESC", group_val)
VALUES (csaba_seq.currval, csaba_seq.nextval, a."DESC" || csaba_seq.currval, a.group_val) ;

-- does not work in a new session. NEXTVAL is needed first
MERGE INTO TEST_DATA t
USING (SELECT NULL as ID, 10 as value , 'Hi' as "DESC", 1 as group_val from dual) a
ON (t.VALUE = a.VALUE)
WHEN NOT MATCHED THEN
INSERT (id, value, "DESC", group_val)
VALUES (csaba_seq.currval, 4, a."DESC" || csaba_seq.currval, a.group_val) ;

-- This works fine
MERGE INTO TEST_DATA t
USING (SELECT NULL as ID, 10 as value , 'Hi' as "DESC", 1 as group_val from dual) a
ON (t.VALUE = a.VALUE)
WHEN NOT MATCHED THEN
INSERT (id, value, "DESC", group_val)
VALUES (csaba_seq.nextval, csaba_seq.currval, a."DESC" || csaba_seq.currval, a.group_val) ;

-- This works fine too. USING does not have to have same number of columns as the insert wants
MERGE INTO TEST_DATA t
USING (SELECT NULL as ID, 10 as value , 'Hi' as "DESC" from dual) a
ON (t.VALUE = a.VALUE)
WHEN NOT MATCHED THEN
INSERT (id, value, "DESC", group_val)
VALUES (csaba_seq.nextval, csaba_seq.currval, a."DESC" || csaba_seq.currval, 9) ;

-- And this works fine too. The two calls to NEXTVAL returns the same value i.e. does not get incremented 2x
MERGE INTO TEST_DATA t
USING (SELECT NULL as ID, 10 as value , 'Hi' as "DESC" from dual) a
ON (t.VALUE = a.VALUE)
WHEN NOT MATCHED THEN
INSERT (id, value, "DESC", group_val)
VALUES (csaba_seq.nextval, csaba_seq.nextval, a."DESC" || csaba_seq.currval, 99) ;

-- This does not work in the MERGE statement. Bug.
MERGE INTO TEST_DATA t
USING (SELECT NULL as ID, 15 as value , 'Hi' as "DESC", 1 as group_val from dual) a
ON (t.VALUE = a.VALUE)
WHEN NOT MATCHED THEN
INSERT (id, value, "DESC", group_val)
VALUES (csaba_seq.nextval, (SELECT last_number FROM user_sequences WHERE sequence_name = sequence_name), a."DESC" || csaba_seq.currval, a.group_val) ;

SELECT last_number FROM all_sequences s WHERE sequence_name = 'CSABA_SEQ' ;

-- Bug. The insert works
INSERT INTO TEST_DATA (id, value, "DESC", group_val)
VALUES (csaba_seq.nextval, (SELECT last_number FROM user_sequences WHERE sequence_name = 'CSABA_SEQ'), 'hm' || csaba_seq.currval, 2) ;
