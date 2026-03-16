-- =============================================
-- Author:      Dmitrii Maistrenko
-- Create date: 2024-12-03
-- Description: Updates metadata object related structured info.
-- =============================================
-- KB5247:2024-02-06: Updated assembly package generation.
CREATE procedure [dbo].[DEF_UPDATE_META_OBJECT_INFO](@MetaObjID int)
as
begin
  set nocount on;
  update [u] set
    [u].[OBJTYPE]=1,
    [u].[OBJINFO]=cast((
      select
       [a].[name]                [@Name]
      ,[a].[permission_set_desc] [@PermissionSet]
      ,[a].[clr_name]            [@FullyQualifiedName]
      ,case when [a].[is_visible]=1 then 'True' else 'False' end [@IsVisible]
      ,(select
           [o].[type] [@Type]
          ,schema_name([o].[schema_id]) [@Schema]
          ,[o].[name] [@Name]
          ,[m].[assembly_class] [@AssemblyClass]
          ,[o].[object_id]      [@ObjectID]
          ,(select
               case when [p].[is_output]=1 then 'True' else 'False' end [@IsOutput]
              ,case when [p].[is_output]=1 then null else [p].[name] end [@Name]
              ,[b].[name]       [@DataType]
              ,[p].[precision]  [@Precision]
              ,[p].[scale]      [@Scale]
              ,[p].[max_length] [@MaxLength]
              ,[p].[parameter_id] [@ParameterID]
              ,case when [p].[is_nullable]=1 then 'True' else 'False' end [@IsNullable]
              ,case when [p].[is_readonly]=1 then 'True' else 'False' end [@IsReadOnly]
            from sys.parameters [p] with(nolock)
              inner join sys.types [b] with(nolock) on [b].[user_type_id]=[p].[user_type_id]
            where [p].[object_id]=[o].[object_id]
            order by [p].[is_output],[p].[parameter_id]
            for xml path('Parameter'),type
            ) [Parameters]
          ,(select
               [c].[name]        [@Name]
              ,[b].[name]        [@DataType]
              ,[c].[precision]   [@Precision]
              ,[c].[scale]       [@Scale]
              ,[c].[max_length]  [@MaxLength]
              ,case when [c].[is_nullable]=1 then 'True' else 'False' end [@IsNullable]
              ,case when [c].[is_identity]=1 then 'True' else 'False' end [@IsIdentity]
              ,[c].[column_id]   [@ColumnID]
            from sys.columns [c]
              inner join sys.types [b] with(nolock) on [b].[user_type_id]=[c].[user_type_id]
            where [c].[object_id]=[o].[object_id]
            order by [c].[column_id]
            for xml path('Column'),type
            ) [Columns]
        from sys.objects [o] with(nolock)
          inner join sys.assembly_modules [m] with(nolock) on [m].[assembly_id]=[a].[assembly_id]
        where [o].[object_id]=[m].[object_id]
        for xml path('Object'),type
        ) [Objects]
        ,(select
            [b].[name]                [@Name]
           ,[b].[file_id]             [@FileID]
           ,cast(N'' as xml).value('xs:base64Binary(xs:hexBinary(sql:column("content")))','varchar(max)') [Content]
          from sys.assembly_files [b] with(nolock) where [b].[assembly_id]=[a].[assembly_id]
          for xml path('AssemblyFile'),type) [AssemblyFiles]
      from sys.assemblies [a] with(nolock)
      where [a].[name]=[u].[NAME]
      for xml path(N'Assembly'),elements) as nvarchar(max))
  from [dbo].[DEF_META] [u]
  where [u].[ID]=@MetaObjID
    and [u].[MTYPE]=200
end