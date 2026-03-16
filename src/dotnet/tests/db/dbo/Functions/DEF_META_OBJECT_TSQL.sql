-- #AZURE06028:2025-09-16: Fixed table and foreign keys resolving for @Schema<>'dbo'.
-- KB5302:2025-03-18: Serializing [SqlTableType].
-- KB5314:2025-03-24: Added [SCHEMA] field processing.
CREATE function [dbo].[DEF_META_OBJECT_TSQL](@ObjectName nvarchar(300), @objectType int, @TableName nvarchar(300),@Schema nvarchar(max))
returns nvarchar(max) as 
begin
  declare @SQL nvarchar(max)
  declare @NL nvarchar(max) = nchar(13) + nchar(10)
  declare @object_name sysname
  declare @object_id int

  if @objectType in (30,40,60,80) /*func proc trigger view*/ 
  begin
    if isnull(@Schema,'') = ''
    begin
      select @SQL = object_definition(object_id(@ObjectName))
    end else
    begin
      select @SQL = object_definition(object_id(@Schema+'.'+@ObjectName))
    end
  end
  else if @objectType = 20 /*table*/
  begin
    select top 1
      @object_id=[a].[object_id]
    from sys.tables [a] with(nolock)
    where [a].[name]=@ObjectName
      and SCHEMA_NAME([a].[schema_id])=isnull(@Schema,'dbo')
    if @object_id is not null
    begin
      select
         @object_name = '[' + object_schema_name(@object_id) + '].[' + object_name(@object_id) + ']'
    end else
    begin
      select
          @object_name = '[' + object_schema_name(o.[object_id]) + '].[' + object_name([object_id]) + ']'
        , @object_id = [object_id]
      from (select [object_id] = object_id(@ObjectName, 'U')) o
    end

    select @SQL = 'CREATE TABLE ' + @object_name + char(13) + char(10) + '(' + char(13) + char(10) + stuff((
      select char(13)+char(10) + '    , [' + c.name + '] ' + 
        case when c.is_computed = 1  then 'AS ' + object_definition(c.[object_id], c.column_id)
             else
               case when c.system_type_id != c.user_type_id
                then '[' + schema_name(tp.[schema_id]) + '].[' + tp.name + ']'
                else /*'[' +*/ upper(tp.name) /*+ ']' */
               end +
               case when tp.name in ('varchar', 'char', 'varbinary', 'binary')
                 then '(' + case when c.max_length = -1
                      then 'MAX' 
                      else cast(c.max_length as varchar(5)) 
                    end + ')'
                      when tp.name IN ('nvarchar', 'nchar')
                          then '(' + case when c.max_length = -1 
                      then 'MAX' 
                      else cast(c.max_length / 2 as varchar(5)) 
                    end + ')'
                      when tp.name IN ('datetime2', 'time2', 'datetimeoffset') 
                          then '(' + cast(c.scale as varchar(5)) + ')'
                      when tp.name = 'decimal'
                          then '(' + cast(c.[precision] as varchar(5)) + ',' + cast(c.scale as varchar(5)) + ')'
                      else ''
                  end /*+
                  case when c.collation_name IS NOT NULL and c.system_type_id = c.user_type_id 
                      then ' COLLATE ' + c.collation_name
                      else ''
                  end */+
                  case when c.is_nullable = 1
                      then ''
                      else ' NOT NULL'
                  end +
                  case when c.default_object_id != 0
                      then isnull(' DEFAULT ' + object_definition(c.default_object_id), '')
                      else ''
                  end +
                  case when c.is_identity = 1
                      then ' IDENTITY(' + cast(identityproperty(c.[object_id], 'SeedValue') as varchar(5)) + ',' +
                    cast(identityproperty(c.[object_id], 'IncrementValue') as varchar(5)) + ')'
                      else ''
                  end 
          end
      from sys.columns c with(nolock)
        inner join sys.types tp with(nolock) on c.user_type_id = tp.user_type_id
      where c.[object_id] = @object_id
      order by c.column_id
      for xml path(''), type).value('.', 'NVARCHAR(MAX)'), 1, 7, '      ') +
      isnull((select '
    , CONSTRAINT [' + isnull(i.name,'*') + '] PRIMARY KEY (' + (
      select stuff(cast((
        select ', [' + col_name(ic.[object_id], ic.column_id) + ']' +
          case when ic.is_descending_key = 1 
              then ' DESC'
              else ''
          end
        from sys.index_columns ic with(nolock)
        where i.[object_id] = ic.[object_id]
          and i.index_id = ic.index_id
        for xml path(N''), type) as nvarchar(max)), 1, 2, '')) + ')'
      from sys.indexes i with(nolock)
      where i.[object_id] = @object_id
        and i.is_primary_key = 1), '') + char(13) + char(10) + ');'
  end
  else if @objectType = 50 /* index */
  begin
     select @SQL = 'create '+case i.is_unique when 1 then ' UNIQUE ' else '' end
              + case i.type when 1 then 'CLUSTERED ' else '' end
              + 'index ' + i.name + ' on '+object_name(i.object_id)+' (' + (
      select stuff(cast((
          select ', [' + col_name(ic.[object_id], ic.column_id) + ']' +
                  case when ic.is_descending_key = 1
                      then ' DESC'
                      else ''
                  end
          from sys.index_columns ic with(nolock)
          where ic.[object_id] = i.[object_id]
            and ic.index_id = i.index_id 
            and ic.is_included_column = 0
      order by ic.key_ordinal
      for xml path(N''), type) as nvarchar(max)), 1, 2, '')) + ') ' + (
        select isnull( ' include ('+ stuff(cast((
            select ', [' + col_name(ic.[object_id], ic.column_id) + ']'
            from sys.index_columns ic with(nolock)
            where ic.[object_id] = i.[object_id]
              and ic.index_id = i.index_id
              and ic.is_included_column = 1
            order by ic.index_column_id
            for xml path(N''), type) as nvarchar(max)), 1, 2, '')+')',''))
        + case when filter_definition is not null then ' where '+filter_definition else '' end
      from sys.indexes i with(nolock)
      where i.is_primary_key <> 1
        and i.name = @ObjectName
        and object_name(i.object_id) = @TableName
  end
  else if @objectType = 70 /* FK constraint */
  begin
    select top 1
      @object_id=[a].[object_id]
    from sys.tables [a] with(nolock)
    where [a].[name]=@TableName
      and SCHEMA_NAME([a].[schema_id])=isnull(@Schema,'dbo')
    if @object_id is not null
    begin
      select
         @object_name = '[' + object_schema_name(@object_id) + '].[' + object_name(@object_id) + ']'
    end else
    begin
      select
          @object_name = '[' + object_schema_name(o.[object_id]) + '].[' + object_name([object_id]) + ']'
        , @object_id = [object_id]
      from (select [object_id] = object_id(@TableName, 'U')) o
    end
    select @SQL = 'ALTER TABLE ' 
       + quotename(cs.name) + '.' + quotename(ct.name) 
       + ' ADD CONSTRAINT ' + quotename(fk.name) 
       + ' FOREIGN KEY (' + stuff((select ',' + quotename(c.name)
      from sys.columns as c 
        inner join sys.foreign_key_columns as fkc on fkc.parent_column_id = c.column_id and fkc.parent_object_id = c.[object_id]
      where fkc.constraint_object_id = fk.[object_id]
      order by fkc.constraint_column_id 
      for xml path(N''), type).value(N'.[1]', N'nvarchar(max)'), 1, 1, N'')
      + ') REFERENCES ' + quotename(rs.name) + '.' + quotename(rt.name)
      + ' (' + stuff((
      select ',' + quotename(c.name)
      from sys.columns as c 
        inner join sys.foreign_key_columns as fkc on fkc.referenced_column_id = c.column_id and fkc.referenced_object_id = c.[object_id]
      where fkc.constraint_object_id = fk.[object_id]
      order by fkc.constraint_column_id 
      for xml path(N''), type).value(N'.[1]', N'nvarchar(max)'), 1, 1, N'') + ') '
      + case when fk.delete_referential_action = 1 then ' ON DELETE CASCADE ' else '' end 
    from sys.foreign_keys fk
      inner join sys.tables  [rt] on fk.referenced_object_id = rt.[object_id]
      inner join sys.schemas [rs] on rt.[schema_id] = rs.[schema_id]
      inner join sys.tables  [ct] on fk.parent_object_id = ct.[object_id]
      inner join sys.schemas [cs] on ct.[schema_id] = cs.[schema_id]
    where rt.is_ms_shipped = 0 
       and ct.is_ms_shipped = 0
       and fk.name = @ObjectName
       and [ct].[object_id]=@object_id
  end else
  if @objectType = 200
  begin
    select @SQL =
        --N'--[QualifiedName]: "' + [a].[clr_name] +N'"'    + @NL +
        N'create assembly ' + quotename([a].[name])       + @NL +
        N'from ' + convert(nvarchar(max),[b].[content],1) + @NL +
        N'with permission_set = ' +
          case when [a].[permission_set]=2 then N'external_access'
               when [a].[permission_set]=3 then N'unsafe'
               else N'safe'
          end + 
        ((select
            @NL + N'go' + @NL +
            N'create aggregate ' + quotename(schema_name([o].[schema_id])) + N'.' + quotename([o].[name]) + N'(' +
              stuff(((select N',' + [dbo].[DEF_PRM_FMT]([p].[object_id],[p].[parameter_id],'InputParameter')
               from sys.parameters [p] with(nolock)
               where [p].[object_id]=[o].[object_id]
                 and [p].[is_output]=0
               for xml path(N''), type).value(N'.[1]', N'nvarchar(max)')),1,1,N'') +
              N')' + @NL +
            N'returns ' +
              isnull((select top 1
                 [dbo].[DEF_PRM_FMT]([p].[object_id],[p].[parameter_id],'ReturnParameter')
               from sys.parameters [p] with(nolock)
               where [p].[object_id]=[o].[object_id]
                 and [p].[is_output]=1),N'sql_variant') +
            @NL +
            N'external name ' + quotename([a].[name]) + '.' + quotename([m].[assembly_class])
         from sys.objects [o] with(nolock)
           inner join sys.assembly_modules [m] with(nolock) on [m].[object_id]=[o].[object_id]
         where [o].[type] = 'AF'
           and [m].[assembly_id]=[a].[assembly_id]
         for xml path(N''), type).value(N'.[1]', N'nvarchar(max)')) + @NL + N'go'
    from sys.assemblies [a] with(nolock)
      inner join sys.assembly_files [b] with(nolock) on [b].[assembly_id]=[a].[assembly_id]
    where [a].[name]=@ObjectName
  end else
  if @objectType = 210
  begin
    --with XMLNAMESPACES (default 'http://schemas.microsoft.com/sqlserver/dac/Serialization/2012/02')
    select @SQL=cast((
      select [dbo].[Serialize_SqlTableType]([a].[type_table_object_id])
      from sys.table_types [a] with(nolock)
      where [a].[name]=@ObjectName
      ) as nvarchar(max))
  end
  return @SQL
end