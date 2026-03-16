create procedure [dbo].PR_NEXT_OPERATION_OLD 
 @DeviceID int, @DoneOperID int
as 
SET nocount on

  declare @RevID int
  declare @ModTypeID int  
  declare @OrdID int
  declare @DoneOperState int
  declare @MapID int
  declare @lastUserInProgress int
  declare @DeviceState int
  declare @AccMode int
  declare @OrderCount int
  declare @BlockCompl int
  set @BlockCompl = 0 /*признак 1 блокирует окончание производства, например когда в процедуре создается операция */

  declare @now datetime
  
  set @now = GETDATE()
  
  select @RevID = D.REVID
       , @OrdID = D.ORDERID 
       , @ModTypeID = M.TYPEID
       , @MapID = D.MAPID
       , @DeviceState = D.S_S
       , @AccMode = ISNULL(T.ACCMODE,0)
       , @OrderCount = D.ORDQUANTITY
    from PR_DEVICE D with (nolock)
    left join PR_MODELS M with (nolock) on M.ID = D.MODELID 
    left join PR_MODELTYPE T with (nolock) on T.ID = M.TYPEID
   where D.ID = @DeviceID;

  if @DeviceState in (1000010/*shipped*/,1000085/*shipped srv*/,1000039 /*srv completed*/,1000022/*prod compl*/, 1000077 /*installed*/)
  begin
  
      set nocount off
      return
  
  end

  if @DoneOperID is null  /*первый запуск с приказа */
  begin
    if (@RevID is null)
    begin
      raiserror('Revision is empty. Unable to run production.[L=pr_empty_rev',15,0); 
      set nocount off
      return
    end
  
    /* найти первые операции */    
    declare @FirstOper table (OPERID int not null,REVOPERID int not null,TC_ACTION int, TC_MINUTE int, SCHEME_GROUP int)
    
    insert into @FirstOper (OPERID, REVOPERID, TC_ACTION, TC_MINUTE, SCHEME_GROUP)
    select A.OPERID,A.ID,A.TC_ACTION,A.TC_MINUTE,A.SCHEME_GROUP
    from PR_MAP_OPER A with (nolock)
    left join PR_MAP_FLOW B with (nolock) on B.OP_TO = A.ID
    where A.MAPID = @MapID
      and B.OP_FROM is null
      and B.OP_TO is not null

    declare @tmp int
    
    select @tmp = COUNT(*) from @FirstOper
    
    if @tmp = 0 
    begin
      raiserror('Production map is empty. Unable to run production.[L=pr_empty_map',15,0); 
      set nocount off
      return
    end
      
    insert into PR_OPERATION (GID,S_S,ORDERID,DEVICEID,OPERTYPEID,S_CDT,REVOPERID,OPLEVEL,TC_ACTION,TC_MINUTE,OPERGR,Q_IN)
    select newid(),1000032,@OrdID,@DeviceID,A.OPERID,@now,A.REVOPERID,0,TC_ACTION,TC_MINUTE,SCHEME_GROUP,@OrderCount
    from @FirstOper A 
    where not exists (select B.ID from PR_OPERATION B with (nolock) 
                      where B.DEVICEID = @DeviceID 
                        and B.REVOPERID = A.REVOPERID 
                        and B.ORDERID = @OrdID 
                        and B.S_S <> 1000023 )
    
  end
  
  
  if @DoneOperID is not null
  begin
  
    declare @repReasonEmtpy int
    declare @parentOper int  
    declare @specialType int
    declare @todoId int
    declare @DoneOperType int
    declare @DoneRevOper int
    declare @orderType int
    declare @orderID int
    declare @userID int 
    declare @DoneLevel int    
    declare @ReRunAll int
    declare @FreeRepair int
    declare @checkDevID int
    declare @oq_out int
    declare @servMap int
    declare @frID0 int
    
    select @DoneOperState = A.S_S 
          ,@parentOper = A.PARENTID
          ,@repReasonEmtpy = case when A.REPAIRREASON is null then 1 else 0 end 
          ,@specialType = S.OPERTYPE
          ,@todoId = A.TODOID
          ,@DoneOperType = A.OPERTYPEID
          ,@DoneRevOper = A.REVOPERID
          ,@orderType = B.ORDERTYPE
          ,@orderID = A.ORDERID
          ,@userID = A.S_MR
          ,@lastUserInProgress = ISNULL(A.LASTUSERINPROGRESS,A.USERINPROGRESS)
          ,@DoneLevel = ISNULL(A.OPLEVEL,0)
          ,@ReRunAll = ISNULL(A.RERUNALL,0)
          ,@FreeRepair = ISNULL(A.FREETR,0)
          ,@checkDevID = A.DEVICEID
          ,@oq_out = A.PREP_RESULT
          ,@servMap = B.SERVMAP
          ,@frID0 = A.FAILUREREPORTID
    from PR_OPERATION A with (nolock)
    left join PR_PRORDER B with (nolock) on B.ID = A.ORDERID
    left join PR_OPERATIONS S with (nolock) on S.ID = A.OPERTYPEID
    left join PR_OPERATIONS_GR G with (nolock) on G.ID = S.OPERGRID
    where A.ID = @DoneOperID;
    
    
    if @orderType = 1 and @servMap is not null
    begin
      set @MapID = @servMap
      set @OrdID = @orderID
    end
    
    if (@checkDevID is null) /*preparatory*/
    begin
    
      if @DoneOperState = 1000018  /*failure*/
        raiserror('Cannot set failure for preparatory operation.',15,0);

      if @DoneOperState = 1000079 /* device failed */
        raiserror('Cannot set failure for preparatory operation.',15,0);
    
      set nocount off
      return
    
    end
    
    if (@AccMode = 1 and @DoneOperState in (1000013,1000019))
    begin
      
      if (isnull(@oq_out,0) < 1)
         raiserror('Result quantity must be more than zero.',15,0);
      
      if isnull(@oq_out,0) > isnull(@OrderCount,0)
         raiserror('Result quantity must be smaller or equal than ordered quantity.',15,0);
         
      declare @alreadyCreated int
      select @alreadyCreated = SUM(isnull(A.PREP_RESULT,0)) 
        from PR_OPERATION A 
       where A.DEVICEID = @checkDevID 
         and A.ORDERID = @orderID 
         and A.REVOPERID = @DoneRevOper
         and A.S_S in (1000013,1000019)

      if isnull(@alreadyCreated,0) > isnull(@OrderCount,0)
         raiserror('Result quantity must be smaller or equal than ordered quantity.',15,0);

      declare @NeedCreate int 
      set @NeedCreate = isnull(@OrderCount,0) - ISNULL(@alreadyCreated,0)
      if (@NeedCreate > 0)
      begin
    
         insert into PR_OPERATION (GID,S_S,ORDERID,DEVICEID,OPERTYPEID,S_CR,S_CDT,REVOPERID,OPLEVEL,Q_IN,Q_PARENT)
         select newid(),1000032,A.ORDERID,A.DEVICEID,A.OPERTYPEID,A.S_MR,@now,A.REVOPERID,A.OPLEVEL,@NeedCreate,@DoneOperID
         from PR_OPERATION A 
         where A.ID = @DoneOperID
        
         set @BlockCompl = 1
    
      end
      
    end
    
    if (@DoneOperState = 1000079) /* device failed */
    begin
      update PR_DEVICE set S_S = 1000078 /* production failed */, FAILED_DT = @now where ID = @checkDevID 
      delete from PR_OPERATION where DEVICEID = @checkDevID and ORDERID = @orderID and S_S = 1000032/*pending*/
      set nocount off
      return
    end
    
    if (@DoneOperState = 1000018) and (@specialType = 1)
    begin
      raiserror('Cannot set failure for troubleshooting operation.[L=pr_cannot_set_trouble',15,0);
      set nocount off
      return
    end
    if (@DoneOperState = 1000019) and (@specialType = 1)
    begin    
      raiserror('Cannot set complete with errors for troubleshooting operation.[L=pr_cannot_set_trouble',15,0);
      set nocount off
      return
    end
      
    if @DoneOperState = 1000018  /*failure*/
    begin
        if @repReasonEmtpy = 1
        begin
          raiserror('Please set failure description.[L=pr_set_failure_desc',15,0);      
          set nocount off
          return
        end
        update PR_OPERATION set REPORTEDERRORUSER = @userID where ID = @DoneOperID 
    end    
      
    if (@specialType = 1) and (@DoneOperState in (1000013,1000019))  /* завершен troubleshooting*/
    begin
      if @FreeRepair = 1
      begin
      
          goto ExitLabel
      
      end
    
      if @ReRunAll = 1 and @orderType = 0
      begin
      
          update PR_OPERATION set S_S = 1000023 /*canceled*/ 
          where DEVICEID = @DeviceID and ORDERID = @orderID and ISNULL(OPLEVEL,0) = @DoneLevel and ID <> @DoneOperID
          
          /*сменить статус ранее установленных компонент на uninstalled*/
          exec PR_CANCEL_INSTALLATION @DeviceID, @orderID
      
          insert into PR_OPERATION (GID,S_S,ORDERID,DEVICEID,OPERTYPEID,S_CDT,REVOPERID,OPLEVEL,TC_ACTION,TC_MINUTE,OPERGR)
          select newid(),1000032,@orderID,@DeviceID,A.OPERID,@now,A.ID,@DoneOperID,A.TC_ACTION,A.TC_MINUTE,A.SCHEME_GROUP
          from PR_MAP_OPER A with (nolock)
          left join PR_MAP_FLOW B with (nolock) on B.OP_TO = A.ID
          where A.MAPID = @MapID
            and (B.ID is null or B.OP_FROM is null)
            and not exists (select B.ID from PR_OPERATION B with (nolock) 
                             where B.DEVICEID = @DeviceID 
                               and B.ORDERID = @OrdID 
                               and B.OPLEVEL = @DoneOperID
                               and B.S_S <> 1000023 )
          
          goto ExitLabel
          
      end
      
    
      /*если в TODO нет незавершенных операций заново создать операцию с 
      которой пошли на troubleshooting (если производственный приказ)
      иначе - следующую по TODO
      */
      update PR_OPERATION_TODO set DONEID = null 
       where OPERID = @DoneOperID
         and not exists (select C.ID from PR_OPERATION C where C.DEVICEID = @DeviceID and C.ID = PR_OPERATION_TODO.DONEID)
         
      if not exists (select D.ID from PR_OPERATION_TODO D where D.OPERID = @DoneOperID and D.DONEID is null)
      begin
      
         if (@orderType = 0) and (@parentOper is not null)
         begin
            /*возврат в производство*/
            insert into PR_OPERATION (GID,S_S,ORDERID,DEVICEID,OPERTYPEID,S_CDT,REVOPERID,RETURNAFTERTROUBLEID,OPLEVEL,OPERGR,USERINPROGRESS)
            select newid(),1000032,@OrdID,@DeviceID,A.OPERTYPEID,@now,A.REVOPERID,@DoneOperID,A.OPLEVEL,A.OPERGR
                  ,case isnull(SG.VISTYPE,0) when 0 then null else A.REPORTEDERRORUSER end
            from PR_OPERATION A 
            left join PR_OPERATIONS S on S.ID = A.OPERTYPEID
            left join PR_OPERATIONS_GR SG on SG.ID = S.OPERGRID
            where A.ID = @parentOper
              and not exists (select B.ID from PR_OPERATION B 
                               where B.DEVICEID = @DeviceID 
                                 and B.RETURNAFTERTROUBLEID = @DoneOperID
                                 and B.S_S <> 1000023)  ;
                                 
            update PR_OPERATION set TROUBLEEXIT = 1 where ID = @parentOper;
                                 
         end
         else if (@orderType = 0) and (@parentOper is null) /* заложен в карте */
         begin  
            goto BackLabel
         end
         
         if (@orderType = 1) /*service order*/
         begin
            
            declare @haveUnclosed int
            select  @haveUnclosed = COUNT(*) from PR_OPERATION C 
             where C.DEVICEID = @DeviceID 
               and C.PARENTID = @DoneOperID
               and C.S_S in (1000031,1000032,1000033) /*in progress,pednig,postponed*/

         
            if ISNULL(@haveUnclosed,0) = 0
            begin
				update PR_DEVICE set S_S = 1000039/*Service Completed*/,SCOMPLETED_DT = @now where ID = @DeviceID
	            
				update PR_PRORDER set S_S = 1000036/*serv completed*/ 
				 where ID = @orderID 
				   and not exists (select B.ID from PR_DEVICE B 
									where B.ID in (select H.DEVICEID from PR_PRORDER_SERVICE H where H.ORDERID = PR_PRORDER.ID)
									  and B.S_S in (1000011) /*02.05.14 не осталось в статусе in service*/
								   )   
            end
         end
      end
      else
      begin
         declare @nextord int
         select @nextord = MIN(A.ORDERPOS) from PR_OPERATION_TODO A with (nolock)
         where A.OPERID = @DoneOperID
           and A.DONEID is null

         insert into PR_OPERATION (GID,S_S,ORDERID,DEVICEID,OPERTYPEID,S_CDT,S_CR,PARENTID,TODOTEXT,TODOID,USERINPROGRESS)
         select newid(),1000032,@orderID,@DeviceID,A.OPERATIONID,@now,@userID,@DoneOperID,A.TODO,A.ID
           ,(select top 1 U.ID from DEF_USERS U where U.EMPLOYEEID = A.EMPLOYEEID)
         from PR_OPERATION_TODO A 
         where A.OPERID = @DoneOperID 
           and A.ORDERPOS = @nextord
           and not exists (select B.ID from PR_OPERATION B 
                            where B.DEVICEID = @DeviceID 
                              and B.PARENTID = @DoneOperID 
                              and B.TODOID = A.ID
                              and B.S_S <> 1000023)            

         if (@nextord is not null and @orderType = 1) /*service order*/
         begin
           update PR_DEVICE set S_S = 1000011/*In Service*/,SCOMPLETED_DT = null where ID = @DeviceID and S_S = 1000039/*Service Completed*/
           update PR_PRORDER set S_S = 1000035/*In Progress*/ where ID = @orderID and S_S = 1000036/*Completed*/ 
         end

      end
      
      set nocount off
      return
    end
    
    if @parentOper is not null /*операция по troubleshooting */
    begin
        if (@DoneOperState in (1000013,1000019))
        begin
          if (select isnull(GG.FREETR,0) from PR_OPERATION GG where GG.ID = @parentOper) = 1
          begin
             goto ExitLabel
          end
        
          update PR_OPERATION_TODO set DONEID = @DoneOperID where OPERID = @parentOper and ID = @todoId 
          
          if @specialType = 8 /*disassembly and recycling*/
          begin
            update PR_DEVICE set S_S = 1000078 /* production failed */, FAILED_DT = @now where ID = @checkDevID 
            delete from PR_OPERATION where DEVICEID = @checkDevID and ORDERID = @orderID and S_S = 1000032/*pending*/
            set nocount off
            return
          end
          
          declare @nextord2 int
          select @nextord2 = MIN(A.ORDERPOS) from PR_OPERATION_TODO A 
          where A.OPERID = @parentOper
            and A.DONEID is null

          if @nextord2 is not null
          begin
             insert into PR_OPERATION (GID,S_S,ORDERID,DEVICEID,OPERTYPEID,S_CDT,S_CR,PARENTID,TODOID,TODOTEXT,USERINPROGRESS)
             select newid(),1000032,@orderID,@DeviceID,A.OPERATIONID,@now,@userID,@parentOper,A.ID,A.TODO
               ,(select top 1 U.ID from DEF_USERS U where U.EMPLOYEEID = A.EMPLOYEEID)
             from PR_OPERATION_TODO A 
             where A.OPERID = @parentOper 
               and A.ORDERPOS = @nextord2
               and not exists (select B.ID from PR_OPERATION B 
                               where B.DEVICEID = @DeviceID 
                                 and B.PARENTID = @parentOper 
                                 and B.TODOID = A.ID
                                 and B.S_S <> 1000023) 
                                 
			 if (@orderType = 1) /*service order*/
			 begin
			   update PR_DEVICE set S_S = 1000011/*In Service*/,SCOMPLETED_DT = null where ID = @DeviceID and S_S = 1000039/*Service Completed*/
			   update PR_PRORDER set S_S = 1000035/*In Progress*/ where ID = @orderID and S_S = 1000036/*Completed*/ 
			 end
          end
          else
          begin
            declare @returnTr int
            declare @badOperID int /* операция с которой уходили в траблешутинг */
            select @returnTr = isnull(A.RETURNTR,0),@badOperID = A.PARENTID from PR_OPERATION A where A.ID = @parentOper
            if @returnTr = 1
            begin
              update PR_OPERATION set S_S = 1000032, COMPLETED_DT = null where ID = @parentOper
            end
            else
            begin
              if @orderType = 0
              begin
                /*возврат в производство*/
                if @badOperID is not null
                begin
					insert into PR_OPERATION (GID,S_S,ORDERID,DEVICEID,OPERTYPEID,S_CDT,REVOPERID,RETURNAFTERTROUBLEID,OPLEVEL,OPERGR,USERINPROGRESS)
					select newid(),1000032,@OrdID,@DeviceID,A.OPERTYPEID,@now,A.REVOPERID,@parentOper,A.OPLEVEL,A.OPERGR
                           ,case isnull(SG.VISTYPE,0) when 0 then null else A.REPORTEDERRORUSER end
					from PR_OPERATION A 
                    left join PR_OPERATIONS S on S.ID = A.OPERTYPEID
                    left join PR_OPERATIONS_GR SG on SG.ID = S.OPERGRID
					where A.ID = @badOperID           
					  and not exists (select B.ID from PR_OPERATION B 
									   where B.DEVICEID = @DeviceID 
										and B.RETURNAFTERTROUBLEID = @parentOper
										and B.S_S <> 1000023) ;
										
                    update PR_OPERATION set TROUBLEEXIT = 1 where ID = @badOperID;										
                end
                else
                begin
                    /* вариант, когда troubleshooting был заложен в карте */
                    
					select @DoneOperID = A.ID  /* подмена на параметры самого траблшутинга - как будто завершается он*/
						  ,@DoneOperType = A.OPERTYPEID
						  ,@DoneRevOper = A.REVOPERID
						  ,@lastUserInProgress = ISNULL(A.LASTUSERINPROGRESS,A.USERINPROGRESS)
						  ,@DoneLevel = ISNULL(A.OPLEVEL,0)
					from PR_OPERATION A with (nolock)
					where A.ID = @parentOper;

                    goto BackLabel
                  
                end
              end
              if (@orderType = 1) /*service order*/
              begin

                update PR_DEVICE set S_S = 1000039/*Service Completed*/,SCOMPLETED_DT = @now  where ID = @DeviceID
                
				update PR_PRORDER set S_S = 1000036/*serv comleted*/ 
				 where ID = @orderID 
				   and not exists (select B.ID from PR_DEVICE B 
				                    where B.ID in (select H.DEVICEID from PR_PRORDER_SERVICE H where H.ORDERID = PR_PRORDER.ID)
				                      and B.S_S in (1000011) /*02.05.14 не осталось в статусе in service*/
				                   )   
              end
              
            end
          end
         
        end 
        
        if (@DoneOperState in (1000018))
        begin
           if @repReasonEmtpy = 1
           begin
             raiserror('Please set failure description.[L=pr_set_failure_desc',15,0);
             set nocount off
             return
           end
             
           update PR_OPERATION_TODO set DONEID = @DoneOperID where OPERID = @parentOper and ID = @todoId                 
           
           /*новый FAR*/
           
           declare @fr2ID int
           set @fr2ID = null
           
           if (@orderType = 0) /*производ. заказ*/
           begin
			   insert into FC_REPORT (GID,S_S,S_CR,S_CDT,MODELID,SN,DEVICEID,FAILUREDESCRIPTION,FAILUREDATE,FROMDEPID,INT_EXT,REQUESTEDACTIONS,QUANTITY,TOTROUBLEID)
			   select NEWID(),1,A.S_MR,@now,B.MODELID,B.SN,B.ID,A.REPAIRREASON,cast (@now as DATE),OG.DEPARTMENTID,3,2,1,@parentOper
			   from PR_OPERATION A 
			   left join PR_DEVICE B on B.ID = A.DEVICEID
			   left join PR_OPERATIONS O on O.ID = A.OPERTYPEID
			   left join PR_OPERATIONS_GR OG on OG.ID = O.OPERGRID
			   where A.ID = @DoneOperID;
			   set @fr2ID = @@IDENTITY
           end

           update PR_OPERATION set S_S = 1000038, COMPLETED_DT = @now, FAILUREREPORTID = @fr2ID where ID = @DoneOperID
           
           /*возобновление troubleshooting*/
           update PR_OPERATION set S_S = 1000032, COMPLETED_DT = null where ID = @parentOper
          
           
        end
        
        set nocount off
        return 
    end 
       
    
       
    if @DoneOperState = 1000038  /*send to repair*/
    begin

      if @specialType = 1
        raiserror('Cannot set failure for troubleshooting operation.[L=pr_cannot_set_trouble',15,0);
      
      if @repReasonEmtpy = 1
        raiserror('Please set failure description.[L=pr_set_failure_desc',15,0);
        

      declare @exID int
      select @exID = B.ID from PR_OPERATION B with (nolock)
      where B.DEVICEID = @DeviceID and B.ORDERID = @OrdID and B.PARENTID = @DoneOperState;
           
      if @exID is null /*нет troubleshooting по этой проблемной операции*/
      begin
      
          declare @TroubleTypeID int
          select top 1 @TroubleTypeID = A.ID 
            from PR_OPERATIONS A with (nolock)
            where A.MTID = @ModTypeID and A.OPERTYPE = 1

          if @TroubleTypeID is null
          begin
            declare @mtName nvarchar(200)
            select @mtName = NAME from PR_MODELTYPE with (nolock) where ID = @ModTypeID;
            declare @errMsg nvarchar(250)
            set @errMsg = 'Troubleshooting operation not defined in model type "'+@mtName+'".'; 
            raiserror(@errMsg,15,0); 
            set nocount off
            return
          end
          
          declare @frID int
          declare @trID int

          if ISNULL(@frID0,0) < 1
          begin
	          
			  insert into FC_REPORT (GID,S_S,S_CR,S_CDT,MODELID,SN,DEVICEID,FAILUREDESCRIPTION,FAILUREDATE,FROMDEPID,INT_EXT,REQUESTEDACTIONS,QUANTITY)
			  select NEWID(),1,A.S_MR,@now,B.MODELID,B.SN,B.ID,A.REPAIRREASON,cast (@now as DATE),OG.DEPARTMENTID,3,2,1
			  from PR_OPERATION A 
			  left join PR_DEVICE B on B.ID = A.DEVICEID
			  left join PR_OPERATIONS O on O.ID = A.OPERTYPEID
			  left join PR_OPERATIONS_GR OG on OG.ID = O.OPERGRID
			  where A.ID = @DoneOperID;
	          
			  set @frID = @@IDENTITY
          
          end
          else
            set @frID = @frID0
          
          
          insert into PR_OPERATION (GID,S_S,ORDERID,DEVICEID,OPERTYPEID,S_CR,S_CDT,PARENTID,TODOTEXT,SPECIALTYPE,FAILUREREPORTID)
          select newid(),1000032,@OrdID,@DeviceID,@TroubleTypeID,A.S_MR,@now,A.ID,A.REPAIRREASON,1,@frID
          from PR_OPERATION A where A.ID = @DoneOperID;
          
          set @trID = @@IDENTITY
          
          update FC_REPORT set TOTROUBLEID = @trID where ID = @frID
          
      end     
      
      update PR_OPERATION set COMPLETED_DT = @now where ID = @DoneOperID 
  
    end
    
    BackLabel: 
    
    if @DoneOperState in (1000013,1000019)  /*Complete , Complete with Err*/
    begin

         if exists (select A.ID 
                      from PR_AUTOPOSTPONE A 
                     where A.DEVICEID = @DeviceID
                       and A.MAPOPERID = @DoneRevOper
                       and A.S_S = 1)
         begin
           update PR_DEVICE set S_S = 1000069 /*postponed*/ where ID = @DeviceID
           update PR_AUTOPOSTPONE set S_S = 1000126	/*Processed*/, OPERID = @DoneOperID where DEVICEID = @DeviceID and MAPOPERID = @DoneRevOper and S_S = 1
           set nocount off
           return
         end

         declare @AllDone int
         set @AllDone = 0
         
         if @BlockCompl = 0
           set @AllDone = dbo.PR_ALL_OP_DONE(@MapID,@DeviceID,@OrdID,@DoneLevel)

         if (@AllDone <> 1)
            exec PR_CREATE_NEXT2 @MapID,@DoneRevOper,@DoneLevel,@DoneOperID,@OrdID,@DeviceID,@lastUserInProgress,@userID

         if @BlockCompl = 0
           if @AllDone <> 1 /* PR_CREATE_NEXT может создать пропуск последней операции - и будет необходимость завершения */
             set @AllDone = dbo.PR_ALL_OP_DONE(@MapID,@DeviceID,@OrdID,@DoneLevel)

         
         if (@AllDone = 1)  /* все готово */
         begin
         
           if (@orderType = 1) /*service order*/
           begin

             update PR_DEVICE set S_S = 1000039/*Service Completed*/,SCOMPLETED_DT = @now  where ID = @DeviceID and S_S = 1000011 /*in serv*/
            
	  		 update PR_PRORDER set S_S = 1000036/*serv comleted*/ 
	 		  where ID = @orderID 
			    and not exists (select B.ID from PR_DEVICE B 
			                    where B.ID in (select H.DEVICEID from PR_PRORDER_SERVICE H where H.ORDERID = PR_PRORDER.ID)
			                      and B.S_S in (1000011) /*02.05.14 не осталось в статусе in service*/
			                   )   
           end
           else
           begin
			   update PR_DEVICE 
				  set S_S = 1000022, COMPLETED_DT = @now, S_MR = @userID, S_MDT = @now , PRRESTTIME = 0
				where ID = @DeviceID and S_S not in (1000022,1000010) 
			   update PR_PRORDER 
				  set S_S = 1000021, COMPLETED_DT = @now , S_MR = @userID, S_MDT = @now 
				where ID = @OrdID 
				  and not exists (select B.ID from PR_DEVICE B where B.ORDERID = PR_PRORDER.ID and B.S_S <> 1000078 and B.COMPLETED_DT is null)
				  
			   update PR_PRORDER set S_S = 1000113 where ID = @OrdID and S_S = 1000021 and UPPER(NN) like '%TEST%'  
           end
           
         end
         else 
         begin
           declare @restProdTime decimal(10,1)
           set @restProdTime = dbo.PR_DEVICE_REST_PROD_TIME(@DeviceID)
           update PR_DEVICE set PRRESTTIME = @restProdTime where ID = @DeviceID and isnull(PRRESTTIME,0) <> @restProdTime
         end
  
    end  
        
    ExitLabel:    
    
  end 
SET nocount off