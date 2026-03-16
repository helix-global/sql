CREATE function [dbo].[PR_DEVICE_COMP_MODEL_TXT](@DeviceID int, @BomID int, @aMode int)
returns nvarchar(max) as 
begin

  declare @res nvarchar(max)
  set @res = ''
   
  select @res = case @aMode 
                when 1 then B.NAME 
                when 2 then CODE 
                when 3 then DESCSTR
                when 4 then DESCRIPTION
                end
  from PR_DEVICE_BOM A with (nolock)
  left join PR_MODELS B on B.ID = A.MODELID
  where A.DEVICEID = @DeviceID
    and A.BOMID = @BomID
  
  return @res  

end