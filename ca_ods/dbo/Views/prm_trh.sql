create view dbo.prm_trh
as 
select 0 match_code,1 excludes_trh
union
select 0,0
union
select 1,0