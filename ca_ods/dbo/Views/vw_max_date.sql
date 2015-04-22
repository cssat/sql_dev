create view dbo.vw_max_date
as
select * from ref_lookup_max_date where is_current=1;