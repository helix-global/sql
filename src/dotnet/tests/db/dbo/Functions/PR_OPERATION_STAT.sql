CREATE function [dbo].[PR_OPERATION_STAT](@OperID int, @aMode int, @now datetime)
returns int
as
begin

   declare @resD decimal(12,2)
   set @resD = dbo.PR_OPERATION_STAT_DEC(@OperID,@aMode,@now)
   set @resD = round(@resD,0)
   return @resD
   
end;