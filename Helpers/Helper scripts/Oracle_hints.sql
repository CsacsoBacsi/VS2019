-- Oracle Hints
WITH feature_hierarchy AS (
   SELECT f.sql_feature,
          level lev,
          SYS_CONNECT_BY_PATH (REPLACE (f.sql_feature, 'QKSFM_', ''), ' -> ') path
   FROM   v$sql_feature f,
          v$sql_feature_hierarchy fh 
   WHERE 
          f.sql_feature = fh.sql_feature 
   CONNECT BY fh.parent_id = PRIOR f.sql_Feature 
   START WITH fh.sql_feature = 'QKSFM_ALL'
)
SELECT hi.name as hint_name,
       f.description,
       REGEXP_REPLACE(fh.path, '^ -> ', '') hint_path,
       hi.version
FROM   v$sql_hint hi,
       feature_hierarchy fh,
       v$sql_feature f
WHERE  hi.sql_feature = fh.sql_feature
       and hi.sql_feature = f.sql_feature
       AND UPPER (hi.name) LIKE UPPER ('USE_HASH%')
ORDER BY name, path ;

SELECT *
FROM   V$SQL_HINT h,
       V$SQL_FEATURE f
WHERE  h.SQL_FEATURE = f.SQL_FEATURE
order by name asc ;

SELECT * FROM V$SQL_FEATURE ;

SELECT LPAD(' ', (level-1)*4) || REPLACE(f.sql_feature, 'QKSFM_','') sqlfh_feature,
       f.description 
FROM   v$sql_feature f,
       v$sql_feature_hierarchy fh 
WHERE  f.sql_feature = fh.sql_feature 
CONNECT BY fh.parent_id = PRIOR f.sql_feature 
START WITH fh.sql_feature = 'QKSFM_ALL' ;

SELECT *
FROM   v$sql_feature_hierarchy fh ;


