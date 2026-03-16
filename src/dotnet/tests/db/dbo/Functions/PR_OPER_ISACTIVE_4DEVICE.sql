CREATE function [dbo].[PR_OPER_ISACTIVE_4DEVICE](@DeviceID int,@OperID int,@Condition int,@Mode int)
returns int as 
begin
  /*KB3686*/ 
  if isnull(@Condition,0) = 1
  begin
    declare @ParamID int
    declare @Action int
    declare @ParamKind int
    declare @ParamValue sql_variant

    select top 1
       @ParamID = [A].[C_PARAMID]
      ,@Action = [A].[C_ACT]
      ,@ParamKind = [B].[PARAMKIND]
      ,@ParamValue = [dbo].[PR_DEVICE_PARAM](@DeviceID,[A].[C_PARAMID])
    from [dbo].[PR_MAP_OPER] [A] with(nolock)
      inner join [dbo].[PR_MODELTYPE_PARAMS] [B] with(nolock) on [B].[ID]=[A].[C_PARAMID]
    where [A].[ID] = @OperID

    if @ParamKind = 2 /*ref.val*/ and @ParamID is not null 
    begin 
      if @Action = 2 /*P1 = True*/ and isnull([dbo].[DEF_VARIANT2BOOL](@ParamValue),0) <> 1
        return 0    
      if @Action = 3 /*P1 != True*/ and isnull([dbo].[DEF_VARIANT2BOOL](@ParamValue),0) = 1
        return 0
    end
  end

  /*KB1011*/
  /*в расчетах PR_STAGE_INFO фильтрует операции в карте, по которым изделие заведомо не пройдет*/

  if isnull(@Condition,0) in (0,1,7)
  begin
    return 1
  end
  return [dbo].[PR_FLOW_OR_OPER_ALLOWED](null,@OperID,@DeviceID)
end