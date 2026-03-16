create function [dbo].[PR_DEVICE_BY_PARENT_DEVICE_TAB](@aDeviceID int,@aSkipID int)
returns @res table (ID int)
as
begin
  
  insert into @res (ID)
  select A.ID
  from PR_DEVICE A with (nolock) 
  where A.PARENTID = @aDeviceID
    and A.ID <> isnull(@aSkipID,0)

  insert into @res(ID)
  select B.ID 
  from @res A
  cross apply dbo.PR_DEVICE_BY_PARENT_DEVICE_TAB(A.ID,@aSkipID) B
  where B.ID is not null
    and B.ID <> isnull(@aSkipID,0)
   
  return 
end;