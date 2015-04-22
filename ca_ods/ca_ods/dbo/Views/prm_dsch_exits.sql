create  view  dbo.prm_dsch_exits
as
	select distinct cd_discharge_type,cd_discharge_type [match_code]
	from ref_state_discharge_xwalk
	where cd_discharge_type <> 0
	union 
	select distinct 0,cd_discharge_type
	from ref_state_discharge_xwalk
	where cd_discharge_type <> 0