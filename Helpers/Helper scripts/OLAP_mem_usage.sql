SELECT vs.username, vs.sid, round(pga_used_mem / 1024 / 1024, 2) || ' MB' pga_used_mem_mb ,
       round(pga_max_mem) / 1024 / 1024 || ' MB' pga_max_mb, round(pool_size) / 1024 / 1024 || ' MB' olap_mb,
       round(100 * (pool_hits - pool_misses) / pool_hits, 2) || ' %' olap_ratio
FROM   v$process vp,  
       v$session vs,
       v$aw_calc va
WHERE  session_id = vs.sid  AND addr = paddr and vs.username = 'GDF_AW' ;

exec dbms_aw.execute ('aw attach gdf_aw.gdf') ;  

exec dbms_aw.execute ('aw detach gdf_aw.gdf') ;

SELECT 'OLAP Pages Occupying: ' || round ((((SELECT sum(nvl(pool_size,1)) 
FROM   v$aw_calc)) / (SELECT value FROM v$pgastat 
WHERE name = 'total PGA inuse')),2) * 100 || '%' info  FROM dual 
UNION   
SELECT 'Total PGA In use Size: ' || value / 1024 || 'KB' info 
FROM v$pgastat  
WHERE  name = 'total PGA inuse'  
UNION
SELECT 'Total OLAP Page Size: ' || round(sum(nvl(pool_size,1)) / 1024, 0) || ' KB' info 
FROM   v$aw_calc  
ORDER BY info DESC ;

SELECT vs.username, vs.sid, round(pga_used_mem / 1024 / 1024, 2) || ' MB' pga_used_mem_mb, 
        round(pga_max_mem  / 1024 / 1024, 2) || ' MB' pga_max_mb, round(pool_size / 1024 / 1024, 2) || ' MB' olap_mb,
        round(100 * (pool_hits - pool_misses) / pool_hits, 2) || ' %' olap_ratio 
FROM   v$process vp,
       v$session vs,
       v$aw_calc va
WHERE  session_id = vs.sid 
       AND    addr = paddr  
       AND vs.username = 'GDF_AW' ;