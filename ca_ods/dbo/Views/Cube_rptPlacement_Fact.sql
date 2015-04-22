



CREATE VIEW [dbo].[Cube_rptPlacement_Fact]
AS
SELECT
	RP.id_placement_fact
	,RP.id_removal_episode_fact
	,RP.child
	,ISNULL(CPD.ID_PEOPLE_DIM, CPD2.ID_PEOPLE_DIM) [child_id_people_dim]
	--,RP.id_case
	--,RP.cd_region
	--,RP.cd_office
	--,RP.cd_county
	,RP.primary_worker
	,ISNULL(WD.ID_WORKER_DIM, WD2.ID_WORKER_DIM) [primary_worker_dim_id]
	,ISNULL(WD.ID_LOCATION_DIM_WORKER, WD2.ID_LOCATION_DIM_WORKER) [primary_worker_location]
	--,RP.cd_worker_region
	--,RP.cd_worker_office
	--,RP.cd_worker_county
	,RP.episode_los
	,RP.placement_los
	,RP.id_calendar_dim_begin
	--,RP.id_epsd
	,RP.id_prvd_org_caregiver
	,ISNULL(PRD.ID_PROVIDER_DIM, PRD2.ID_PROVIDER_DIM) [id_prvd_dim_org_caregiver]
	,IIF(RP.id_calendar_dim_afcars_end = 0, 99991231, RP.id_calendar_dim_afcars_end) [id_calendar_dim_afcars_end]
	,CONVERT(INT, CONVERT(VARCHAR, RP.discharge_dt, 112)) [id_calendar_dim_discharge_force18]
	--,RP.cd_epsd_type
	--,RP.[18bday]
	--,RP.child_age
	--,RP.relative
	--,RP.cd_rel
	--,RP.current_setting
	,ISNULL(RP.mom_id, 0) [mom_id]
	,ISNULL(MPD.ID_PEOPLE_DIM, MPD2.ID_PEOPLE_DIM) [mom_people_dim_id]
	,ISNULL(RP.dad_id, 0) [dad_id]
	,ISNULL(DPD.ID_PEOPLE_DIM, DPD2.ID_PEOPLE_DIM) [dad_people_dim_id]
	,RP.placement_worker_id
	,ISNULL(PWD.ID_WORKER_DIM, PWD2.ID_WORKER_DIM) [placement_worker_dim_id]
	,ISNULL(PWD.ID_LOCATION_DIM_WORKER, PWD2.ID_LOCATION_DIM_WORKER) [placement_worker_location]
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
	,IIF(RP.id_calendar_dim_afcars_end = 0, 0, 1) [fl_exited]
	,RP.vpa_lngth
	--,RP.cd_rmvl_mnr
	--,ISNULL(RP.cd_placement_care_auth, -99) [cd_placement_care_auth]
	--,ISNULL(RP.orig_cd_plcm_dsch_rsn, -99) [orig_cd_plcm_dsch_rsn]
	,RP.fl_child_clinically_diagnosed
	,RP.fl_dep_exist
	--,RP.id_intake_fact
	,ISNULL(RP.age_at_removal_mos, -99) [age_at_removal_mos_id]
	,RP.age_at_removal_mos
	,IIF(dbo.fnc_datediff_mos(RP.birthdate, IIF(DATEADD(YEAR, 18, RP.birthdate) < RP.discharge_dt, DATEADD(YEAR, 18, RP.birthdate), RP.discharge_dt)) < -12
		,-99
		,IIF(dbo.fnc_datediff_mos(RP.birthdate, IIF(DATEADD(YEAR, 18, RP.birthdate) < RP.discharge_dt, DATEADD(YEAR, 18, RP.birthdate), RP.discharge_dt)) < 0
			,0
			,ISNULL(dbo.fnc_datediff_mos(RP.birthdate, IIF(DATEADD(YEAR, 18, RP.birthdate) < RP.discharge_dt, DATEADD(YEAR, 18, RP.birthdate), RP.discharge_dt)), -99)
		)
	) [age_at_exit_mos_id]
	,IIF(dbo.fnc_datediff_mos(RP.birthdate, IIF(DATEADD(YEAR, 18, RP.birthdate) < RP.discharge_dt, DATEADD(YEAR, 18, RP.birthdate), RP.discharge_dt)) < -12
		,NULL
		,IIF(dbo.fnc_datediff_mos(RP.birthdate, IIF(DATEADD(YEAR, 18, RP.birthdate) < RP.discharge_dt, DATEADD(YEAR, 18, RP.birthdate), RP.discharge_dt)) < 0
			,0
			,dbo.fnc_datediff_mos(RP.birthdate, IIF(DATEADD(YEAR, 18, RP.birthdate) < RP.discharge_dt, DATEADD(YEAR, 18, RP.birthdate), RP.discharge_dt))
		)
	) [age_at_exit_mos]
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
		AND WD.DT_ROW_BEGIN <= RP.removal_dt
		AND WD.DT_ROW_END >= RP.removal_dt
