CREATE function [dbo].[PR_OPERATION_LAST_WORKTIME_EMPLOYEE] (@OperationID int)
returns int
as 
begin

  DECLARE @res int

  set @res = (select top 1 T.EMPID from PR_OPERATION_TIME T with (nolock) where T.OPERID = @OperationID	order By ID DESC)

  return @res

end