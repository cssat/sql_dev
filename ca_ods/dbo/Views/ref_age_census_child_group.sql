create view dbo.ref_age_census_child_group
as select distinct census_child_group_cd [age_grouping_cd],census_child_group_tx [age_grouping]from age_dim where age_mo between 0 and 18 * 12
						and census_child_group_cd <> -99 union select age_grouping_cd,age_grouping  from ref_age_groupings_census where age_grouping_cd=0
