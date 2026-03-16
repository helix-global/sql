CREATE procedure [dbo].[PR_PLACE_ORDERS] 
 @orderID int, @userID int
as 
SET nocount on

  declare @devices table (DEVICEID int not null,MTID int,REVISIONID int,BOMID int, AMODE int not null, ORDERROWID int not null)
  
  insert into @devices (DEVICEID,MTID,REVISIONID,BOMID,AMODE,ORDERROWID)
  select A.ID, B.TYPEID ,A.REVID, C.ID, C.AORDER, A.ORDERROWID
  from PR_DEVICE A with (nolock) 
  left join PR_MODELS B with (nolock) on B.ID = A.MODELID
  left join PR_MODELTYPE_BOM C with (nolock) on C.MTID = B.TYPEID
  left join PR_PRORDER O with (nolock) on O.ID = A.ORDERID
  left join PR_MODELTYPE T with (nolock) on T.ID = B.TYPEID
  where A.ORDERID = @orderID
    and C.AORDER in (1,2)
    and O.DEPARTMENTID = T.DEPARTMENTID /*условие добавлено 10.04.15 чтобы не создавались дочерние заказы если модель унаследована */
    
  if @@ROWCOUNT = 0
  begin
     SET nocount off
     return
  end
  
  declare @now datetime
  declare @devID int
  declare @bomID int
  declare @OrderRowID int
  declare @mode int
  set @now = GETDATE()
  
  declare @res table (MODELID int,REVID int, AMODE int, ORDERROWID int)  
  
  declare cur cursor local read_only for select DEVICEID, BOMID, AMODE, ORDERROWID from @devices
  open cur;
  WHILE 1=1
  BEGIN
     FETCH NEXT FROM cur INTO @devID,@bomID,@mode,@OrderRowID;
     IF @@FETCH_STATUS<>0 BREAK;

     insert into @res (MODELID,REVID,AMODE,ORDERROWID)
     select B.PARTMODELID,B.PARTONLYREVID,@mode,@OrderRowID
     from dbo.PR_DEVICE_BOM_MODELS(@devID) B 
     where B.BOMID = @bomID and B.BOMIDMODELSCOUNT = 1
  
  END
  close cur;
  deallocate cur;

  declare @res2 table (MODELID int not null,REVID int, QUANTITY int, DEPID int, AMODE int,ORDERROWID int not null)  
  
  insert into @res2 (MODELID,REVID,QUANTITY,AMODE,ORDERROWID)
  select A.MODELID,A.REVID,COUNT(*),A.AMODE,A.ORDERROWID
  from @res A
  group by A.MODELID,A.REVID,A.AMODE,A.ORDERROWID
  
  update @res2 set DEPID = (select A.DEPARTMENTID from PR_MODELTYPE A with (nolock) where A.ID = (select B.TYPEID from PR_MODELS B with (nolock) where B.ID = "@res2".MODELID))
  
  /* убрать непроизводственные подразделения*/
  update @res2 set DEPID = null where DEPID in (select ID from COM_DEPARTMENTS where NONPROD = 1)
  
  declare @depID int
  declare @depCode nvarchar(100)
  declare @newID int
  
  declare @OurDepCode nvarchar(100)
  declare @OurCustID int
  
  /*TODO ? переделать */
  select @OurDepCode = B.CODE
  from PR_PRORDER A with (nolock)
  left join COM_DEPARTMENTS B with (nolock) on B.ID = A.DEPARTMENTID
  where A.ID = @orderID
  select top 1 @OurCustID = A.ID from COM_CUSTOMER A with (nolock) where A.NAME = @OurDepCode
  
  
  declare cur2 cursor local read_only for select distinct DEPID,AMODE from @res2 where DEPID is not null
  open cur2;
  WHILE 1=1
  BEGIN
     FETCH NEXT FROM cur2 INTO @depID,@mode;
     IF @@FETCH_STATUS<>0 BREAK;

     select @depCode = A.CODE from COM_DEPARTMENTS A with (nolock) where A.ID = @depID

     if @mode = 2
       set @depCode = @depCode+'.A'

     insert into PR_PRORDER (S_S,S_CR,S_CDT,GID,PARENTORDER,NN,NN2,DEPARTMENTID,EXPDATE,URGENCY,CUSTOMERID,DD,ORDERTYPE)
     select 1000082,@userID,@now,NEWID(),A.ID,substring(A.NN+'.'+@depCode,1,20),A.NN,@depID,A.EXPDATE,A.URGENCY,@OurCustID,@now,0
     from PR_PRORDER A with (nolock) 
     where A.ID = @orderID
     
     set @newID = @@IDENTITY
     
     
     insert into PR_PRORDER_T (GID,S_CR,S_CDT,PRORDERID,MODELID,REVID,QUANTITY,PARENTORDERROWID)
     select NEWID(),@userID,@now,@newID,A.MODELID,A.REVID,A.QUANTITY,A.ORDERROWID
     from @res2 A where A.DEPID = @depID and A.AMODE = @mode
  
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