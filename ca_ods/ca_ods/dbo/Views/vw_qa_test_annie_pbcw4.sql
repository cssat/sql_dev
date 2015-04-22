create view dbo.vw_qa_test_annie_pbcw4
as
select sum(date_type)[date_type],sum(qry_type)[qry_type],sum(age_Grouping_cd)[age_Grouping_cd],sum(pk_gndr)[pk_gndr]
,sum(cd_race_census)[cd_race_census],sum(census_hispanic_latino_origin_cd)[census_hispanic_latino_origin_cd]
,sum(init_cd_plcm_setng)[init_cd_plcm_setng],sum(long_cd_plcm_setng)[long_cd_plcm_setng],sum(county_cd)[county_cd],sum(bin_dep_cd)[bin_dep_cd]
,sum(max_bin_los_cd)[max_bin_los_cd],sum(bin_placement_cd)[bin_placement_cd],sum(cd_reporter_type)[cd_reporter_type],sum(bin_ihs_svc_cd)[bin_ihs_svc_cd]
,sum(kincare)[kincare],sum(bin_sibling_group_size)[bin_sibling_group_size]
,sum(all_sib_together)[all_sib_together],sum(some_sib_together)[some_sib_together],sum(no_sib_together)[no_sib_together]
,sum(total)[total],count(*) [row_count]
from prtl.prtl_pbcw4