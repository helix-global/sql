create function [dbo].[PR_DEVICE_PARAM_IN_OPLIST_STR2](@DeviceID int, @MtID int, @ParamN int)
returns nvarchar(200) as 
begin
  declare @prmID int
  declare @prmDataType int
  
  select top 1 @prmID = A.ID , @prmDataType = A.DATATYPE 
  from PR_MODELTYPE_PARAMS A with (nolock) 
  where A.TYPEID = @MtID
   and A.USEINOPLIST = @ParamN
  
  
  if @prmID is not null
  begin
    declare @vvv sql_variant
    declare @prmEx int
    
    select @vvv = A.PVALUE, @prmEx = A.PARAMID from PR_LIST_PARAMS_CACHE A with (nolock) where A.DEVICEID = @DeviceID and A.PARAMID = @prmID
    
    if (@prmEx is null)    
      set @vvv = dbo.PR_DEVICE_PARAM(@DeviceID,@prmID)
    
    if (@vvv is null)    
      return null
    
    if @prmDataType = 9 /*date*/
    begin
         declare @dd date
         declare @dds nvarchar(50)
         set @dds = cast(@vvv as nvarchar(50)) 
         set @dds = ltrim(rtrim(@dds))
         if len(@dds) = 8  /* 01.01.50 */
         begin
           set @dd = convert(date,@dds,4)
           return convert(varchar,@dd,104)
         end
         else
         begin
            set @dd = convert(date,@vvv,104)
            return convert(varchar,@dd,104)
         end
    end
    else if @prmDataType = 2 /*datetime*/
    begin
         declare @dt datetime
         set @dt = CAST(@vvv as datetime)
         return convert(varchar,@dt,104) + ' ' + convert(varchar,@dt,108)
    end
  
    return cast (@vvv as nvarchar(200))
  end
  return null
end