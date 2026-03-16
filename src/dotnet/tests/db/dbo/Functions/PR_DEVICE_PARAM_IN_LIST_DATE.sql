CREATE function [dbo].[PR_DEVICE_PARAM_IN_LIST_DATE](@DeviceID int, @ParamID int)
returns datetime as 
begin
  declare @val sql_variant
  declare @prmEx int
    
  select @val = A.PVALUE, @prmEx = A.PARAMID from PR_LIST_PARAMS_CACHE A with (nolock) where A.DEVICEID = @DeviceID and A.PARAMID = @ParamID
  if (@prmEx is null)    
    set @val = dbo.PR_DEVICE_PARAM(@DeviceID, @ParamID)
    
  if @val is null
    return null

   
   declare @dds nvarchar(50)
   declare @dd datetime
   set @dds = cast(@val as nvarchar(50)) 
   set @dds = ltrim(rtrim(@dds))
   if len(@dds) = 8  /* 01.01.50 */
   begin
       set @dd = convert(date,@dds,4)
       return @dd
   end


   return convert(date,@val,104)
   
   
end