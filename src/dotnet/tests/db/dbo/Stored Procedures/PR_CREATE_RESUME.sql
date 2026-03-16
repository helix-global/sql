create procedure [dbo].[PR_CREATE_RESUME] 
 @DeviceID int, @OrdID int,@now datetime,@MapID int, @OrderCount int,@parentID int,@TrMapN int, @OperationId int
as 
SET nocount on

/*
28.09.22 написана по образу PR_CREATE_FIRST для того чтобы запустить карту не с первой операции
используется в запуске "куска" после деления в FP в случае если карта не меняется, а остается той-же 
что и у "родительского" изделия

@OperationId - операция родительского изделия, которая сейчас завершается из нее определяется место
               в карте, после которого создавать операции
*/    
    declare @LastMapOperID int
    select @LastMapOperID = A.REVOPERID
      from PR_OPERATION A with(nolock)
     where A.ID = @OperationId
    
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
      and B.OP_FROM = @LastMapOperID
      and B.OP_TO is not null

    declare @tmp int
    declare @parentQty int = null
    
    select @tmp = COUNT(*) from @FirstOper
    
    if @tmp = 0 
    begin
      raiserror('Production map is empty. Unable to run production.[L=pr_empty_map',15,0); 
      set nocount off
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

set nocount off