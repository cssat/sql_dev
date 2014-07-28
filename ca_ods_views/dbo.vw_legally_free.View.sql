USE [CA_ODS]
GO

/****** Object:  View [dbo].[vw_legally_free]    Script Date: 7/28/2014 10:07:08 AM ******/
DROP VIEW [dbo].[vw_legally_free]
GO

/****** Object:  View [dbo].[vw_legally_free]    Script Date: 7/28/2014 10:07:08 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO







--if OBJECT_ID('tempDB..##legfree') is not null drop table ##legfree

CREATE view [dbo].[vw_legally_free]
as 
with cte_legally_free as (
		SELECT         tce.id_prsn_child 
					, tce.id_removal_episode_fact
                     , isnull((SELECT pk_gndr  FROM   ref_lookup_gender WHERE        tce.cd_gndr = ref_lookup_gender.cd_gndr), 3) [pk_gndr]
					 , tce.eps_total
					 , tce.cd_race_census [cd_race_census]
					 , tce.child_age_removal_begin
					 , tce.child_age_removal_end
					 , tce.census_hispanic_latino_origin_cd
					  , state_custody_start_date
					  , state_discharge_date
					  , max(dbo.IntDate_to_CalDate(lf.id_calendar_dim_effective)) [legally_free_date] 
                      , federal_discharge_date
					  , Federal_Discharge_Date_Force_18
					  , count(DISTINCT lf.id_legal_fact) [count_of_results] 
                      , tce.federal_discharge_reason_code
					  , tce.state_discharge_reason_code
					  , tce.state_discharge_reason
					  , ljd.cd_jurisdiction
					  , ljd.tx_jurisdiction
					  , IIF(Federal_Discharge_Date_Force_18 < = cutoff_date AND Federal_Discharge_Date > cutoff_date
					  , 'Emancipation' 
					  , Federal_Discharge_Reason) [Federal_Discharge_Reason_Force]
					  , tce.federal_discharge_reason
					  , datediff(dd, State_Custody_Start_Date
											 , max(dbo.IntDate_to_CalDate(ID_CALENDAR_DIM_EFFECTIVE))) AS custody_to_term
					  , row_number()  OVER (partition BY id_prsn_child
                                                       ORDER BY datediff(dd, State_Custody_Start_Date, max(dbo.IntDate_to_CalDate(ID_CALENDAR_DIM_EFFECTIVE))) ASC,ljd.tx_jurisdiction desc) [row_num] 
                        , tce.cnt_plcm
						, IIF( Federal_Discharge_Date_Force_18 > cutoff_date
								, datediff(dd, max(dbo.IntDate_to_CalDate(lf.id_calendar_dim_effective)),cutoff_date) +1
								, datediff(dd, max(dbo.IntDate_to_CalDate(lf.id_calendar_dim_effective)), Federal_Discharge_Date_Force_18) + 1 
							) [term_to_perm]
							, IIF(Federal_Discharge_Date_Force_18 > cutoff_date 
									AND federal_discharge_date > cutoff_date , 0,1) [discharge_flag]
FROM            base.tbl_child_episodes tce
		JOIN ref_last_dw_transfer on 1=1
		JOIN		dbo.legal_fact lf ON tce.id_prsn_child = lf.id_prsn
				 AND dbo.IntDate_to_CalDate(lf.id_calendar_dim_effective) > tce.state_custody_start_date  
				--			and dbo.IntDate_to_CalDate(lf.id_calendar_dim_effective) < =coalesce(federal_discharge_date,federal_discharge_date_force_18,cutoff_date)
				 AND dbo.IntDate_to_CalDate(ID_CALENDAR_DIM_EFFECTIVE) > '1998-01-29' 
		JOIN       dbo.legal_result_dim lrd ON lrd.id_legal_result_dim = lf.id_legal_result_dim 
					AND lrd.cd_result IN (47, 48, 56, 57, 58, 59, 60) --termination of parental rights
		LEFT JOIN     dbo.legal_jurisdiction_dim ljd ON ljd.id_legal_jurisdiction_dim = lf.id_legal_jurisdiction_dim
GROUP BY tce.id_prsn_child
				, state_custody_start_date
				, state_discharge_date
				, Federal_Discharge_Date_Force_18
				, federal_discharge_reason_code
				, federal_discharge_reason
				, state_discharge_reason_code
				, state_discharge_reason
				, federal_discharge_date
				, tce.cnt_plcm
				, ljd.tx_jurisdiction
				,ljd.CD_JURISDICTION
				, tce.eps_total
				, tce.cd_race_census
				, tce.child_age_removal_begin
				, tce.child_age_removal_end
				, tce.census_hispanic_latino_origin_cd
				, tce.cd_gndr
				, cutoff_date
				, tce.id_removal_episode_fact)

				select 
						lf.id_removal_episode_fact
						, lf.id_prsn_child
						, lf.pk_gndr
						, lf.eps_total
						, lf.cd_race_census
						, lf.child_age_removal_begin
						,  lf.child_age_removal_end
                         , lf.census_hispanic_latino_origin_cd
						 , lf.state_custody_start_date
						 , lf.state_discharge_date
						 , lf.legally_free_date
						 , lf.federal_discharge_date
                         , lf.federal_discharge_date_force_18
						 , lf.count_of_results
						 , lf.federal_discharge_reason_code
						 , lf.state_discharge_reason_code
						 , lf.cd_jurisdiction
						 , lf.tx_jurisdiction
                         , iif(lf.Federal_Discharge_Reason_Force  IN ('Deceased', 'Transfer to Private Agency Authority', '-' ) 
									,'Other'
									,lf.Federal_Discharge_Reason_Force) [Federal_Discharge_Reason_Force]
						 , lf.federal_discharge_reason
                         , lf.custody_to_term
						 , lf.cnt_plcm
						 , lf.term_to_perm
						 ,  iif(lf.Federal_Discharge_Reason_Force  IN ('Deceased', 'Transfer to Private Agency Authority', '-' ) ,1,lf.discharge_flag) [discharge_flag]
--				into ##legfree
				from cte_legally_free lf
				where lf.row_num=1 and (lf.federal_discharge_reason_code <> 1  )
				and lf.term_to_perm >= 0 
				--and not exists(select * from vw_legally_free vlf where vlf.id_prsn_child=lf.id_prsn_child);

				


GO


