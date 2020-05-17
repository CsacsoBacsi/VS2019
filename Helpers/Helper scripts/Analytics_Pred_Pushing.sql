WITH emp as (
   select 1 as empno, 'MILLER' as ename, 10 as deptno, 5000 as sal, 'CLERK' as job from dual
   union all
   select 2 as empno, 'SMITH' as ename, 10 as deptno, 6000 as sal, 'CLERK' as job from dual
   union all
   select 3 as empno, 'JAMES' as ename, 10 as deptno, 15000 as sal, 'TEACHER' as job from dual
   union all
   select 4 as empno, 'CSACSI' as ename, 20 as deptno, 3000 as sal, 'CLERK' as job from dual
   union all
   select 5 as empno, 'ANNA' as ename, 10 as deptno, 8000 as sal, 'DRIVER' as job from dual
   union all
   select 6 as empno, 'VICTORIA' as ename, 20 as deptno, 11000 as sal, 'CLERK' as job from dual
),
analytics AS (
   select ename, sal, job,
          sum(sal) over (partition by job) sal_by_job,
          sum(sal) over (partition by deptno) sal_by_deptno
   from emp
) select /*+ NO_MERGE (a) PUSH_PRED (a) */ * 
  from   analytics a
  where job = 'CLERK' ;
-- PRED_PUSH does not work with analytic function in the view

WITH emp as (
   select 1 as empno, 'MILLER' as ename, 10 as deptno, 5000 as sal, 'CLERK' as job from dual
   union all
   select 2 as empno, 'SMITH' as ename, 10 as deptno, 6000 as sal, 'CLERK' as job from dual
   union all
   select 3 as empno, 'JAMES' as ename, 10 as deptno, 15000 as sal, 'TEACHER' as job from dual
   union all
   select 4 as empno, 'CSACSI' as ename, 20 as deptno, 3000 as sal, 'CLERK' as job from dual
   union all
   select 5 as empno, 'ANNA' as ename, 10 as deptno, 8000 as sal, 'DRIVER' as job from dual
   union all
   select 6 as empno, 'VICTORIA' as ename, 20 as deptno, 11000 as sal, 'CLERK' as job from dual
),
analytics AS (
   select ename, sal, job
          --sum(sal) over (partition by job) sal_by_job,
          -- sum(sal) over (partition by deptno) sal_by_deptno
   from emp
) select /*+ NO_MERGE (a) PUSH_PRED (a) */ * 
  from   analytics a
  where job = 'CLERK' ;
