CREATE procedure [dbo].[sp_QA_transfer_to_dbCore]
as 
select ld.tbl_name ,ld.row_count,tr.row_count as load_count
from (select *,row_number() over (partition by tbl_name order by tbl_name,date_loaded desc) as row_num 
		from dbo.CA_DATA_LOADED ) ld 
left join (select *,row_number() over (partition by tbl_name order by tbl_name,insert_date desc) as row_num
		from   dbo.ca_transfer_row_counts ) tr on tr.tbl_name=ld.tbl_name and  tr.row_num=1
				and tr.insert_date > ld.date_loaded
where ld.row_num=1  
 and (tr.tbl_name is null or tr.row_count <> ld.row_count)

