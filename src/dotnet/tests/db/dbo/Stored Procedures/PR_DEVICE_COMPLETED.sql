
CREATE procedure [dbo].[PR_DEVICE_COMPLETED] 
  @DeviceID int, @OrdID int ,@now datetime ,@userID int, @aOperationID int = null /* KB4213 (KB2742) для правильной фильтрации необходимых подписок */
as 
set nocount on

  declare @ddd datetime = getdate(),
    @orderType int,
    @oldOrderStatus int,
    @updatedRowCount int;

  select @orderType = ISNULL([ORDERTYPE], 0), @oldOrderStatus = [S_S]
  from [dbo].[PR_PRORDER] (nolock)
  where [ID] = @OrdID
  
  if (@orderType in (1,2)) /*service order*/
  begin

     update PR_DEVICE set S_S = 1000039/*Service Completed*/,SCOMPLETED_DT = @now  
     where ID = @DeviceID 
       and S_S = 1000011 /*in serv*/
       and not exists (select D.ID /*13.07.15 нет другого открытого сервисного заказа по изделию*/
                         from PR_PRORDER_SERVICE D
                         left join PR_PRORDER F on F.ID = D.ORDERID
                        where D.DEVICEID = PR_DEVICE.ID
                          and D.ORDERID <> @OrdID
                          and F.COMPLETED_DT is null
                          and F.S_S <> 1000036 /*compl*/
                          and F.S_S > 1
                        )
                        
     update PR_DEVICE set S_S = 1000022/*Production Completed*/,COMPLETED_DT = @now  
     where ID = @DeviceID 
       and S_S = 1000008 /*in product*/
       and not exists (select D.ID /*13.07.15 нет другого открытого сервисного заказа по изделию*/
                         from PR_PRORDER_SERVICE D
                         left join PR_PRORDER F on F.ID = D.ORDERID
                        where D.DEVICEID = PR_DEVICE.ID
                          and D.ORDERID <> @OrdID
                          and F.COMPLETED_DT is null
                        )
         
     update PR_PRORDER_SERVICE set SCOMPLETED_DT = @now where ORDERID = @OrdID and DEVICEID = @DeviceID
    
     update PR_PRORDER set S_S = 1000036/*serv comleted*/ ,COMPLETED_DT = @now , S_MR = @userID, S_MDT = @now 
	   where ID = @OrdID
	     and not exists (select B.ID from PR_DEVICE B 
	                     where B.ID in (select H.DEVICEID from PR_PRORDER_SERVICE H where H.ORDERID = PR_PRORDER.ID)
	                       and B.S_S in (1000011) /*02.05.14 не осталось в статусе in service*/ )

     set @updatedRowCount = @@ROWCOUNT;
  
     /*KB2356>*/
     update PR_PRORDER set S_S = 1000036/*serv comleted*/ ,COMPLETED_DT = @now , S_MR = @userID, S_MDT = @now 
      where PR_PRORDER.ID = @OrdID
        and PR_PRORDER.S_S = 1000035 /*in service*/
        and not exists (select H.DEVICEID from PR_PRORDER_SERVICE H where H.ORDERID = PR_PRORDER.ID and H.SCOMPLETED_DT is null)  
        and not exists (select H.ID from PR_OPERATION H with (nolock) where H.ORDERID = PR_PRORDER.ID and H.COMPLETED_DT is null and H.S_S <> 1000023)                         
     /*<KB2356*/

     set @updatedRowCount = @updatedRowCount + @@ROWCOUNT;

     -- Azure#39: write PR_PRORDER changes to log, run entity row trigger.
     if @updatedRowCount > 0
     begin
         insert into [dbo].[DEF_LOG] ([DD], [LEV], [CAPTION], [S_USERID], [EV_TYPE], [DOCOID], [DOCID], [EV_TEXT])
         values (getdate(), 1, 'Device Completed', @UserID, 20000, 1000062 /* pr_service_order */, @ordID, concat('PR_DEVICE_COMPLETED, S_S_OLD=', @oldOrderStatus, ', S_S_NEW=', 1000036 /*serv comleted*/))

         exec [dbo].[MSG_PRORDER_STATE_CHANGED] @ordID, @UserID, @oldOrderStatus, 1000036
     end

	 --DEVOPS:6195
        declare @SettedDeviceState int = (select top 1 S_S from PR_DEVICE where ID = @DeviceID)
        if(@SettedDeviceState = 1000039/*Service Completed*/)
        begin
              exec MSG_PREPARE_FILENOTIFICATION @DeviceID, @userID, @aOperationID 
        end


  
  end
  else
  begin
	   update PR_DEVICE 
		  set S_S = 1000022, COMPLETED_DT = @now, S_MR = @userID, S_MDT = @now , PRRESTTIME = 0, STOREDREADINESS = 100
		where ID = @DeviceID and S_S  in (1000008/*in production*/,1000069/*postponed*/,1000029/*pend prod*/) 
		   /*not in (1000022,1000010) */
		
		update PR_DEVICE 
		   set S_S = 1000010 /*shipped*/
		      ,SHIPPED_DT = @ddd
		      ,SHIPPED_FIRSTTIME = isnull(SHIPPED_FIRSTTIME,@ddd)
		 where ID = @DeviceID 
		   and S_S = 1000022
		   and SHIPPEDBEFORECMPL_DT is not null
		
		/*KB4637*/   
	    declare @nnState int
	    declare @allowInstall int
	    select @nnState = A.S_S
	          ,@allowInstall = isnull(C.ALLOWUSEINPRODUCTION,0)
	      from PR_DEVICE A 
	      left join PR_MODELS B with(nolock) on B.ID = A.MODELID
	      left join PR_MODELTYPE C with(nolock) on C.ID = B.TYPEID
	      where A.ID = @DeviceID
	      
		  if @allowInstall = 1 and @nnState = 1000022 and dbo.PR_DEVICE_IN_DEVICE(@DeviceID,0) is not null
		  begin
				update PR_DEVICE set S_S = 1000077 /*installed*/
				where ID = @DeviceID 
				  and S_S = 1000022		  
		  end
		
		
      update PR_PRORDER 
      set
        S_S = case when (UPPER([NN]) like 'TEST-%' or isnull([TESTORDER], 0) = 1) then 1000113 /* Test Production Completed */
                   else 1000021 /* Completed */ end,
        COMPLETED_DT = @now,
        S_MR = @userID,
        S_MDT = @now 
      where ID = @OrdID 
        and not exists (select B.ID from PR_DEVICE B where B.ORDERID = PR_PRORDER.ID and B.S_S <> 1000078 /*failed*/ and B.S_S <> 1000101 /*canceled*/ and B.COMPLETED_DT is null)

      set @updatedRowCount = @@ROWCOUNT;

      declare @newOrderStatus int = (select top 1 S_S from [dbo].[PR_PRORDER] (nolock) where [ID] = @OrdID);

      -- Azure#39: write PR_PRORDER changes to log, run entity row trigger.
      if @updatedRowCount > 0
      begin
          insert into [dbo].[DEF_LOG] ([DD], [LEV], [CAPTION], [S_USERID], [EV_TYPE], [DOCOID], [DOCID], [EV_TEXT])
          values (getdate(), 1, 'Device Completed', @UserID, 20000, 1000037 /* pr_production_order */, @ordID, concat('PR_DEVICE_COMPLETED, S_S_OLD=', @oldOrderStatus, ', S_S_NEW=', @newOrderStatus));

          exec [dbo].[MSG_PRORDER_STATE_CHANGED] @ordID, @UserID, @oldOrderStatus, @newOrderStatus
      end

	   exec PR_UPDATE_ORDERS @DeviceID, null, null, null
	   
	   exec MSG_PREPARE_FILENOTIFICATION @DeviceID, @userID

     exec PR_UPDATE_COMPONENT_TEST @userID, @DeviceID
	   
  end
  
  exec PR_DEVICE_UPD_STAT @DeviceID, @OrdID
  

set nocount off