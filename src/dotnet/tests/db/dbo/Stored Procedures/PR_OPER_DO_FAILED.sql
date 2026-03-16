CREATE procedure [dbo].[PR_OPER_DO_FAILED] @OperID int, @UserID int
as 
SET nocount on

    declare @now datetime
    set @now = getdate()
    
    declare @failed int
        /*  ! чтобы отличать операции с таким контролом от операций без:   
            0 - операция без контрола - на сервере ничего вообще не делать,  
            1 - зафейлить изделие, создать FAR по параетрам, прописать в PR_OPERATION.FAILUREREPORT
            2 - не фейлить изделие (!и убрать FAR если ранее было зафейлено)
        */
            
    declare @farID int
    declare @failedxml nvarchar(max)
    declare @deviceState int
    declare @deviceMTID int
    declare @MTname nvarchar(300)
    declare @deviceID int
    declare @orderID int
    declare @q_in_nullable int
    
    select @failed = isnull(A.ITEMFAILED,0)
          ,@farID = case when R.ID is null then null else A.FAILUREREPORTID end
          ,@failedxml = A.FAILEDXML
          ,@deviceID = A.DEVICEID
          ,@orderID = A.ORDERID
          ,@q_in_nullable = A.Q_IN
    from PR_OPERATION A with (nolock)
    left join PR_DEVICE B with (nolock) on B.ID = A.DEVICEID
    left join PR_MODELS C with (nolock) on C.ID = B.MODELID
    left join FC_REPORT R on A.FAILUREREPORTID=R.ID
    where A.ID = @OperID
    
    
    if @failed = 0
    begin
    
       SET nocount off
       return
       
    end
    else if @failed = 1
    begin
    
    
         select @deviceState = B.S_S
               ,@deviceMTID = C.TYPEID
               ,@MTname = D.NAME
         from PR_OPERATION A with (nolock)
         left join PR_DEVICE B with (nolock) on B.ID = A.DEVICEID
         left join PR_MODELS C with (nolock) on C.ID = B.MODELID
         left join PR_MODELTYPE D with (nolock) on D.ID = C.TYPEID
         where A.ID = @OperID

         declare @depID int

         select @depID = E.DEPID
         from DEF_USERS U
            join COM_EMPLOYEE E on U.EMPLOYEEID=E.ID
            where U.ID=@UserID

         declare @xml xml = @failedxml
         declare @failureDescription nvarchar(max) = @xml.value('(/Failure/FailureDescription)[1]', 'nvarchar(max)')
         declare @reqActions int = @xml.value('(/Failure/RequestedActions)[1]', 'int')

         declare @dateOfReceiptStr nvarchar(100) = @xml.value('(/Failure/Analysis/DateOfReceipt)[1]', 'nvarchar(100)')       
         declare @dateOfReceipt DATE
         set @dateOfReceipt = CAST(@dateOfReceiptStr as DATE)

         declare @resultsOfIncomingInspection nvarchar(100) = @xml.value('(/Failure/Analysis/ResultsOfIncomingInspection)[1]', 'nvarchar(100)')

         declare @correctiveActions nvarchar(1000) = @xml.value('(/Failure/Analysis/CorrectiveActions)[1]', 'nvarchar(1000)')

         declare @failureDate date = CAST(@xml.value('(/Failure/FailureDate)[1]', 'nvarchar(100)') as date)  
         declare @warrantyItem int = @xml.value('(/Failure/WarrantyItem)[1]', 'int')
         declare @failureLocation int = @xml.value('(/Failure/FailureLocation)[1]', 'int')
         declare @serviceNumberType int = @xml.value('(/Failure/ServiceNumberType)[1]', 'int')
         declare @serviceNumber nvarchar(20) = @xml.value('(/Failure/ServiceNumber)[1]', 'nvarchar(20)')
         declare @fromCustomerGUID nvarchar(100) = @xml.value('(/Failure/FromCustomer)[1]', 'nvarchar(100)')
         declare @dateSentToRepair date = CAST(@xml.value('(/Failure/DateSentToRepair)[1]', 'nvarchar(100)') as date)  

         declare @fromCustomer int
         select @fromCustomer = C.ID
            from COM_CUSTOMER C
            where GID=@fromCustomerGUID
			         
         if @farID is null
         begin       
             insert into FC_REPORT (GID
                                    ,S_CR
                                    ,S_CDT
                                    ,S_S
                                    ,MODELID
                                    ,SN
                                    ,DEVICEID
                                    ,INT_EXT
                                    ,REQUESTEDACTIONS
                                    ,CORRECTIVE_ACTION
                                    ,PARENTID
                                    ,FAILUREDATE
                                    ,FAILUREDESCRIPTION
                                    ,USER3DT
                                    ,RESULT_INC_INSP
                                    ,FROMDEPID
                                    ,WARRANTY
                                    ,RMA_TYPE
                                    ,RMA
                                    ,FROMCUSTOMERID
                                    ,USER1DT)
             select newid()
                   ,@UserID
                   ,@now
                   ,1
                   ,B.ID as MODELID
                   ,A.SN
                   ,A.ID as DEVICEID
                   ,case when @failureLocation is not null then @failureLocation 
						 when @failureLocation is null and D.ORDERTYPE=0 then 3 
						 else 1 
							end as INT_EXT
                   --,@failureLocation
                   ,isnull(@reqActions,2) as REQUESTEDACTIONS /*analysis and repair*/
                   ,@correctiveActions
                   ,dbo.FC_FIND_PARENT_FAR(O.ORDERID,O.DEVICEID) as PARENTFARID 
                   --,@now
                   ,isnull(@failureDate,@now)
                   ,@failureDescription
                   ,@dateOfReceipt
                   ,@resultsOfIncomingInspection
                   ,@depID
                   ,@warrantyItem
                   ,@serviceNumberType
                   ,@serviceNumber
                   ,@fromCustomer
                   ,@dateSentToRepair
                from PR_OPERATION O with (nolock)
                left join PR_DEVICE A with (nolock) on A.ID = O.DEVICEID
                left join PR_MODELS B with (nolock) on B.ID = A.MODELID
                left join PR_PRORDER D with (nolock) on D.ID = O.ORDERID
                where O.ID = @OperID
                
              select @farID = @@identity    
              
              update PR_OPERATION set FAILUREREPORTID = @farID where ID = @OperID
              
          end
          else
          begin
            
            update FC_REPORT set S_S = 1
                        ,FAILUREDESCRIPTION = isnull(@failureDescription,FAILUREDESCRIPTION)
                        ,USER3DT=@dateOfReceipt
                        ,RESULT_INC_INSP=@resultsOfIncomingInspection
                        ,CORRECTIVE_ACTION=@correctiveActions
                        ,FROMDEPID=case when F.FROMDEPID is null then @depID else F.FROMDEPID end --User's Department if null
                        ,FAILUREDATE=isnull(@failureDate,FAILUREDATE)
                        ,WARRANTY=ISNULL(@warrantyItem,WARRANTY)
                        ,INT_EXT=ISNULL(@failureLocation,INT_EXT)
                        ,RMA_TYPE=ISNULL(@serviceNumberType,RMA_TYPE)
                        ,RMA=ISNULL(@serviceNumber,RMA)
                        ,FROMCUSTOMERID=isnull(@fromCustomer,FROMCUSTOMERID)
                        ,USER1DT=ISNULL(@dateSentToRepair,USER1DT)
            from FC_REPORT F
                where ID = @farID
            
          end
          
       
          declare @codes table (CODEID int)
          insert into @codes (CODEID)
          select A.Code.value('.', 'int') 
          from @xml.nodes('/Failure/FailureCodes/Code') A (Code)

          declare @errCode int
          select top 1 @errCode = A.CODEID
          from @codes A 
          where not exists (select B.ID from FC_FAILURECODES B with (nolock) where B.ID = A.CODEID and B.MTID = @deviceMTID)
          
          if @errCode is not null
          begin
            
            declare @err nvarchar(max) = '#EItem Failed Control: Model type "'+isnull(@MTname,'')+'" does not contains failure code "'+ltrim(rtrim(str(@errCode)))+'".'
            raiserror(@err,16,0)
            SET nocount off
            return
          
          end
       
          insert into FC_REPORT_CODES (GID,S_CR,S_CDT,VNESHID,REPCODEID)
          select newid(),@UserID,@now,@farID,A.CODEID
          from @codes A
          where not exists (select B.ID from FC_REPORT_CODES B where B.VNESHID = @farID and B.REPCODEID = A.CODEID)
          
          
        declare @aCodes table (FCODE int, ACODE int, MREASON int)
        insert into @aCodes (FCODE, ACODE, MREASON)
        select Code.value('@FCode', 'int'), Code.value('@ACode', 'int'), Code.value('@MReason', 'int')
        from @xml.nodes('/Failure/Analysis/AnalysisCodes/Code') A (Code)


          select top 1 @errCode = A.ACODE
          from @aCodes A 
          where not exists (select B.ID from FC_FAILUREANALYSISCODES B with (nolock) where B.ID = A.ACODE and B.MTID = @deviceMTID)
          
          if @errCode is not null
          begin
            
            set @err = '#EItem Failed Control: Model type "'+isnull(@MTname,'')+'" does not contains failure analysis code "'+ltrim(rtrim(str(@errCode)))+'".'
            raiserror(@err,16,0)
            SET nocount off
            return
          
          end
       
          insert into FC_REPORT_ANALYSIS_CODES(GID,S_CR,S_CDT,VNESHID, FCODE, ANALYSISCODEID, INITI)
          select newid(),@UserID,@now,@farID,C.ID, A.ACODE, A.MREASON
          from @aCodes A 
            join FC_REPORT_CODES C on A.FCODE=C.REPCODEID AND C.VNESHID=@farID
          where 
            not exists (select B.ID from FC_REPORT_ANALYSIS_CODES B where B.VNESHID = @farID and B.FCODE = A.FCODE and B.ANALYSISCODEID=A.ACODE)

        declare @createItemFailedOperation nvarchar(1) = @xml.value('(/Failure/Analysis/CreateItemFailedOperation)[1]', 'nvarchar(1)')
        if @createItemFailedOperation='1'
        begin
            update PR_OPERATION set S_S = 1000079 /* device failed */ where ID = @OperID

            update PR_DEVICE set S_S = 1000078 /* production failed */, FAILED_DT = @now where ID = @deviceID 
            delete from PR_OPERATION where DEVICEID = @deviceID and ORDERID = @orderID and S_S = 1000032/*pending*/
      
            declare @ItemFailedTypeID int
            
            select top 1 @ItemFailedTypeID = A.ID 
                from PR_OPERATIONS A with (nolock)
                where A.MTID = @deviceMTID and A.OPERTYPE = 12
      
            if @ItemFailedTypeID > 0
            begin
                insert into PR_OPERATION (GID,S_S,ORDERID,DEVICEID,OPERTYPEID,S_CR,S_CDT,PARENTID,SPECIALTYPE,Q_IN)
                    select newid(),1000032,@orderID,@DeviceID,@ItemFailedTypeID,A.S_MR,@now,A.ID,12,@q_in_nullable
                    from PR_OPERATION A where A.ID = @OperID;      
            end  
        end
            
    end 
    else if @failed = 2
    begin
    
       if @farID is not null
       begin
          update PR_OPERATION set FAILUREREPORTID = null where ID = @OperID
          delete from FC_REPORT where ID = @farID
       end  
    
    end

SET nocount off