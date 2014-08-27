select [start_date], poc2ab.cd_sib_age_grp , poc2ab.cd_race ethnicity_cd, 
                           poc2ab.cd_reporter_type, poc2ab.cd_allegation, 
                         poc2ab.cd_finding,old_region_cd  [geography],
			round((case when (sum(poc2ab.cnt_opened)) > 0 /* jitter all above 0 */  
                    then 
                        case when round((sum(poc2ab.cnt_opened)) + (2 * sqrt(-2 * log(max(poc2ab.x1))) * cos(2*pi()*max(poc2ab.x2))),0)  < 1
                        then 1
                        else round((sum(poc2ab.cnt_opened)) + (2 * sqrt(-2 * log(max(poc2ab.x1))) * cos(2*pi()*max(poc2ab.x2))),0) 
                        end
                    else (sum(poc2ab.cnt_opened) )
            end/(sum(pop.pop_cnt) * 1.00) * 1000),2)  data
-- into #temp
from prtl.cache_poc2ab_aggr poc2ab
join [dbo].[prm_household_census_population] pop on pop.cd_race=poc2ab.cd_race
and poc2ab.cd_county=pop.county_cd
and poc2ab.cd_sib_age_grp=pop.cd_sib_age_grp
and poc2ab.start_year=pop.measurement_year
and pop.pop_cnt > 0
join ref_lookup_county cnty on cnty.county_cd=poc2ab.cd_county
where qry_type=2 and date_type=2 and cd_access_type=0  and poc2ab.fl_include_perCapita=1  
group by [start_date], poc2ab.cd_sib_age_grp,poc2ab.cd_race, 
                     cnty.old_region_cd, poc2ab.cd_reporter_type, poc2ab.cd_allegation, 
                         poc2ab.cd_finding
order by [start_date], poc2ab.cd_sib_age_grp,poc2ab.cd_race, 
                       cnty.old_region_cd, poc2ab.cd_reporter_type, poc2ab.cd_allegation, 
                         poc2ab.cd_finding

--select * from #temp where [geography] is not null

--select * from ref_lookup_county where old_region_cd=2

--select * from #temp where geography=2 order by start_date ,cd_sib_age_grp,ethnicity_cd,cd_reporter_type,cd_allegation,cd_finding
--select * from prtl.cache_poc2ab_aggr  where cd_county in (3,7,11,19,20,36,39) and qry_type=2 and date_type=2 and cd_access_type=0  and fl_include_perCapita=1  
--order by start_date ,cd_sib_age_grp,cd_race,cd_reporter_type,cd_allegation,cd_finding

