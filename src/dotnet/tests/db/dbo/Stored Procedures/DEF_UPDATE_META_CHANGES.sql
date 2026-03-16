
--#AZURE06028:2025-09-19: Updated existed metadata based on [dbo].[DEF_META_OBJECTS].[OBJXML] field.
--#AZURE06028:2025-09-16: Updated existed metadata based on [dbo].[DEF_META_OBJECTS] table.
--KB5132:2024-12-03: Refactoring. Added support for {Assembly}.
--KB5302:2025-03-19: Added support for {User-defined table types}. Functions with 'Serialize_' prefix will be moved into 'com_' module.
--KB5302:2025-03-21: Added "Unclassified objects" support.
--KB5314:2025-03-24: Added [SCHEMA] field processing.
CREATE PROCEDURE [dbo].[DEF_UPDATE_META_CHANGES]
  @UserID int
AS
BEGIN
  update [a] set
    [a].[S_S] = 1
  from [dbo].[DEF_META] [a]
    inner join [dbo].[DEF_META_OBJECTS] [b] on [b].[OBJID]=[a].[ID]
  where [S_S] = 2130024 /*changed*/
    and cast(isnull([a].[SQLTEXT],'{none}') as nvarchar(max)) = isnull([b].[OBJSQL],'{none}')
    and isnull(cast([a].[OBJINFO] as nvarchar(max)),'{none}') = isnull(cast([b].[OBJXML] as nvarchar(max)),'{none}')

  update [a] set
    [a].[S_S] = 2130024 /*changed*/
  from [dbo].[DEF_META] [a]
    inner join [dbo].[DEF_META_OBJECTS] [b] on [b].[OBJID]=[a].[ID]
  where [a].[S_S] = 1
    and (cast(isnull([a].[SQLTEXT],'{none}') as nvarchar(max)) <> isnull([b].[OBJSQL],'{none}')
           or isnull(cast([a].[OBJINFO] as nvarchar(max)),'{none}') <> isnull(cast([b].[OBJXML] as nvarchar(max)),'{none}'))

  update [a] set
    [a].[SQLTEXT] = [b].[OBJSQL]
  from [dbo].[DEF_META] [a]
    left join [dbo].[DEF_META_OBJECTS] [b] on [b].[OBJID]=[a].[ID]
  where [a].[S_S] = 2130025 /*found new*/
    and (cast(isnull([a].[SQLTEXT],'{none}') as nvarchar(max)) <> isnull([b].[OBJSQL],'{none}')
           or isnull(cast([a].[OBJINFO] as nvarchar(max)),'{none}') <> isnull(cast([b].[OBJXML] as nvarchar(max)),'{none}'))

  update [a] set
    [a].[S_S] = 1
  from [dbo].[DEF_META] [a]
  where [a].[S_S] = 2130026 /*not exists*/
    and exists (select [b].[OID]
                from [DEF_META_DB_OBJECTS] [b]
                where [b].[NAME]=[a].[NAME]
                  and [b].[MTYPE] = [a].[MTYPE]
                  and isnull([b].[TABLENAME],'NA') = isnull([a].[TABLENAME],'NA')
                  and isnull([b].[SCHEMA],'dbo') = isnull([a].[SCHEMA],'dbo'))

  update [a] set
    [a].[S_S] = 2130026 /*not exists*/
  from [dbo].[DEF_META] [a]
    left join [dbo].[DEF_META_OBJECTS] [b] on [b].[OBJID]=[a].[ID]
  where [a].[S_S] in (1,2130025)
    and [b].[OBJID] is null
    and [a].[MTYPE] not in (1000,10)

  update [a] set
    [a].[SCHEMA]=[b].[OBJSCHEMA]
  from [dbo].[DEF_META] [a]
    inner join [dbo].[DEF_META_OBJECTS] [b] on [b].[OBJID]=[a].[ID]
  where [a].[SCHEMA] is null

  update [a] set
    [a].[TABLENAME]=[b].[MAJORNAME]
  from [dbo].[DEF_META] [a]
    inner join [dbo].[DEF_META_OBJECTS] [b] on [b].[OBJID]=[a].[ID]
  where [a].[MTYPE] = 70

  declare @ModuleOID int
  declare @ComModuleOID int
  declare @UncModuleOID int
  declare @Name nvarchar(150)
  declare @TableName nvarchar(150)
  declare @SchemaName nvarchar(32)
  declare @ObjType int
  declare @ObjSql nvarchar(max)
  declare @ObjXml xml
  declare @ObjDate datetime

  declare @MetaObjectsN table ([NAME] nvarchar(150) not null,[MTYPE] int not null,[OBJSQL] nvarchar(max),[OBJXML] xml,[MODULEOID] int,[TABLENAME] nvarchar(150),[SCHEMA] nvarchar(32),[S_CDT] datetime)
  insert into @MetaObjectsN([NAME],[MTYPE],[OBJSQL],[OBJXML],[TABLENAME],[SCHEMA],[S_CDT])
    select
       case when [a].[OBJTYPE] in (50,70,60,90) then [a].[MINORNAME] else [a].[MAJORNAME] end
      ,[a].[OBJTYPE]
      ,[a].[OBJSQL]
      ,[a].[OBJXML]
      ,case when [a].[OBJTYPE] in (50,70,60,90) then [a].[MAJORNAME] else [a].[MINORNAME] end
      ,[a].[OBJSCHEMA]
      ,[a].[OBJDATE]
    from [dbo].[DEF_META_OBJECTS] [a] with(nolock)
    where [a].[OBJID] is null

  select top 1
    @ComModuleOID=[b].[OID]
  from [DEF_MODULES] [b] with(nolock)
  where [b].[LABEL]=N'com_'

  select top 1
    @UncModuleOID=[b].[OID]
  from [DEF_MODULES] [b] with(nolock)
  where [b].[LABEL]=N'un_'

  --!{Index,Foreign Key Constraint}
  update [a] set
    [MODULEOID] = (select top 1 [b].[OID]
                   from [DEF_MODULES] [b] with(nolock)
                   where upper([b].[LABEL])=upper(substring([a].[NAME],1,len([b].[LABEL]))))
  from @MetaObjectsN [a]
  where [a].[MTYPE] not in (50,70)

  --{Function}
  update [a] set
    [a].[MODULEOID]=@ComModuleOID
  from @MetaObjectsN [a]
  where [a].[MODULEOID] is null
    and [a].[MTYPE]=30
    and [a].[NAME] like 'Serialize_%'

  --{Index}
  update [a] set
    [a].[MODULEOID] = (select top 1 [b].[OID] from [DEF_MODULES] [b] with(nolock) where upper('IX_'+[b].[LABEL]) = upper(substring([a].[NAME],1,len('IX_'+[b].[LABEL]))))
  from @MetaObjectsN [a]
  where [a].[MTYPE] = 50

  --{Foreign Key Constraint}
  update [a] set
    [a].[MODULEOID] = (select top 1 [b].[OID] from [DEF_MODULES] [b] with(nolock) where upper('FK_'+[b].[LABEL]) = upper(substring([a].[NAME],1,len('FK_'+[b].[LABEL]))))
  from @MetaObjectsN [a]
  where [a].[MTYPE] = 70

  --{CLR Assembly}
  update [a] set
    [a].[MODULEOID]=@ComModuleOID
  from @MetaObjectsN [a]
  where [a].[MTYPE]=200
    and [a].[OBJSQL] is not null

  --{User-defined table types}
  update [a] set
    [a].[MODULEOID]=@ComModuleOID
  from @MetaObjectsN [a]
  where [a].[MTYPE]=210
    and [a].[OBJSQL] is not null

  --!{Index,Foreign Key Constraint,Table}
  update [a] set
    [a].[MODULEOID]=@UncModuleOID
  from @MetaObjectsN [a]
  where [a].[MTYPE] not in (50,70,20)
    and [a].[MODULEOID] is null

  declare [c] cursor local read_only for
    select
       isnull([a].[MODULEOID],@UncModuleOID)
      ,[a].[NAME]
      ,[a].[MTYPE]
      ,[a].[OBJSQL]
      ,[a].[OBJXML]
      ,[a].[TABLENAME]
      ,[a].[SCHEMA]
      ,[a].[S_CDT]
    from @MetaObjectsN [a]

  open [c]
  while 1=1
  begin
    fetch next from [c] into @ModuleOID,@Name,@ObjType,@ObjSql,@ObjXml,@TableName,@SchemaName,@ObjDate;
    if @@FETCH_STATUS<>0 break;

    insert into [DEF_META] ([GID],[S_CR],[S_CDT],[S_S],[OID],[MODULEOID],[NAME],[MTYPE],[SQLTEXT],[OBJINFO],[DISABLED],[TABLENAME],[SCHEMA])
      values (newid(),@UserID,isnull(@ObjDate,getdate()),2130025 /*found new*/,
        (select isnull(max(OID),1000000)+1 from [DEF_META]),
        @ModuleOID,@Name,
        @ObjType,@ObjSql,@ObjXml,
        0,@TableName,@SchemaName)
  end
  close [c];
  deallocate [c];
END