

--ALTER TABLE [prtl].[prtl_poc1ab] add primary key 
--(qry_type
--,date_type
--,[start_date]
--,[bin_dep_cd]
--,[max_bin_los_cd]
--,[bin_placement_cd]
--,[bin_ihs_svc_cd]
--,[cd_reporter_type]
--,[census_hispanic_latino_origin_cd]
--,[int_match_param_key]
--,[filter_allegation]
--,[filter_finding]
--,[filter_service_category]
--,[filter_service_budget]
--,[filter_access_type]
--)



/****** Object:  Index [idx_fl_cps_invs_start_date_other_9999]    Script Date: 9/7/2013 7:37:46 AM ******/
CREATE NONCLUSTERED INDEX [idx_fl_cps_invs_start_date_other_9999] ON [prtl].[prtl_poc1ab]
(
	[fl_cps_invs] ASC,
	[start_date] ASC
)
INCLUDE ( 	[qry_type],
	[date_type],
	[max_bin_los_cd],
	[bin_placement_cd],
	[bin_ihs_svc_cd],
	[cd_reporter_type],
	[cd_race],
	[census_hispanic_latino_origin_cd],
	[int_match_param_key],
	[cnt_first],
	[cnt_entries],
	[cnt_exits],
	[cnt_dcfs_first],
	[cnt_dcfs_entries],
	[cnt_dcfs_exits]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO



/****** Object:  Index [idx_prtl_poc1ab_dadnfsl]    Script Date: 9/7/2013 7:37:18 AM ******/
CREATE NONCLUSTERED INDEX [idx_prtl_poc1ab_dadnfsl] ON [prtl].[prtl_poc1ab]
(
	[start_date] ASC
)
INCLUDE ( 	[qry_type],
	[date_type],
	[max_bin_los_cd],
	[bin_placement_cd],
	[bin_ihs_svc_cd],
	[cd_reporter_type],
	[fl_cps_invs],
	[cd_race],
	[census_hispanic_latino_origin_cd],
	[int_match_param_key],
	[cnt_first],
	[cnt_entries],
	[cnt_exits],
	[cnt_dcfs_first],
	[cnt_dcfs_entries],
	[cnt_dcfs_exits],
	[filter_allegation]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO


/****** Object:  Index [idx_start_date_587]    Script Date: 9/7/2013 7:36:10 AM ******/
CREATE NONCLUSTERED INDEX [idx_start_date_587] ON [prtl].[prtl_poc1ab]
(
	[start_date] ASC
)
INCLUDE ( 	[qry_type],
	[date_type],
	[max_bin_los_cd],
	[bin_placement_cd],
	[bin_ihs_svc_cd],
	[cd_reporter_type],
	[fl_cps_invs],
	[cd_race],
	[census_hispanic_latino_origin_cd],
	[int_match_param_key],
	[cnt_first],
	[cnt_entries],
	[cnt_exits],
	[cnt_dcfs_first],
	[cnt_dcfs_entries],
	[cnt_dcfs_exits]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

update statistics prtl.prtl_poc1ab;