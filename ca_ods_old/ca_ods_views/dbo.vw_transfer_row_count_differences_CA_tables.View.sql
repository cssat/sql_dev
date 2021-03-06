USE [CA_ODS]
GO
/****** Object:  View [dbo].[vw_transfer_row_count_differences_CA_tables]    Script Date: 4/10/2014 8:12:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[vw_transfer_row_count_differences_CA_tables]
as 
select tbl.tbl_name,tbl.row_count as 'ca_ods',trns.row_count as 'dbcore' from CA_DATA_LOADED  tbl
join ca_transfer_row_counts trns on trns.ca_tbl_id=tbl.ca_tbl_id and trns.insert_date > getdate()-1
where date_loaded > getdate()-3 
and tbl.row_count <> trns.row_count



GO
