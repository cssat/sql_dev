CREATE procedure [dbo].[dispro_state_diai]
as
BEGIN

/*
    Calculate DI/AI for each decision point

	This query first unpivots the measure columns from dispro_data
	Adds a DI/AI column
	And fills in the DI/AI column by joining to a subquery that
		year, measure, and optionally region and selects the rate corresponding
		to the reference race (White or Non-Hispanic White only).
*/

if object_id('tempdb..#dispro_data_nonull') is not null drop table #dispro_data_nonull;
select
year
-- , intake_region
-- , SINGLE_RACE
-- , CD_MULTI_RACE_ETHNICITY
, TX_MULTI_RACE_ETHNICITY
		, isnull(screen_in             , 0)	screen_in            
		, isnull(removal			   , 0)	removal			  
		, isnull(removal_60day		   , 0)	removal_60day		  
		, isnull(removal_2yr		   , 0)	removal_2yr		  
		, isnull(not_reun_within_1yr	   , 0)	not_reun_within_1yr	  
		, isnull(kin_not_1st_placement , 0)	kin_not_1st_placement
		, isnull(initial_instability   , 0)	initial_instability  
		, isnull(ongoing_instability   , 0) ongoing_instability 
INTO #dispro_data_nonull
from dispro_data;


if object_id('tempdb..##dispro_state_diai') is not null drop table ##dispro_state_diai;
select
  year
--	, intake_region
	, TX_MULTI_RACE_ETHNICITY
	, measure
	, sum(value) numerator
	, count(*) denominator
	, sum(value) * 1.0 / count(*) rate
	, cast(NULL as float) diai
INTO ##dispro_state_diai
FROM
(select
  -- non-pivot columns
    year
  --	, intake_region
	, TX_MULTI_RACE_ETHNICITY
  -- pivot columns
    , measure
	, value
FROM #dispro_data_nonull
	UNPIVOT (value for measure in (
		  screen_in
		, removal
		, removal_60day
		, removal_2yr
		, not_reun_within_1yr
		, kin_not_1st_placement
		, initial_instability
		, ongoing_instability
	)) as measure) unpvt
WHERE
 --   intake_region in (
	--	 'Region 1'
	--	,'Region 2'
	--	,'Region 3'
	--	,'Region 4'
	--	,'Region 5'
	--	,'Region 6'
	--) AND
	TX_MULTI_RACE_ETHNICITY <> 'Unknown'
GROUP BY 
  year
--	, intake_region
	, TX_MULTI_RACE_ETHNICITY
	, measure
ORDER BY
  year
--	, intake_region
	, TX_MULTI_RACE_ETHNICITY
	, measure;


UPDATE du 
SET du.diai = cast(iif(wr.white_rate = 0, 0.0, du.rate * 1.0 / wr.white_rate) as float)
FROM ##dispro_state_diai du
LEFT JOIN 
	(select year
	-- , intake_region
	, measure
	, rate white_rate
	from ##dispro_state_diai
	where TX_MULTI_RACE_ETHNICITY = 'White/Caucasian') wr
ON du.year = wr.year
	-- AND du.intake_region = wr.intake_region
	AND du.measure = wr.measure;

END;