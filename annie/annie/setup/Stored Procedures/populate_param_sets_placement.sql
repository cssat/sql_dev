CREATE PROCEDURE [setup].[populate_param_sets_placement]
AS
IF (
		SELECT count()
		FROM prtl.param_sets_placement
		) = 0
BEGIN
	INSERT prtl.param_sets_placement (
		bin_ihs_service_cd
		,initial_cd_placement_setting
		,longest_cd_placement_setting
		,bin_dependency_cd
		,bin_los_cd
		,bin_placement_cd
		,cd_discharge_type
		)
	SELECT isv.bin_ihs_service_cd
		,ips.cd_placement_setting
		,lps.cd_placement_setting
		,d.bin_dependency_cd
		,l.bin_los_cd
		,np.bin_placement_cd
		,dt.cd_discharge_type
	FROM ref.filter_ihs_services isv
	CROSS JOIN ref.lookup_placement_setting ips
	CROSS JOIN ref.lookup_placement_setting lps
	CROSS JOIN ref.filter_dependency d
	CROSS JOIN ref.filter_los l
	CROSS JOIN ref.filter_nbr_placement np
	CROSS JOIN ref.filter_discharge_type dt
	ORDER BY 1
		,2
		,3
		,4
		,5
		,6
		,7

    UPDATE STATISTICS prtl.param_sets_placement
END
