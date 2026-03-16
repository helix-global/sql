CREATE function [dbo].[PR_DOPTION](@DeviceID int, @OptionN int, @Mode int)
returns nvarchar(200) as 
begin
  declare @Code nvarchar(50);
  declare @Name nvarchar(250);
   
  select top 1 @Code = B.CODE
              ,@Name = B.NAME
  from PR_DEVICE_OPT A with (nolock) 
  left join PR_MODELTYPE_OPTIONS B with (nolock) on B.ID = A.OPTID
  where A.DEVICEID = @DeviceID
    and (select COUNT(*) from PR_DEVICE_OPT N with (nolock) where N.DEVICEID = @DeviceID and N.ID < A.ID) = @OptionN - 1
   
  if @Mode = 1
    return @Code

  if @Mode = 2
    return @Name
     
  return null 
   
end