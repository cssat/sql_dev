CREATE VIEW [dbo].[cube_prtl_poc1ab_dim]
AS
SELECT poc1ab.pk_key
	,poc1ab.qry_type
	,IIF(poc1ab.qry_type = 2, 'All', 'First') [qry_type_desc]
	,poc1ab.date_type
	,IIF(poc1ab.date_type = 2, 'Year', 'Quarter') [date_type_desc]
	,poc1ab.start_date
	,poc1ab.bin_dep_cd
	,dep.bin_dep_desc
	,poc1ab.bin_los_cd
	,losd.bin_los_desc
	,poc1ab.bin_placement_cd
	,plc.bin_placement_desc
	,poc1ab.bin_ihs_svc_cd
	,ihs.bin_ihs_svc_tx
	,poc1ab.cd_reporter_type
	,rpt.tx_reporter_type
	,poc1ab.age_grouping_cd
	,age.age_grouping
	,poc1ab.cd_race
	,poc1ab.pk_gndr
	,gdr.tx_gndr
	,fpl.init_cd_plcm_setng
	,fpl.[Initial Placement Setting]
	,poc1ab.long_cd_plcm_setng
	,lpl.tx_plcm_setng [long_tx_plcm_setng]
	,poc1ab.county_cd
	,cnty.county_desc
	,poc1ab.cd_access_type
	,acc.fl_alternate_intervention
	,acc.fl_cfws
	,acc.fl_cps_invs
	,acc.fl_frs
	,acc.fl_risk_only
	,acc.fl_far
	,acc.fl_dlr
	,poc1ab.cd_allegation
	,ISNULL(alg.fl_phys_abuse, 0) [fl_phys_abuse]
	,ISNULL(alg.fl_sexual_abuse, 0) [fl_sexual_abuse]
	,ISNULL(alg.fl_neglect, 0) [fl_neglect]
	,ISNULL(alg.fl_any_legal, 0) [fl_any_legal]
	,poc1ab.cd_finding
	,ISNULL(fnd.fl_founded_phys_abuse, 0) [fl_founded_phys_abuse]
	,ISNULL(fnd.fl_founded_sexual_abuse, 0) [fl_founded_sexual_abuse]
	,ISNULL(fnd.fl_founded_neglect, 0) [fl_founded_neglect]
	,ISNULL(fnd.fl_any_finding_legal, 0) [fl_any_finding_legal]
	,poc1ab.int_param_key
FROM dbo.cube_prtl_poc1ab_fact poc1ab
LEFT JOIN (
	SELECT DISTINCT [filter_allegation]
		,[fl_phys_abuse]
		,[fl_sexual_abuse]
		,[fl_neglect]
		,[fl_any_legal]
	FROM [dbo].[ref_match_allegation]
	) alg ON alg.filter_allegation = poc1ab.cd_allegation
LEFT JOIN (
	SELECT DISTINCT filter_access_type
		,iif(cd_access_type = 1, 1, 0) [fl_cps_invs]
		,iif(cd_access_type = 2, 1, 0) [fl_alternate_intervention]
		,iif(cd_access_type = 3, 1, 0) [fl_frs]
		,iif(cd_access_type = 4, 1, 0) [fl_risk_only]
		,iif(cd_access_type = 5, 1, 0) [fl_cfws]
		,iif(cd_access_type = 6, 1, 0) [fl_far]
		,iif(cd_access_type = 7, 1, 0) [fl_dlr]
	FROM ref_filter_access_type ref
	) acc ON acc.filter_access_type = poc1ab.cd_access_type
LEFT JOIN (
	SELECT DISTINCT [filter_finding]
		,[fl_founded_phys_abuse]
		,[fl_founded_sexual_abuse]
		,[fl_founded_neglect]
		,[fl_any_finding_legal]
	FROM [ref_match_finding]
	) fnd ON fnd.filter_finding = poc1ab.cd_finding
LEFT JOIN (
	SELECT cd_plcm_setng [init_cd_plcm_setng]
		,tx_plcm_setng [Initial Placement Setting]
	FROM ref_lookup_plcmnt
	) fpl ON fpl.init_cd_plcm_setng = poc1ab.init_cd_plcm_setng
LEFT JOIN ref_filter_nbr_placement plc ON plc.bin_placement_cd = poc1ab.bin_placement_cd
LEFT JOIN ref_filter_dependency dep ON dep.bin_dep_cd = poc1ab.bin_dep_cd
LEFT JOIN ref_filter_ihs_services ihs ON ihs.bin_ihs_svc_cd = poc1ab.bin_ihs_svc_cd
LEFT JOIN ref_filter_reporter_type rpt ON rpt.cd_reporter_type = poc1ab.cd_reporter_type
LEFT JOIN ref_filter_los losD ON losD.bin_los_cd = poc1ab.bin_los_cd
LEFT JOIN ref_age_census_child_group age ON age.age_grouping_cd = poc1ab.age_grouping_cd
LEFT JOIN ref_lookup_ethnicity_census rc ON rc.cd_race_census = poc1ab.cd_race
LEFT JOIN ref_lookup_gender gdr ON gdr.pk_gndr = poc1ab.pk_gndr
LEFT JOIN ref_lookup_plcmnt lpl ON lpl.cd_plcm_setng = poc1ab.long_cd_plcm_setng
LEFT JOIN ref_lookup_county cnty ON cnty.county_cd = poc1ab.county_cd
