		create view dbo.vw_qa_rptPlacement_cd_discharge_type
		as 
	select exit_reason,cd_discharge_type,count(distinct id_removal_episode_fact)  [eps_count]
	 from base.rptPlacement
	 group by  exit_reason,cd_discharge_type