USE [CA_ODS]
GO

/****** Object:  StoredProcedure [base].[prod_build_WRK_NonDCFS]    Script Date: 9/12/2019 12:06:01 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/*****************************************************************************************************************/
-- Script Title: WRK_nonDCFS.sql
-- Author: J Messerly (Transcribing spss code written by D. Marshall)
-- CHANGES  --- DATE:  BY:  Description:
-- DATE: 2012-08-02  BY: J.Messerly Description: ADDED FL_VOID=0 
/*****************************************************************************************************************/
CREATE PROCEDURE [base].[prod_build_WRK_NonDCFS] (@permission_key DATETIME)
AS
IF @permission_key = (
		SELECT cutoff_date
		FROM ref_last_DW_transfer
		)
BEGIN
	IF object_ID('tempDB..#Auth') IS NOT NULL
		DROP TABLE #Auth;

	SELECT DISTINCT ID_PLACEMENT_CARE_AUTH_FACT
		,ID_PLCMNT_CARE_AUTHORITY
		,ID_CALENDAR_DIM_BEGIN
		,ID_CALENDAR_DIM_END
		,ID_PEOPLE_DIM
		,pcaf.ID_PLACEMENT_CARE_AUTH_DIM
		,ID_PRSN
		,CD_PLACEMENT_CARE_AUTH
		,dbo.IntDate_to_CalDate(ID_CALENDAR_DIM_BEGIN) AS cust_begin
		,dbo.IntDate_to_CalDate(ID_CALENDAR_DIM_END) AS cust_end
		,CASE 
			WHEN ID_CALENDAR_DIM_END = 0
				THEN 999999
			ELSE datediff(dd, dbo.IntDate_to_CalDate(ID_CALENDAR_DIM_BEGIN), dbo.IntDate_to_CalDate(ID_CALENDAR_DIM_END))
			END AS custlos
		,CASE 
			WHEN CD_PLACEMENT_CARE_AUTH IN (
					3
					,4
					,5
					,6
					,10
					,11
					)
				THEN 0
			ELSE 1
			END AS custc
		,cast(0 AS INT) AS backtoDCFS
		,row_number() OVER (
			PARTITION BY ID_PRSN
			,dbo.IntDate_to_CalDate(ID_CALENDAR_DIM_BEGIN) ORDER BY ID_PLACEMENT_CARE_AUTH_FACT
				,CASE 
					WHEN ID_CALENDAR_DIM_END = 0
						THEN 999999
					ELSE datediff(dd, dbo.IntDate_to_CalDate(ID_CALENDAR_DIM_BEGIN), dbo.IntDate_to_CalDate(ID_CALENDAR_DIM_END))
					END DESC --,CD_PLACEMENT_CARE_AUTH desc
			) AS cust_order
	INTO #AUTH
	FROM dbo.PLACEMENT_CARE_AUTH_FACT pcaf
	JOIN dbo.PLACEMENT_CARE_AUTH_DIM pcad ON pcad.ID_PLACEMENT_CARE_AUTH_DIM = pcaf.ID_PLACEMENT_CARE_AUTH_DIM
	WHERE CD_PLACEMENT_CARE_AUTH <> - 99
		AND ID_PRSN >= 0
		AND dbo.IntDate_to_CalDate(ID_CALENDAR_DIM_BEGIN) IS NOT NULL
		AND ID_CALENDAR_DIM_BEGIN >= 19980101
		AND FL_VOID = 0
	ORDER BY ID_PRSN
		,dbo.IntDate_to_CalDate(ID_CALENDAR_DIM_BEGIN) ASC

	DELETE
	FROM #AUTH
	WHERE cust_order <> 1

	UPDATE #AUTH
	SET custlos = NULL
	WHERE custlos = 999999;

	UPDATE q2
	SET backtoDCFS = 1
	FROM #AUTH A
	JOIN (
		SELECT *
			,row_number() OVER (
				PARTITION BY id_prsn ORDER BY id_prsn
					,cust_begin DESC
				) AS auth_sort
		FROM #AUTH
		) lag ON lag.id_prsn = a.id_prsn
	JOIN (
		SELECT *
			,row_number() OVER (
				PARTITION BY id_prsn ORDER BY id_prsn
					,cust_begin DESC
				) AS auth_sort
		FROM #AUTH
		) q2 ON q2.id_prsn = a.id_prsn
		AND q2.auth_sort = lag.auth_sort + 1
		AND q2.ID_PLACEMENT_CARE_AUTH_DIM = A.ID_PLACEMENT_CARE_AUTH_DIM
	WHERE lag.custc = 1
		AND q2.custc = 0
		AND lag.CD_PLACEMENT_CARE_AUTH <> 1;

	UPDATE q2
	SET backtoDCFS = 1
	FROM #AUTH A
	JOIN (
		SELECT *
			,row_number() OVER (
				PARTITION BY id_prsn ORDER BY id_prsn
					,cust_begin DESC
				) AS auth_sort
		FROM #AUTH
		) lag2 ON lag2.id_prsn = a.id_prsn
	JOIN (
		SELECT *
			,row_number() OVER (
				PARTITION BY id_prsn ORDER BY id_prsn
					,cust_begin DESC
				) AS auth_sort
		FROM #AUTH
		) lag ON lag.id_prsn = a.id_prsn
		AND lag.auth_sort = lag2.auth_sort + 1
	JOIN (
		SELECT *
			,row_number() OVER (
				PARTITION BY id_prsn ORDER BY id_prsn
					,cust_begin DESC
				) AS auth_sort
		FROM #AUTH
		) q2 ON q2.id_prsn = a.id_prsn
		AND q2.auth_sort = lag2.auth_sort + 2
		AND q2.ID_PLACEMENT_CARE_AUTH_DIM = A.ID_PLACEMENT_CARE_AUTH_DIM
	WHERE q2.custc = 0
		AND lag2.custc = 1
		AND lag.CD_PLACEMENT_CARE_AUTH = 1;

	IF object_id(N'base.WRK_nonDCFS_All', N'U') IS NOT NULL
		DROP TABLE base.WRK_nonDCFS_All;

	SELECT DISTINCT ID_PRSN
		,CUST_BEGIN
		,CUST_END
		,backtoDCFS
		,CD_PLACEMENT_CARE_AUTH
		,CASE CD_PLACEMENT_CARE_AUTH
			WHEN 1
				THEN 'Closed'
			WHEN 2
				THEN 'DCFS'
			WHEN 3
				THEN 'Other State'
			WHEN 4
				THEN 'Private Agency'
			WHEN 5
				THEN 'Tribal w/o IV-E'
			WHEN 6
				THEN 'Tribal with IV-E'
			WHEN 7
				THEN 'Parental'
			WHEN 8
				THEN '3rd Party'
			WHEN 9
				THEN 'Court Ordered'
			WHEN 10
				THEN 'JRA'
			WHEN 11
				THEN 'Federal'
			END AS PLACEMENT_CARE_AUTH
		,1 AS nondcfs_mark
		,cast(convert(VARCHAR(10), getdate(), 101) AS DATETIME) AS tbl_refresh_dt
	INTO base.WRK_nonDCFS_All
	FROM #AUTH
	WHERE custc = 0
	ORDER BY ID_PRSN
		,CUST_BEGIN;

	UPDATE base.WRK_nonDCFS_All
	SET cust_end = '12/31/9999'
	WHERE cust_end IS NULL;

	IF object_ID('tempDB..#nondcfs') IS NOT NULL
		DROP TABLE #nondcfs;

	SELECT *
		,row_number() OVER (
			PARTITION BY id_prsn
			,CD_PLACEMENT_CARE_AUTH ORDER BY id_prsn
				,CD_PLACEMENT_CARE_AUTH
				,cust_begin
				,cust_end
			) AS cust_asc
		,row_number() OVER (
			PARTITION BY id_prsn
			,CD_PLACEMENT_CARE_AUTH ORDER BY id_prsn
				,CD_PLACEMENT_CARE_AUTH
				,cust_begin DESC
				,cust_end DESC
			) AS cust_desc
	INTO #nondcfs
	FROM base.WRK_nonDCFS_All
	ORDER BY id_prsn
		,CD_PLACEMENT_CARE_AUTH

	IF object_ID('tempDB..#mult') IS NOT NULL
		DROP TABLE #mult;

	SELECT *
	INTO #mult
	FROM #nondcfs
	WHERE NOT (
			cust_asc = 1
			AND cust_desc = 1
			)
	ORDER BY id_prsn
		,CD_PLACEMENT_CARE_AUTH
		,cust_asc

	IF object_ID('tempDB..#unq') IS NOT NULL
		DROP TABLE #unq;

	SELECT *
	INTO #unq
	FROM #mult
	WHERE cust_asc = 1;

	INSERT INTO #unq
	SELECT *
	FROM #nondcfs
	WHERE (
			cust_asc = 1
			AND cust_desc = 1
			)

	DECLARE @loopcnt INT
	DECLARE @loopstop INT

	SET @loopcnt = 1;

	SELECT @loopstop = max(cust_desc)
	FROM #mult;

	WHILE @loopcnt < @loopstop
	BEGIN
		-- concatenate dates for same person,auth
		UPDATE unq
		SET cust_end = m.cust_end
			,cust_asc = m.cust_asc
			,backtoDCFS = m.backtoDCFS
		FROM #unq unq
		JOIN #mult m ON m.id_prsn = unq.id_prsn
			AND m.CD_PLACEMENT_CARE_AUTH = unq.CD_PLACEMENT_CARE_AUTH
		WHERE m.cust_asc = unq.cust_asc + 1
			AND (
				m.cust_begin <= unq.cust_end
				OR dateadd(dd, - 1, m.cust_begin) = unq.cust_end
				)

		-- if not concatenated insert into table
		INSERT INTO #unq
		SELECT m.*
		FROM #mult m
		LEFT JOIN #unq unq ON unq.id_prsn = m.id_prsn
			AND unq.CD_PLACEMENT_CARE_AUTH = m.CD_PLACEMENT_CARE_AUTH
			AND unq.cust_asc = m.cust_asc
		WHERE unq.id_prsn IS NULL
			AND m.cust_asc = @loopcnt + 1;

		SET @loopcnt = @loopcnt + 1;
	END

	TRUNCATE TABLE base.WRK_nonDCFS_All;

	INSERT INTO base.WRK_nonDCFS_All
	SELECT [ID_PRSN]
		,[CUST_BEGIN]
		,[CUST_END]
		,[backtoDCFS]
		,[CD_PLACEMENT_CARE_AUTH]
		,[PLACEMENT_CARE_AUTH]
		,[nondcfs_mark]
		,cast(convert(VARCHAR(10), getdate(), 121) AS DATETIME)
	FROM #unq
	ORDER BY id_prsn
		,cust_begin
		,cust_end;

	UPDATE base.procedure_flow
	SET last_run_date = getdate()
	WHERE procedure_nm = 'prod_build_WRK_NonDCFS'
END
ELSE
BEGIN
	SELECT 'Need permission key to execute this --BUILDS nonDCFS custody table!' AS [Warning]
END

GO


