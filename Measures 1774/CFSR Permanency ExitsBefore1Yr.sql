/******************************************************************************************************
Name:  CFSR Permanency ExitsBefore1Yr.sql
Page 22607 of Federal Registry Volume 79 No. 78
Permanency Performance Area 1: Permanency in 12 Months for Children  Entering Foster Care
Author: Jane Messerly
*********************************************************************************************************/

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

--Get the entry cohorts;   Want the next episode even if duration of next episode is  less than 8 days 
if object_id('tempDB..##first_entries_in_yr') is not null drop table ##first_entries_in_yr;
select  distinct cd.state_fiscal_year
		, eps.id_prsn_child
		, first_value(removal_dt) over (partition by cd.state_fiscal_year,eps.id_prsn_child order by  eps.removal_dt) frst_removal_dt_in_year
		, removal_dt
		, lead(removal_dt) over (partition by eps.id_prsn_child order by eps.removal_dt) nxt_removal_dt
		, max_bin_los_cd
into ##first_entries_in_yr
from   prtl.ooh_dcfs_eps eps 
join CALENDAR_DIM cd on cd.CALENDAR_DATE=removal_dt
where    cd.state_fiscal_year >=@state_fiscal_year;

-- only want first removals excluding episodes less than 8 days (bin_los_cd=0)
delete from ##first_entries_in_yr where removal_dt <> frst_removal_dt_in_year or  max_bin_los_cd=0;


-- first NO FILTERS
while @state_fiscal_year <=@max_state_fiscal_year
begin
		
		insert into @surv_data(id_prsn_child,dur_days,fl_close,filtercode)
		select eps.id_prsn_child
			,iif( federal_discharge_date < getdate() ,datediff(dd,eps.removal_dt,eps.federal_discharge_date)  ,datediff(dd,eps.removal_dt,cutoff_date)) + 1  [dur_days]
			,iif(federal_discharge_date < getdate() and cd_discharge_type in (1,3,4),1,0)[fl_close]
			,0
		 from   prtl.ooh_dcfs_eps eps  
		 join ##first_entries_in_yr entries on entries.id_prsn_child=eps.id_prsn_child and eps.removal_dt=frst_removal_dt_in_year
		  join CALENDAR_DIM cd on cd.CALENDAR_DATE=entries.frst_removal_dt_in_year
		  join ref_last_dw_transfer dw on dw.cutoff_date=dw.cutoff_date
		  where  cd.state_fiscal_year = @state_fiscal_year 
		  order by dur_days desc


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
			,iif( federal_discharge_date < getdate() ,datediff(dd,eps.removal_dt,eps.federal_discharge_date)  ,datediff(dd,eps.removal_dt,cutoff_date)) + 1  [dur_days]
			,iif(federal_discharge_date < getdate() and cd_discharge_type in (1,3,4),1,0) [fl_close],eps. '
			set @mysql=CONCAT(@mysql, @parameter_column_name)
			set @mysql=CONCAT(@mysql,'
		 from   prtl.ooh_dcfs_eps eps  
		 join ##first_entries_in_yr entries on entries.id_prsn_child=eps.id_prsn_child and eps.removal_dt=frst_removal_dt_in_year
		  join CALENDAR_DIM cd on cd.CALENDAR_DATE=frst_removal_dt_in_year
		  join ref_last_dw_transfer dw on dw.cutoff_date=dw.cutoff_date
		  where  cd.state_fiscal_year = ')
		  set @mysql=CONCAT(@mysql,char(39),convert(varchar(10),@state_fiscal_year,121),char(39),'  
		    order by  ');
		  set @mysql=concat(@mysql,'[',@parameter_column_name,'] ,dur_days asc');

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

if object_id(N'prtl.cfsr_permanency_exits_wi_1yr ',N'U') is not null truncate table prtl.cfsr_permanency_exits_wi_1yr 
insert into prtl.cfsr_permanency_exits_wi_1yr 
select  state_fiscal_year,filtername ,filtercode,dur_days,num,n_i,q_i,s_i,1.0000 - s_i  as [1-s]  from @results 
--where filtercode <> -99
 order by state_fiscal_year,filtercode;

select iif(filtercode<>0,1,0) filtercode,sum(n_i)  from prtl.cfsr_permanency_exits_wi_1yr  where dur_days=365
 and year(state_fiscal_year)=2010
 group by  iif(filtercode<>0,1,0)
  order by filtercode asc;

  select * from  prtl.cfsr_permanency_exits_wi_1yr where filtercode <> -99 and dur_days=365 order by state_fiscal_year,filtercode,dur_days




 

 






			





 

 
