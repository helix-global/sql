CREATE procedure [dbo].[PR_CREATE_NEXT2]
  @MapID int,@DoneOper int,@DoneLevel int,@NextLevel int,@OrdID int,@DeviceID int,@lastUserInProgress int,@UserID int
as 
SET nocount on

    declare @now datetime
    set @now = GETDATE()

    declare @devFlow table (FLOWID int not null,TOID int,CONDITION int not null)
    
    insert into @devFlow (FLOWID,TOID,CONDITION) 
    select ID, OP_TO, isnull(CONDITION,0)
      from PR_MAP_FLOW with (nolock) 
     where MAPID = @MapID and OP_FROM = @DoneOper 

    delete from @devFlow 
     where CONDITION not in (0,100)
       and dbo.PR_FLOW_OR_OPER_ALLOWED(FLOWID,null,@DeviceID) = 0


    delete from @devFlow /* убрать RestWay если есть другой выход из операции */
     where CONDITION = 100
       and exists (select B.FLOWID from @devFlow B where B.FLOWID <> [@devFlow].FLOWID)

    delete from @devFlow /* убрать если не завершены предыдущие операции, связанные обязательными связями. */
     where exists (select A.ID from PR_MAP_FLOW A with (nolock) 
                    where MAPID = @MapID 
                      and A.OP_TO = "@devFlow".TOID
                      and A.OP_FROM is not null
                      and isnull(A.FLOWNOWAIT,0) = 0
                      and dbo.PR_PREVIOS_OP_DONE(@DeviceID,@OrdID,@DoneLevel,A.OP_FROM) = 0)
                      
    

    declare @Opers table (REVOPERID int not null
                         ,OPERID int not null
                         ,CANDO int not null
                         ,OPEREXISTS int not null
                         ,VISMODE int
                         ,SETUSERID int
                         ,SKIPPED int
                         ,OPLEVEL int 
                         ,LEVELUP int
                         ,CONDITION int
                         ,TC_ACTION int, TC_MINUTE int
                         ,SCHEME_GROUP int
                         ,MANHOUR decimal(10,4)
                         ,EXTDEPID INT)
        
    insert into @Opers (REVOPERID,OPERID,CANDO,OPEREXISTS,VISMODE,OPLEVEL,LEVELUP,CONDITION,TC_ACTION,TC_MINUTE,SCHEME_GROUP)
    select A.ID,O.ID,1,0,isnull(GR.VISTYPE,0),@DoneLevel,ISNULL(F.FLOWNOWAIT,0),isnull(A.CONDITION,0),A.TC_ACTION,A.TC_MINUTE,A.SCHEME_GROUP
    from PR_MAP_FLOW F with (nolock)
    left join PR_MAP_OPER A with (nolock) on A.ID = F.OP_TO
    left join PR_OPERATIONS O with (nolock) on O.ID = A.OPERID
    left join PR_OPERATIONS_GR GR with (nolock) on GR.ID = O.OPERGRID
    where F.MAPID = @MapID
      and F.ID in (select FLOWID from @devFlow)
      and A.ID is not null
    
    /*
      Требуется уникальный номер уровня для обеспечения нескольких "колец" в одной карте 
       для него будет использован ID завершенной операции.
       Уровень поднимается только если сл. операция уже есть со старым уровнем (т.е. есть оставшаяся от первого прохода)
    */
    update @Opers set OPLEVEL = @NextLevel
    where LEVELUP = 1
      and exists (select A.ID from PR_OPERATION A with (nolock) 
                    where A.DEVICEID = @DeviceID 
                      and A.ORDERID = @OrdID
                      and A.OPLEVEL = "@Opers".OPLEVEL
                      and A.REVOPERID = "@Opers".REVOPERID
                      and A.S_S <> 1000023 /*анулировано*/)

    
    update @Opers set CANDO = 0, SKIPPED = 1
     where CONDITION > 0
       and CANDO = 1 
       and dbo.PR_FLOW_OR_OPER_ALLOWED(null,REVOPERID,@DeviceID) = 0
       /*
       and ONLYOPTGR not in (select distinct B.OPTGROUP 
                                 from PR_DEVICE_OPT A with (nolock)
                            left join PR_MODELTYPE_OPTIONS B with (nolock) on B.ID = A.OPTID
                                where A.DEVICEID = @DeviceID)
       */                                
    /* можно добавить больше условий пропуска чем просто по ONLYOPTGR */
    /* and dbo.PR_OPER_ALLOWED( */

    update @Opers set OPEREXISTS = 1
     where CANDO = 1
       and exists (select A.ID from PR_OPERATION A with (nolock) 
                    where A.DEVICEID = @DeviceID 
                      and A.ORDERID = @OrdID
                      and A.OPLEVEL = "@Opers".OPLEVEL
                      and A.REVOPERID = "@Opers".REVOPERID
                      and A.S_S <> 1000023 /*анулировано*/)

    update @Opers set SETUSERID = @lastUserInProgress
    where VISMODE in (1,2,3,4) /* пролонгировать привязку пользователя */
      and CANDO = 1 
      and dbo.PR_OPERTYPE_QUALIFICATION(OPERID,@lastUserInProgress,@now) = 1
      
    /*фиксация нормы времени */  
    update @Opers set MANHOUR = (select ISNULL(H.MANHOUR2,G.MANHOUR) 
                                  from PR_OPERATIONS G with (nolock)
                                  left join PR_DEVICE D with (nolock) on D.ID = @DeviceID
                                  left join PR_REV_OVER_MH H with (nolock) on H.OPERID = G.ID and H.REVID = D.REVID
                                  where G.ID = "@Opers".OPERID)
    where CANDO = 1 and OPEREXISTS = 0                        
                    

    ;with cte_oper as ( 
    select
         op.*
         ,dbo.PR_EXTERNAL_OPERATION_USERID(@DeviceID, op.OPERID) as EXT_USER_ID
    from @Opers op)
    update cte_oper
         SET SETUSERID = EXT_USER_ID
            ,EXTDEPID = dbo.COM_USER_DEPARTMENT(EXT_USER_ID)
    WHERE
         EXT_USER_ID != -1


    insert into PR_OPERATION (GID,S_S,ORDERID,DEVICEID,OPERTYPEID,S_CDT,S_CR,REVOPERID,USERINPROGRESS,OPLEVEL,TC_ACTION,TC_MINUTE,OPERGR,MANHOUR,EXTDEPID)
    select newid(),1000032,@OrdID,@DeviceID,A.OPERID,@now,@UserID,REVOPERID,SETUSERID,OPLEVEL,TC_ACTION,TC_MINUTE,SCHEME_GROUP,MANHOUR,EXTDEPID
    from @Opers A where CANDO = 1 and OPEREXISTS = 0
    
    
    /* те, что пропускать запустить на рекурсию после создания самих операций */
    declare @SkippedOper int
    declare nxx cursor local read_only for 
    select REVOPERID from @Opers where SKIPPED = 1
    open nxx 
    WHILE 1=1
    BEGIN
        FETCH NEXT FROM nxx INTO @SkippedOper;
        IF @@FETCH_STATUS<>0 BREAK;
        
        if not exists (select DEVICEID from PR_DEVICE_SKIPPED_OP 
                        where DEVICEID = @DeviceID
                           and ORDERID = @OrdID
                           and OPLEVEL = @DoneLevel
                           and REVOPERID = @SkippedOper )
        begin                     
           insert into PR_DEVICE_SKIPPED_OP (DEVICEID,ORDERID,OPLEVEL,REVOPERID)
           values (@DeviceID,@OrdID,@DoneLevel,@SkippedOper)
        end
        
        exec PR_CREATE_NEXT2 @MapID,@SkippedOper,@DoneLevel,@NextLevel,@OrdID,@DeviceID,@lastUserInProgress,@UserID
        
    END
    close nxx;
    deallocate nxx;

set nocount off