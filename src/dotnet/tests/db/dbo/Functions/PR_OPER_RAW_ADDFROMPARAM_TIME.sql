create function [dbo].[PR_OPER_RAW_ADDFROMPARAM_TIME](@OperID int, @ParamID int)
returns decimal as 
begin
  /* не учитывает состояние операции @OperID  
     eсли значение берется с одной из предыдущих операций, то состояние учитывается
  */

  declare @res sql_variant;

  select top 1 @res = A.PVALUE 
  from PR_OPERATION_PARAMS A with (nolock)
  where A.OPERID = @OperID
	and A.PARAMID = @ParamID

  if @res is not null 
  begin 
	return cast(@res as decimal)
  end	

  declare @DeviceID int
  select @DeviceID = B.DEVICEID from PR_OPERATION B with (nolock) where B.ID = @OperID
  
  select top 1 @res = A.PVALUE 
  from PR_OPERATION_PARAMS A with (nolock)
  left join PR_OPERATION B with (nolock) on B.ID = A.OPERID
  where B.DEVICEID = @DeviceID
	and A.PARAMID = @ParamID
	and B.S_S in (1000013,1000019,1000116)
	and B.ID < @OperID
  order by B.ID desc

  if @res is not null 
  begin 
	return cast(@res as decimal)
  end	
 
  return null 

end