
create view [dbo].[vw_qa_test_annie_cache_pbcw4_aggr]
as
select sum(date_type)[date_type],sum(qry_type)[qry_type],sum(age_Grouping_cd)[age_Grouping_cd],sum(pk_gndr)[pk_gndr]
,sum(cd_race)[cd_race_census]
,sum(init_cd_plcm_setng)[init_cd_plcm_setng],sum(long_cd_plcm_setng)[long_cd_plcm_setng],sum(county_cd)[county_cd],sum(bin_dep_cd)[bin_dep_cd]
,sum(bin_los_cd)[max_bin_los_cd],sum(bin_placement_cd)[bin_placement_cd],sum(cd_reporter_type)[cd_reporter_type],sum(bin_ihs_svc_cd)[bin_ihs_svc_cd]
,sum(kincare)[kincare],sum(bin_sibling_group_size)[bin_sibling_group_size]
,sum(cache_pbcw4_aggr.all_together)[all_sib_together],sum(some_together)[some_sib_together],sum(none_together)[no_sib_together]
,sum(cnt_cohort)[total],count(*) [row_count]
from prtl.cache_pbcw4_aggr
