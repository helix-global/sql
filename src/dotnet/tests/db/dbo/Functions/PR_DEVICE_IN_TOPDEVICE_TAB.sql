CREATE function [dbo].[PR_DEVICE_IN_TOPDEVICE_TAB](@aDeviceID int)
returns @res table (ID int)
as
begin
  
  insert into @res (ID)
  select B.DEVICEID
  from PR_OPERATION_INSTALL A with (nolock) 
  left join PR_OPERATION B with (nolock) on B.ID = A.OPERID
  where A.PARTID = @aDeviceID
    and dbo.PR_UNINSTALL_ID(A.ID) is null
    and (B.S_S IN (1000013, 1000019, 1000038, 1000116))

  insert into @res (ID)
  select B.ID
  from @res A
  outer apply dbo.PR_DEVICE_IN_TOPDEVICE_TAB(A.ID) B
  
  delete from @res
  where exists (select B.ID from PR_OPERATION_INSTALL B where B.PARTID = "@res".ID)
   
  delete from @res where ID is null 
   
  return 
end;