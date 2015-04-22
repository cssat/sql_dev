
create view [dbo].[vw_qa_load_ca_data_received_with_prior]
as
with cte_dates  as 
(select  convert(datetime,convert(varchar(10),ca.date_loaded,121),121) load_date ,Rank() over(order by convert(datetime,convert(varchar(10),ca.date_loaded,121),121) desc) row_num
			from CA_DATA_LOADED ca
			group by convert(datetime,convert(varchar(10),ca.date_loaded,121),121)) 

		

select  curr.ca_tbl_id,tbl.tbl_name,curr.date_loaded curr_load_date
,pr.date_loaded prior_load_date,curr.row_count current_row_count,pr.row_count prior_row_count
,(curr.row_count-pr.row_count)/(pr.row_count * 1.000)  * 100 [perc increase]
from CA_DATA_LOADED curr
join ca_table_id tbl on tbl.ca_tbl_id=curr.ca_tbl_id
 join CA_DATA_LOADED pr on tbl.ca_tbl_id=pr.ca_tbl_id 
join cte_dates dt_curr on convert(datetime,convert(varchar(10),curr.date_loaded,121),121)=dt_curr.load_date and  dt_curr.row_num=1
 join cte_dates dt_pri on convert(datetime,convert(varchar(10),pr.date_loaded,121),121)=dt_pri.load_date  and dt_pri.row_num=2


 
 

