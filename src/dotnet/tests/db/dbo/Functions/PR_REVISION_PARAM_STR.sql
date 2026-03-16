-- =============================================
-- Author:      Dmitrii Maistrenko
-- Create date: 2024-03-01
-- Description: Fetch specified revision parameter as "string".
-- =============================================
-- KB4638:2024-03-01: Initial update.
create function [dbo].[PR_REVISION_PARAM_STR](@RevisionID int,@ParamID int)
returns nvarchar(max) as
begin
  declare @Value sql_variant
  set @Value = [dbo].[PR_REVISION_PARAM](@RevisionID,@ParamID)
  if @Value is null return null

  declare @DataType int
  select @DataType = A.DATATYPE from PR_MODELTYPE_PARAMS A with (nolock) where A.ID = @ParamID

  if @DataType = 9 return format(cast([dbo].[COM_CONVERT_TO_DT](@Value) as date),'dd.MM.yyyy')
  if @DataType = 2 return format(cast([dbo].[COM_CONVERT_TO_DT](@Value) as datetime),'dd.MM.yyyy HH:mm:ss')

  declare @ValueBaseType sysname = cast(SQL_VARIANT_PROPERTY(@Value,'BaseType') as sysname)
  if @ValueBaseType = 'datetime' return format(cast([dbo].[COM_CONVERT_TO_DT](@Value) as datetime),'dd.MM.yyyy HH:mm:ss')
  if @ValueBaseType = 'date'     return format(cast([dbo].[COM_CONVERT_TO_DT](@Value) as date),'dd.MM.yyyy')
  if @ValueBaseType = 'time'     return format(cast([dbo].[COM_CONVERT_TO_DT](@Value) as datetime),'HH:mm:ss')
  return cast(@Value as nvarchar(max))
end