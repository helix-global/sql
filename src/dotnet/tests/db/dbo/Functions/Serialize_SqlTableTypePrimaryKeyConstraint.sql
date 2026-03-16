

-- =============================================
-- Author:      Dmitrii Maistrenko
-- Create date: 2025-03-18
-- Description: Serialize [SqlTableTypePrimaryKeyConstraint] into xml.
-- =============================================
-- KB5302:2025-03-18: Initial Update.
CREATE function [dbo].[Serialize_SqlTableTypePrimaryKeyConstraint](@ObjectID int)
returns xml
as
begin
  declare @Out xml
  set @Out =
    (select
       'SqlTableTypePrimaryKeyConstraint' [@Type]
      ,case when [b].[type_desc]='CLUSTERED' then
        (select
           'IsClustered' [@Name]
          ,'True'        [@Value]
         for xml path('Property'),type) else null end
        ,(select
            'ColumnSpecifications' [@Name]
            ,(select
              'SqlTableTypeIndexedColumnSpecification' [Element/@Type]
              ,'Column' [Element/Relationship/@Name]
              ,'['+SCHEMA_NAME([o].[schema_id])+'].[' + [o].[name]+']' + '.['+[c].[name]+']' [Element/Relationship/Entry/References/@Name]
              from sys.index_columns [i] with(nolock)
                inner join sys.columns [c] with(nolock) on [c].[object_id]=[i].[object_id] and [c].[column_id]=[i].[column_id]
              where [i].[object_id]=[b].[object_id]
                and [i].[index_id]=[b].[index_id]
              for xml path('Entry'),type,elements
              )
          for xml path('Relationship'),type,elements)
          ,(
          select
            'SqlInlineConstraintAnnotation' [@Type]
            ,'['+SCHEMA_NAME([o].[schema_id])+'].['+[b].[name]+']' [@Name]
          for xml path('Annotation'),type
          )
    from sys.key_constraints [a] with(nolock)
      inner join sys.indexes     [b] with(nolock) on [b].[object_id]=[a].[parent_object_id] and [b].[index_id]=[a].[unique_index_id]
      inner join sys.table_types [o] with(nolock) on [o].[type_table_object_id]=[b].[object_id]
    where [a].[object_id]=@ObjectID
    for xml path('Element'),type)
  return @Out
end