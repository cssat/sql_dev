CREATE DEFINER=`test_annie`@`localhost` PROCEDURE `sp_rate_referral`(p_date varchar(3000),p_cd_county varchar(200),p_entry_point varchar(30))
BEGIN

select
	rr.start_date as 'Date'
	,rr.county_cd
	,c.county as 'County'
	,rr.entry_point as 'cd_access_type'
	,fat.tx_access_type as 'Access type desc'
	,rr.cnt_referrals
	,rr.tot_pop
	,rr.referral_rate as 'Referral Rate'
from rate_referrals as rr
left join ref_filter_access_type as fat on
	fat.cd_access_type = rr.entry_point
left join ref_lookup_county as c on
	c.county_cd = rr.county_cd
where
	find_in_set(rr.county_cd,p_cd_county)>0
	and find_in_set(rr.entry_point,p_entry_point)>0
order by
	rr.county_cd
	,rr.start_date asc
	,rr.entry_point asc;
END 
