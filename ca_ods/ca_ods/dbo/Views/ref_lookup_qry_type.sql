
create view [dbo].[ref_lookup_qry_type] as
select 0 [qry_type],'unique' [qry_type_desc]
union
select 1,'first'
union
select 2,'all';
