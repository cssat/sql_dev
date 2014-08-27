select [start_date], poc2ab.cd_sib_age_grp , poc2ab.cd_race ethnicity_cd, 
                           poc2ab.cd_reporter_type, poc2ab.cd_allegation, 
                         poc2ab.cd_finding,cd_county [geography],
			round(((case when
            (
                (case when poc2ab.cnt_start_date > 0   
                    then 
                        case when round(poc2ab.cnt_start_date + (2 * sqrt(-2 * log(poc2ab.x1)) * cos(2*pi()*poc2ab.x2)),0)  < 1
                        then 1
                        else round(poc2ab.cnt_start_date + (2 * sqrt(-2 * log(poc2ab.x1)) * cos(2*pi()*poc2ab.x2)),0) 
                        end
                    else poc2ab.cnt_start_date
                    end)		
                + 
                (case when (poc2ab.cnt_opened) > 0   
                    then 
                        case when round((poc2ab.cnt_opened) + (2 * sqrt(-2 * log(poc2ab.x1)) * cos(2*pi()*poc2ab.x2)),0)  < 1
                        then 1
                        else round((poc2ab.cnt_opened) + (2 * sqrt(-2 * log(poc2ab.x1)) * cos(2*pi()*poc2ab.x2)),0) 
                        end
                    else (poc2ab.cnt_opened) 
                end))
                <  
                (case when (poc2ab.cnt_closed) > 0   
                    then 
                        case when round(poc2ab.cnt_closed + (2 * sqrt(-2 * log(poc2ab.x1)) * cos(2*pi()*poc2ab.x2)),0)  < 1
                        then 1
                        else round(poc2ab.cnt_closed + (2 * sqrt(-2 * log(poc2ab.x1)) * cos(2*pi()*poc2ab.x2)),0) 
                        end
                    else (poc2ab.cnt_closed) 
                        end)
        then 
            (
                (case when poc2ab.cnt_start_date > 0   
                    then 
                        case when round(poc2ab.cnt_start_date + (2 * sqrt(-2 * log(poc2ab.x1)) * cos(2*pi()*poc2ab.x2)),0)  < 1
                        then 1
                        else round(poc2ab.cnt_start_date + (2 * sqrt(-2 * log(poc2ab.x1)) * cos(2*pi()*poc2ab.x2)),0) 
                        end
                    else poc2ab.cnt_start_date
                    end)		
                + 
                (case when (poc2ab.cnt_opened) > 0   
                    then 
                        case when round((poc2ab.cnt_opened) + (2 * sqrt(-2 * log(poc2ab.x1)) * cos(2*pi()*poc2ab.x2)),0)  < 1
                        then 1
                        else round((poc2ab.cnt_opened) + (2 * sqrt(-2 * log(poc2ab.x1)) * cos(2*pi()*poc2ab.x2)),0) 
                        end
                    else (poc2ab.cnt_opened) 
                end))
        else 
                    (case when (poc2ab.cnt_closed) > 0   
                    then 
                        case when round(poc2ab.cnt_closed + (2 * sqrt(-2 * log(poc2ab.x1)) * cos(2*pi()*poc2ab.x2)),0)  < 1
                        then 1
                        else round(poc2ab.cnt_closed + (2 * sqrt(-2 * log(poc2ab.x1)) * cos(2*pi()*poc2ab.x2)),0) 
                        end
                    else (poc2ab.cnt_closed) 
                        end)
        end)/(pop.pop_cnt * 1.00) * 1000),2)  data
from prtl.cache_poc2ab_aggr poc2ab
join [dbo].[prm_household_census_population] pop on pop.cd_race=poc2ab.cd_race
and poc2ab.cd_county=pop.county_cd
and poc2ab.cd_sib_age_grp=pop.cd_sib_age_grp
and poc2ab.start_year=pop.measurement_year
and pop.pop_cnt > 0
where qry_type=2 and date_type=2 and cd_access_type=0  and poc2ab.fl_include_perCapita=1
order by [start_date], poc2ab.cd_sib_age_grp,poc2ab.cd_race, 
                     cd_county, poc2ab.cd_reporter_type, poc2ab.cd_allegation, 
                         poc2ab.cd_finding

 