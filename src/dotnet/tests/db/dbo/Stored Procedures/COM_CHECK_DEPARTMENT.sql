create procedure [dbo].[COM_CHECK_DEPARTMENT] @aDepID int, @aMode int, @aUserID int 
as 
set nocount on

declare @now datetime
set @now = getdate()

if dbo.COM_DEP_ACCESS(null,@aDepID,@aMode,@aUserID,@now) <> 1
  raiserror('Cannot write changes to this deparment.[L=com_cannot_write_ch_dep',15,0);


set nocount off