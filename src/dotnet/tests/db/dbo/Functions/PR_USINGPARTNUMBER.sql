CREATE function [dbo].PR_USINGPARTNUMBER(@aDeviceID int,@aOrderID int,@aPN nvarchar(50),@aMode int)
returns @res table (OPERID int) as 
begin

  insert into @res (OPERID)
  select distinct C.ID
  from PR_OPERATION_INSTALL A with (nolock)
  left join PR_OPERATION C with (nolock) on C.ID = A.OPERID
  left join PR_DEVICE B with (nolock) on B.ID = A.PARTID
  left join PR_MODELS M with (nolock) on M.ID = B.MODELID
  where C.DEVICEID = @aDeviceID
    and C.ORDERID = @aOrderID
    and C.COMPLETED_DT is not null
    and M.CODE = @aPN

  insert into @res (OPERID)
  select C.ID
  from PR_OPERATION_MU A with (nolock)
  left join PR_OPERATION C with (nolock) on C.ID = A.OPERID
  where C.DEVICEID = @aDeviceID
    and C.ORDERID = @aOrderID
    and C.COMPLETED_DT is not null
    and A.CODE = @aPN
    and not exists (select GG.OPERID from @res GG where GG.OPERID = C.ID)

  
  return

end