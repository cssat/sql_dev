
create view [dbo].[vw_qa_ooh_dcfs_eps_age]
as
select  distinct exit_cdc_census_mix_age_cd ,'exit_cdc_census_mix_age_cd' [parameter_name] ,count(*) [row_count]  from prtl.ooh_dcfs_eps group by exit_cdc_census_mix_age_cd
union
select  distinct exit_census_child_group_cd ,'exit_census_child_group_cd' [parameter_name] ,count(*) [row_count]   from prtl.ooh_dcfs_eps  group by exit_census_child_group_cd
union
select  distinct exit_developmental_age_cd ,'exit_developmental_age_cd' [parameter_name]   ,count(*) [row_count]  from prtl.ooh_dcfs_eps  group by exit_developmental_age_cd
union
 select eps.entry_cdc_census_mix_age_cd,'entry_cdc_census_mix_age_cd'   ,count(*) [row_count] from prtl.ooh_dcfs_eps  eps group by eps.entry_cdc_census_mix_age_cd
 union
 select eps.entry_census_child_group_cd,'entry_census_child_group_cd'   ,count(*) [row_count] from prtl.ooh_dcfs_eps  eps group by eps.entry_census_child_group_cd
  union
 select eps.entry_developmental_age_cd,'entry_developmental_age_cd'   ,count(*) [row_count] from prtl.ooh_dcfs_eps  eps group by eps.entry_developmental_age_cd
 

