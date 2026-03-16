CREATE function [dbo].[PR_DEVICE_PARAM_STR_BYNAME](@DeviceID int, @ParamName nvarchar(300))
returns nvarchar(max) as 
begin

  declare @mtid int
  
  select @mtid = B.TYPEID
  from PR_DEVICE A with (nolock)
  left join PR_MODELS B with (nolock) on B.ID = A.MODELID
  where A.ID = @DeviceID

  declare @ParamID int
  select @ParamID = A.ID
  from PR_MODELTYPE_PARAMS A with (nolock)
  where A.TYPEID = @mtid
    and A.NAME = @ParamName

  declare @val sql_variant
  set @val = dbo.PR_DEVICE_PARAM(@DeviceID, @ParamID)
  if @val is null
    return null
    
  declare @dataType int
  select @dataType = A.DATATYPE from PR_MODELTYPE_PARAMS A with (nolock) where A.ID = @ParamID
  if @dataType = 9
    return convert(nvarchar,@val,104)
  else if @dataType = 2
  begin
    if SQL_VARIANT_PROPERTY(@val,'BaseType')  = 'datetime'
       return convert(nvarchar,@val,104)+' '+convert(nvarchar,@val,108)
    else
       return convert(nvarchar,@val)
  end
  
  return cast(@val as nvarchar(max))
end