LEFT JOIN (
	SELECT
		RP.id_removal_episode_fact
		,WD.ID_WORKER_DIM
		,WD.ID_LOCATION_DIM_WORKER
		,ROW_NUMBER() OVER(PARTITION BY RP.id_removal_episode_fact ORDER BY WD.DT_ROW_BEGIN) [closeness_rank]
	FROM
		base.rptPlacement RP
		INNER JOIN dbo.WORKER_DIM WD ON
			WD.ID_PRSN = RP.primary_worker
				AND (
					(RP.removal_dt <= WD.DT_ROW_BEGIN
						OR RP.removal_dt >= WD.DT_ROW_END)
					OR RP.primary_worker = 0)
	WHERE NOT EXISTS(
		SELECT
			*
		FROM dbo.WORKER_DIM D
		WHERE D.ID_PRSN = RP.primary_worker
			AND D.DT_ROW_BEGIN <= RP.removal_dt
			AND D.DT_ROW_END >= RP.removal_dt
	)
) WD2 ON
	WD2.id_removal_episode_fact = RP.id_removal_episode_fact
		AND WD2.closeness_rank = 1
LEFT JOIN dbo.WORKER_DIM PWD ON
	PWD.ID_PRSN = RP.placement_worker_id
		AND PWD.DT_ROW_BEGIN <= RP.removal_dt
		AND PWD.DT_ROW_END >= RP.removal_dt
LEFT JOIN (
	SELECT
		RP.id_removal_episode_fact
		,WD.ID_WORKER_DIM
		,WD.ID_LOCATION_DIM_WORKER
		,ROW_NUMBER() OVER(PARTITION BY RP.id_removal_episode_fact ORDER BY WD.DT_ROW_BEGIN) [closeness_rank]
	FROM
		base.rptPlacement RP
		INNER JOIN dbo.WORKER_DIM WD ON
			WD.ID_PRSN = RP.placement_worker_id
				AND (
					(RP.removal_dt <= WD.DT_ROW_BEGIN
						OR RP.removal_dt >= WD.DT_ROW_END)
					OR RP.placement_worker_id = 0)
	WHERE NOT EXISTS(
		SELECT
			*
		FROM dbo.WORKER_DIM D
		WHERE D.ID_PRSN = RP.placement_worker_id
			AND D.DT_ROW_BEGIN <= RP.removal_dt
			AND D.DT_ROW_END >= RP.removal_dt
	)
) PWD2 ON
	PWD2.id_removal_episode_fact = RP.id_removal_episode_fact
		AND PWD2.closeness_rank = 1
LEFT JOIN dbo.PEOPLE_DIM CPD ON
	CPD.ID_PRSN = RP.child
		AND CPD.DT_ROW_BEGIN <= RP.removal_dt
		AND CPD.DT_ROW_END >= RP.removal_dt
LEFT JOIN (
	SELECT
		RP.id_removal_episode_fact
		,PD.ID_PEOPLE_DIM
		,ROW_NUMBER() OVER(PARTITION BY RP.id_removal_episode_fact ORDER BY PD.DT_ROW_BEGIN) [closeness_rank]
	FROM
		base.rptPlacement RP
		INNER JOIN dbo.PEOPLE_DIM PD ON
			PD.ID_PRSN = RP.child
				AND (RP.removal_dt <= PD.DT_ROW_BEGIN
						OR RP.removal_dt >= PD.DT_ROW_END)
	WHERE NOT EXISTS(
		SELECT
			*
		FROM dbo.PEOPLE_DIM D
		WHERE D.ID_PRSN = RP.child
			AND D.DT_ROW_BEGIN <= RP.removal_dt
			AND D.DT_ROW_END >= RP.removal_dt
	)
) CPD2 ON
	CPD2.id_removal_episode_fact = RP.id_removal_episode_fact
		AND CPD2.closeness_rank = 1
