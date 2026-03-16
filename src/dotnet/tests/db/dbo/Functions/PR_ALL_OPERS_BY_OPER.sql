create function [dbo].[PR_ALL_OPERS_BY_OPER] (@OperID int)
returns @res table (ID int)
as 
begin

  declare @DeviceID int
  select @DeviceID = A.DEVICEID from PR_OPERATION A with (nolock) where A.ID = @OperID 
  
  insert into @res(ID)
  select A.ID from PR_OPERATION A with (nolock) where A.DEVICEID = @DeviceID

  return 
end