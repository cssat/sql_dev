
create view [dbo].[prm_cd_sib_age_grp]
as select cd_sib_age_grp,cd_sib_age_grp [match_code]
		from ref_lookup_sib_age_grp age
		where cd_sib_age_grp <> 0
		union all 
		select 0,cd_sib_age_grp
		from ref_lookup_sib_age_grp age
		where cd_sib_age_grp <> 0

