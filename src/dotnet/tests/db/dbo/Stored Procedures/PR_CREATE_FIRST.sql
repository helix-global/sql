-- #AZURE06081:2025-11-25: Added call tracing.
CREATE procedure [dbo].[PR_CREATE_FIRST] 
  @DeviceID int, @OrdID int,@now datetime,@MapID int,
  @OrderCount int,@parentID int,@TrMapN int,
  @ScopeGroup nvarchar(max) = null
as
begin
  SET nocount on
  declare @ScopeContext xml=(
    select top 1
       isnull(@ScopeGroup,N'{x:Null}') [@ScopeGroup]
      ,N'[dbo].[PR_CREATE_FIRST]'   [@ScopeName]
      ,(select
          @DeviceID   [DeviceID]
         ,@OrdID      [OrdID]
         ,@MapID      [MapID]
         ,@OrderCount [OrderCount]
         ,@parentID   [ParentID]
         ,@TrMapN     [TrMapN]
      for xml path('ScopeContext.Parameters'),type,elements xsinil)
    for xml path('ScopeContext'),elements)
  exec [trace].[SPTraceEnter] @ScopeName=N'[dbo].[PR_CREATE_FIRST]',@ScopeContext=@ScopeContext,@ScopeGroup=@ScopeGroup
  begin try
    /* найти первые операции */    
    declare @FirstOper table (
            OPERID int not null
           ,REVOPERID int not null
           ,TC_ACTION int
           ,TC_MINUTE int
           ,SCHEME_GROUP int
           ,EX int
           ,EMPLID int
           ,USERID int
           ,MANHOUR decimal(10,4)
           ,TODOTEXT ntext)
    
    insert into @FirstOper (EX, OPERID, REVOPERID, TC_ACTION, TC_MINUTE, SCHEME_GROUP)
      select 0, A.OPERID,A.ID,A.TC_ACTION,A.TC_MINUTE,A.SCHEME_GROUP
      from PR_MAP_OPER A with (nolock)
        left join PR_MAP_FLOW B with (nolock) on B.OP_TO = A.ID
      where A.MAPID = @MapID
        and B.OP_FROM is null
        and B.OP_TO is not null

    declare @tmp int
    declare @parentQty int = null
    
    select @tmp = COUNT(*) from @FirstOper
    
    if @tmp = 0 
    begin
      exec [trace].[SPTraceEvent] @Message=N'Production map is empty. Unable to run production.',@ScopeName=N'{code:{cf98c6ac-6d02-4acc-ae21-bf00c956a294}}'
      raiserror('Production map is empty. Unable to run production.[L=pr_empty_map',15,0); 
      return
    end
    
    /*TODO тут нужно запускать PR_CREATE_NEXT3 чтобы отрабатывали все условия и алгоритмы пропуска ! */
    
    
    update @FirstOper set EX = 1
    where exists (select B.ID from PR_OPERATION B with (nolock) 
                      where B.DEVICEID = @DeviceID 
                        and B.REVOPERID = "@FirstOper".REVOPERID 
                        and B.ORDERID = @OrdID 
                        and ISNULL(B.PARENTID,0) = ISNULL(@parentID,0) 
                        and ISNULL(B.TRMAP_N,0) = ISNULL(@TrMapN,0) 
                        and B.S_S <> 1000023 )
    
    /*фиксация нормы времени */  
    update @FirstOper set MANHOUR = (select ISNULL(H.MANHOUR2,G.MANHOUR) 
                                  from PR_OPERATIONS G with (nolock)
                                  left join PR_DEVICE D with (nolock) on D.ID = @DeviceID
                                  left join PR_REV_OVER_MH H with (nolock) on H.OPERID = G.ID and H.REVID = D.REVID
                                  where G.ID = "@FirstOper".OPERID)
    where EX = 0
    
      
    if @parentID is not null
    begin  
      update @FirstOper set TODOTEXT = (select A.TODO
                                        from PR_OPERATION_TODO_MAP A with (nolock)
                                       where A.OPERID = @parentID and A.MAPOPERID = "@FirstOper".REVOPERID)
      where EX = 0 
    
      update @FirstOper set EMPLID = (select A.EMPLOYEEID
                                        from PR_OPERATION_TODO_MAP A with (nolock)
                                       where A.OPERID = @parentID and A.MAPOPERID = "@FirstOper".REVOPERID)
      where EX = 0 
      
      update @FirstOper set USERID = (select top 1 U.ID from DEF_USERS U with (nolock) where U.EMPLOYEEID = "@FirstOper".EMPLID)
      where EMPLID is not null
      
      select @parentQty = isnull(A.PREP_RESULT,A.Q_IN) from PR_OPERATION A with (nolock) where A.ID = @parentID
      
    end  
      
    insert into PR_OPERATION (GID,S_S,ORDERID,DEVICEID,OPERTYPEID,S_CDT,REVOPERID,OPLEVEL,TC_ACTION,TC_MINUTE,OPERGR,MANHOUR,Q_IN,PARENTID,TRMAP_N,USERINPROGRESS,TODOTEXT)
    select newid(),1000032,@OrdID,@DeviceID,A.OPERID,@now,A.REVOPERID,0,TC_ACTION,TC_MINUTE,SCHEME_GROUP,MANHOUR,isnull(@parentQty,@OrderCount),@parentID,@TrMapN,A.USERID,A.TODOTEXT
    from @FirstOper A 
    where EX = 0
    exec [trace].[SPTraceLeave] @ScopeName=N'{code:{c395cb61-770a-413e-a542-351415973c21}}'
  end try
  begin catch
    set @ScopeContext=(
      select top 1
         isnull(@ScopeGroup,N'{x:Null}') [@ScopeGroup]
        ,N'[dbo].[PR_CREATE_FIRST]'      [@ScopeName]
        ,(select
           error_message()   [Message]
          ,error_number()    [Number]
          ,error_severity()  [Severity]
          ,error_state()     [State]
          ,error_line()      [Line]
          ,error_procedure() [Procedure]
        for xml path('ScopeContext.Exception'),type,elements xsinil)
      for xml path('ScopeContext'),elements)
    exec [trace].[SPTraceLeave] @ScopeContext=@ScopeContext,@ScopeName=N'{code:{595da63f-eadf-45c6-9ed5-97f1ae32422c}}';
    throw;
  end catch
  set nocount off
end