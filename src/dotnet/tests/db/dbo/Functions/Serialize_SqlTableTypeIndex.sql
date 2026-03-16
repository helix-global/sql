

-- =============================================
-- Author:      Dmitrii Maistrenko
-- Create date: 2025-03-18
-- Description: Serialize [SqlTableTypeIndex] into xml.
-- =============================================
-- KB5302:2025-03-18: Initial Update.
create function [dbo].[Serialize_SqlTableTypeIndex](@ObjectID int,@IndexID int)
returns xml
as
begin
  declare @Out xml
  set @Out =
    (select
       'SqlTableTypeIndex' [@Type]
      ,case when [b].[type_desc]='CLUSTERED' then
        (select
           'IsClustered' [@Name]
          ,'True'        [@Value]
         for xml path('Property'),type) else null end
      ,(select
          'ColumnSpecifications' [@Name]
          ,(select
             (select
               'SqlTableTypeIndexedColumnSpecification' [@Type]
               ,(select
                   'IsAscending' [@Name]
                  ,case when [i].[is_descending_key]=0 then 'True' else 'False' end [@Value]
                 for xml path('Property'),type)
              ,'Column' [Relationship/@Name]
              ,'['+SCHEMA_NAME([o].[schema_id])+'].[' + [o].[name]+']' + '.['+[c].[name]+']' [Relationship/Entry/References/@Name]
              from sys.index_columns [i] with(nolock)
                inner join sys.columns [c] with(nolock) on [c].[object_id]=[i].[object_id] and [c].[column_id]=[i].[column_id]
              where [i].[object_id]=[b].[object_id]
                and [i].[index_id]=[b].[index_id]
              for xml path('Element'),type,elements)
            for xml path('Entry'),type,elements
            )
          for xml path('Relationship'),type,elements)
        ,(select
          'SqlInlineConstraintAnnotation' [@Type]
          ,'['+SCHEMA_NAME([o].[schema_id])+'].[' + [o].[name]+']' + '.['+[b].[name]+']' [@Name]
        for xml path('Annotation'),type)
    from sys.indexes [b] with(nolock)
      inner join sys.table_types [o] with(nolock) on [o].[type_table_object_id]=[b].[object_id]
    where [b].[object_id]=@ObjectID
      and [b].[index_id]=@IndexID
    for xml path('Element'),type)
  return @Out
end