create view dbo.ref_lookup_date_type as 
select 0 [date_type],'Month' [date_type_desc]
union
select 1,'Quarter'
union
select 2,'Year';