LEFT JOIN dbo.PEOPLE_DIM DPD ON
	DPD.ID_PRSN = RP.dad_id
		AND DPD.DT_ROW_BEGIN <= RP.removal_dt
		AND DPD.DT_ROW_END >= RP.removal_dt
LEFT JOIN (
	SELECT
		RP.id_removal_episode_fact
		,PD.ID_PEOPLE_DIM
		,ROW_NUMBER() OVER(PARTITION BY RP.id_removal_episode_fact ORDER BY PD.DT_ROW_BEGIN) [closeness_rank]
	FROM
		base.rptPlacement RP
		INNER JOIN dbo.PEOPLE_DIM PD ON
			PD.ID_PRSN = ISNULL(RP.dad_id, 0)
				AND (
					(RP.removal_dt <= PD.DT_ROW_BEGIN
						OR RP.removal_dt >= PD.DT_ROW_END)
					OR RP.dad_id = 0
					OR RP.dad_id IS NULL)
	WHERE NOT EXISTS(
		SELECT
			*
		FROM dbo.PEOPLE_DIM D
		WHERE D.ID_PRSN = RP.dad_id
			AND D.DT_ROW_BEGIN <= RP.removal_dt
			AND D.DT_ROW_END >= RP.removal_dt
	)
) DPD2 ON
	DPD2.id_removal_episode_fact = RP.id_removal_episode_fact
		AND DPD2.closeness_rank = 1
LEFT JOIN dbo.PEOPLE_DIM MPD ON
	MPD.ID_PRSN = RP.mom_id
		AND MPD.DT_ROW_BEGIN <= RP.removal_dt
		AND MPD.DT_ROW_END >= RP.removal_dt
LEFT JOIN (
	SELECT
		RP.id_removal_episode_fact
		,PD.ID_PEOPLE_DIM
		,ROW_NUMBER() OVER(PARTITION BY RP.id_removal_episode_fact ORDER BY PD.DT_ROW_BEGIN) [closeness_rank]
	FROM
		base.rptPlacement RP
		INNER JOIN dbo.PEOPLE_DIM PD ON
			PD.ID_PRSN = ISNULL(RP.mom_id, 0)
				AND (
					(RP.removal_dt <= PD.DT_ROW_BEGIN
						OR RP.removal_dt >= PD.DT_ROW_END)
					OR RP.mom_id = 0
					OR RP.mom_id IS NULL)
	WHERE NOT EXISTS(
		SELECT
			*
		FROM dbo.PEOPLE_DIM D
		WHERE D.ID_PRSN = RP.mom_id
			AND D.DT_ROW_BEGIN <= RP.removal_dt
			AND D.DT_ROW_END >= RP.removal_dt
	)
) MPD2 ON
	MPD2.id_removal_episode_fact = RP.id_removal_episode_fact
		AND MPD2.closeness_rank = 1
LEFT JOIN dbo.PROVIDER_DIM PRD ON
	PRD.ID_PRVD_ORG = RP.id_prvd_org_caregiver
		AND PRD.DT_ROW_BEGIN <= RP.removal_dt
		AND PRD.DT_ROW_END >= RP.removal_dt
		AND PRD.ID_PROVIDER_DIM != 386453
LEFT JOIN (
	SELECT
		RP.id_removal_episode_fact
		,PRD.ID_PROVIDER_DIM
		,ROW_NUMBER() OVER(PARTITION BY RP.id_removal_episode_fact ORDER BY PRD.DT_ROW_BEGIN) [closeness_rank]
	FROM
		base.rptPlacement RP
		INNER JOIN dbo.PROVIDER_DIM PRD ON
			PRD.ID_PRVD_ORG = RP.id_prvd_org_caregiver
				AND (RP.removal_dt <= PRD.DT_ROW_BEGIN
						OR RP.removal_dt >= PRD.DT_ROW_END)
				AND PRD.ID_PROVIDER_DIM != 386453
	WHERE NOT EXISTS(
		SELECT
			*
		FROM dbo.PROVIDER_DIM D
		WHERE D.ID_PRVD_ORG = RP.id_prvd_org_caregiver
			AND D.DT_ROW_BEGIN <= RP.removal_dt
			AND D.DT_ROW_END >= RP.removal_dt
			AND D.ID_PROVIDER_DIM != 386453
	)
) PRD2 ON
	PRD2.id_removal_episode_fact = RP.id_removal_episode_fact
		AND PRD2.closeness_rank = 1
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
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'Cube_rptPlacement_Fact';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'Cube_rptPlacement_Fact';

