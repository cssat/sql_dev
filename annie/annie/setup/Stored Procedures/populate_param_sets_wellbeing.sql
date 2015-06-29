CREATE PROCEDURE [setup].[populate_param_sets_wellbeing]
AS
IF (
		SELECT count()
		FROM prtl.param_sets_wellbeing
		) = 0
BEGIN
	INSERT prtl.param_sets_wellbeing (
		kincare
		,bin_sibling_group_size
		)
	SELECT k.kincare
		,sg.bin_sibling_group_size
	FROM ref.filter_kincare k
	CROSS JOIN ref.lookup_sibling_groups sg
	ORDER BY 1
		,2

    UPDATE STATISTICS prtl.param_sets_wellbeing
END
