

declare @surv_data surv_table;
declare @filtercode int;
declare @state_fiscal_year datetime;
declare @max_state_fiscal_year datetime;
declare @results table (state_fiscal_year datetime,filtername varchar(255),filtercode int,dur_days int,fl_close int ,num int,n_i float,q_i int,s_i  float)
declare @parameter_column_name varchar(255);
declare @mysql varchar(8000);
set @parameter_column_name='removal_county_cd'


set @state_fiscal_year=(select min(state_fiscal_year) from calendar_dim where state_fiscal_year > '2000-01-01');
set @max_state_fiscal_year=(select max(state_fiscal_year) from calendar_dim  where  dateadd(yy,1,(state_fiscal_year)) < (select cutoff_date from ref_last_dw_transfer) );

--Get the entry cohorts; exclude episodes less than 8 days (bin_los_cd=0)
if object_id('tempDB..##first_entries_in_yr') is not null drop table ##first_entries_in_yr;
select  distinct cd.state_fiscal_year
		, eps.id_prsn_child
		, first_value(removal_dt) over (partition by cd.state_fiscal_year,eps.id_prsn_child order by  eps.removal_dt) frst_removal_dt_in_year
into ##first_entries_in_yr
from   prtl.ooh_dcfs_eps eps 
join CALENDAR_DIM cd on cd.CALENDAR_DATE=removal_dt
where   max_bin_los_cd > 0  and cd.state_fiscal_year >=@state_fiscal_year;


-- first NO FILTERS
while @state_fiscal_year <=@max_state_fiscal_year
begin
		
		insert into @surv_data(id_prsn_child,dur_days,fl_close,filtercode)
		select eps.id_prsn_child
			,iif( federal_discharge_date < getdate() 
						,datediff(dd,eps.removal_dt,eps.federal_discharge_date)  + 1 
						,datediff(dd,eps.removal_dt,(select cutoff_date from ref_last_dw_transfer)))  [dur_days]
			,iif(nxt.removal_dt is not null and datediff(dd,eps.discharge_dt,nxt.removal_dt )<=365,1,0) fl_close
			,0
		 from   prtl.ooh_dcfs_eps eps  
		 join ##first_entries_in_yr entries on entries.id_prsn_child=eps.id_prsn_child and eps.removal_dt=frst_removal_dt_in_year
		  join CALENDAR_DIM cd on cd.CALENDAR_DATE=removal_dt
		  left join  prtl.ooh_dcfs_eps nxt on nxt.child_eps_rank_asc =eps.child_eps_rank_asc + 1
		  where  cd.state_fiscal_year = @state_fiscal_year  
				and eps.max_bin_los_cd > 0 
				and eps.cd_discharge_type in (1,4)
				and eps.federal_discharge_date < getdate() 
				and datediff(dd,eps.removal_dt,eps.federal_discharge_date)  + 1  <= 365
				



			insert into @results
			select distinct  @state_fiscal_year,@parameter_column_name,*
			from survfit(@surv_data,1) sf order by filtercode,dur_days
			delete from @surv_data ;
			set @state_fiscal_year=dateadd(yy,1,@state_fiscal_year)
	end
--reinitialize federal fiscal year start date;

set @state_fiscal_year=(select min(state_fiscal_year) from calendar_dim where state_fiscal_year > '2000-01-01');
if OBJECT_ID('tempDB..##temp' ) is not null drop table ##temp;

create table ##temp (id_prsn_child int,dur_days int,fl_close int,filtercode int)
while @state_fiscal_year <=@max_state_fiscal_year
begin
		set @mysql='
		insert into ##temp (id_prsn_child,dur_days,fl_close,filtercode)
		select eps.id_prsn_child
			,iif( federal_discharge_date < getdate() ,datediff(dd,eps.removal_dt,eps.federal_discharge_date)  + 1 ,datediff(dd,eps.removal_dt,(select cutoff_date from ref_last_dw_transfer)))  [dur_days]
			,iif(federal_discharge_date < getdate() and cd_discharge_type in (1,3,4),1,0) [fl_close],eps. '
			set @mysql=CONCAT(@mysql, @parameter_column_name)
			set @mysql=CONCAT(@mysql,'
		 from   prtl.ooh_dcfs_eps eps  
		 join ##first_entries_in_yr entries on entries.id_prsn_child=eps.id_prsn_child and eps.removal_dt=frst_removal_dt_in_year
		  join CALENDAR_DIM cd on cd.CALENDAR_DATE=removal_dt
		  where  cd.state_fiscal_year = ')
		  set @mysql=CONCAT(@mysql,char(39),convert(varchar(10),@state_fiscal_year,121),char(39),'  and eps.max_bin_los_cd > 0
		  order by dur_days desc');

		  execute(@mysql);

		  insert into @surv_data
		  select * from ##temp;

			insert into @results
			select distinct  @state_fiscal_year,@parameter_column_name,*
			from survfit(@surv_data,1) sf order by filtercode,dur_days;

			delete from @surv_data ;
			truncate table ##temp;

			set @state_fiscal_year=dateadd(yy,1,@state_fiscal_year)
			set @mysql=''
	end

if object_id(N'prtl.cfsr_permanency_outcome_1 ',N'U') is not null truncate table prtl.cfsr_permanency_outcome_1 
insert into prtl.cfsr_permanency_outcome_1 
select  state_fiscal_year,filtername ,filtercode,dur_days,num,n_i,q_i,s_i,1.0000 - s_i  as [1-s]  from @results 
where filtercode <> -99
 order by state_fiscal_year,filtercode;

 select * from prtl.cfsr_permanency_outcome_1  where dur_days=365 order by state_fiscal_year,filtercode asc;






 

 






			





 

 
