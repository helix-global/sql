CREATE function [dbo].[PR_DEVICES_OPERATIONS](@aDevIDs nvarchar(max))
returns @res table (ID int)
as
begin
  
  declare @dev table (ID int)
  
  insert into @dev (ID)
  select ID from dbo.COM_STR2TABLE_INT(@aDevIDs) 
  
  insert into @res (ID)
  select A.ID
  from PR_OPERATION A with (nolock) 
  where A.DEVICEID in (select B.ID from @dev B)

  insert into @res (ID)
  select A.OPERID
  from PR_PARENT_OPERATION A with (nolock) 
  where A.DEVICEID in (select B.ID from @dev B)

   
  return 
end;