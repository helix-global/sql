
-- =============================================
-- Author:      Dmitrii Maistrenko
-- Create date: 2025-03-18
-- Description: Serialize [SqlTableType] into xml.
-- =============================================
-- KB5302:2025-03-18: Initial Update.
create function [dbo].[Serialize_SqlTableType](@ObjectID int)
returns xml
as
begin
  declare @Out xml
  set @Out =
    (select
       'SqlTableType' [@Type]
      ,'['+SCHEMA_NAME([a].[schema_id])+'].[' + [a].[name]+']' [@Name]
      ,(select
           'Columns' [@Name]
          ,(select
              [dbo].[Serialize_SqlTableTypeColumn]([c].[object_id],[c].[column_id])
            from sys.columns [c] with(nolock)
            where [c].[object_id]=[b].[object_id]
            for xml path('Entry'),type)
        for xml path('Relationship'),type)
      ,(select
           'Constraints' [@Name]
          ,(select
              [dbo].[Serialize_SqlTableTypePrimaryKeyConstraint]([c].[object_id])
            from sys.key_constraints [c] with(nolock)
            where [c].[parent_object_id]=[b].[object_id]
            for xml path('Entry'),type)
        for xml path('Relationship'),type)
      ,(select
           'Indexes' [@Name]
          ,(select
              [dbo].[Serialize_SqlTableTypeIndex]([c].[object_id],[c].[index_id])
            from sys.indexes [c] with(nolock)
              left join sys.key_constraints [d] with(nolock) on [d].[parent_object_id]=[c].[object_id] and [d].[unique_index_id]=[c].[index_id]
            where [c].[object_id]=[b].[object_id]
              and [d].[object_id] is null
            for xml path('Entry'),type)
        for xml path('Relationship'),type)
      ,(select
          'Schema' [@Name]
          ,'BuiltIns' [Entry/References/@ExternalSource]
          ,'['+SCHEMA_NAME([a].[schema_id])+']' [Entry/References/@Name]
        for xml path('Relationship'),type,elements)
    from sys.table_types [a] with(nolock)
      inner join sys.objects [b] with(nolock) on [b].[object_id]=[a].[type_table_object_id]
    where [b].[object_id]=@ObjectID
    for xml path('Element'),type)
  return @Out
end