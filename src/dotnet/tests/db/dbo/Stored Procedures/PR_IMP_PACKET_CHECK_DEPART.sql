CREATE PROCEDURE [dbo].[PR_IMP_PACKET_CHECK_DEPART] 
  @ContextID int
as
begin

  /*
  процедура проверяет если в заголовке пакета (##temp_import_csv_header) указан отдел не из числа отделов шлюза, то проставляет в пакете WASSHIPPED_FLAG = 1
  на этом основании не присваивается статус imported - вместо него используется shipped*
  */
  
  declare @rootDepID int, @transID int;
   
  select
    @rootDepID = impTrans.[DEPID],
    @transID = impPacket.[TYPEID]
  from [dbo].[PR_IMP_PACKET] impPacket (nolock)
    left join [dbo].[PR_IMP_TRANS] impTrans (nolock) on impTrans.[ID] = impPacket.[TYPEID]
  where impPacket.[ID] = @ContextID;

  create table #depIDs ([ID] int);
   
  insert into #depIDs ([ID])
  select @rootDepID as [ID]
  union all
  select [ID] from [dbo].[COM_GETCHILD_DEPARTMENTS](@rootDepID)
  union all
  select distinct modelType.[DEPARTMENTID] as [ID]
  from [dbo].[PR_IMP_TRANS_ADDT] impTransAdd (nolock)
    left join [dbo].[PR_MODELTYPE] modelType (nolock) on modelType.[ID] = impTransAdd.[MTID]
  where impTransAdd.[VNESHID] = @transID;
   
  -- KB5515: BUG Item import: interactions during import
  -- Fixed by using temp tables with import packet ID in table name suffix.
  declare @temp_import_csv_header_tablename nvarchar(100) = concat('##temp_import_csv_header_', @ContextID);

  if object_id('tempdb..' + @temp_import_csv_header_tablename) is null
  begin
    set @temp_import_csv_header_tablename = '##temp_import_csv_header';
  end

  declare
    @packetToDepCode nvarchar(50),
    @packetToDepGID nvarchar(50);
   
  if object_id('tempdb..' + @temp_import_csv_header_tablename) is not null
  begin
    declare @sql nvarchar(max), @paramdef nvarchar(max);

    set @sql = '
      select top 1 @packetToDepGID_OUT = [TAGVALUE]
      from ' + @temp_import_csv_header_tablename + '
      where lower([TAGNAME]) = ''todepartmentgid'';

      select top 1 @packetToDepCode_OUT = [TAGVALUE]
      from ' + @temp_import_csv_header_tablename + '
      where lower([TAGNAME]) = ''todepartment'';
      ';

    exec sp_executesql @sql, N'@packetToDepGID_OUT nvarchar(50) output, @packetToDepCode_OUT nvarchar(50) output', @packetToDepGID_OUT = @packetToDepGID output, @packetToDepCode_OUT = @packetToDepCode output;

    --TODO: remove old code
    --select top 1 @packetToDepGID = [TAGVALUE] from ##temp_import_csv_header where lower([TAGNAME]) = 'todepartmentgid';
    --select top 1 @packetToDepCode = [TAGVALUE] from ##temp_import_csv_header where lower([TAGNAME]) = 'todepartment';
  end   

  declare @anotherDep int = 1;

  if @packetToDepGID is not null 
  begin
    if exists (select [ID] from [dbo].[COM_DEPARTMENTS] (nolock) where [GID] = @packetToDepGID and [ID] in (select [ID] from #depIDs))
    begin
      set @anotherDep = 0;
    end
      
    update [dbo].[PR_IMP_PACKET]
    set [WASSHIPPED_FLAG] = @anotherDep, [WASSHIPPED_TO] = @packetToDepCode
    where [ID] = @ContextID;
  end
  else if @packetToDepCode is not null 
  begin
    if exists (select [ID] from [dbo].[COM_DEPARTMENTS] (nolock) where [CODE] = @packetToDepCode and [ID] in (select [ID] from #depIDs))
    begin
      set @anotherDep = 0;
    end
      
    update [dbo].[PR_IMP_PACKET]
    set [WASSHIPPED_FLAG] = @anotherDep, [WASSHIPPED_TO] = @packetToDepCode
    where [ID] = @ContextID;
  end

end