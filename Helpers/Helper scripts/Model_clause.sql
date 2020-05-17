-- Model clause

select prod, country, cyear, s from 
((select 'Prod A' as prod, 'Country A' as country, '2000' as cyear, 15 as sales from dual
union
select 'Prod A' as prod, 'Country B' as country, '2000' as cyear, 20 as sales from dual
union
select 'Prod B' as prod, 'Country A' as country, '2001' as cyear, 12 as sales from dual
union
select 'Prod B' as prod, 'Country B' as country, '2000' as cyear, 10 as sales from dual) t)
MODEL RETURN ALL ROWS
PARTITION BY (prod)
DIMENSION BY (country, cyear)
MEASURES (sales s)
KEEP NAV
RULES UPSERT SEQUENTIAL ORDER 
( s ['Country A', '2001'] = s ['Country B', 2000] * 6,
 s ['Country B', '2001'] = s ['Country A', '2000'] * 5,
 s ['Total', 2010] = SUM (nvl (s, 0)) [ANY, ANY]) ;
 
 s ['TotalP', 'Total C', FOR cyear like '%' FROM '2000' to '2001' increment 1] = sum (s) [prod, country, cv ()],
 s ['Max P', 'Max C', 'Year'] = MAX (nvl (s, 0)) [prod, country, ANY]) ;

select prod, country, cyear, s from 
((select 'Prod A' as prod, 'Country A' as country, '2000' as cyear, 15 as sales from dual
union
select 'Prod A' as prod, 'Country B' as country, '2000' as cyear, 20 as sales from dual
union
select 'Prod B' as prod, 'Country A' as country, '2001' as cyear, 12 as sales from dual
union
select 'Prod B' as prod, 'Country B' as country, '2000' as cyear, 10 as sales from dual) t)
MODEL RETURN ALL ROWS
PARTITION BY (prod)
DIMENSION BY (country, cyear)
MEASURES (sales s)
KEEP NAV
RULES UPSERT SEQUENTIAL ORDER 
(s ['Country A', '2001'] = s ['Country B', 2000] * 6,
 s ['Country B', '2001'] = s ['Country A', '2000'] * 5,
 s ['Total', 2010] = SUM (nvl (s, 0)) [ANY, ANY],
 s ['Total C', FOR cyear IN ('2000','2001')] = sum (s) [country, cv (cyear)], 
 s ['Max C', FOR cyear IN ('2000','2001')] = MAX (nvl (s, 0)) [country, ANY]) 
 ;

