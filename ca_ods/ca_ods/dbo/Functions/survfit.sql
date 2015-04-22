

CREATE function [dbo].[survfit] 
(    
    @survdata surv_table readonly
    ,@usegroup as bit
)

returns @result table (
	filtercode bigint
	,dur_days float
	,fl_close smallint -- Events
	,num int -- num of values at specific time
	,n_i int -- children awaiting exit
	,q_i float -- rate of survivors (qi=(ni-di)/ni)
	,s_i float-- survival rate (q1 * q2 * ... * qi)
	)
as

begin

    declare @N int
	declare @S float
	declare @n_i int
	declare @q_i float
	declare @mintime float
    declare @timepoint float
	declare @fl_close int
	declare @num int
	declare @filtercode bigint
    
    -- local input table
    declare @survlocal 
		table (id_prsn_child int
				,dur_days float
				,fl_close int
				,filtercode bigint)
				--,filtercode nvarchar (150))
	declare @grouptable 
		table (id_prsn_child int
				,dur_days float
				,fl_close int
				,filtercode bigint)
				--,filtercode nvarchar (150))
    
    -- copy data into table
    insert into @survlocal
    select s.id_prsn_child
			,s.dur_days
			,s.fl_close
			,filtercode=iif( s.filtercode IS null , -999 , s.filtercode) 
	from @survdata s
    where dur_days is not null 
        
    if (@usegroup = 0)
        begin
            insert @grouptable (filtercode) values (-999)
            update @survlocal
            set filtercode= -999
        end
    if (@usegroup = 1)
        begin
            insert @grouptable (filtercode)
            select distinct filtercode from @survlocal
        end
        
    while (select count(*) from @grouptable) > 0
    begin
				-- select first or only group
				select top 1 @filtercode= filtercode 
				from @grouptable
				-- determine N and mintime
				select @N=count(id_prsn_child)
						,@mintime=min(dur_days) 
				from @survlocal 
				where dur_days is not null 
					and filtercode=@filtercode
				-- Set S=1
				set @S=1
				-- Get List od Timepoints for iterating through values
				declare @timepoints table(timepoint float)
				insert @timepoints
					select s.dur_days 
					from @survlocal s
					where s.filtercode=@filtercode
					order by s.dur_days
        
				-- insert only valid survival data into our result set
				insert into @result (filtercode,dur_days,fl_close,num)
				select 
					s.filtercode
					,s.dur_days
					,sum(s.fl_close)
					,count(s.id_prsn_child) 
				from @survlocal s
				where s.dur_days is not null 
					and s.fl_close is not null 
					and s.filtercode=@filtercode
				group by 
					s.filtercode
					,s.dur_days
				order by 
					s.dur_days

				-- iterate through survival data
				while (select count(*) from @timepoints) >0
							begin
								select top 1 @timepoint= timepoint 
								from @timepoints 
								order by timepoint
							 -- determine nI and qi for this time point
							 select 
								@fl_close=r.fl_close
								,@num=r.num 
							 from @result r 
							 where r.filtercode=@filtercode 
								and r.dur_days=@timepoint
							 select @n_i=@N-@num
							 select @q_i=(@N-(@fl_close*1.0))/@N
            
							 -- calculate survival rate
							 select @S=@S*@q_i
             
							 -- update table
							 update @result
							 set n_i=@N,q_i=@q_i,s_i=@S
							 where filtercode=@filtercode and dur_days=@timepoint
							 -- clean-up
							 Set @N=@n_i
							 delete 
							 from @timepoints 
							 where timepoint=@timepoint
   				end

				delete 
				from @survlocal 
				where filtercode=@filtercode

				delete 
				from @grouptable 
				where filtercode =@filtercode
    end

				insert into @result(filtercode,dur_days,fl_close,num,n_i,q_i,s_i)
				select R.filtercode,n.number,r.fl_close,r.num,r.n_i,r.q_i,r.s_i
				from @result R
				join (
						select  filtercode,dur_days,LEAD(dur_days) over  (partition by filtercode order by dur_days) nxt_dur_days
						from @result) q on q.filtercode=R.filtercode and q.dur_days=r.dur_days
				join numbers n on n.number > q.dur_days and n.number < q.nxt_dur_days
				where q.nxt_dur_days is not null and q.nxt_dur_days-q.dur_days <> 1 
return 
end