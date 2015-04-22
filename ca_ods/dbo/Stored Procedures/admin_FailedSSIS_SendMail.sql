CREATE PROCEDURE [dbo].[admin_FailedSSIS_SendMail]
          @ToEmail varchar(1000) = '',
          @CCEmail varchar(1000) = '',
          @minute int = null 
AS
SET NOCOUNT ON 

insert into ssis_proc_email
select @ToEmail,@CCEmail,@minute;

declare @id int
	, @event varchar(256)
	, @computer varchar(256)
	, @operator varchar(256)
	, @source varchar(256)
	, @sourceid uniqueidentifier
	, @executionid uniqueidentifier
	, @starttime datetime
	, @endtime datetime
	, @message varchar(1024)
	, @errormsg varchar(4000)
	
declare @email1 varchar(1000);
declare @email2 varchar(1000);

--set @email1= rtrim(ltrim(@ToEmail)) + ';'
--set @email2 = rtrim(ltrim(@CCEmail)) + ';'
 
declare @startid int
		, @cur_package varchar(256)
		, @endid int
		, @pre_id int
		, @start_time datetime
		, @end_time datetime
		, @cmd varchar(8000)
		
declare @subject1 varchar(256)

declare c4 cursor for 
select  id 
		, [event] 
		, computer 
		, operator 
		, [source]
		, [sourceid]
		, [executionid]
		, starttime 
		, endtime 
		, [message]
from sysssislog 
where executionid 
in (select executionid from sysssislog where event = 'OnError' )
and starttime > dateadd(mi, -@minute, getdate()) order by executionid, id 
 
open c4

 
set @errormsg = ''
set @cmd = ''
fetch next from c4 
into @id 
	, @event 
	, @computer 
	, @operator 
	, @source 
	, @sourceid 
	, @executionid 
	, @starttime 
	, @endtime 
	, @message 

while @@fetch_status = 0
begin
       
      if @message like 'End of package execution.%'
      begin 
               set @endid = @id
               set @end_time = @endtime
               
               SELECT @startid = id from sysssislog where executionid = @executionid and 
					event = 'PackageStart' and message like 'Beginning of package execution.%'
               SELECT @start_time = starttime from sysssislog where executionid = @executionid and 
					event = 'PackageStart' and message like 'Beginning of package execution.%'
               select @errormsg = @errormsg + message from sysssislog where id between @startid and 
					@endid and executionid = @executionid
               
               set @subject1 = 'SSIS Package ' + @source + ' Failed on ' + @@SERVERNAME
               
               select @cmd = @cmd + 'SQL Instance: ' + @@SERVERNAME + char(10)
               select @cmd = @cmd + 'Package Name: ' + @source + char(10)
               select @cmd = @cmd + 'Job Originating Host: ' + @computer + char(10)
               select @cmd = @cmd + 'Run As: ' + @operator + char(10)
               select @cmd = @cmd + 'Start DT: ' + convert(varchar(30),@start_time,121) + char(10)
               select @cmd = @cmd + 'End DT: ' + convert(varchar(30),@end_time,121) + char(10)
               select @cmd = @cmd + 'Error Message: '+ char(10) + @errormsg 
               
                         exec  msdb.dbo.sp_send_dbmail 
						 'pocdata',
                         @recipients= @ToEmail,
                         @copy_recipients = @CCEmail,
                         @subject =  @subject1, 
                         @body_format ='TEXT',
                         @body = @cmd
	               
		  set @errormsg = ''             
		  set @cmd = ''
      end
	set @pre_id = @id
	fetch next from c4 
	into @id 
		, @event 
		, @computer 
		, @operator 
		, @source 
		, @sourceid 
		, @executionid 
		, @starttime 
		, @endtime 
		, @message 
	end
 
close c4
deallocate c4
