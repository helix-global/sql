
-- =============================================
-- Author:      Dmitrii Maistrenko
-- Create date: 2025-03-18
-- Description: Serialize [SqlTableTypeColumn] into xml.
-- =============================================
-- KB5302:2025-03-18: Initial Update.
create function [dbo].[Serialize_SqlTableTypeColumn](@ObjectID int,@ColumnID int)
returns xml
as
begin
  declare @Out xml
  declare @IsComputed int
  select top 1
    @IsComputed=[a].[is_computed]
  from sys.columns [a] with(nolock)
  where [a].[object_id]=@ObjectID
    and [a].[column_id]=@ColumnID

  if @IsComputed=1
  begin
    set @Out=[dbo].[Serialize_SqlTableTypeComputedColumn](@ObjectID,@ColumnID)
  end else
  begin
    set @Out=[dbo].[Serialize_SqlTableTypeSimpleColumn](@ObjectID,@ColumnID)
  end
  return @Out
end