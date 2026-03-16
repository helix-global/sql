create function [dbo].[PR_DEVICE_INVALUE_STR2](@DeviceID int, @ParamID int)
returns nvarchar(max) as 
begin


  declare @val sql_variant
  select TOP (1) @val = PVALUE 
  FROM PR_DEVICE_IN_VALUES WITH (nolock)
  WHERE (DEVICEID = @DeviceID) AND (PARAMID = @ParamID)
  order by ID desc

  if @val is null
  begin
  
  	  select top 1 @val = A.PVALUE 
	  from PR_OPERATION_PARAMS A with (nolock)
	  left join PR_OPERATION B with (nolock) on B.ID = A.OPERID
	  where B.DEVICEID = @DeviceID
		and A.PARAMID = @ParamID
		and B.S_S in (1000013,1000019,1000116)
	  order by B.ID desc
  
  end

  if @val is null
    return null
    
 
  return CAST(@val as varchar(max))
  
end