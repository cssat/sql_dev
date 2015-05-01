


CREATE function [dbo].[compute_ci](@risk_data risk_table readonly,@event_of_interest_cd int, @event_of_interest char(100),@usegroup int) returns @ci_result table (
 param_id bigint
	 , outcome_cd int
	,outcome char(100)
	,dur_days int
	,fl_risk int
	,fl_competingrisk int
	,fl_rightcensor int
	,num int -- num of values at specific time
	,n_j int -- children awaiting exit
	,e_j int -- children exiting for specific outcome
	,r_j int -- children exiting for competing outcome
	,c_j int -- children exiting (right censored)
	,q1_j float -- rate of risksurvivors (qi=(ni-di)/ni)
	,q2_j float -- rate of risksurvivors (qi=(ni-di)/ni)
	,s1_j float-- risksurvival rate specific outcome (q1 * q2 * ... * qi)
	,s2_j float-- risksurvival rate competing risks (q1 * q2 * ... * qi)
	,ci_j float -- probability of failure
	)
begin



declare @survlocal risk_table

	
	declare @N float -- initial number of kids at risk
	declare @S1 float -- survival rate of kids who fail from event of interest 
	declare @S2 float -- survival rate of kids who fail from competing risk
	declare @e_j int -- number of kids who fail from event of interest at time j
	declare @r_j int -- number of kids who fail from competing risk at time j
	declare @c_j int -- number of kids who are censored at time j
	declare @n_j int -- number of kids who are known to be at risk beyond time j
	declare @q1_j float -- rate of survivors from event of interest
	declare @q2_j float -- rate of survivors from competing risk
	declare @mintime float
	declare @timepoint int
	declare @fl_risk int
	declare @fl_competingrisk int
	declare @fl_rightcensor int
	declare @num int
	declare @param bigint
	declare @CI_j float


	insert into @survlocal 
	select * from @risk_data

	declare @paramtable table(param_id bigint)

	

	if @usegroup=0
		begin
			insert into  @paramtable
			select 99999999999999999 
			
		end
	else
		begin 
			insert into @paramtable
			select distinct param_id from @survlocal order by param_id
		end

		
-- loop through the parameters
	while (select count(*) from @paramtable) > 0
	begin
		--select first parameter
		select top 1 @param=param_id from @paramtable
		
		-- get the count and min time period
		select    @N = count(id_prsn_child) 
				, @mintime = min(dur_days)
		from @survlocal
		where param_id=@param

		set @S1=1
		set @S2=1
		set @CI_j = 0
		declare @timepoints table (timepoint int)

		insert into @timepoints
			select distinct dur_days from @survlocal
			where param_id=@param
			order by dur_days asc

	    insert into @ci_result(param_id,outcome_cd,outcome,dur_days,num,fl_risk,fl_competingrisk,fl_rightcensor)
		select 
			s.param_id
			, @event_of_interest_cd
			, @event_of_interest
			, s.dur_days
			,count(s.id_prsn_child) 
			,sum(s.fl_risk) as fl_risk
			,sum(s.fl_competingrisk) as fl_competingrisk
			,sum(s.fl_rightcensor) as fl_rightcensor
		from @survlocal s 
		where s.param_id=@param
		group by s.param_id,s.dur_days
		
		-- loop through dur_days
		while (select count(*) from @timepoints) > 0
			begin

				select top 1 @timepoint = timepoint from @timepoints order by timepoint

				select @num=r.num,@fl_risk=r.fl_risk
						, @fl_competingrisk=r.fl_competingrisk
						, @fl_rightcensor=r.fl_rightcensor
				from @ci_result r 
				where r.param_id=@param and r.dur_days=@timepoint

				set @e_j=@fl_risk
				set @r_j=@fl_competingrisk
				set @c_j=@fl_rightcensor

				set @q1_j = (@N - (@e_j * 1.00)) / @N
				set @S1=@S1 * @q1_j

				set @q2_j = (@N - (@r_j * 1.00)) / @N
				set @S2=@S2 * @q2_j
				
				set @CI_j=@CI_j + ((@e_j * 1.00)/@N)*(@S1 * @S2)


				set @n_j = @N- ( @e_j + @r_j + @c_j)

				update @ci_result
				set  n_j=@N
					,num=@num
					,q1_j=@q1_j
					,q2_j=@q2_j
					,s1_j=@s1
					,s2_j=@s2
					,c_j = @c_j
					,r_j=@r_j
					,e_j=@e_j
					,ci_j=@CI_j
				where param_id=@param and dur_days=@timepoint


				set @N = @n_j
				delete from @timepoints where timepoint=@timepoint


			end
			delete from @survlocal where param_id=@param
			delete from @paramtable where param_id=@param
		end
 return
 end