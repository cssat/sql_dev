CREATE VIEW [ref].[vw_los_lag]
    AS 
SELECT 
    los.bin_los_cd, 
    los.bin_los_desc, 
    los.dur_days_from, 
    los.dur_days_thru, 
    los.lag_days, 
    1 [date_type], 
    IIF(los.bin_los_cd = 0, dw.cutoff_date, DATEADD(mm,-3,DATEADD(dd,(-1 * ABS(los.lag_days)),dw.cutoff_date))) [max_filter_date], 
    IIF(los.bin_los_cd = 0, dw.cutoff_date, DATEADD(mm,-12,DATEADD(dd,(-1 * ABS(los.lag_days)),dw.cutoff_date))) [cohort_max_filter_date] 
FROM ref.filter_los los 
CROSS JOIN ref.last_dw_transfer dw 

UNION ALL 
	
SELECT 
    los.bin_los_cd, 
    los.bin_los_desc, 
    los.dur_days_from, 
    los.dur_days_thru, 
    los.lag_days, 
    2 [date_type], 
    IIF(los.bin_los_cd = 0, dw.cutoff_date, DATEADD(mm,-12,DATEADD(dd,(-1 * ABS(los.lag_days)),dw.cutoff_date))) [max_filter_date], 
    IIF(los.bin_los_cd = 0, dw.cutoff_date, DATEADD(mm,-21,DATEADD(dd,(-1 * ABS(los.lag_days)),dw.cutoff_date) )) [cohort_max_filter_date] 
FROM ref.filter_los los 
CROSS JOIN ref.last_dw_transfer dw 
