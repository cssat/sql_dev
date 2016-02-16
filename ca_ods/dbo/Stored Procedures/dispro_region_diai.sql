CREATE procedure [dbo].[dispro_region_diai]
as
BEGIN

/*
    Calculate DIAI for each measure
	Based on the table dispro_data

	This query
	
	- selects all the measure columns, filling in NULLs with 0s
	- unpivots the measure columns, filtering out 'unknown' race and any non-standard regions
	- Initializes a DI/AI column
	- Fills in the DI/AI column by joining to a subquery that
		year, measure, and optionally region and selects the rate corresponding
		to the reference race (White or Non-Hispanic White only).
*/


-- Fill in NULLs as 0s so they will be included in the unpivot
if object_id('tempdb..#dispro_data_nonull') is not null drop table #dispro_data_nonull;
select
year
, intake_region
, SINGLE_RACE
, CD_MULTI_RACE_ETHNICITY
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


-- Unpivot measure columns
-- Aggregate measure columns summing for numerators, counting for denominators
--    this gives the individual race rates post-intake
-- Filter out any non-standard regions
-- Filter out any 'Unknown' race
if object_id('tempdb..##dispro_region_diai') is not null drop table ##dispro_region_diai;
select
  year
	, intake_region
	, TX_MULTI_RACE_ETHNICITY
	, measure
	, sum(value) numerator
	, count(*) denominator
	, sum(value) * 1.0 / count(*) rate
	, cast(NULL as float) diai
INTO ##dispro_region_diai
FROM
(select
  -- non-pivot columns
    year
	, intake_region
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
    intake_region in (
		 'Region 1'
		,'Region 2'
		,'Region 3'
		,'Region 4'
		,'Region 5'
		,'Region 6'
	)
	AND TX_MULTI_RACE_ETHNICITY <> 'Unknown'
GROUP BY 
  year
	, intake_region
	, TX_MULTI_RACE_ETHNICITY
	, measure
ORDER BY
  year
	, intake_region
	, TX_MULTI_RACE_ETHNICITY
	, measure;


-- Calculate the DIAI
-- Divide each race rate by the white rate for that measure:year:region combination
UPDATE du 
SET du.diai = cast(iif(wr.white_rate = 0, 0.0, du.rate * 1.0 / wr.white_rate) as float)
FROM ##dispro_region_diai du
LEFT JOIN 
	(select year, intake_region, measure, rate white_rate
	from ##dispro_region_diai
	where TX_MULTI_RACE_ETHNICITY = 'White/Caucasian') wr
ON du.year = wr.year
	AND du.intake_region = wr.intake_region
	AND du.measure = wr.measure;

END;