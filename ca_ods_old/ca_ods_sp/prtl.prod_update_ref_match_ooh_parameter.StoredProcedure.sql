USE [CA_ODS]
GO
/****** Object:  StoredProcedure [prtl].[prod_update_ref_match_ooh_parameters]    Script Date: 3/19/2014 9:42:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER procedure [prtl].[prod_update_ref_match_ooh_parameters]
as


update prm
set fl_in_tbl_child_episodes =0
from dbo.ref_match_ooh_parameters prm 
where fl_in_tbl_child_episodes=1

declare @i int;

set @i=1
while @i <= 4 
begin
update prm
set fl_in_tbl_child_episodes=1
from prtl.prtl_poc1ab tce
join dbo.ref_match_ooh_parameters prm on prm.[int_match_param_key]=tce.int_match_param_key	
where  tce.age_grouping_cd =@i			 
and fl_in_tbl_child_episodes=0	
set @i=@i+1;
end


set @i=1
while @i <= 4 
begin
update prm
set fl_in_tbl_child_episodes=1
from prtl.ooh_dcfs_eps tce
join dbo.ref_match_ooh_parameters prm on prm.[int_match_param_key]=tce.[entry_int_match_param_key_census_child_group]	
where tce.entry_census_child_group_cd = @i					
set @i=@i+1;
end



set @i=1
while @i <= 4 
begin
update prm
set fl_in_tbl_child_episodes=1
from prtl.ooh_dcfs_eps tce
join dbo.ref_match_ooh_parameters prm on prm.[int_match_param_key]=tce.[exit_int_match_param_key_census_child_group]	
where federal_discharge_date is not null
and tce.exit_census_child_group_cd =@i			 
and fl_in_tbl_child_episodes=0	
set @i=@i+1;
end



update statistics  [dbo].[ref_match_ooh_parameters]




