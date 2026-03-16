CREATE function [dbo].[PR_DEVICE_FINDINDEX](@PrmID int, @ParamValue nvarchar(250))
returns @res table (ID int)
begin
  if @PrmID is null
    return
    
 
  declare @index nvarchar(250) = upper(@ParamValue)

  insert into @res
  select B.DEVICEID 
  from PR_OPERATION_PARAMS A with (nolock)
  left join PR_OPERATION B with (nolock) on B.ID = A.OPERID
  where A.PARAMID = @PrmID
    and A.INDEX_STR = @index
    
  insert into @res
  select A.DEVICEID 
  from PR_OPERATION_EXT_PARAMS A with (nolock)
  where A.PARAMID = @PrmID
    and A.INDEX_STR = @index
    
  insert  into @res
  select I.DEVICEID 
  from PR_DEVICE_IN_VALUES I with (nolock)
  where I.PARAMID = @PrmID
                and I.INDEX_STR = @index
    
  return 
end