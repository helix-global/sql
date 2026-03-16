
-- =============================================
-- Author:      Dmitrii Maistrenko
-- Create date: 2025-03-18
-- Description: Serialize [SqlTableTypeSimpleColumn] into xml.
-- =============================================
-- KB5302:2025-03-18: Initial Update.
create function [dbo].[Serialize_SqlTableTypeSimpleColumn](@ObjectID int,@ColumnID int)
returns xml
as
begin
  declare @Out xml
  set @Out =
    (select
       'SqlTableTypeSimpleColumn' [@Type]
      ,'['+SCHEMA_NAME([b].[schema_id])+'].[' + [b].[name]+'].[' + [a].[name]+']' [@Name]
      ,case when [a].[is_nullable]=1 then
        (select
           'IsNullable' [@Name]
          ,'True'       [@Value]
         for xml path('Property'),type) else null end
      ,(select
           'TypeSpecifier' [@Name]
          ,(select
              [dbo].[Serialize_SqlTypeSpecifier]([a].[object_id],[a].[column_id])
            for xml path('Entry'),type)
        for xml path('Relationship'),type)
    from sys.columns [a] with(nolock)
      inner join sys.table_types [b] with(nolock) on [b].[type_table_object_id]=[a].[object_id]
    where [a].[object_id]=@ObjectID
      and [a].[column_id]=@ColumnID
    for xml path('Element'),type)
  return @Out
end