-- Analytics

-- Create TEST_DATA and populate it
create table test_data (
   "ID" number,
   "VALUE" number,
   "DESC" varchar2 (100),
   "GROUP_VAL" number)
;

insert into test_data
select rownum as id,
       1000-rownum as value,
       CASE WHEN length (to_char (rownum)) > 1 and substr (to_char (rownum), length (to_char (rownum)) - 1, 2) = '11'
            THEN to_char (rownum) || 'th row'
            WHEN length (to_char (rownum)) > 1 and substr (to_char (rownum), length (to_char (rownum)) - 1, 2) = '12'
            THEN to_char (rownum) || 'th row'
            WHEN length (to_char (rownum)) > 1 and substr (to_char (rownum), length (to_char (rownum)) - 1, 2) = '13'
            THEN to_char (rownum) || 'th row'
            WHEN substr (to_char (rownum), length (to_char (rownum)), 1) = '1'
            THEN to_char (rownum) || 'st row'
            WHEN substr (to_char (rownum), length (to_char (rownum)), 1) = '2'
            THEN to_char (rownum) || 'nd row'
            WHEN substr (to_char (rownum), length (to_char (rownum)), 1) = '3'
            THEN to_char (rownum) || 'rd row'
            ELSE to_char (rownum) || 'th row'
       END "DESC",
       to_number (substr (to_char (rownum), length (to_char (rownum)), 1)) as GROUP_VAL
from   dual
connect by level <= 1000 ;

-- #1 rule: where applicable, all functions work in the window RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW

