CREATE function [dbo].[PR_OPER_MINUS_TIME](@aOperID int,@aUser int,@aNow datetime)
returns int as 
begin
  declare @WorkTimeID int
  declare @DepID int
  declare @EmplID int
  declare @MinusMin int
  
  select @WorkTimeID = A.PERSONALWT
        ,@DepID = A.DEPID
        ,@EmplID = A.ID
  from COM_EMPLOYEE A with (nolock)
  where A.ID = (select B.EMPLOYEEID from DEF_USERS B with (nolock) where B.ID = @aUser)
  
  if @WorkTimeID is null
    select top 1 @WorkTimeID = A.ID from COM_WORKTIME A with (nolock) where A.DEPID = @DepID and A.WTDEFAULT = 1

  if @WorkTimeID is null
    return null

  declare @DTbegin datetime
  select @DTbegin = min(A.DBEG) from PR_OPERATION_TIME A with (nolock) where A.OPERID = @aOperID and A.EMPID = @EmplID and A.DEND is null
  
  if @DTbegin is not null 
    if @DTbegin < @aNow
      set @MinusMin = dbo.COM_NOT_WORK_TIME (@WorkTimeID, @DTbegin, @aNow)
  

  return @MinusMin
end