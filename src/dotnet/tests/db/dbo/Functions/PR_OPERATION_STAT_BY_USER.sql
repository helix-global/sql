CREATE function [dbo].[PR_OPERATION_STAT_BY_USER](@OperID int, @aMode int, @now datetime, @userId int)
returns int
as
begin

declare @resD decimal(12,2)
set @resD = dbo.PR_OPERATION_STAT_BY_USER_DEC(@OperID,@aMode,@now, @userId)
set @resD = round(@resD,0)
return @resD

end;