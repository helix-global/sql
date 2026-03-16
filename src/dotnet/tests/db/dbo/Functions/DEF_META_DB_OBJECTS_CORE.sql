-- =============================================
-- Author:      Dmitrii Maistrenko
-- Create date: 2024-12-03
-- Description: Resolves metadata objects.
-- =============================================
-- KB5314:2025-03-24: Added [SCHEMA] field.
-- KB5302:2025-03-18: Added "User-defined table types" block.
-- KB5132:2024-12-03: Initial Update.
CREATE function [dbo].[DEF_META_DB_OBJECTS_CORE](@Options nvarchar(max))
returns 
  @Output table (
    [OID]  nvarchar(max),
    [NAME] nvarchar(max),
    [S_CR] int,
    [S_MR] int,
    [S_CDT] datetime,
    [S_MDT] datetime,
    [MTYPE] int,
    [TABLENAME] nvarchar(max),
    [OBJID] bigint,
    [SCHEMA] nvarchar(max)
    )
as
begin
  insert into @Output
    select
       [a].[TABLE_NAME]             [OID]
      ,[a].[TABLE_NAME]             [NAME]
      ,null                         [S_CR]
      ,null                         [S_MR]
      ,cast('20010101' as datetime) [S_CDT]
      ,cast('20010101' as datetime) [S_MDT]
      ,case [a].[TABLE_TYPE] when 'VIEW' then 80 else 20 end [MTYPE]
      ,null [TABLENAME]
      ,cast(object_id([TABLE_NAME]) as bigint) * 4294967296
      ,[a].[TABLE_SCHEMA] [SCHEMA]
     from INFORMATION_SCHEMA.TABLES [a] with(nolock)
     where [a].[TABLE_TYPE] in ('VIEW','BASE TABLE')
       and [a].[TABLE_NAME] not like 'temp%'
       and [a].[TABLE_NAME] not like 'TEMP%'
       and [a].[TABLE_NAME] not like 'tmp%'
       and [a].[TABLE_NAME] not like 'sys%'
    union all /*******************************/
    select
      [a].[name]   [OID]
     ,[a].[name]   [NAME]
     ,null         [S_CR]
     ,null         [S_MR]
     ,[a].[crdate] [S_CDT]
     ,null         [S_MDT]
     ,60           [MTYPE]
     ,null         [TABLENAME]
     ,cast([a].[id] as bigint)* 4294967296
     ,SCHEMA_NAME(b.[schema_id]) [SCHEMA]
    from sys.sysobjects [a] with(nolock)
      inner join sys.objects [b] with(nolock) on [b].[object_id]=[a].[id]
    where [a].[xtype] = 'TR'
    union all /*******************************/
    select
       [a].[ROUTINE_NAME] [OID]
      ,[a].[ROUTINE_NAME] [NAME]
      ,null           [S_CR]
      ,null           [S_MR]
      ,[a].CREATED        [S_CDT]
      ,[a].LAST_ALTERED   [S_MDT]
      ,case [a].[ROUTINE_TYPE] when 'FUNCTION' then 30 when 'PROCEDURE' then 40 end [MTYPE]
      ,null [TABLENAME]
      ,cast(object_id([a].[ROUTINE_NAME]) as bigint)*4294967296
      ,[a].[ROUTINE_SCHEMA]
     from INFORMATION_SCHEMA.ROUTINES [a] with(nolock)
     where [a].[ROUTINE_NAME] not like 'sp_%' 
       and [a].[ROUTINE_NAME] not like 'fn_%' 
       and [a].[ROUTINE_TYPE] in ('FUNCTION','PROCEDURE')
       and [a].[ROUTINE_BODY] = 'SQL'
    union all /*******************************/
    select
       [a].[name] [OID]
      ,[a].[name] [NAME]
      ,null       [S_CR]
      ,null       [S_MR]
      ,cast('20010101' as datetime) [S_CDT]
      ,cast('20010101' as datetime) [S_MDT]
      ,50 [MTYPE]
      ,object_name([a].object_id) [TABLENAME]
      ,(cast([a].[object_id] as bigint)*4294967296)+[a].[index_id]
      ,schema_name([b].[schema_id])
    from sys.indexes [a] with(nolock)
      inner join sys.objects [b] with(nolock) on [b].[object_id]=[a].[object_id]
    where [a].[is_primary_key] <> 1
      and [a].[name] like 'IX_%'
      and object_name([a].object_id) not like 'temp%'
    union all /*******************************/
    select
       [a].[name] [OID]
      ,[a].[name] [NAME]
      ,null [S_CR]
      ,null [S_MR]
      ,cast('20010101' as datetime) [S_CDT]
      ,cast('20010101' as datetime) [S_MDT]
      ,70 [MTYPE]
      ,object_name([b].object_id) [TABLENAME]
      ,cast([a].[object_id] as bigint)*4294967296
      ,schema_name([b].[schema_id])
    from sys.foreign_keys [a] with(nolock)
      inner join sys.objects [b] with(nolock) on [b].[object_id]=[a].[parent_object_id]
    where [a].[name] not like 'temp%'
      and [b].[name] not like 'temp%'
      and [b].[name] not like 'TEMP%'
      and [b].[name] not like 'tmp%'
      and ('['+SCHEMA_NAME([b].[schema_id])+'].['+[b].[name] +']') not in (
        '[dbo].[sysdiagrams]')

  -- CLR Assembly Catalog Views
  insert into @Output([OID],[NAME],[S_CDT],[S_MDT],[MTYPE],[OBJID])
    select
       [a].[name] [OID]
      ,[a].[name] [NAME]
      ,[a].[create_date]
      ,[a].[modify_date]
      ,200 [MTYPE]
      ,cast([a].[assembly_id] as bigint)*4294967296
    from sys.assemblies [a] with(nolock)
    where [a].[is_user_defined]=1

  -- User-defined table types
  insert into @Output([OID],[NAME],[S_CDT],[S_MDT],[MTYPE],[OBJID],[SCHEMA])
    select
       [a].[name] [OID]
      ,[a].[name] [NAME]
      ,[b].[create_date]
      ,[b].[modify_date]
      ,210 [MTYPE]
      ,cast([a].[type_table_object_id] as bigint)*4294967296
      ,schema_name([a].[schema_id])
    from sys.table_types [a] with(nolock)
      inner join sys.objects [b] with(nolock) on [b].[object_id]=[a].[type_table_object_id]
    where [a].[is_user_defined]=1
  return
end