
CREATE VIEW [UI].[vw_report_procedure_paramter_display_lookup_table]
AS
SELECT     TOP (20000) R.report_id AS [Report ID], R.report_name AS [Report Name], sp.sp_id AS [Stored Procedure ID], sp.sp_name AS [Stored Procedure Name], 
                      p.parameter_id AS [Parameter ID], p.parameter_name AS [Parameter Name], plt.parameter_lookup_table_name AS [Parameter Table Name], 
                      pd.parameter_display_id AS [Parameter Display ID], pd.parameter_display_name AS [Parameter Dispay Name]
FROM         UI.report_stored_procedure AS rsp LEFT OUTER JOIN
                      UI.stored_procedure_parameter AS spp ON rsp.sp_id = spp.sp_id LEFT OUTER JOIN
                      UI.report AS R ON R.report_id = rsp.report_id LEFT OUTER JOIN
                      UI.parameter AS p ON p.parameter_id = spp.parameter_ID LEFT OUTER JOIN
                      UI.parameter_lookup_table AS plt ON plt.parameter_lookup_table_id = spp.parameter_lookup_table_id LEFT OUTER JOIN
                      UI.stored_procedure AS sp ON sp.sp_id = spp.sp_id LEFT OUTER JOIN
                      UI.report_parameter_display AS rpd ON R.report_id = rpd.report_id AND p.parameter_id = rpd.parameter_id LEFT OUTER JOIN
                      UI.parameter_display AS pd ON pd.parameter_display_id = rpd.parameter_display_id
ORDER BY [Report ID]