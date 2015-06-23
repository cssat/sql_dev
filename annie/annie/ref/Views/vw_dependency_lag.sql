CREATE VIEW [ref].[vw_dependency_lag]
    AS 
SELECT 
    dep.bin_dependency_cd, 
    dep.bin_dependency_desc, 
    dep.diff_days_from, 
    dep.diff_days_thru, 
    dep.fl_dep_exist, 
    dep.lag_days, 
    dep.min_filter_date, 
    1 [date_type], 
    IIF(dep.bin_dependency_cd = 0, dw.cutoff_date, DATEADD(mm,-3,DATEADD(dd,(-1 * ABS(dep.lag_days)),dw.cutoff_date))) [max_filter_date], 
    IIF(dep.bin_dependency_cd = 0, dw.cutoff_date, DATEADD(mm,-12,DATEADD(dd,(-1 * ABS(dep.lag_days)),dw.cutoff_date))) [cohort_max_filter_date]
FROM ref.filter_dependency dep 
CROSS JOIN ref.last_dw_transfer dw 

UNION ALL

SELECT 
    dep.bin_dependency_cd, 
    dep.bin_dependency_desc, 
    dep.diff_days_from, 
    dep.diff_days_thru, 
    dep.fl_dep_exist, 
    dep.lag_days, 
    dep.min_filter_date, 
    2 [date_type], 
    IIF(dep.bin_dependency_cd = 0, dw.cutoff_date, DATEADD(mm,-12,DATEADD(dd,(-1 * ABS(dep.lag_days)),dw.cutoff_date))) [max_filter_date], 
    IIF(dep.bin_dependency_cd = 0, dw.cutoff_date, DATEADD(mm,-21,DATEADD(dd,(-1 * ABS(dep.lag_days)),dw.cutoff_date))) [cohort_max_filter_date] 
FROM ref.filter_dependency dep 
CROSS JOIN ref.last_dw_transfer dw 
