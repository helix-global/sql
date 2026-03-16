CREATE function [dbo].[RO_DEVICE_PROP_IN_LIST](@DeviceID int, @BomTree nvarchar(max), @aMode int)
returns nvarchar(200) as 
begin
  
  declare @dID int
  set @dID = dbo.RO_DEVICE_FROM_TREE(@DeviceID,@BomTree)
  
  declare @resSN nvarchar(200)
  
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
  else if @aMode = 4
    select @resSN = R.NAME
      from PR_DEVICE A with (nolock)
	  left join PR_REVISION R with(nolock) on A.REVID=R.ID
     where A.ID = @dID  
  
  return @resSN
  
  
end