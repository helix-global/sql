CREATE function [dbo].[PR_OPERATION_PARAM](@OperID int, @ParamID int)
returns sql_variant as
begin
  declare @RetVal sql_variant;
  declare @PKind int;
  select
    @PKind=[mdlP].[PARAMKIND]
  from [dbo].[PR_MODELTYPE_PARAMS] [mdlP] with(nolock)
  where [mdlP].[ID]=@ParamID
  if @PKind = 1
  begin
    select top 1
      @RetVal=[oprP].[PVALUE]
    from [dbo].[PR_OPERATION_PARAMS] [oprP] with(nolock)
      inner join [dbo].[PR_OPERATION] [oper] on [oper].[ID]=[oprP].[OPERID]
    where [oper].[ID]=@OperID
      and [oprP].[PARAMID]=@ParamID
    order by [oper].[ID] desc
  end else
  if @PKind = 2
  begin
    declare @DeviceID int
    declare @RevID int
    select
       @DeviceID=[oper].[DEVICEID]
      ,@RevID=[devi].[REVID]
    from [dbo].[PR_OPERATION] [oper] with(nolock)
      inner join [dbo].[PR_DEVICE] [devi] with(nolock) on [devi].[ID]=[oper].[DEVICEID]
    where [oper].[ID]=@OperID

    select top 1
      @RetVal=[revP].[PVALUE]
    from [dbo].[PR_REV_PARAMS] [revP] with(nolock)
    where [revP].[REVISIONID]=@RevID
      and [revP].[PARAMID]=@ParamID
      and [revP].[ONLYOPTION] in (select [devO].[OPTID]
                                  from [dbo].[PR_DEVICE_OPT] [devO] with(nolock)
                                  where [devO].[DEVICEID]=@DeviceID)

    if @RetVal is null
    begin
      select top 1
        @RetVal=[revP].[PVALUE]
      from [PR_REV_PARAMS] [revP] with(nolock)
      where [revP].[REVISIONID]=@RevID
        and [revP].[PARAMID]=@ParamID
        and [revP].[ONLYOPTION] is null
    end
  end
  return @RetVal
end