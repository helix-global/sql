-- =============================================
-- Author:      Dmitrii Maistrenko
-- Create date: 2024-01-29
-- Description: Returns "numbered" parameter value for specified model and revision.
-- =============================================
-- KB4081:2024-01-29: Initial update.
create function [dbo].[PR_PARAM_IN_RELIST_STR1](@ModelTypeId int, @RevisonId int, @ParamN int)
returns nvarchar(200) as
begin
  declare @ParamId int
  declare @ParamDataType int

  select top 1
     @ParamId = [a].[ID]
    ,@ParamDataType = [a].[DATATYPE]
  from [dbo].[PR_MODELTYPE_PARAMS] [a] with(nolock) 
  where [a].[TYPEID] = @ModelTypeId
    and [a].[USEINRELIST] = @ParamN

  if @ParamId is not null
  begin
    declare @ParamValue sql_variant
    select top 1
      @ParamValue = [a].[PVALUE]
    from [dbo].[PR_REV_PARAMS] [a] with(nolock)
    where [a].[REVISIONID]=@RevisonId
      and [a].[PARAMID] = @ParamId
    order by [a].[ID] desc

    if @ParamDataType = 9 /*date*/
    begin
      if (@ParamValue is not null)
      begin
        return convert(varchar,cast([dbo].[COM_CONVERT_TO_DT](@ParamValue) as date),104)
      end
    end else
    if @ParamDataType = 2 /*datetime*/
    begin
      if (@ParamValue is not null)
      begin
        return format([dbo].[COM_CONVERT_TO_DT](@ParamValue),'dd.MM.yyyy HH:mm:ss')
      end
    end else
      return cast (@ParamValue as nvarchar(200))
  end
  return null
end