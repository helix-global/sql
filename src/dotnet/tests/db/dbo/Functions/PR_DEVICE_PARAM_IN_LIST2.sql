create function [dbo].[PR_DEVICE_PARAM_IN_LIST2](@DeviceID int, @MtID int, @ParamN int)
returns sql_variant as 
begin
  declare @prmID int
  declare @prmDataType int
  
  select top 1 @prmID = A.ID, @prmDataType = A.DATATYPE
  from PR_MODELTYPE_PARAMS A with (nolock) 
  where A.TYPEID = @MtID
    and A.USEINLIST = @ParamN
  
  
  if @prmID is not null
  begin
    if @prmDataType = 9 /*date*/
    begin
      declare @dtv sql_variant
      declare @dd date
      set @dtv = dbo.PR_DEVICE_PARAM(@DeviceID,@prmID)
      if (@dtv is not null)
      begin
         --set @dd = CAST(@dtv as date)
         set @dd = convert(date,@dtv,104)
         return convert(varchar,@dd,104)
      end  
    end
    else if @prmDataType = 2 /*datetime*/
    begin
      declare @dtv2 sql_variant
      declare @dt datetime
      set @dtv2 = dbo.PR_DEVICE_PARAM(@DeviceID,@prmID)
      if (@dtv2 is not null)
      begin
         set @dt = CAST(@dtv2 as datetime)
         return convert(varchar,@dt,104) + ' ' + convert(varchar,@dt,108)
      end  
    end

    return dbo.PR_DEVICE_PARAM(@DeviceID,@prmID)
  end  
  return null
end