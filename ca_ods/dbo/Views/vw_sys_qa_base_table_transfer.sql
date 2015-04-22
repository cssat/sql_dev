

CREATE view [dbo].[vw_sys_qa_base_table_transfer] as

select 'episode_payment_services' as tbl_name,getdate() as transfer_date
	,(select count(*) from dbcoreadministrativetables.[dbo].[episode_payment_services]) as cnt_coreadmin
	, (select count(*) from base.episode_payment_services) as cnt_ca_ods
union all
select 'placement_payment_services' as tbl_name,getdate()
	,(select count(*) from dbcoreadministrativetables.[dbo].placement_payment_services) as cnt_coreadmin
	, (select count(*) from base.placement_payment_services) as cnt_ca_ods
union all
select 'tbl_case_dim' as tbl_name,getdate()
	,(select count(*) from dbcoreadministrativetables.[dbo].tbl_case_dim) as cnt_coreadmin
	, (select count(*) from base.tbl_case_dim) as cnt_ca_ods
	union all
select 'tbl_child_episodes' as tbl_name,getdate()
	,(select count(*) from dbcoreadministrativetables.[dbo].tbl_child_episodes) as cnt_coreadmin
	, (select count(*) from base.tbl_child_episodes) as cnt_ca_ods
		union all
select 'tbl_child_placement_settings' as tbl_name,getdate()
	,(select count(*) from dbcoreadministrativetables.[dbo].tbl_child_placement_settings) as cnt_coreadmin
	, (select count(*) from base.tbl_child_placement_settings) as cnt_ca_ods

			union all
select 'tbl_household_children' as tbl_name,getdate()
	,(select count(*) from dbcoreadministrativetables.[dbo].tbl_household_children) as cnt_coreadmin
	, (select count(*) from base.tbl_household_children) as cnt_ca_ods

			union all
select 'tbl_ihs_episodes' as tbl_name,getdate()
	,(select count(*) from dbcoreadministrativetables.[dbo].tbl_ihs_episodes) as cnt_coreadmin
	, (select count(*) from base.tbl_ihs_episodes) as cnt_ca_ods
			union all
select 'tbl_ihs_services' as tbl_name,getdate()
	,(select count(*) from dbcoreadministrativetables.[dbo].tbl_ihs_services) as cnt_coreadmin
	, (select count(*) from base.tbl_ihs_services) as cnt_ca_ods
			union all
select 'tbl_intake_grouper' as tbl_name,getdate()
	,(select count(*) from dbcoreadministrativetables.[dbo].tbl_intake_grouper) as cnt_coreadmin
	, (select count(*) from base.tbl_intake_grouper) as cnt_ca_ods
	union all
select 'tbl_intakes' as tbl_name,getdate()
	,(select count(*) from dbcoreadministrativetables.[dbo].tbl_intakes) as cnt_coreadmin
	, (select count(*) from base.tbl_intakes) as cnt_ca_ods
	union all
select 'WRK_nonDCFS_All' as tbl_name,getdate()
	,(select count(*) from dbcoreadministrativetables.[dbo].WRK_nonDCFS_All) as cnt_coreadmin
	, (select count(*) from base.WRK_nonDCFS_All) as cnt_ca_ods
	union all
select 'WRK_TRHEvents' as tbl_name,getdate()
	,(select count(*) from dbcoreadministrativetables.[dbo].WRK_TRHEvents) as cnt_coreadmin
	, (select count(*) from base.WRK_TRHEvents) as cnt_ca_ods

