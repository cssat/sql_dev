USE [CA_ODS]
GO

/****** Object:  StoredProcedure [prtl].[prod_update_ref_match_ooh_parameters]    Script Date: 3/6/2014 1:57:33 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


alter procedure [prtl].[prod_update_ref_match_ooh_parameters]
as


SELECT [int_param_key]
      ,[param_key]
      ,[age_grouping_cd]
      ,[cd_race_census]
      ,[pk_gndr]
      ,[init_cd_plcm_setng]
      ,[long_cd_plcm_setng]
      ,[county_cd]
      ,[int_match_param_key]
      ,[match_param_key]
      ,[match_age_grouping_cd]
      ,[match_cd_race_census]
      ,[match_cd_hispanic_latino_origin]
      ,[match_pk_gndr]
      ,[match_init_cd_plcm_setng]
      ,[match_long_cd_plcm_setng]
      ,[match_county_cd]
      ,0 as fl_in_tbl_child_episodes
	  ,row_number() over (order by [int_param_key],[int_match_param_key]) as row_num
	  into #temp
  FROM dbo.[ref_match_ooh_parameters]
  


update prm
set fl_in_tbl_child_episodes = 1
from base.tbl_child_episodes tce
join age_dim age on age.age_mo=tce.age_eps_begin_mos 
join dbo.ref_lookup_placement_event frstplc on frstplc.id_plcmnt_evnt=tce.init_id_plcmnt_evnt
join dbo.ref_lookup_placement_event longplc on longplc.id_plcmnt_evnt=tce.longest_id_plcmnt_evnt
join dbo.ref_lookup_ethnicity_census RC on RC.cd_race_census=tce.cd_race_census
join dbo.ref_lookup_gender G on G.CD_GNDR=tce.CD_GNDR
join dbo.ref_lookup_county cnty on cnty.County_Cd=tce.Removal_County_Cd
join #temp prm on prm.age_grouping_cd=age.census_child_group_cd	
	and prm.match_cd_race_census=tce.cd_race_census
	and prm.match_cd_hispanic_latino_origin=tce.census_hispanic_latino_origin_cd
	and prm.match_pk_gndr=g.pk_gndr
	and prm.match_init_cd_plcm_setng=frstplc.cd_plcm_setng
	and prm.match_long_cd_plcm_setng=longplc.cd_plcm_setng
	and prm.match_county_cd=tce.Removal_County_Cd

							


-- now get the 'ALLS '
update prm
set fl_in_tbl_child_episodes = 1
from #temp prm  
join #temp  prm2 on prm2.int_match_param_key=prm.int_match_param_key 
where prm.fl_in_tbl_child_episodes=0
and prm2.fl_in_tbl_child_episodes=1;




truncate table [dbo].[ref_match_ooh_parameters]
create index idx_row_num on #temp(row_num);

declare @loop_stop int
declare @loop_start int
declare @exit_loop int
select @exit_loop=max(row_num) from #temp;

set @loop_start = 1
set @loop_stop= @loop_start + 500000
while @loop_start <= @exit_loop
begin
begin tran t1
insert into  [dbo].[ref_match_ooh_parameters]
select #temp.[int_param_key]
      , #temp.[param_key]
      , #temp.[age_grouping_cd]
      , #temp.[cd_race_census]
      , #temp.[pk_gndr]
      , #temp.[init_cd_plcm_setng]
      , #temp.[long_cd_plcm_setng]
      , #temp.[county_cd]
      , #temp.[int_match_param_key]
      , #temp.[match_param_key]
      , #temp.[match_age_grouping_cd]
      , #temp.[match_cd_race_census]
      , #temp.[match_cd_hispanic_latino_origin]
      , #temp.[match_pk_gndr]
      , #temp.[match_init_cd_plcm_setng]
      , #temp.[match_long_cd_plcm_setng]
      , #temp.[match_county_cd]
      , #temp.fl_in_tbl_child_episodes
from #temp
left join [ref_match_ooh_parameters] t2 on t2.int_match_param_key=#temp.int_match_param_key and t2.int_param_key=#temp.int_param_key
where #temp.row_num between @loop_start and @loop_stop
and t2.int_match_param_key is null;
commit tran t1
set @loop_start=@loop_start + 500000
set @loop_stop=@loop_stop + 500000

end

update statistics  [dbo].[ref_match_ooh_parameters]

drop table #temp;


--19440000