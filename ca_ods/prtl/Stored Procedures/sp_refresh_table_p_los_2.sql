CREATE procedure [prtl].[sp_refresh_table_p_los_2] 
as
set nocount on
declare @surv_data surv_table;
declare @filtercode int;
declare @state_fiscal_year datetime;
declare @max_state_fiscal_year datetime;
declare @results table (state_fiscal_year datetime,filtername varchar(255),filtercode int,dur_days int,fl_close int ,num int,n_i float,q_i int,s_i  float)
declare @parameter_column_name varchar(255);
declare @mysql varchar(8000);
declare @starttime datetime=getdate();
set @parameter_column_name='county_cd'


set @state_fiscal_year=(select min(state_fiscal_year) from calendar_dim where state_fiscal_year > '2000-01-01');
set @max_state_fiscal_year=(select max(state_fiscal_year) from calendar_dim  join ref_last_dw_transfer dw on dw.cutoff_date=dw.cutoff_date
 where  dateadd(yy,1,(state_fiscal_year)) < cutoff_date );

--Get the entry cohorts; exclude episodes less than 8 days (bin_los_cd=0) -- kids who are legally free in state_fiscal year
if object_id('tempDB..#legfree') is not null drop table #legfree;
select  distinct 
		  cd.state_fiscal_year
		, eps.id_prsn_child
		, legally_free_date
		, legfree.id_removal_episode_fact
		, eps.removal_dt
		, eps.federal_discharge_date
		, eps.Removal_County_Cd
		, legfree.cd_jurisdiction
		, legfree.tx_jurisdiction
		, ROW_NUMBER() over (partition by legfree.id_prsn_child,legfree.legally_free_date order by eps.removal_dt desc) row_num
into #legfree
from   prtl.ooh_dcfs_eps eps 
join vw_legally_free legfree on 
	 legfree.id_removal_episode_fact=eps.id_removal_episode_fact
join CALENDAR_DIM cd on cd.CALENDAR_DATE=legfree.legally_free_date
where   max_bin_los_cd > 0   
and cd.state_fiscal_year >=@state_fiscal_year;


delete from #legfree where row_num > 1

-- first NO FILTERS
while @state_fiscal_year <=@max_state_fiscal_year
begin
		
		insert into @surv_data(id_prsn_child,dur_days,fl_close,filtercode)
		select eps.id_prsn_child
					,iif( eps.federal_discharge_date < getdate() 
							-- true
							,datediff(dd,entries.legally_free_date,eps.federal_discharge_date) 
							-- false
							,datediff(dd,entries.legally_free_date	,cutoff_date))   + 1   [dur_days]
					,iif(eps.federal_discharge_date < getdate() and cd_discharge_type in (1),1,0)[fl_close]
					,0
		 from   prtl.ooh_dcfs_eps eps  
		 join #legfree entries on entries.id_removal_episode_fact=eps.id_removal_episode_fact
		  join ref_last_dw_transfer dw on dw.cutoff_date=dw.cutoff_date
		  where  entries.state_fiscal_year = @state_fiscal_year  and eps.max_bin_los_cd > 0
		  and iif( eps.federal_discharge_date < getdate() 
							,datediff(dd,entries.legally_free_date,eps.federal_discharge_date)  
							,datediff(dd,entries.legally_free_date
								,cutoff_date))  + 1   > 0
		  order by dur_days desc


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
			,iif( eps.federal_discharge_date < getdate() 
					,datediff(dd,entries.legally_free_date,eps.federal_discharge_date)  
					,datediff(dd,entries.legally_free_date,(select cutoff_date from ref_last_dw_transfer)))  + 1 [dur_days]
			,iif(eps.federal_discharge_date < getdate() and eps.cd_discharge_type in (1),1,0) [fl_close],cnty. '
			set @mysql=CONCAT(@mysql, @parameter_column_name)
			set @mysql=CONCAT(@mysql,'
		 from   prtl.ooh_dcfs_eps eps  
			join #legfree entries on entries.id_removal_episode_fact=eps.id_removal_episode_fact
			join vw_desc_cd_jurisdiction cnty on cnty.cd_jurisdiction=entries.cd_jurisdiction
			join ref_last_dw_transfer dw on dw.cutoff_date=dw.cutoff_date
		  where  entries.state_fiscal_year = ')
		  set @mysql=CONCAT(@mysql,char(39),convert(varchar(10),@state_fiscal_year,121),char(39),'  and eps.max_bin_los_cd > 0
		  and iif( eps.federal_discharge_date < getdate() ,datediff(dd,entries.legally_free_date,eps.federal_discharge_date)
							,datediff(dd,entries.legally_free_date
								,cutoff_date))    + 1   > 0
			order by  ');
		  set @mysql=concat(@mysql,'[',@parameter_column_name,'] ,dur_days asc');

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

if object_id(N'prtl.p_los_2 ',N'U') is not null truncate table prtl.p_los_2 
insert  into prtl.p_los_2 
select  state_fiscal_year,filtername ,filtercode,dur_days,num,n_i,q_i,s_i,1.0000 - s_i  as [1-s] from @results 
--  where filtercode<>-99
 order by state_fiscal_year,filtercode;

  delete from  prtl.p_los_2 where dur_days <> 365 or  filtercode = -99
-- select iif(filtercode<>0,1,0) filtercode,sum(n_i)  from prtl.p_los_2  where dur_days=365
-- and year(state_fiscal_year)=2010
-- group by  iif(filtercode<>0,1,0)
--  order by filtercode asc;


--select * from  prtl.p_los_2  where dur_days=365 and filtercode <> -99 order by state_fiscal_year,filtercode,dur_days;


declare @endtime datetime;
set @endtime=getdate();


   update [prtl].[prtl_tables_last_update]
set last_build_date=getdate(),
	row_count=(select count(*) from prtl.p_los_2),load_time_mins=dbo.fnc_datediff_mis(@starttime,@endtime)
	where [tbl_id]=54;



 

 






			





 

 


