CREATE TABLE [dbo].[ca_file_location] (
    [dir]         VARCHAR (500) NULL,
    [ext]         CHAR (4)      NULL,
    [insert_date] DATETIME      NULL
);


GO
CREATE trigger [dbo].[ca_file_location_update]
  on dbo.ca_file_location
  after insert
  as 
  begin
	set nocount on;
	update [dbo].[ca_file_location]
	set insert_date=getdate()
end
