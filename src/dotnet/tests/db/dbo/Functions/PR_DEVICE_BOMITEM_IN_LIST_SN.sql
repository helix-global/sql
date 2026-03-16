CREATE function [dbo].[PR_DEVICE_BOMITEM_IN_LIST_SN](@DeviceID int, @BomItemN int)
returns nvarchar(100) as 
begin
  declare @bomitemID int
  select top 1 @bomitemID = A.ID 
  from PR_MODELTYPE_BOM A with (nolock) 
  where A.MTID = (select M.TYPEID 
                    from PR_MODELS M with (nolock)  
                   where M.ID = (select D.MODELID 
                                   from PR_DEVICE D with (nolock)
                                  where D.ID = @DeviceID))
     and A.USEINLIST = @BomItemN
  
  declare @resSN nvarchar(50)
  if @bomitemID is not null
     select top 1 @resSN = A.SN from PR_DEVICE_BOM A where A.DEVICEID = @DeviceID and A.UNINSTALLOPERID is null and A.BOMID = @bomitemID

  return @resSN
end