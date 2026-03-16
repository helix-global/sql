CREATE function [dbo].[PR_OPERATION_STAT_DEC](@OperID int, @aMode int, @now datetime)
returns decimal(12,2)
as
begin
  return dbo.PR_OPERATION_STAT_BY_USER_DEC(@OperID, @aMode, @now, null)
end;