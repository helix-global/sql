CREATE function [dbo].[PR_DEVICE_BOMITEM_GR_STR](@DeviceID int, @BomMTID int, @aMode int)
returns nvarchar(max) as 
begin

  declare @res nvarchar(max)
  set @res = ''
  
  select @res = @res + 
    case @aMode 
    when 1 then T.NAME + ' sn '  
    when 2 then M.NAME + ' sn '  
    else '' 
    end + B.SN + CHAR(13) + CHAR(10)
  from PR_DEVICE_BOM A with (nolock)
  left join PR_DEVICE B with (nolock) on B.ID = A.PARTID
  left join PR_MODELS M with (nolock) on M.ID = B.MODELID
  left join PR_MODELTYPE_BOM T with (nolock) on T.ID = A.BOMID
  where A.DEVICEID = @DeviceID
    and A.UNINSTALLOPERID is null
    and M.TYPEID = @BomMTID
  order by T.NAME, A.SN
  
  return @res  

end