create function [dbo].[PR_DEVICE_BOMITEM_IN_LIST_XX](@DeviceID int, @BomID int, @aMode int)
returns nvarchar(max) as 
begin
  declare @dID int
  set @dID = dbo.PR_DEVICE_BOMITEM(@DeviceID,@BomID)
  if @dID is null
    return null
    
  declare @resSN nvarchar(max)
  
  if @aMode = 1
    select @resSN = A.SN from PR_DEVICE A with (nolock) where A.ID = @dID
  else if @aMode = 2
    select @resSN = B.NAME 
      from PR_DEVICE A with (nolock)
      left join PR_MODELS B with (nolock) on B.ID = A.MODELID 
     where A.ID = @dID
  else if @aMode = 3
    select @resSN = B.CODE
      from PR_DEVICE A with (nolock)
      left join PR_MODELS B with (nolock) on B.ID = A.MODELID 
     where A.ID = @dID

  return @resSN
end