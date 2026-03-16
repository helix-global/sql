create function [dbo].[PR_DEVICE_INVALUE_FLOAT2](@DeviceID int, @ParamID int)
returns float as 
begin
/* версия 2 ищет значение в PR_OPERATION_PARAMS в случае отсутствия значения в PR_DEVICE_IN_VALUES
   !НО без ревизий (ref.value), опций, ext.params и т.п. что дает некоторое ускорение по сравнению со стандартной
   dbo.PR_DEVICE_PARAM 
 */

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
    
  declare @valstr varchar(200)
  set @valstr = CAST(@val as varchar(200))
  set @valstr = REPLACE(@valstr,',','.')
  
  return cast(@valstr as float);
  
end