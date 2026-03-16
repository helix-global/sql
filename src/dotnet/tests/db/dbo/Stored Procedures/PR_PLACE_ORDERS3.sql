CREATE procedure [dbo].[PR_PLACE_ORDERS3] @orderID int, @userID int
as 
SET nocount on

  declare @OrderDepID int
  select @OrderDepID = O.DEPARTMENTID 
  from PR_PRORDER O with (nolock) 
  where O.ID = @orderID

  /* возможные BOM items на которые есть настройки */
  declare @check table (DEVICEID int not null,MODELID int not null,DEVICEMTID int not null,BOMID int not null,ORDERROWID int not null)
  
  insert into @check (DEVICEID,MODELID,DEVICEMTID,BOMID,ORDERROWID)
  select A.ID, A.MODELID, B.TYPEID, C.ID, A.ORDERROWID
  from PR_DEVICE A with (nolock) 
  left join PR_MODELS B with (nolock) on B.ID = A.MODELID
  left join PR_MODELTYPE_BOM C with (nolock) on C.MTID = B.TYPEID
  left join PR_PRORDER O with (nolock) on O.ID = A.ORDERID
  left join PR_MODELTYPE T with (nolock) on T.ID = B.TYPEID
  where A.ORDERID = @orderID
    and C.ID is not null
    and exists (select NN.ID from PR_PLACED_SETTINGS NN 
                 where NN.DEPID = O.DEPARTMENTID 
                   and (NN.PLACEDMTID = C.BOMMTID or NN.PLACEDMTID in (select G.BOMMTID from PR_MODELTYPE_BOM_T G where G.VNESHID = C.ID))
                   and NN.MTID = B.TYPEID
                   and NN.PLACEDORDER in (1,2)
                   and not exists (select JJ.ID 
                                     from PR_PLACED_SETTINGS_T JJ with (nolock) 
                                    where JJ.VNESHID = NN.ID
                                      and JJ.MODELID = B.ID)
                   )
    
  if @@ROWCOUNT = 0
  begin
     SET nocount off
     return
  end
  
  declare @now datetime
  declare @nowDD datetime  
  declare @devID int
  declare @devModelID int  
  declare @devMTID int
  declare @bomID int
  declare @OrderRowID int
  set @now = GETDATE()
  set @nowDD = cast(@now as date)
  
  declare @ComponentsToOrder table (DEVICEID int not null,
                                    BOMID int not null,   
                                    PARTMODELID int not null,
                                    PARTMTID int not null,
                                    ORDERROWID int not null,
                                    SETTINGID int not null)  
  
  declare cur cursor local read_only for select DEVICEID, MODELID, DEVICEMTID, BOMID, ORDERROWID from @check
  open cur;
  WHILE 1=1
  BEGIN
     FETCH NEXT FROM cur INTO @devID,@devModelID,@devMTID,@bomID,@OrderRowID;
     IF @@FETCH_STATUS<>0 BREAK;

     insert into @ComponentsToOrder (DEVICEID,BOMID,PARTMODELID,PARTMTID,SETTINGID,ORDERROWID)
     select @devID
           ,B.BOMID
           ,B.PARTMODELID
           ,C.TYPEID
           ,(select N2.ID from PR_PLACED_SETTINGS N2 where N2.DEPID = @OrderDepID and N2.PLACEDMTID = C.TYPEID and N2.MTID = @devMTID)
           ,@OrderRowID
     from dbo.PR_DEVICE_BOM_MODELS(@devID) B 
     left join PR_MODELS C on C.ID = B.PARTMODELID
     where B.BOMID = @bomID 
       /*and B.BOMIDMODELSCOUNT = 1*/  /* PLA попросили создавать заказы, включая туда все варианты */
       and isnull(B.PARTMODELFROM,0) not in (5,6) /* 04.06.17 PLA попросили не включать совместимые *//*+ 6 тип по KB3665*/
       and exists (select NN.ID from PR_PLACED_SETTINGS NN 
                    where NN.DEPID = @OrderDepID
                      and NN.PLACEDMTID = C.TYPEID 
                      and NN.MTID = @devMTID
                      and NN.PLACEDORDER in (1,2)
					  and not exists (select JJ.ID 
                                       from PR_PLACED_SETTINGS_T JJ with (nolock) 
                                      where JJ.VNESHID = NN.ID
                                        and JJ.MODELID = @devModelID)                                            
                      )
  
  END
  close cur;
  deallocate cur;
  

  declare @res2 table (PARTMODELID int not null,QUANTITY int, DEPID int, SETTINGID int,ORDERROWID int not null)  
  
  insert into @res2 (PARTMODELID,QUANTITY,SETTINGID,ORDERROWID)
  select A.PARTMODELID,COUNT(*),A.SETTINGID,A.ORDERROWID
  from @ComponentsToOrder A
  group by A.PARTMODELID,A.SETTINGID,A.ORDERROWID
  
  update @res2 set DEPID = (select B.DEPID from PR_MODELS B with (nolock) where B.ID = "@res2".PARTMODELID)
  
  /* убрать непроизводственные подразделения*/
  update @res2 set DEPID = null where DEPID in (select ID from COM_DEPARTMENTS where NONPROD = 1)
  
  declare @depID int
  declare @depCode nvarchar(100)
  declare @newID int
  
  declare @OurDepCode nvarchar(100)
  declare @OurCustID int
  declare @OurCustID2 int
  
  /*TODO ? переделать */
  select @OurDepCode = B.CODE
        ,@OurCustID2 = B.CUSTOMERID 
  from PR_PRORDER A with (nolock)
  left join COM_DEPARTMENTS B with (nolock) on B.ID = A.DEPARTMENTID
  where A.ID = @orderID
  
  select top 1 @OurCustID = A.ID from COM_CUSTOMER A with (nolock) where A.NAME = @OurDepCode
  
  set @OurCustID = isnull(@OurCustID, @OurCustID2)
  
  if @OurCustID is null
  begin
	   raiserror('Unable to find link to Business Partner record using source order department.',15,0);
       SET nocount off
       return  
  end
  
  declare @settingID int
  declare @mode int

  declare @urgency int
  declare @nn nvarchar(20)
  declare @expDate datetime
  declare @shiftDate int
  
  declare @newOrderN nvarchar(20)
  declare @newExpDate datetime
  
  declare @ordNn int
  set @ordNn = 0
  
  declare cur2 cursor local read_only for select distinct DEPID,SETTINGID from @res2 where DEPID is not null
  open cur2;
  WHILE 1=1
  BEGIN
     FETCH NEXT FROM cur2 INTO @depID,@settingID;
     IF @@FETCH_STATUS<>0 BREAK;

     set @ordNn = @ordNn + 1
  
     select @mode = N2.PLACEDORDER 
           ,@shiftDate = isnull(N2.DAYSLAG,0)
       from PR_PLACED_SETTINGS N2 with (nolock)
      where N2.ID = @settingID
     
     select @depCode = A.CODE from COM_DEPARTMENTS A with (nolock) where A.ID = @depID

     if @mode = 2
       set @depCode = @depCode+'.A'
       
     select @nn = A.NN
           ,@urgency = A.URGENCY
           ,@expDate = A.EXPDATE
     from PR_PRORDER A with (nolock) 
     where A.ID = @orderID
     
     set @expDate = cast(@expDate as date) 
     
     declare @ordNnStr nvarchar(20) = ltrim(rtrim(str(@ordNn)))

     if (len(@nn) + 1 + len(@ordNnStr) > 20)
     begin
       raiserror('New production orders based on Placed Order Settings cannot be created because original order has too long number.',15,0);
       SET nocount off
       return
     end
     set @newOrderN = @nn + '.'+@ordNnStr     
          
     set @newExpDate = dateadd(day,@shiftDate,@expDate)
     
     if @newExpDate < @nowDD
     begin
        set @newExpDate = @nowDD
        declare @mess nvarchar(max)
        set @mess = '#WPlanned date for '+@newOrderN+' was changed to '+convert(nvarchar,@nowDD,104)+' because the calculated date is in the past.'
        print @mess
     end


     insert into PR_PRORDER (S_S,S_CR,S_CDT,GID,PARENTORDER,NN,NN2,DEPARTMENTID,EXPDATE,URGENCY,CUSTOMERID,DD,ORDERTYPE,PLACEDSETTINGID)
     values (1000082,@userID,@now,NEWID(),@orderID,@newOrderN,@nn,@depID,@newExpDate,@urgency,@OurCustID,@now,0,@settingID)
     
     set @newID = @@IDENTITY
     
     insert into PR_PRORDER_T (GID,S_CR,S_CDT,PRORDERID,MODELID,QUANTITY,PARENTORDERROWID)
     select NEWID(),@userID,@now,@newID,A.PARTMODELID,A.QUANTITY,A.ORDERROWID
     from @res2 A 
     where A.DEPID = @depID 
       and A.SETTINGID = @settingID
  
     if (@mode = 2)
       update PR_PRORDER set S_S = 1000063 where ID = @newID
       
  END
  close cur2;
  deallocate cur2;

  /* передача опций */ 
  declare @rowID int
  declare @rowMTID int
  declare @LinkCode nvarchar(50)
  
  declare cur3 cursor local read_only for 
  select distinct ID,TYPEID,LINKCODE
  from
  (
  select B.ID,M.TYPEID,O.LINKCODE
  from PR_PRORDER A with (nolock)
  left join PR_PRORDER_T B on B.PRORDERID = A.ID
  left join PR_PRORDER_TO C on C.OPID = B.PARENTORDERROWID
  left join PR_MODELTYPE_OPTIONS O on O.ID = C.OPTID
  left join PR_MODELS M on M.ID = B.MODELID
  where A.PARENTORDER = @orderID
    and O.LINKCODE is not null
  union all  
  select B.ID,M.TYPEID,O.LINKCODE  /*predefined*/
  from PR_PRORDER A with (nolock)
  left join PR_PRORDER_T B on B.PRORDERID = A.ID
  left join PR_PRORDER_T SOURCE_T on SOURCE_T.ID = B.PARENTORDERROWID
  left join PR_MODEL_OPTIONS SOURCE_O on SOURCE_O.MODELID = SOURCE_T.MODELID
  left join PR_MODELTYPE_OPTIONS O on O.ID = SOURCE_O.OPTIONID
  left join PR_MODELS M on M.ID = B.MODELID
  where A.PARENTORDER = @orderID
    and O.LINKCODE is not null
    and isnull(SOURCE_O.PREDEFINEDOPT,0) = 1
  ) M 
  /*
  select distinct B.ID,M.TYPEID,O.LINKCODE
  from PR_PRORDER A with (nolock)
  left join PR_PRORDER_T B on B.PRORDERID = A.ID
  left join PR_PRORDER_TO C on C.OPID = B.PARENTORDERROWID
  left join PR_MODELTYPE_OPTIONS O on O.ID = C.OPTID
  left join PR_MODELS M on M.ID = B.MODELID
  where A.PARENTORDER = @orderID
    and O.LINKCODE is not null
    */
  open cur3;
  WHILE 1=1
  BEGIN
     FETCH NEXT FROM cur3 INTO @rowID,@rowMTID,@LinkCode;
     IF @@FETCH_STATUS<>0 BREAK;
     
     insert into PR_PRORDER_TO (GID,S_CR,S_CDT,OPID,OPTID)
     select newid(),@userID,@now,@rowID,A.ID
     from PR_MODELTYPE_OPTIONS A with (nolock)
     left join PR_MODELTYPE_OPTION_GR B on B.ID = A.OPTGROUP
     where B.TYPEID = @rowMTID
       and A.LINKCODE = @LinkCode
     
  END
  close cur3;
  deallocate cur3;


  /* передача параметров */ 
  declare @sourceRowID int, @sourceParamID int

  declare cur4 cursor local read_only for 
  select distinct B.ID,M2.TYPEID,P.LINKCODE,C.ID,P.ID
  from PR_PRORDER A with (nolock)
  left join PR_PRORDER_T B on B.PRORDERID = A.ID
  left join PR_PRORDER_T C on C.ID = B.PARENTORDERROWID  
  left join PR_MODELS M on M.ID = C.MODELID
  left join PR_MODELS M2 on M2.ID = B.MODELID
  left join PR_MODELTYPE_PARAMS P on P.TYPEID = M.TYPEID
  where A.PARENTORDER = @orderID
    and P.LINKCODE is not null  

  declare @paramValue sql_variant;
  declare @swID int;
  declare @swVerID int;
  declare @swMode int;
    
  open cur4;
  WHILE 1=1
  BEGIN
     FETCH NEXT FROM cur4 INTO @rowID,@rowMTID,@LinkCode,@sourceRowID, @sourceParamID;
     IF @@FETCH_STATUS<>0 BREAK;

     set @paramValue = dbo.PR_ORDERROW_PARAM(@sourceRowID, @sourceParamID)
     
     select @swID = A.SWTOOLID
           ,@swMode = A.SWMODE
           ,@swVerID = A.SWVERID
     from dbo.PR_ORDERROW_SW_TAB(@sourceRowID, @sourceParamID) A
     
     if @paramValue is not null
     begin
		 insert into PR_PRORDER_TP (GID,S_CR,S_CDT,OPID,PARAMID,PVALUE,SWID,SWVERID,SWMODE)
		 select newid(),@userID,@now,@rowID,A.ID,@paramValue,@swID,@swVerID,@swMode
		 from PR_MODELTYPE_PARAMS A with (nolock)
		 where A.TYPEID = @rowMTID
		   and A.LINKCODE = @LinkCode
     end
     
  END
  close cur4;
  deallocate cur4;
  
  
SET nocount off