-- *** SUM ***
-- Cummulative (running) sum. The sum of VALUEs of the current row and preceding rows (as of the #1 rule!)
SELECT t.*, SUM (value) over (order by ID desc) CUMMULATIVE_SUM
FROM   TEST_DATA t ;

-- Total sum in each group
SELECT t.*, SUM (value) over (partition by group_val) GROUP_SUM
FROM   TEST_DATA t ;

-- *** MAX ***
-- The max VALUE up to the current row
SELECT t.*, MAX (value) over (order by ID desc) MAX_SO_FAR
FROM   TEST_DATA t ;

-- The max in each group
SELECT t.*, MAX (value) over (partition by group_val) GROUP_MAX
FROM   TEST_DATA t ;

-- *** AVG ***
-- The average in each group
SELECT t.*, AVG (value) over (partition by group_val) GROUP_AVG
FROM   TEST_DATA t ;

-- *** WINDOW ***
-- Running average per group
SELECT t.*, AVG (value) OVER (ORDER BY GROUP_VAL ROWS UNBOUNDED PRECEDING) AVG_PER_GROUP
FROM   TEST_DATA t
ORDER BY GROUP_VAL ;

-- Running average per group. Current row and all preceding rows' average
SELECT t.*, AVG (value) OVER (PARTITION BY GROUP_VAL ORDER BY GROUP_VAL ROWS UNBOUNDED PRECEDING) AVG_PER_GROUP
FROM   TEST_DATA t
ORDER BY GROUP_VAL ;

-- Average per group. Current row and 2 preceding rows' average
SELECT t.*, AVG (value) OVER (PARTITION BY GROUP_VAL ORDER BY GROUP_VAL ROWS 2 PRECEDING) AVG_3_PER_GROUP
FROM   TEST_DATA t
ORDER BY GROUP_VAL ;

-- Running SUM per group. Current row, 2 preceding rows' and 2 following rows' sum
SELECT t.*, SUM (value) OVER (PARTITION BY GROUP_VAL ORDER BY GROUP_VAL ROWS BETWEEN 2 PRECEDING AND 2 FOLLOWING) SUM_5_PER_GROUP
FROM   TEST_DATA t
ORDER BY GROUP_VAL ;

-- Running SUM per group. Current row and 2 following rows' sum
SELECT t.*, SUM (value) OVER (PARTITION BY GROUP_VAL ORDER BY GROUP_VAL ROWS BETWEEN CURRENT ROW AND 2 FOLLOWING) SUM_3_PER_GROUP
FROM   TEST_DATA t
ORDER BY GROUP_VAL ;

-- Difference between ROWS and RANGE. RANGE refers to the column in the order by clause.
-- Running SUM per group. Current row and all preceding rows' sum
SELECT t.*, SUM (value) OVER (PARTITION BY GROUP_VAL ORDER BY ID RANGE UNBOUNDED PRECEDING) SUM_PER_GROUP
FROM   TEST_DATA t
ORDER BY GROUP_VAL ;

-- Insert a duplicate
INSERT INTO TEST_DATA (ID, VALUE, "DESC", GROUP_VAL)
VALUES (50, 100, '50th second row', 0) ;

-- Running SUM using RANGE per group. Current row and all preceding rows' sum
SELECT t.*, SUM (value) OVER (PARTITION BY GROUP_VAL ORDER BY ID RANGE UNBOUNDED PRECEDING) SUM_PER_GROUP
FROM   TEST_DATA t
ORDER BY GROUP_VAL ; -- The rows with the same id get the same sum

-- Running SUM using ROWS per group. Current row and all preceding rows' sum
SELECT t.*, SUM (value) OVER (PARTITION BY GROUP_VAL ORDER BY ID ROWS UNBOUNDED PRECEDING) SUM_PER_GROUP
FROM   TEST_DATA t
ORDER BY GROUP_VAL, ID ; -- The rows with the same id get different sums dependent upon which comes first

-- *** KEEP FIRST/LAST DENSE RANK ***
-- When you need a value from the first or last row of a sorted group, but the needed value is not the sort key, 
-- the FIRST and LAST functions eliminate the need for self-joins or views and enable better performance
SELECT t.*,
       MIN (value) KEEP (DENSE_RANK FIRST ORDER BY id) OVER (PARTITION BY GROUP_VAL) MIN_VALUE
       MAX (value) KEEP (DENSE_RANK LAST ORDER BY id) OVER (PARTITION BY GROUP_VAL) MAX_VALUE, 
FROM TEST_DATA t
ORDER BY GROUP_VAL, ID ; -- Within GROUP_VAL, sort by ID and get FIRST's and LAST's VALUE value.
-- Sorting key is ID but the value needed is VALUE

-- Insert duplicate value to see the effect of an aggregation function
INSERT INTO TEST_DATA (ID, VALUE, "DESC", GROUP_VAL)
VALUES (10, 1, '10th second row', 0) ;

-- The KEEP means nothing just says that we keep the first or last row
SELECT t.*,
       SUM (value) KEEP (DENSE_RANK FIRST ORDER BY id) OVER (PARTITION BY GROUP_VAL) MIN_VALUE,
       MAX (value) KEEP (DENSE_RANK LAST ORDER BY id) OVER (PARTITION BY GROUP_VAL) MAX_VALUE
FROM TEST_DATA t
ORDER BY GROUP_VAL, ID ;
-- If two values finish with the same rank, the sum of the two values will be the result

-- Otherwise the equivalent would be two table scans:
SELECT t.GROUP_VAL, t2.MIN_ID, SUM (VALUE) as MIN_ID_VALUE
FROM   TEST_DATA t, 
       (SELECT t2.GROUP_VAL, MIN (t2.ID) as MIN_ID
        FROM TEST_DATA t2
        GROUP BY t2.GROUP_VAL) t2 -- Get the min ID per GROUP_VAL
WHERE  t.GROUP_VAL = t2.GROUP_VAL
       AND t.ID = t2.MIN_ID
GROUP BY t.GROUP_VAL, t2.MIN_ID
ORDER BY t.GROUP_VAL, t2.MIN_ID ; -- SUM (value) for group 0 is 901 because there is a duplicate id (10) in this group

-- *** FIRST_VALUE, LAST_VALUE ***
-- First value returns the first (min) value after a sort
SELECT t.*, FIRST_VALUE (value) over (partition by group_val order by id) FIRST_VAL
FROM   TEST_DATA t
ORDER BY t.GROUP_VAL, ID ;

SELECT t.*, LAST_VALUE (value) over (partition by group_val order by id) LAST_VAL
FROM   TEST_DATA t
ORDER BY t.GROUP_VAL, ID ; -- Is this a bug?????
-- No, the default window clause is RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW, so the system only considered
-- the current row and anything before

-- It works now fine:
SELECT t.*, LAST_VALUE (value) over (partition by group_val order by id RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) LAST_VAL
FROM   TEST_DATA t
ORDER BY t.GROUP_VAL, ID ;

-- *** LAG, LEAD ***
-- Get nth previous or following row's value
SELECT t.*,
       LAG (value, 3, 0) over (partition by group_val order by id) PREVIOUS_VAL,
       LEAD (value, 3, 0) over (partition by group_val order by id) NEXT_VAL
FROM   TEST_DATA t
ORDER BY t.GROUP_VAL, ID ;

-- The following does not work (invalid) as there is no windowing-clause with LAG or LEAD
SELECT t.*,
       LAG (value, 3, 0) over (partition by group_val order by id ROWS BETWEEN 2 PRECEDING AND 2 FOLLOWING) PREVIOUS_VAL,
       LEAD (value, 3, 0) over (partition by group_val order by id ROWS BETWEEN 2 PRECEDING AND 2 FOLLOWING) NEXT_VAL
FROM   TEST_DATA t
ORDER BY t.GROUP_VAL, ID ;

-- *** RATIO_TO_REPORT ***
-- Current value devided by the partition total (GROUP_VAL)
SELECT t.*, 
       SUM (value) OVER (PARTITION BY GROUP_VAL) GROUP_VAL_SUM,
       RATIO_TO_REPORT (value) over (partition by group_val) RATIO_TO_REPORT
FROM   TEST_DATA t
ORDER BY t.GROUP_VAL, ID ;

-- *** COUNT ***
-- It is like count (*) with a group by
SELECT t.*, 
       COUNT (value) OVER (PARTITION BY GROUP_VAL) GROUP_VAL_COUNT
FROM   TEST_DATA t
ORDER BY t.GROUP_VAL, ID ;

-- *** ROW_NUMBER ***
-- Assigns a number to each row returned (also within the partition)
SELECT t.*, 
       ROW_NUMBER () OVER (PARTITION BY GROUP_VAL order by value) ROW_NUM_GROUPED
FROM   TEST_DATA t
ORDER BY t.GROUP_VAL, ID ;

-- Highest to lowest value
SELECT t.*, 
       ROW_NUMBER () OVER (order by value desc) ROW_NUM_GLOBAL
FROM   TEST_DATA t
ORDER BY t.GROUP_VAL, ID ;

-- STDDEV ***
-- Standard deviation (within a group)
SELECT t.*, 
       STDDEV (value) OVER (PARTITION BY GROUP_VAL) STDDEV
FROM   TEST_DATA t
ORDER BY t.GROUP_VAL, ID ;

-- End
