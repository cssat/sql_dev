CREATE PROCEDURE [base].[prod_build_placement_care_days_otr]
	-- Add the parameters for the stored procedure here
	@fystart INT = 2000
	,@fystop INT = 2013
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF OBJECT_ID('tempdb..#placements') IS NOT NULL
		DROP TABLE #placements

	SELECT rp.removal_dt
		,rp.birthdate
		-- age yr at removal
		,ISNULL(dbo.fnc_datediff_yrs(birthdate, removal_dt), -99) [age_yrs_removal]
		--age_yrs_exit
		,ISNULL(IIF(rp.discharge_dt <= cutoff_date, dbo.fnc_datediff_yrs(birthdate, dbo.lessorDate(rp.[18bday], rp.discharge_dt)), -99), -99) [age_yrs_exit]
		-- race
		,ISNULL(pd.cd_race_census, 7) [cd_race_census]
		----ethnicity
		,ISNULL(pd.census_Hispanic_Latino_Origin_cd, 5) [census_Hispanic_Latino_Origin_cd]
		--county_cd
		,ISNULL(rp.derived_county, -99) [county_cd]
		-- federal discharge date force
		,-- lessor date of 18th birthday is greater than cutoff_date use cutoff else use lessor date 18 bday or discharge date
			dbo.lessorDate3([18bday], rp.discharge_dt, cutoff_date) [discharg_frc_18]
		,rp.id_removal_episode_fact
		,rp.id_placement_fact
		,rp.plcmnt_seq
		,rp.begin_date plc_begin
		,dbo.lessorDate4([18bday], rp.discharge_dt, cutoff_date, rp.end_date) [plc_end]
		,IIF(rp.plcmnt_seq >= 11, 11, rp.plcmnt_seq) [ord]
		,child
		,tx_srvc
		,ISNULL(rpx.berk_tx_plcm_setng, 'Other') [current_setng]
		--,LEAD(ISNULL(rpx.berk_tx_plcm_setng, 'Other'), 1,0) 
		--	OVER (PARTITION BY child ORDER BY begin_date) [next_setng]
		,tx_end_rsn
		,LAG(tx_end_rsn) OVER (
			PARTITION BY sfy
			,id_removal_episode_fact ORDER BY begin_date
				,end_date
			) [prior_end_rsn]
		,CAST(IIF(DATEDIFF(dd, removal_dt, dbo.lessorDate3([18bday], cutoff_date, rp.discharge_dt)) < 8, 1, 0) AS SMALLINT) [flag_7day]
		,CAST(0 AS SMALLINT) [flag_trh]
		,(
			SELECT MAX(calendar_date)
			FROM CALENDAR_DIM
			WHERE MONTH(calendar_date) = MONTH(rp.removal_dt)
				AND CALENDAR_DATE BETWEEN cd.fy_start_date
					AND cd.fy_stop_date
				AND DAY(calendar_date) <= DAY(rp.removal_dt)
			) [anniv_removal_dt]
		,sfy
		,cd.fy_start_date
		,cd.fy_stop_date
		,IIF(nd.id_prsn IS NOT NULL, 1, 0) [fl_nondcfs_custody]
		,CAST(NULL AS INT) [care_day_cnt_prior_anniv]
		,CAST(NULL AS INT) [care_day_cnt_post_anniv]
		,CAST(NULL AS INT) [prior_year_service]
		,CAST(NULL AS INT) [post_year_service]
		,CAST(NULL AS INT) [otr_order]
		,CAST(NULL AS DATETIME) [plc_begin_otr]
		,CAST(NULL AS DATETIME) [plc_end_otr]
		,CAST(NULL AS INT) [care_day_cnt_prior_anniv_otr]
		,CAST(NULL AS INT) [care_day_cnt_post_anniv_otr]
	INTO #placements
	FROM (
		SELECT DISTINCT state_fiscal_yyyy [sfy]
			,MIN(ID_CALENDAR_DIM) OVER (
				PARTITION BY state_fiscal_yyyy ORDER BY ID_CALENDAR_DIM
				) [fy_start_date_int]
			,MAX(ID_CALENDAR_DIM) OVER (
				PARTITION BY state_fiscal_yyyy ORDER BY ID_CALENDAR_DIM ASC RANGE BETWEEN CURRENT ROW
						AND UNBOUNDED FOLLOWING
				) [fy_stop_date_int]
			,MIN(calendar_date) OVER (
				PARTITION BY state_fiscal_yyyy ORDER BY calendar_date
				) [fy_start_date]
			,MAX(calendar_date) OVER (
				PARTITION BY state_fiscal_yyyy ORDER BY calendar_date ASC RANGE BETWEEN CURRENT ROW
						AND UNBOUNDED FOLLOWING
				) [fy_stop_date]
		FROM.dbo.calendar_dim
		WHERE state_fiscal_yyyy BETWEEN @fystart AND @fystop
		) cd
	JOIN ref_last_dw_transfer dw ON dw.cutoff_date = dw.cutoff_date
	JOIN base.rptPlacement_Events rp ON removal_dt <= cd.fy_stop_date
		-- discharge_dt >=fy_start_date
		AND -- lessor date of 18th birthday is greater than cutoff_date use cutoff else use lessor date 18 bday or discharge date
			dbo.lessorDate3([18bday], rp.discharge_dt, cutoff_date) >= fy_start_date
		AND rp.begin_date <= cd.fy_stop_date
		--  end_date >=cd.fy_start_date
		AND dbo.lessorDate4([18bday], rp.discharge_dt, cutoff_date, rp.end_date) >= cd.fy_start_date
	LEFT JOIN dbo.ref_plcm_setting_xwalk rpx ON rp.cd_plcm_setng = rpx.cd_plcm_setng
	LEFT JOIN PEOPLE_DIM pd ON pd.ID_PRSN = rp.child
		AND pd.IS_CURRENT = 1
	LEFT JOIN dbo.vw_nondcfs_combine_adjacent_segments nd ON nd.id_prsn = rp.child
		AND nd.cust_begin <= rp.begin_date
		AND rp.end_date <= nd.cust_end
	WHERE rp.cd_epsd_type <> 5
		AND dbo.fnc_datediff_yrs(pd.dt_birth, begin_date) < 18
		-- and placement begin date less than cutoff_date
		AND removal_dt <= dbo.lessorDate3([18bday], rp.discharge_dt, cutoff_date)
	--and DATEDIFF(yy, birthdate, cd.fy_stop_date) >= 9
	ORDER BY child
		,begin_date
		,sfy

	UPDATE #placements
	SET flag_trh = 1
	--  SELECT * 
	FROM #placements
	WHERE NOT (
			tx_end_rsn = 'Changed Caregiver'
			AND CHARINDEX('Trial Return Home', prior_end_rsn) > 0
			)
		AND CHARINDEX('Trial Return Home', prior_end_rsn) > 0

	--SELECT * FROM #placements WHERE anniv_removal_dt IS NULL
	--these are last placements before a discharge where the discharge occurs prior to the removal anniversary date within the fiscal year
	UPDATE #placements
	SET anniv_removal_dt = NULL
		,care_day_cnt_prior_anniv = DATEDIFF(dd, dbo.greatorDate(fy_start_date, plc_begin), dbo.lessorDate3(plc_end, discharg_frc_18, fy_stop_date))
		,prior_year_service = dbo.fnc_datediff_yrs(removal_dt, discharg_frc_18)
	WHERE anniv_removal_dt NOT BETWEEN removal_dt
			AND discharg_frc_18

	DELETE #placements
	WHERE anniv_removal_dt IS NULL
		AND care_day_cnt_prior_anniv = 0;

	-- update the placements containing the anniversary dates.
	UPDATE #placements
	SET care_day_cnt_prior_anniv = DATEDIFF(dd, dbo.greatorDate(fy_start_date, plc_begin), anniv_removal_dt)
		,prior_year_service = dbo.fnc_datediff_yrs(removal_dt, CASE
			WHEN removal_dt != anniv_removal_dt
				THEN DATEADD(dd, -1, anniv_removal_dt)
			ELSE removal_dt
			END)
		,care_day_cnt_post_anniv = DATEDIFF(dd, anniv_removal_dt, dbo.lessorDate(fy_stop_date, plc_end))
		,post_year_service = dbo.fnc_datediff_yrs(removal_dt, anniv_removal_dt)
	WHERE anniv_removal_dt IS NOT NULL
		AND anniv_removal_dt BETWEEN plc_begin AND plc_end

	--update the placements without the anniversary dates
	UPDATE P
	SET care_day_cnt_prior_anniv = DATEDIFF(dd, dbo.greatorDate(fy_start_date, plc_begin), dbo.lessorDate(fy_stop_date, plc_end))
		,prior_year_service = dbo.fnc_datediff_yrs(removal_dt, dbo.greatorDate(fy_start_date, plc_begin))
	FROM #placements P
	WHERE anniv_removal_dt IS NOT NULL
		AND anniv_removal_dt NOT BETWEEN plc_begin AND plc_end

	IF OBJECT_ID('tempdb..#otr_spells') IS NOT NULL
		DROP TABLE #otr_spells

	SELECT RANK() OVER (
			PARTITION BY child ORDER BY begin_date
			) otr_order
		,id_placement_fact
		,child
		,begin_date plc_begin_otr
		,end_date plc_end_otr
	INTO #otr_spells
	FROM.base.rptPlacement_Events
	WHERE tx_srvc IN ('On The Run','OR: On the Run')

	UPDATE #placements
	SET otr_order = otr.otr_order
		,plc_begin_otr = otr.plc_begin_otr
		,plc_end_otr = otr.plc_end_otr
	FROM (
		SELECT *
		FROM #otr_spells
		) otr
	WHERE #placements.id_placement_fact = otr.id_placement_fact

	UPDATE #placements
	SET care_day_cnt_prior_anniv_otr = IIF(otr_order IS NULL, NULL, care_day_cnt_prior_anniv)
		,care_day_cnt_post_anniv_otr = IIF(otr_order IS NULL, NULL, care_day_cnt_post_anniv)
		,otr_order = 3
	WHERE otr_order >= 3

	--SELECT * FROM #placements WHERE anniv_removal_dt IS NOT NULL AND care_day_cnt_prior_anniv IS NULL AND care_day_cnt_post_anniv IS NULL ORDER BY child, id_removal_episode_fact
	CREATE NONCLUSTERED INDEX idx_1 ON #placements (
		[flag_7day]
		,[flag_trh]
		,[fl_nondcfs_custody]
		) INCLUDE (
		[removal_dt]
		,[age_yrs_removal]
		,[age_yrs_exit]
		,[cd_race_census]
		,[census_Hispanic_Latino_Origin_cd]
		,[county_cd]
		,[plcmnt_seq]
		,[plc_begin]
		,[current_setng]
		,[sfy]
		,[fy_start_date]
		,[fy_stop_date]
		,[care_day_cnt_post_anniv]
		,[post_year_service]
		,[otr_order]
		,[care_day_cnt_post_anniv_otr]
		)

	CREATE NONCLUSTERED INDEX idx_2 ON #placements (
		[cd_race_census]
		,[census_Hispanic_Latino_Origin_cd]
		,[flag_7day]
		,[flag_trh]
		,[fl_nondcfs_custody]
		) INCLUDE (
		[removal_dt]
		,[age_yrs_removal]
		,[age_yrs_exit]
		,[county_cd]
		,[plcmnt_seq]
		,[plc_begin]
		,[current_setng]
		,[sfy]
		,[fy_start_date]
		,[fy_stop_date]
		,[care_day_cnt_post_anniv]
		,[post_year_service]
		,[otr_order]
		,[care_day_cnt_post_anniv_otr]
		)

	IF OBJECT_ID('tempdb..#care_day_count') IS NOT NULL
		DROP TABLE #care_day_count

	CREATE TABLE #care_day_count (
		fiscal_yr INT
		,care_days INT
		,care_days_otr INT
		,years_in_care INT
		,age_removal INT
		,age_exit INT
		,cd_race INT
		,cd_cnty INT
		,excludes_7day INT
		,excludes_trh INT
		,excludes_nondcfs INT
		,placement_moves INT
		,kin_cnt INT
		,foster_cnt INT
		,group_cnt INT
		,otr_order INT
		)

	INSERT INTO #care_day_count (
		fiscal_yr
		,years_in_care
		,age_removal
		,age_exit
		,cd_race
		,cd_cnty
		,excludes_7day
		,excludes_trh
		,excludes_nondcfs
		,care_days
		,care_days_otr
		,placement_moves
		,kin_cnt
		,foster_cnt
		,group_cnt
		,otr_order
		)
	SELECT rp.sfy fiscal_yr
		,IIF(rp.prior_year_service > 10, 10, rp.prior_year_service)
		,yrs.age_yr age_removal
		,yrs_exit.age_yr age_exit
		,eth.cd_race
		,cnty.cd_cnty
		,ss.excludes_7day
		,trh.excludes_trh
		,nd.excludes_nondcfs
		,SUM(rp.care_day_cnt_prior_anniv) n_care_days
		,SUM(rp.care_day_cnt_prior_anniv_otr) n_care_days_otr
		,SUM(IIF(plcmnt_seq > 1
				AND plc_begin BETWEEN fy_start_date AND fy_stop_date, 1, 0)) [placement_moves]
		,SUM(IIF(plcmnt_seq > 1
				AND plc_begin BETWEEN fy_start_date AND fy_stop_date
				AND current_setng = 'Kin', 1, 0)) [kin_cnt]
		,SUM(IIF(plcmnt_seq > 1
				AND plc_begin BETWEEN fy_start_date AND fy_stop_date
				AND current_setng = 'Foster', 1, 0)) [foster_cnt]
		,SUM(IIF(plcmnt_seq > 1
				AND plc_begin BETWEEN fy_start_date AND fy_stop_date
				AND current_setng = 'Group', 1, 0)) [group_cnt]
		,otr_order
	FROM #placements rp
	JOIN prm_age_yrs yrs ON yrs.match_age_yr = rp.age_yrs_removal
	JOIN prm_age_yrs yrs_exit ON yrs_exit.match_age_yr = rp.age_yrs_exit
	JOIN prm_eth_census eth ON eth.match_code = rp.cd_race_census
		AND eth.cd_origin = rp.census_Hispanic_Latino_Origin_cd
	JOIN prm_cnty cnty ON cnty.match_code = rp.county_cd
	JOIN prm_shortstay ss ON ss.match_code = rp.flag_7day
	JOIN prm_trh trh ON trh.match_code = rp.flag_trh
	JOIN prm_nondcfs_custody nd ON nd.match_code = rp.fl_nondcfs_custody
	GROUP BY rp.sfy
		,IIF(rp.prior_year_service > 10, 10, rp.prior_year_service)
		,yrs.age_yr
		,yrs_exit.age_yr
		,eth.cd_race
		,cnty.cd_cnty
		,ss.excludes_7day
		,trh.excludes_trh
		,nd.excludes_nondcfs
		,otr_order

	INSERT INTO #care_day_count (
		fiscal_yr
		,years_in_care
		,age_removal
		,age_exit
		,cd_race
		,cd_cnty
		,excludes_7day
		,excludes_trh
		,excludes_nondcfs
		,care_days
		,care_days_otr
		,placement_moves
		,kin_cnt
		,foster_cnt
		,group_cnt
		,otr_order
		)
	SELECT rp.sfy fiscal_yr
		,IIF(rp.post_year_service > 10, 10, rp.post_year_service)
		,yrs.age_yr age_removal
		,yrs_exit.age_yr age_exit
		,eth.cd_race
		,cnty.cd_cnty
		,ss.excludes_7day
		,trh.excludes_trh
		,nd.excludes_nondcfs
		,SUM(rp.care_day_cnt_post_anniv) [n_care_days]
		,SUM(rp.care_day_cnt_prior_anniv_otr) [n_care_days_otr]
		,SUM(IIF(plcmnt_seq > 1
				AND plc_begin BETWEEN fy_start_date AND fy_stop_date, 1, 0)) [placement_moves]
		,SUM(IIF(plcmnt_seq > 1
				AND plc_begin BETWEEN fy_start_date AND fy_stop_date
				AND current_setng = 'Kin', 1, 0)) [kin_cnt]
		,SUM(IIF(plcmnt_seq > 1
				AND plc_begin BETWEEN fy_start_date AND fy_stop_date
				AND current_setng = 'Foster', 1, 0)) [foster_cnt]
		,SUM(IIF(plcmnt_seq > 1
				AND plc_begin BETWEEN fy_start_date AND fy_stop_date
				AND current_setng = 'Group', 1, 0)) [group_cnt]
		,otr_order
	FROM #placements rp
	JOIN prm_age_yrs yrs ON yrs.match_age_yr = rp.age_yrs_removal
	JOIN prm_age_yrs yrs_exit ON yrs_exit.match_age_yr = rp.age_yrs_exit
	JOIN prm_eth_census eth ON eth.match_code = rp.cd_race_census
		AND eth.cd_origin = rp.census_Hispanic_Latino_Origin_cd
	JOIN prm_cnty cnty ON cnty.match_code = rp.county_cd
	JOIN prm_shortstay ss ON ss.match_code = rp.flag_7day
	JOIN prm_trh trh ON trh.match_code = rp.flag_trh
	JOIN prm_nondcfs_custody nd ON nd.match_code = rp.fl_nondcfs_custody
	GROUP BY rp.sfy
		,IIF(rp.post_year_service > 10, 10, rp.post_year_service)
		,yrs.age_yr
		,yrs_exit.age_yr
		,eth.cd_race
		,cnty.cd_cnty
		,ss.excludes_7day
		,trh.excludes_trh
		,nd.excludes_nondcfs
		,otr_order

	TRUNCATE TABLE base.placement_care_days_otr

	INSERT INTO base.placement_care_days_otr (
		fiscal_yr
		,age_in_fy
		,cd_cnty
		,excludes_trh
		,excludes_nondcfs
		,excludes_7day
		,care_days
		,care_days_otr
		)
	SELECT fiscal_yr
		,(years_in_care + age_removal) [age_in_fy]
		,cd_cnty
		,excludes_trh
		,excludes_nondcfs
		,excludes_7day
		,SUM(care_days) care_days
		,ISNULL(SUM(care_days_otr), 0) [care_days_otr]
	FROM #care_day_count
	WHERE
		-- excludes_7day = 1
		--AND excludes_nondcfs = 1
		--AND excludes_trh = 1
		--AND age_exit <> -99
		--AND age_removal <> -99 
		years_in_care + age_removal BETWEEN 9
			AND 17
	--AND cd_cnty = 0
	GROUP BY fiscal_yr
		,(years_in_care + age_removal)
		,cd_cnty
		,excludes_trh
		,excludes_nondcfs
		,excludes_7day
	ORDER BY fiscal_yr
		,(years_in_care + age_removal)
		,cd_cnty
END
