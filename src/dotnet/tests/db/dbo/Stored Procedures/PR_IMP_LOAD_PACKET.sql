CREATE PROCEDURE [dbo].[PR_IMP_LOAD_PACKET]
  @ContextID int,
  @UserID int
as
begin
  set nocount on;

  exec [dbo].[PR_IMP_PACKET_CHECK_DEPART] @ContextID;
  exec [dbo].[PR_IMP_ROLLBACK_PACKET] @ContextID, @UserID;

  -- KB5515: BUG Item import: interactions during import
  -- Fixed by using temp tables with import packet ID in table name suffix.
  declare
    @temp_import_csv_tablename nvarchar(100) = concat('##temp_import_csv_', @ContextID),
    @temp_import_csv_params_tablename nvarchar(100) = concat('##temp_import_csv_params_', @ContextID),
    @temp_import_csv_bom_tablename nvarchar(100) = concat('##temp_import_csv_bom_', @ContextID),
    @temp_import_csv_files_tablename nvarchar(100) = concat('##temp_import_csv_files_', @ContextID),
    @temp_import_csv_header_tablename nvarchar(100) = concat('##temp_import_csv_header_', @ContextID),
    @errorMessage nvarchar(max) = null;

  -- Check presence of each global temp table; if we cannot find a temp table with packet suffix, use "common" temp table
  -- as fallback (backward compatibility). This code can be removed after we update code in all places (PDB and PDBMailService).
  if object_id('tempdb..' + @temp_import_csv_tablename) is null
  begin
    set @temp_import_csv_tablename = '##temp_import_csv';
    if object_id('tempdb..' + @temp_import_csv_tablename) is null
    begin
      set @errorMessage = concat('Global temp tables ', '##temp_import_csv_', @ContextID, ', ', @temp_import_csv_tablename, ' don''t exist.');
      raiserror(@errorMessage, 16, 0);
      set nocount off;
      return;
    end
  end

  if object_id('tempdb..' + @temp_import_csv_params_tablename) is null
  begin
    set @temp_import_csv_params_tablename = '##temp_import_csv_params';
    if object_id('tempdb..' + @temp_import_csv_params_tablename) is null
    begin
      set @errorMessage = concat('Global temp tables ', '##temp_import_csv_params_', @ContextID, ', ', @temp_import_csv_params_tablename, ' don''t exist.');
      raiserror(@errorMessage, 16, 0);
      set nocount off;
      return;
    end
  end

  if object_id('tempdb..' + @temp_import_csv_bom_tablename) is null
  begin
    set @temp_import_csv_bom_tablename = '##temp_import_csv_bom';
    if object_id('tempdb..' + @temp_import_csv_bom_tablename) is null
    begin
      set @errorMessage = concat('Global temp tables ', '##temp_import_csv_bom_', @ContextID, ', ', @temp_import_csv_bom_tablename, ' don''t exist.');
      raiserror(@errorMessage, 16, 0);
      set nocount off;
      return;
    end
  end

  if object_id('tempdb..' + @temp_import_csv_files_tablename) is null
  begin
    set @temp_import_csv_files_tablename = '##temp_import_csv_files';
    if object_id('tempdb..' + @temp_import_csv_files_tablename) is null
    begin
      set @errorMessage = concat('Global temp tables ', '##temp_import_csv_files_', @ContextID, ', ', @temp_import_csv_files_tablename, ' don''t exist.');
      raiserror(@errorMessage, 16, 0);
      set nocount off;
      return;
    end
  end

  if object_id('tempdb..' + @temp_import_csv_header_tablename) is null
  begin
    set @temp_import_csv_header_tablename = '##temp_import_csv_header';
    if object_id('tempdb..' + @temp_import_csv_header_tablename) is null
    begin
      set @errorMessage = concat('Global temp tables ', '##temp_import_csv_header_', @ContextID, ', ', @temp_import_csv_header_tablename, ' don''t exist.');
      raiserror(@errorMessage, 16, 0);
      set nocount off;
      return;
    end
  end

  declare
    @packType int,
    @impModelTypeID int,
    @packTransId int,
    @DepID int,
    @TargetStateKind int,
    @WasShippedToAnotherDep int,
    @OnlyMT int,
    @now datetime = getdate(),
    @nowDate datetime = cast(getdate() as date),
    @sql nvarchar(max);

  select
    @packType = impTrans.[PTYPE],
    @impModelTypeID = impTrans.[IMPMODELTYPE],
    @packTransId = impPacket.[TYPEID],
    @DepID = impTrans.[DEPID],
    @TargetStateKind = isnull(impTrans.[TARGETSTATE], 0),
    @WasShippedToAnotherDep = isnull(impPacket.[WASSHIPPED_FLAG], 0),
    @OnlyMT = isnull(impTrans.[ONLYMT], 0)
  from
    [dbo].[PR_IMP_PACKET] impPacket (nolock)
    left join [dbo].[PR_IMP_TRANS] impTrans (nolock) on impTrans.[ID] = impPacket.[TYPEID]
  where
    impPacket.[ID] = @ContextID;

  -- Insert data from temp table to PR_IMP_PACKET_T in batches to avoid table blocking (we had cases with large imports, table )
  declare @batchSize int = 1000,
    @startRow int = 1,
    @rowsInserted int = 1;

  while @rowsInserted > 0
  begin
    set @sql = concat('
      insert into [dbo].[PR_IMP_PACKET_T]
            ([VNESHID], [IMPSN], [IMPMODEL], [TEMPID], [IMPSTATE],
            [IMPCODE],
            [IMPREV],
            [IMPCOMPLETED_DT],
            [RESQUANTITY])
      select ', @ContextID, ', ltrim(rtrim([SN])), [MODELNAME], [TEMPROWID], 1,
	      case when len(ltrim([CODE])) = 0 then null else [CODE] end as [IMPCODE],
	      [REVNAME] as [IMPREV],
	      case
          when [COMPLETED_DT] is null then null
		      else datefromparts(
            substring(convert(varchar(20), [COMPLETED_DT], 104), 7, 4),
            substring(convert(varchar(20), [COMPLETED_DT], 104), 4, 2),
            substring(convert(varchar(20), [COMPLETED_DT], 104), 1, 2))
	      end as [IMPCOMPLETED_DT],
	      [RESQUANTITY] --KB5453
      from ', @temp_import_csv_tablename, ' 
      where [TEMPROWID] between ', @startRow, ' and ', @startRow + @batchSize - 1, ';');
  
    exec sp_executesql @sql;

    set @rowsInserted = @@rowcount;
    --print concat('startRow: ', @startRow, ', rowsInserted: ', @rowsInserted);
    set @startRow = @startRow + @batchSize;
    waitfor delay '00:00:00.100';
  end


  if @packType in (1,3) /* CSV с названием модели*/
  begin
    if @packType = 1  --KB0616
    begin
      update impPacketT
      set [TEMPMODELID] = (select [ID] from [dbo].[PR_MODELS] (nolock) where [TYPEID] = @impModelTypeID and [CODE] = impPacketT.[IMPMODEL])
      from [dbo].[PR_IMP_PACKET_T] impPacketT
      where [VNESHID] = @ContextID and [TEMPMODELID] is null and len([IMPMODEL]) = 16
    end 
      
    update impPacketT
    set [TEMPMODELID] = (select [MODELID] from [dbo].[PR_IMP_TRANS_SYN] (nolock) where [VNESHID] = @packTransId and [MODELNAME] = impPacketT.[IMPMODEL])
    from [dbo].[PR_IMP_PACKET_T] impPacketT
    where [VNESHID] = @ContextID and [TEMPMODELID] is null

    update impPacketT
    set [TEMPMODELID] = (select [ID] from [dbo].[PR_MODELS] (nolock) where [TYPEID] = @impModelTypeID and [NAME] = impPacketT.[IMPMODEL])
    from [dbo].[PR_IMP_PACKET_T] impPacketT
    where [VNESHID] = @ContextID and [TEMPMODELID] is null

    update impPacketT
    set [IMPCODE] = (select [CODE] from [dbo].[PR_MODELS] (nolock) where [ID] = impPacketT.[TEMPMODELID])
    from [dbo].[PR_IMP_PACKET_T] impPacketT
    where [VNESHID] = @ContextID and [IMPCODE] is null
  end

  if @packType = 2  /* XML с кодом модели */
  begin
    update impPacketT
    set [TEMPMODELID] = (select [MODELID] from [dbo].[PR_IMP_MCHANGING] (nolock) where [IMPTYPEID] = @impModelTypeID and [PN] = impPacketT.[IMPCODE])
    from [dbo].[PR_IMP_PACKET_T] impPacketT
    where [VNESHID] = @ContextID and [IMPCODE] is not null

    update impPacketT
    set [TEMPMODELID] = (select [ID] from [dbo].[PR_MODELS] (nolock) where [TYPEID] = @impModelTypeID and [CODE] = impPacketT.[IMPCODE])
    from [dbo].[PR_IMP_PACKET_T] impPacketT
    where [VNESHID] = @ContextID and [TEMPMODELID] is null and [IMPCODE] is not null
   
    update impPacketT
    set [TEMPMODELID] = (select [ID] from [dbo].[PR_MODELS] (nolock) where [TYPEID] in (select [MTID] from [dbo].[PR_IMP_TRANS_ADDT] (nolock) where [VNESHID] = @packTransId) and [CODE] = impPacketT.[IMPCODE])
    from [dbo].[PR_IMP_PACKET_T] impPacketT
    where [VNESHID] = @ContextID and [TEMPMODELID] is null and [IMPCODE] is not null

    /* если не найдено по коду - поискать по имени */
    update impPacketT
    set [TEMPMODELID] = (select [ID] from [dbo].[PR_MODELS] (nolock) where [TYPEID] = @impModelTypeID and [NAME] = impPacketT.[IMPMODEL]
        and (select count(*) from [dbo].[PR_MODELS] (nolock) where [TYPEID] = @impModelTypeID and [NAME] = impPacketT.[IMPMODEL]) = 1)
    from [dbo].[PR_IMP_PACKET_T] impPacketT
    where [VNESHID] = @ContextID and [TEMPMODELID] is null and [IMPMODEL] is not null

    update impPacketT
    set [IMPMODEL] = (select [NAME] from [dbo].[PR_MODELS] (nolock) where [ID] = impPacketT.[TEMPMODELID])
    from [dbo].[PR_IMP_PACKET_T] impPacketT
    where [VNESHID] = @ContextID and [IMPMODEL] is null and [TEMPMODELID] is not null
  end
   	    
  declare @allowedMT table (ID int);

  insert into @allowedMT (ID)
  select @impModelTypeID as [ID]
  union all
  select distinct [MTID] as [ID] from [dbo].[PR_IMP_TRANS_ADDT] (nolock) where [VNESHID] = @packTransId;

  if @OnlyMT = 1
  begin
    delete from [dbo].[PR_IMP_PACKET_T]
    where [VNESHID] = @ContextID and [TEMPMODELID] is null;
   
    delete from PR_IMP_PACKET_T
    where [VNESHID] = @ContextID
        and not exists (select models.[ID] from [dbo].[PR_MODELS] models (nolock) where models.[ID] = PR_IMP_PACKET_T.[TEMPMODELID] and models.[TYPEID] in (select [ID] from @allowedMT))
  end
   	    
  update impPacketT
  set [TEMPREVID] = (select [ID] from [dbo].[PR_REVISION] (nolock) where [MODELID] = impPacketT.[TEMPMODELID] and [NAME] = impPacketT.[IMPREV])
  from [dbo].[PR_IMP_PACKET_T] impPacketT
  where [VNESHID] = @ContextID and [TEMPMODELID] is not null and [IMPREV] is not null
   	    
  update PR_IMP_PACKET_T
  set [IMPSTATE] = 2, [IMPERROR] = 'Model not found' 
  where [VNESHID] = @ContextID and [TEMPMODELID] is null

  update impPacketT
  set [DEVICEID] = (select [ID] from [dbo].[PR_DEVICE] (nolock) where [MODELID] = impPacketT.[TEMPMODELID] and [SN] = impPacketT.[IMPSN])
  from [dbo].[PR_IMP_PACKET_T] impPacketT
  where [VNESHID] = @ContextID and [TEMPMODELID] is not null
   
  if @impModelTypeID <> 9
  begin
    -- 12/03/15  не принимать изделия, произведенным в БД (есть производственный заказ)
    delete from [dbo].[PR_IMP_PACKET_T]
    where [VNESHID] = @ContextID and [DEVICEID] is not null
        and exists (select device.[ID] from [dbo].[PR_DEVICE] device (nolock) where device.[ID] = PR_IMP_PACKET_T.[DEVICEID] and device.[ORDERID] is not null)
  end   

  update impPacketT 
  set [UNIQSNMODELTYPE] = (
      select models.[TYPEID] from [dbo].[PR_MODELS] models (nolock)
      left join [dbo].[PR_MODELTYPE] modelType (nolock) on modelType.[ID] = models.TYPEID
      where models.[ID] = impPacketT.[TEMPMODELID] and isnull(modelType.[SNUNIQUE], 0) = 1)
  from [dbo].[PR_IMP_PACKET_T] impPacketT
  where [VNESHID] = @ContextID and [TEMPMODELID] is not null

  update impPacketT
  set
    [IMPSTATE] = 2,
    [IMPERROR] = 'SN:' + [IMPSN] + ' already used with another model.'
  from [dbo].[PR_IMP_PACKET_T] impPacketT
  where [VNESHID] = @ContextID and [TEMPMODELID] is not null and [DEVICEID] is null and [UNIQSNMODELTYPE] is not null
      and exists (select device.[ID]
                  from [dbo].[PR_DEVICE] device (nolock)
                  left join [dbo].[PR_MODELS] models (nolock) on models.[ID] = device.[MODELID]
                  where device.[SN] = impPacketT.[IMPSN] and models.[TYPEID] = impPacketT.[UNIQSNMODELTYPE] and device.[MODELID] <> impPacketT.[TEMPMODELID])

  update impPacketT
  set
    [IMPSTATE] = 2,
    [IMPERROR] = 'SN:' + [IMPSN] + ' used for another model in packet.'
  from [dbo].[PR_IMP_PACKET_T] impPacketT
  where [VNESHID] = @ContextID and [TEMPMODELID] is not null and [DEVICEID] is null and [UNIQSNMODELTYPE] is not null
      and exists (select impPacketAnotherModel.[ID]
                  from [dbo].[PR_IMP_PACKET_T] impPacketAnotherModel
                  where impPacketAnotherModel.[VNESHID] = @ContextID
                      and impPacketAnotherModel.[UNIQSNMODELTYPE] = impPacketT.[UNIQSNMODELTYPE]
                      and impPacketAnotherModel.[IMPSN] = impPacketT.[IMPSN]
                      and impPacketAnotherModel.[TEMPMODELID] <> impPacketT.[TEMPMODELID])

  if @impModelTypeID = 9 /* 31.05.2017 можно и для всех проставлять, но не нужно т.к. используется только в модулях */   
  begin
     update [dbo].[PR_DEVICE]
     set [IMPPACKDEP] = @DepID
     where [ID] in (select impPacketT.[DEVICEID] from [dbo].[PR_IMP_PACKET_T] impPacketT (nolock) where impPacketT.[VNESHID] = @ContextID) 
  end
												
  declare @DevState int = 1000030 /* shipped */
  if (@TargetStateKind = 1)
    set @DevState = 1000130 /* imported */
  else if (@TargetStateKind = 2)
    set @DevState = 1000022 /* production completed */
   
  if @DevState = 1000130 and @WasShippedToAnotherDep = 1
    set @DevState = 1000030 /* shipped */  
   
  /* KB528 */
  update [dbo].[PR_DEVICE]
  set [S_S] = @DevState
  where [ID] in (select [DEVICEID] from [dbo].[PR_IMP_PACKET_T] impPacketT where impPacketT.[VNESHID] = @ContextID and impPacketT.[TEMPMODELID] is not null and isnull(impPacketT.[IMPSTATE], 0) <> 2)
    and [S_S] = 1000080 /* repair req. */

  insert into [dbo].[PR_DEVICE]
        ([GID],   [S_CR],  [S_CDT],   [S_S],     [SN],    [MODELID],     [ORDERID], [IMPPACKID],  [IMPID], [IMPPACKDEP], [REVID],    [COMPLETED_DT], [RESQUANTITY])
  select newid(), @UserID, @now,      @DevState, [IMPSN], [TEMPMODELID], null,      @ContextID,   [ID],    @DepID,       [TEMPREVID],
    isnull([IMPCOMPLETED_DT], @nowDate),  --KB3923 edit @nowDate => isnull(IMPCOMPLETED_DT, @nowDate) /*if imported file has [COMPLETED_DATE] column value*/
    isnull([RESQUANTITY], 1)
  from [dbo].[PR_IMP_PACKET_T] (nolock)
  where [VNESHID] = @ContextID and [TEMPMODELID] is not null and [DEVICEID] is null and ISNULL([IMPSTATE], 0) <> 2

  update impPacketT
  set [DEVICEID] = (select [ID] from [dbo].[PR_DEVICE] (nolock) where [IMPPACKID] = @ContextID and [IMPID] = impPacketT.[ID])
  from [dbo].[PR_IMP_PACKET_T] impPacketT
  where [VNESHID] = @ContextID and [DEVICEID] is null											 

  drop table if exists #tmpDevices;
  create table #tmpDevices ([TEMPID] int, [DEVICEID] int, [MTID] int, [SP_IMP_OPER] int, [SP_IMP_OPER_ID] int);

  insert into #tmpDevices ([TEMPID], [DEVICEID], [MTID])
  select impPacketT.[TEMPID], impPacketT.[DEVICEID], models.[TYPEID]
  from [dbo].[PR_IMP_PACKET_T] impPacketT
    left join [dbo].[PR_DEVICE] device (nolock) on device.[ID] = impPacketT.[DEVICEID]
    left join [dbo].[PR_MODELS] models (nolock) on models.[ID] = device.[MODELID]
  where impPacketT.[VNESHID] = @ContextID and impPacketT.[DEVICEID] is not null

  update devices
  set [SP_IMP_OPER] = (select top 1 [ID] from [dbo].[PR_OPERATIONS] (nolock) where [MTID] = devices.[MTID] and [OPERTYPE] = 7)
  from #tmpDevices devices

  insert into [dbo].[PR_OPERATION]
        ([GID],   [S_S],   [S_CR],  [S_CDT], [DEVICEID], [OPERTYPEID],  [IMPID],    [COMPLETED_DT])
  select newid(), 1000116, @UserID, @now,    [DEVICEID], [SP_IMP_OPER], @ContextID, @now
  from (select distinct [DEVICEID], [SP_IMP_OPER] from #tmpDevices where [DEVICEID] is not null and [SP_IMP_OPER] is not null) dev

  update devices
  set [SP_IMP_OPER_ID] = (select top 1 max(operation.[ID]) from [dbo].[PR_OPERATION] operation (nolock) where operation.[DEVICEID] = devices.[DEVICEID] and operation.[IMPID] = @ContextID)
  from #tmpDevices devices
  where [SP_IMP_OPER] is not null and [DEVICEID] is not null


  /* параметры */
  drop table if exists #prms;
  create table #prms ([DEVICEID] int, [PARAMID] int, [PARAMNAME] nvarchar(300), [PVALUE] sql_variant, [MTID] int, [SP_IMP_OPER] int, [SP_IMP_OPER_ID] int);

  set @sql = concat('
    insert into #prms
          ([DEVICEID],       [PARAMID],           [PARAMNAME],           [PVALUE],                                                          [SP_IMP_OPER],         [SP_IMP_OPER_ID])
    select devices.DEVICEID, csvParams.[PARAMID], csvParams.[PARAMNAME], [dbo].[PR_PARAM_CONVERT](csvParams.[PVALUE], typeParams.[TYPEID]), devices.[SP_IMP_OPER], devices.[SP_IMP_OPER_ID]
    from ', @temp_import_csv_params_tablename, ' csvParams
      left join ', @temp_import_csv_tablename, ' csv on csv.[TMPID] = csvParams.[TMPID]
      left join #tmpDevices devices on devices.[TEMPID] = csv.[TEMPROWID]
      left join [dbo].[PR_MODELTYPE_PARAMS] typeParams on typeParams.ID = csvParams.PARAMID
    where devices.[DEVICEID] is not null');

  exec sp_executesql @sql;
 
  update prms
  set [MTID] = (select [TYPEID] from [dbo].[PR_MODELS] models (nolock) where models.[ID] = (select device.[MODELID] from [dbo].[PR_DEVICE] device (nolock) where device.[ID] = prms.[DEVICEID]))
  from #prms prms
  where [PARAMID] is null

  update prms
  set [PARAMID] = (select typeParams.[ID] from [dbo].[PR_MODELTYPE_PARAMS] typeParams (nolock) where typeParams.[TYPEID] = prms.[MTID] and typeParams.[NAME] = prms.[PARAMNAME] collate DATABASE_DEFAULT)
  from #prms prms
  where PARAMID is null

  insert into [dbo].[PR_DEVICE_IN_VALUES]
        ([DEVICEID],      [PACKETID], [PARAMID],      [PVALUE])
  select prms.[DEVICEID], @ContextID, prms.[PARAMID], prms.[PVALUE]
  from #prms prms
  where [PARAMID] is not null and [DEVICEID] is not null and [PVALUE] is not null and [SP_IMP_OPER] is null
    and not exists
      (select vals.[ID]
       from [dbo].[PR_DEVICE_IN_VALUES] vals (nolock)
       where vals.[DEVICEID] = prms.[DEVICEID] and vals.[PARAMID] = prms.[PARAMID] and isnull(vals.[PVALUE], -262123) = isnull(prms.[PVALUE], -262123))
  
  update [dbo].[PR_DEVICE_IN_VALUES]
  set [INDEX_STR] = upper(cast([PVALUE] AS nvarchar(250)))
  where [INDEX_STR] is null and [PACKETID] = @ContextID and [PARAMID] in (select [PRMID] from [dbo].[PR_IMP_INDEX_PRMS] (nolock))

  insert into [dbo].[PR_OPERATION_PARAMS]
        ([OPERID],         [PARAMID], [PVALUE])
  select [SP_IMP_OPER_ID], [PARAMID], [PVALUE]
  from #prms
  where [DEVICEID] is not null and [SP_IMP_OPER_ID] is not null and [PARAMID] is not null

  update [dbo].[PR_OPERATION_PARAMS]
  set [INDEX_STR] = upper(cast([PVALUE] AS nvarchar(250)))
  where [PARAMID] in (select [PRMID] from [dbo].[PR_IMP_INDEX_PRMS] (nolock))
    and [INDEX_STR] is null
    and [OPERID] in (select [SP_IMP_OPER_ID] from #prms)


  /* комплектующие */
  declare @modelTypeWithoutSpecialOperation nvarchar(300);
  set @sql = concat('
    select top 1 @modelTypeOut = modelType.[NAME]
    from ', @temp_import_csv_bom_tablename, ' csvBom
      left join ', @temp_import_csv_tablename, ' csv on csv.[TMPID] = csvBom.[TMPID]
      left join #tmpDevices devices on devices.[TEMPID] = csv.[TEMPROWID]
      left join [dbo].[PR_MODELTYPE] modelType (nolock) on modelType.[ID] = devices.[MTID]
    where devices.[SP_IMP_OPER_ID] is null');
  
  exec sp_executesql @sql, N'@modelTypeOut nvarchar(300) output', @modelTypeOut = @modelTypeWithoutSpecialOperation output;

  if @modelTypeWithoutSpecialOperation is not null
  begin
    set @errorMessage = 'Unable to import components by items in the packet. Modeltype "' + @modelTypeWithoutSpecialOperation + '" does not contain operation "Special Operation - Import".';
    raiserror(@errorMessage, 16, 0);
    set nocount off;
    return;
  end

  drop table if exists #parts;
  create table #parts ([DEVICEID] int, [MTID] int, [BOMID] int, [BOMNAME] nvarchar(300), [PARTCODE] nvarchar(50), [PARTMODELID] int,
      [PARTSN] nvarchar(50), [PARTID] int, [QUANTITY] decimal(20,10), [CMODE] int, [SP_IMP_OPER_ID] int, [PART_INSTALLED_IN_ID] int);

  set @sql = concat('
    insert into #parts
          ([DEVICEID],         [BOMNAME],        [PARTCODE],          [PARTSN],                          [QUANTITY],                    [SP_IMP_OPER_ID])
    select devices.[DEVICEID], csvBom.[BOMNAME], csvBom.[BOMPART_PN], ltrim(rtrim(csvBom.[BOMPART_SN])), isnull(csvBom.[BOMPART_Q], 1), devices.[SP_IMP_OPER_ID]
    from ', @temp_import_csv_bom_tablename, ' csvBom
      left join ', @temp_import_csv_tablename, ' csv on csv.[TMPID] = csvBom.[TMPID]
      left join #tmpDevices devices on devices.[TEMPID] = csv.[TEMPROWID]
    where devices.[SP_IMP_OPER_ID] is not null');
  
  exec sp_executesql @sql;

  update parts
  set [MTID] = (select models.[TYPEID] from [dbo].[PR_MODELS] models (nolock) where models.[ID] = (select device.[MODELID] from [dbo].[PR_DEVICE] device (nolock) where device.[ID] = parts.[DEVICEID]))
  from #parts parts
  where [DEVICEID] is not null

  update parts
  set [BOMID] = (select modelTypeBom.[ID] from [dbo].[PR_MODELTYPE_BOM] modelTypeBom (nolock) where modelTypeBom.[NAME] = parts.[BOMNAME] collate DATABASE_DEFAULT and modelTypeBom.[MTID] = parts.MTID)
  from #parts parts
						 
  update parts
  set [PARTMODELID] = (select mchanging.[MODELID] from [dbo].[PR_IMP_MCHANGING] mchanging (nolock) where mchanging.[IMPTYPEID] = @impModelTypeID and mchanging.[PN] = parts.[PARTCODE] collate DATABASE_DEFAULT)
  from #parts parts
  where [PARTMODELID] is null
     						      
  update parts
  set [PARTMODELID] = (select models.[ID] from [dbo].[PR_MODELS] models (nolock) where models.[CODE] = parts.[PARTCODE] collate DATABASE_DEFAULT)
  from #parts parts
  where [PARTMODELID] is null

  update parts
  set [PARTMODELID] = (select top 1 models.[ID] from [dbo].[PR_MODELS] models (nolock) where models.[OLDCODE] = parts.[PARTCODE] collate DATABASE_DEFAULT)
  from #parts parts
  where [PARTMODELID] is null

  if @OnlyMT = 1
  begin
    delete from #parts
    where [PARTMODELID] is null;
   
    delete from #parts
    where not exists (select models.[ID] from [dbo].[PR_MODELS] models (nolock) where models.[ID] = #parts.[PARTMODELID] and models.[TYPEID] in (select [ID] from @allowedMT))
  end

  set @errorMessage = null;
  select top 1 @errorMessage = 'Model with part number ' + [PARTCODE] + ' is not found.'
  from #parts
  where [PARTMODELID] is null;

  if @errorMessage is not null
  begin
    raiserror(@errorMessage, 16, 0);
    set nocount off;
    return;
  end

  update #parts
  set [PARTID] = (select device.[ID] from [dbo].[PR_DEVICE] device (nolock) where device.[MODELID] = #parts.[PARTMODELID] and device.[SN] = #parts.[PARTSN] collate DATABASE_DEFAULT)

  update #parts
  set CMODE = (select models.[CMODE] from [dbo].[PR_MODELS] models with (nolock) where models.[ID] = #parts.[PARTMODELID])
  /*CMODE = 1 - разрешает ее создать*/

  declare @PartsToCreate table ([ID] int identity, [PARTSN] nvarchar(50), [PARTMODELID] int, [MTID_SNUNIQ] int, [SNNOUNIQ] int, [SNNOUNIQ_FROMPACKET] int);
  
  insert into @PartsToCreate
                 ([PARTSN], [PARTMODELID])
  select distinct [PARTSN], [PARTMODELID]
  from #parts
  where [PARTMODELID] is not null and [BOMID] is not null and [PARTID] is null and [PARTSN] is not null and [CMODE] = 1

  update @PartsToCreate
  set [MTID_SNUNIQ] =
        (select models.[TYPEID]
         from [dbo].[PR_MODELS] models (nolock)
         left join [dbo].[PR_MODELTYPE] modelType (nolock) on modelType.[ID] = models.[TYPEID]
         where models.[ID] = [PARTMODELID] and isnull(modelType.[SNUNIQUE], 0) = 1)
  where [PARTSN] <> '0' and [PARTSN] <> '-';
                             
  update @PartsToCreate
  set [SNNOUNIQ] =
        (select top 1 device.[ID]
        from [dbo].[PR_DEVICE] device (nolock)
        left join [dbo].[PR_MODELS] models (nolock) on models.[ID] = device.[MODELID]
        where models.[TYPEID] = [MTID_SNUNIQ] and device.[SN] = [PARTSN] and device.[MODELID] <> [PARTMODELID])
  where [MTID_SNUNIQ] is not null;

  set @errorMessage = null;

  select top 1 @errorMessage = 'The component ' + partsToCreate.[PARTSN] + ' (' + partModel.[CODE] + ' ' + partModel.[NAME] +
    ') cannot be created because another component ' + device.[SN] + ' (' + existingModel.[CODE] + ' ' + existingModel.[NAME] + ') already exists.'
  from @PartsToCreate partsToCreate
    left join [dbo].[PR_MODELS] partModel (nolock) on partModel.[ID] = partsToCreate.[PARTMODELID]
    left join [dbo].[PR_DEVICE] device (nolock) on device.[ID] = partsToCreate.[SNNOUNIQ]
    left join [dbo].[PR_MODELS] existingModel (nolock) on existingModel.[ID] = device.[MODELID]
  where partsToCreate.[SNNOUNIQ] is not null

  if @errorMessage is not null
  begin
    raiserror (@errorMessage, 16, 0);
    set nocount off;
    return;
  end

  update parts1
  set [SNNOUNIQ_FROMPACKET] =
      (select top 1 parts2.[ID] from @PartsToCreate parts2
       where parts2.[MTID_SNUNIQ] = parts1.[MTID_SNUNIQ]
         and parts2.[PARTSN] = parts1.[PARTSN]
         and parts2.[PARTMODELID] <> parts1.[PARTMODELID]
         and parts2.[ID] <> parts1.[ID])
  from @PartsToCreate parts1
  where parts1.[MTID_SNUNIQ] is not null;

  set @errorMessage = null;

  select top 1 @errorMessage = 'The component ' + parts1.[PARTSN] + ' (' + model1.[CODE] + ' ' + model1.[NAME] +
    ') cannot be created because another component ' + parts2.[PARTSN] + ' (' + model2.[CODE] + ' ' + model2.[NAME] + ') exists in packet.'
  from @PartsToCreate parts1
    left join [dbo].[PR_MODELS] model1 (nolock) on model1.[ID] = parts1.[PARTMODELID]
    left join @PartsToCreate parts2 on parts2.[ID] = parts1.[SNNOUNIQ_FROMPACKET]
    left join [dbo].[PR_MODELS] model2 (nolock) on model2.[ID] = parts2.[PARTMODELID]
  where parts1.[SNNOUNIQ_FROMPACKET] is not null

  if @errorMessage is not null
  begin
    raiserror(@errorMessage, 16, 0);
    set nocount off;
    return;
  end

  update #parts
  set [PART_INSTALLED_IN_ID] = [dbo].[PR_DEVICE_IN_DEVICE]([PARTID], null)
  where [PARTID] is not null;

  set @errorMessage = null;

  select top 1 @errorMessage = concat('The component ', parts.[PARTSN] collate DATABASE_DEFAULT, ' (', models.[CODE], ' ', models.[NAME], ') is already installed into another item.')
  from #parts parts
    left join [dbo].[PR_MODELS] models (nolock) on models.[ID] = parts.[PARTMODELID]
    left join [dbo].[PR_MODELTYPE] modelType (nolock) on modelType.[ID] = models.[TYPEID]
  where parts.[PARTID] is not null and isnull(modelType.[ACCMODE], 0) = 0 and parts.[PART_INSTALLED_IN_ID] is not null and parts.[PART_INSTALLED_IN_ID] <> parts.[DEVICEID];

  if @errorMessage is not null
  begin
    raiserror(@errorMessage, 16, 0);
    set nocount off;
    return;
  end

  insert into [dbo].[PR_DEVICE]
        ([GID],   [S_CR],  [S_CDT], [S_S],   [SN],     [MODELID],     [IMPPACKID])
  select newid(), @UserID, @now,    1000077, [PARTSN], [PARTMODELID], @ContextID
  from @PartsToCreate;

  update parts
  set [PARTID] = (select [ID] from [dbo].[PR_DEVICE] device (nolock) where device.[MODELID] = parts.[PARTMODELID] and device.[SN] = parts.[PARTSN] collate DATABASE_DEFAULT)
  from #parts parts
  where [PARTID] is null;

  insert into [dbo].[PR_OPERATION_INSTALL]
          ([S_CR],  [S_CDT], [OPERID],         [BOMID], [SN],     [PARTID], [PARTQUANTITY], [PARTMODELID])
  select   @UserID, @now,    [SP_IMP_OPER_ID], [BOMID], [PARTSN], [PARTID], [QUANTITY],     [PARTMODELID]
  from #parts parts
  where [SP_IMP_OPER_ID] is not null and [BOMID] is not null and [PARTID] is not null and [DEVICEID] is not null
      and not exists (select operationInst.[ID]
                      from [dbo].[PR_OPERATION_INSTALL] operationInst (nolock)
                      left join [dbo].[PR_OPERATION] operation (nolock) on operation.[ID] = operationInst.[OPERID]
                      where operation.[DEVICEID] = parts.DEVICEID and operationInst.[BOMID] = parts.[BOMID] and operationInst.[PARTID] = parts.[PARTID])


  update [dbo].[PR_DEVICE]
  set [S_S] = 1000077 /* Installed */
  where [ID] in (select [PARTID] from #parts where [PARTID] is not null and [BOMID] is not null and [DEVICEID] is not null and [SP_IMP_OPER_ID] is not null)
    and [S_S] in (1000010, 1000030, 1000085, 1000086, 1000081, 1000130);

			
  /*files*/			
  drop table if exists #files;
  create table #files ([DEVICEID] int, [FILENAME] nvarchar(1024), [FILEBLOB] image, [SP_IMP_OPER_ID] int, [PARAMID] int);

  set @sql = concat('
    insert into #files
          ([DEVICEID],         [FILENAME],          [FILEBLOB],          [SP_IMP_OPER_ID],         [PARAMID])
    select devices.[DEVICEID], csvFiles.[FILENAME], csvFiles.[FILEBLOB], devices.[SP_IMP_OPER_ID],
        (select top 1 operationParams.[PARAMID]
         from [dbo].[PR_OPERATION_PARAMS] operationParams (nolock)
         left join [dbo].[PR_MODELTYPE_PARAMS] modelTypeParams (nolock) on modelTypeParams.[ID] = operationParams.[PARAMID]
         where operationParams.[OPERID] = devices.[SP_IMP_OPER_ID] and modelTypeParams.[DATATYPE] in (7,8) and cast(operationParams.[PVALUE] as nvarchar(max)) = csvFiles.[FILENAME] collate DATABASE_DEFAULT
         ) as [PARAMID]
    from ', @temp_import_csv_files_tablename, ' csvFiles
      left join ', @temp_import_csv_tablename, ' csv on csv.[TMPID] = csvFiles.[TMPID]
      left join #tmpDevices devices on devices.[TEMPID] = csv.[TEMPROWID]
    where devices.[SP_IMP_OPER_ID] is not null');

  exec sp_executesql @sql;

  insert into [dbo].[PR_OPERATION_FILES]
        ([GID],   [S_CR],  [S_CDT], [OPERATIONID],    [FILENAME], [FILEDATE], [FILESIZE],             [FILEBLOB], [PARAMID])
  select newid(), @UserID, @now,    [SP_IMP_OPER_ID], [FILENAME], @now,       datalength([FILEBLOB]), [FILEBLOB], [PARAMID]
  from #files;
									 
  if exists (select [ID] from [dbo].[PR_IMP_PACKET_T] where [VNESHID] = @ContextID and [IMPSTATE] = 2)
  begin
    update [dbo].[PR_IMP_PACKET]
    set [S_S] = 1000070
    where [ID] = @ContextID;
  end

  update [dbo].[PR_IMP_PACKET]
  set [RECIEVED] = @now
  where [ID] = @ContextID;

  exec [dbo].[PR_IMP_UPDATE_BUFFER] @DepID, @ContextID;

  update failureReport
  set [DEVICEID] = device.[ID]
  from [dbo].[PR_IMP_PACKET_T] impPacketT
    left join [dbo].[PR_DEVICE] device (nolock) on device.[ID] = impPacketT.[DEVICEID]
    left join [dbo].[FC_REPORT] failureReport (nolock) on failureReport.[MODELID] = device.[MODELID] and failureReport.[SN] = device.[SN] and failureReport.[DEVICEID] is null
  where impPacketT.[VNESHID] = @ContextID and failureReport.DEVICEID is null;

  set nocount off;
end