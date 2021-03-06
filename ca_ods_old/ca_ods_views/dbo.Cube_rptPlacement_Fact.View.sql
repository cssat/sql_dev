USE [CA_ODS]
GO
/****** Object:  View [dbo].[Cube_rptPlacement_Fact]    Script Date: 4/10/2014 8:12:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[Cube_rptPlacement_Fact]
AS
SELECT
	RP.id_placement_fact
	--,RP.id_removal_episode_fact
	,RP.child
	,RP.id_case
	--,RP.cd_region
	--,RP.cd_office
	--,RP.cd_county
	,RP.primary_worker
	,WD.ID_LOCATION_DIM_WORKER [primary_worker_location]
	--,RP.cd_worker_region
	--,RP.cd_worker_office
	--,RP.cd_worker_county
	,RP.episode_los
	,RP.placement_los
	,RP.id_calendar_dim_begin
	--,RP.id_epsd
	,RP.id_prvd_org_caregiver
	,RP.id_calendar_dim_afcars_end
	--,RP.cd_epsd_type
	--,RP.[18bday]
	--,RP.child_age
	--,RP.relative
	--,RP.cd_rel
	--,RP.current_setting
	,COALESCE(RP.mom_id, -99) [mom_id]
	,COALESCE(RP.dad_id, -99) [dad_id]
	,RP.placement_worker_id
	--,RP.placement_worker_region_cd
	--,RP.placement_worker_office_cd
	--,RP.placement_worker_county_cd
	--,RP.placement_worker_unit
	--,RP.placement_workerint_level
	--,RP.cd_cnty
	,RP.fl_abandonment
	,RP.fl_caretaker_inability_cope
	,RP.fl_child_abuse_alcohol
	,RP.fl_child_abuses_drug
	,RP.fl_child_behavior_problems
	,RP.fl_inadequate_housng
	,RP.fl_neglect
	,RP.fl_parent_abuse_alcohol
	,RP.fl_parent_death
	,RP.fl_parent_drug_abuse
	,RP.fl_parent_incarceration
	,RP.fl_physical_abuse
	,RP.fl_sex_abuse
	,RP.fl_relinquishment
	--,ISNULL(RP.cd_primary_ppln, -99) [cd_primary_ppln]
	--,ISNULL(RP.cd_alt_ppln, -99) [cd_alt_ppln]
	--,RP.multi_race_mask
	--,RP.cd_hspnc
	,RP.fl_false
	,RP.vpa_lngth
	--,RP.cd_rmvl_mnr
	--,ISNULL(RP.cd_placement_care_auth, -99) [cd_placement_care_auth]
	--,ISNULL(RP.orig_cd_plcm_dsch_rsn, -99) [orig_cd_plcm_dsch_rsn]
	,RP.fl_child_clinically_diagnosed
	,RP.fl_dep_exist
	--,RP.id_intake_fact
	,RP.age_at_removal_mos
	--,RP.child_eps_rank
	,RP.child_cnt_episodes
	--,RP.cd_race_census
	--,RP.census_hispanic_latino_origin_cd
	--,RP.initial_id_placement_fact
	--,RP.longest_id_placement_fact
	,RP.days_to_reentry
	--,RP.cd_discharge_type
	--,ISNULL(RP.max_bin_los_cd, -99) [max_bin_los_cd]
	--,RP.bin_dep_cd
	--,RP.bin_ihs_svc_cd
	,RP.dur_days
	--,RP.exit_within_month_mult3
	--,RP.nxt_reentry_within_min_month_mult3
	,RP.nbr_events
	--,RP.bin_placement_cd
	,RP.nbr_ooh_events
	--,RP.init_cd_plcm_setng
	--,RP.pk_gndr
FROM base.rptPlacement RP
LEFT JOIN dbo.WORKER_DIM WD ON
	WD.ID_PRSN = RP.primary_worker
		AND (WD.IS_CURRENT = 1 OR WD.ID_WORKER_DIM = 0)
WHERE NOT EXISTS(
	SELECT
		*
	FROM dbo.vw_nondcfs_combine_adjacent_segments NCAS
	INNER JOIN dbo.CALENDAR_DIM CD ON
		CD.CALENDAR_DATE >= NCAS.cust_begin
			AND CD.CALENDAR_DATE <= NCAS.cust_end
	WHERE NCAS.id_prsn = RP.child
		AND (CD.ID_CALENDAR_DIM = RP.id_calendar_dim_begin
			OR CD.ID_CALENDAR_DIM = RP.id_calendar_dim_afcars_end)
)



GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "rptPlacement (base)"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 320
               Right = 326
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'Cube_rptPlacement_Fact'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'Cube_rptPlacement_Fact'
GO
