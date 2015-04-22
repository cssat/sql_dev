
CREATE VIEW [dbo].[vw_qa_prtl_pbcw3_parameter_field_values]
AS
SELECT        'qry_type' [col_name], qry_type [col_value], count(*) [cnt]
FROM            prtl.ooh_point_in_time_measures
WHERE fl_w3=1 GROUP BY  qry_type
UNION ALL
SELECT        'age_grouping_cd_mix' [col_name], age_grouping_cd_mix, count(*) [cnt]
FROM            prtl.ooh_point_in_time_measures
WHERE fl_w3=1 GROUP BY  age_grouping_cd_mix
UNION ALL
SELECT        'pk_gndr' [col_name], pk_gndr, count(*) [cnt]
FROM            prtl.ooh_point_in_time_measures
WHERE fl_w3=1 GROUP BY  pk_gndr
UNION ALL
SELECT        'cd_race_census' [col_name], cd_race, count(*) [cnt]
FROM            prtl.ooh_point_in_time_measures
WHERE fl_w3=1 GROUP BY  cd_race
UNION ALL
SELECT        'census_hispanic_latino_origin_cd' [col_name], census_hispanic_latino_origin_cd, count(*) [cnt]
FROM            prtl.ooh_point_in_time_measures
WHERE fl_w3=1 GROUP BY  census_hispanic_latino_origin_cd
UNION ALL
SELECT        'init_cd_plcm_setng' [col_name], init_cd_plcm_setng, count(*) [cnt]
FROM            prtl.ooh_point_in_time_measures
WHERE fl_w3=1 GROUP BY  init_cd_plcm_setng
UNION ALL
SELECT        'long_cd_plcm_setng' [col_name], long_cd_plcm_setng, count(*) [cnt]
FROM            prtl.ooh_point_in_time_measures
WHERE fl_w3=1 GROUP BY  long_cd_plcm_setng
UNION ALL
SELECT        'county_cd' [col_name], county_cd, count(*) [cnt]
FROM            prtl.ooh_point_in_time_measures
WHERE fl_w3=1 GROUP BY  county_cd
UNION ALL
SELECT        'bin_dep_cd' [col_name], bin_dep_cd, count(*) [cnt]
FROM            prtl.ooh_point_in_time_measures
WHERE fl_w3=1 GROUP BY  bin_dep_cd
UNION ALL
SELECT        'max_bin_los_cd' [col_name], max_bin_los_cd, count(*) [cnt]
FROM            prtl.ooh_point_in_time_measures
WHERE fl_w3=1 GROUP BY  max_bin_los_cd
UNION ALL
SELECT        'bin_placement_cd' [col_name], bin_placement_cd, count(*) [cnt]
FROM            prtl.ooh_point_in_time_measures
WHERE fl_w3=1 GROUP BY  bin_placement_cd
UNION ALL
SELECT        'cd_reporter_type' [col_name], cd_reporter_type, count(*) [cnt]
FROM            prtl.ooh_point_in_time_measures
WHERE fl_w3=1 GROUP BY  cd_reporter_type
UNION ALL
SELECT        'bin_ihs_svc_cd' [col_name], bin_ihs_svc_cd, count(*) [cnt]
FROM            prtl.ooh_point_in_time_measures
WHERE fl_w3=1 GROUP BY  bin_ihs_svc_cd
UNION ALL
SELECT        'family_setting_cnt' [col_name], family_setting_cnt, count(*) [cnt]
FROM            prtl.ooh_point_in_time_measures
WHERE fl_w3=1 GROUP BY  family_setting_cnt
UNION ALL
SELECT        'family_setting_DCFS_cnt' [col_name], family_setting_DCFS_cnt, count(*) [cnt]
FROM            prtl.ooh_point_in_time_measures
WHERE fl_w3=1 GROUP BY  family_setting_DCFS_cnt
UNION ALL
SELECT        'family_setting_private_agency_cnt' [col_name], family_setting_private_agency_cnt, count(*) [cnt]
FROM            prtl.ooh_point_in_time_measures
WHERE fl_w3=1 GROUP BY  family_setting_private_agency_cnt
UNION ALL
SELECT        'relative_care' [col_name], relative_care, count(*) [cnt]
FROM            prtl.ooh_point_in_time_measures
WHERE fl_w3=1 GROUP BY  relative_care
UNION ALL
SELECT        'group_inst_care_cnt' [col_name], group_inst_care_cnt, count(*) [cnt]
FROM            prtl.ooh_point_in_time_measures
WHERE fl_w3=1 GROUP BY  group_inst_care_cnt
UNION ALL
SELECT        'cnt_child' [col_name], cnt_child, count(*) [cnt]
FROM            prtl.ooh_point_in_time_measures
WHERE fl_w3=1 GROUP BY  cnt_child


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
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vw_qa_prtl_pbcw3_parameter_field_values';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vw_qa_prtl_pbcw3_parameter_field_values';

