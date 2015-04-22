CREATE procedure [prtl].[sp_refresh_table_p_lop_1] 
as
set nocount on
set nocount on
declare @surv_data surv_table;
declare @filtercode int;
declare @state_fiscal_year datetime;
declare @max_state_fiscal_year datetime;
declare @results table (state_fiscal_year datetime,filtername varchar(255),filtercode int,dur_days int,fl_close int ,num int,n_i float,q_i int,s_i  float)
declare @parameter_column_name varchar(255);
declare @mysql varchar(8000);

declare @starttime datetime= getdate();

set @parameter_column_name='removal_county_cd'


set @state_fiscal_year=(select convert(varchar(10),min(state_fiscal_year),121)  from calendar_dim where state_fiscal_year > '2000-01-01');
set @max_state_fiscal_year=(select convert(varchar(10),max(state_fiscal_year),121) from calendar_dim join ref_last_dw_transfer dw on dw.cutoff_date=dw.cutoff_date
  where  dateadd(yy,1,(state_fiscal_year)) < cutoff_date );

--Get the entry cohorts;   Want the next episode even if duration of next episode is  less than 8 days
if object_id('tempDB..#first_entries_in_yr') is not null drop table #first_entries_in_yr;
select  distinct cd.state_fiscal_year
		, eps.id_prsn_child
		, first_value(removal_dt) over (partition by cd.state_fiscal_year,eps.id_prsn_child order by  eps.removal_dt) frst_removal_dt_in_year
		, removal_dt
		, lead(removal_dt) over (partition by eps.id_prsn_child order by eps.removal_dt) nxt_removal_dt
		, max_bin_los_cd
into #first_entries_in_yr
from   prtl.ooh_dcfs_eps eps 
join CALENDAR_DIM cd on cd.CALENDAR_DATE=removal_dt
where    cd.state_fiscal_year >=@state_fiscal_year;

-- only want first removals excluding episodes less than 8 days (bin_los_cd=0)
delete from #first_entries_in_yr where removal_dt <> frst_removal_dt_in_year or  max_bin_los_cd=0;

 -- now  keep only those discharged within 1 year with our discharge types (reunification to parent or gaurdian)
 delete frst from #first_entries_in_yr  frst 
		join prtl.ooh_dcfs_eps eps on eps.removal_dt=frst.frst_removal_dt_in_year and eps.id_prsn_child=frst.id_prsn_child
		join ref_last_dw_transfer dw on dw.cutoff_date=dw.cutoff_date
		where NOT( eps.cd_discharge_type in (1,4)
				and eps.federal_discharge_date <= cutoff_date
				and datediff(dd,eps.removal_dt,eps.federal_discharge_date)  + 1  between 0 and  365)

-- first NO FILTERS
while @state_fiscal_year <=@max_state_fiscal_year
begin
		
		insert into @surv_data(id_prsn_child,dur_days,fl_close,filtercode)
		select eps.id_prsn_child
			,iif( nxt_removal_dt is not null
						,datediff(dd,eps.federal_discharge_date,nxt_removal_dt)  
						,datediff(dd,eps.federal_discharge_date,cutoff_date))  + 1  [dur_days]
			,iif( nxt_removal_dt is not null and datediff(dd,eps.federal_discharge_date,nxt_removal_dt)  <=365,1,0) fl_close
			,0
		 from   prtl.ooh_dcfs_eps eps  
			join #first_entries_in_yr entries on entries.id_prsn_child=eps.id_prsn_child and eps.removal_dt=frst_removal_dt_in_year
			join ref_last_dw_transfer dw on dw.cutoff_date=dw.cutoff_date
			where entries.state_fiscal_year=@state_fiscal_year
			order by dur_days asc;
		 
				

			insert into @results
			select distinct  @state_fiscal_year,@parameter_column_name,*
			from survfit(@surv_data,1) sf order by filtercode,dur_days
			delete from @surv_data ;
			set @state_fiscal_year=dateadd(yy,1,@state_fiscal_year)
	end
--reinitialize federal fiscal year start date;

set @state_fiscal_year=(select min(state_fiscal_year) from calendar_dim where state_fiscal_year > '2000-01-01');
if OBJECT_ID('tempDB..#temp' ) is not null drop table #temp;

create table #temp (id_prsn_child int,dur_days int,fl_close int,filtercode int)
while @state_fiscal_year <=@max_state_fiscal_year
begin
		set @mysql='
		insert into #temp (id_prsn_child,dur_days,fl_close,filtercode)
		select eps.id_prsn_child
			,iif( nxt_removal_dt is not null
						,datediff(dd,eps.federal_discharge_date,nxt_removal_dt)  
						,datediff(dd,eps.federal_discharge_date,cutoff_date))  + 1  [dur_days]
			,iif( nxt_removal_dt is not null and datediff(dd,eps.federal_discharge_date,nxt_removal_dt)  <=365,1,0) fl_close
			,isnull(eps. '
			set @mysql=CONCAT(@mysql, @parameter_column_name)
			set @mysql=CONCAT(@mysql,', -99)  [',@parameter_column_name,']
		 from   prtl.ooh_dcfs_eps eps  
		 join #first_entries_in_yr entries on entries.id_prsn_child=eps.id_prsn_child and eps.removal_dt=frst_removal_dt_in_year
		  join ref_last_dw_transfer dw on dw.cutoff_date=dw.cutoff_date
		  where entries.state_fiscal_year=',char(39),@state_fiscal_year,char(39),'  
		  order by  ');
		  set @mysql=concat(@mysql,'[',@parameter_column_name,'] ,dur_days asc');
		--  print @mysql
		  execute(@mysql);

		  insert into @surv_data
		  select * from #temp;

			insert into @results
			select distinct  @state_fiscal_year,@parameter_column_name,*
			from survfit(@surv_data,1) sf order by filtercode,dur_days;

			delete from @surv_data ;
			truncate table #temp;

			set @state_fiscal_year=dateadd(yy,1,@state_fiscal_year)
			set @mysql=''
	end

if object_id(N'prtl.p_lop_1 ',N'U') is not null truncate table prtl.p_lop_1 
insert into prtl.p_lop_1
select  state_fiscal_year,filtername ,filtercode,dur_days,num,n_i,q_i,s_i,1.0000 - s_i  as [1-s]  
from @results 
--where filtercode <> -99
 order by state_fiscal_year,filtercode;


 delete from  prtl.p_lop_1 where dur_days <> 365 or  filtercode = -99
 --select iif(filtercode=0,filtercode,1),state_fiscal_year,dur_days,sum(n_i) n_i
 -- from  prtl.p_lop_1  where dur_days=365 
 --  group  by iif(filtercode=0,filtercode,1),state_fiscal_year,dur_days
 -- order by state_fiscal_year, iif(filtercode=0,filtercode,1),dur_days

 -- select * from prtl.p_los_3  where dur_days=365  
 ------ and filtercode <> -99
 -- order by state_fiscal_year,filtercode
  
declare @endtime datetime=getdate();  

  update [CA_ODS].[prtl].[prtl_tables_last_update]
set last_build_date=getdate(),
	row_count=(select count(*) from prtl.p_lop_1),load_time_mins=dbo.fnc_datediff_mis(@starttime,@endtime)
	where [tbl_id]=52;

 
