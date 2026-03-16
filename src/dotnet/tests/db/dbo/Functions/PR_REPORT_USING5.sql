CREATE function [dbo].[PR_REPORT_USING5](@aReportID int,@aDeviceID int,@OperationID int)
returns int as 
begin

-- v.5 берет заказчика из заказа от операции (нужно для сервисных заказов)
  
    declare @hasModelAccess bit = 0
    declare @hasCustomerAccess bit = 0
    declare @hasOptionsAccess bit = 0

    declare @ModelID int
    declare @RevID int
    declare @custID int
    declare @visibilityForCustomers int
    declare @visibilityForOptions int
    declare @orderDepID int
    declare @visibilityForDepID int

    declare @ret int = 0
  
    select @RevID = A.REVID
        ,@ModelID = A.MODELID 
        ,@custID = isnull(S.CUSTOMERID,O.CUSTOMERID)
        ,@orderDepID = O.DEPARTMENTID
    from PR_DEVICE A with (nolock) 
        left join PR_SUPPLY S with (nolock) on S.ID=A.SORDERID 
    left join PR_PRORDER O with (nolock) on O.ID = A.ORDERID
    where A.ID = @aDeviceID
    
    if @OperationID is not null
    begin
      declare @orderCustID int
      select @orderCustID = B.CUSTOMERID
      from PR_OPERATION A with (nolock)
      left join PR_PRORDER B with (nolock) on B.ID = A.ORDERID
      where A.ID = @OperationID 
        and B.ORDERTYPE = 1
      
      if @orderCustID is not null
         if @orderCustID <> isnull(@custID,0)
           set @custID = @orderCustID
    end

    select @visibilityForCustomers=ISNULL(R.VISIBILITY_FOR_CUSTOMERS,0)
         , @visibilityForOptions=ISNULL(R.VISIBILITY_FOR_OPTIONS,0)
         , @visibilityForDepID = R.USE_ONLYINDEP
      from PR_REPORTS R with (nolock) 
     where ID=@aReportID

    if @visibilityForDepID is not null  
    begin /*KB586*/
      if @visibilityForDepID <> @orderDepID 
        return 0
    end

    if not exists (select A.ID from PR_REPORTS_T A with (nolock) where A.VNESHID = @aReportID)
        set @hasModelAccess = 1
    else  
        if exists (select A.ID from PR_REPORTS_T A with (nolock) where A.VNESHID = @aReportID and A.REVID = @RevID)  
            set @hasModelAccess = 1
        else
            if exists (select A.ID from PR_REPORTS_T A with (nolock) 
                        where A.VNESHID = @aReportID 
                        and A.MODELID = @ModelID
                        and A.REVID is null                  
                        )
                set @hasModelAccess = 1  
            
    if @visibilityForCustomers=0 
        set @hasCustomerAccess = 1    
    else if not exists (select A.ID from PR_REPORTS_C A with (nolock) where A.VNESHID = @aReportID)
        set @hasCustomerAccess = 1    
    else  
    begin
        if @visibilityForCustomers=1
        begin
            if exists (select A.ID from PR_REPORTS_C A with (nolock)
                    join PR_REPORTS R on A.VNESHID=R.ID
                     where A.VNESHID = @aReportID and A.CUSTID = @custID)  
                set @hasCustomerAccess = 1
        end

        if @visibilityForCustomers=2
        begin
            if not exists (select A.ID from PR_REPORTS_C A with (nolock)
                    join PR_REPORTS R on A.VNESHID=R.ID
                     where A.VNESHID = @aReportID and A.CUSTID = @custID)  
                set @hasCustomerAccess = 1
        end
    end
            
    if @visibilityForOptions=0 
        set @hasOptionsAccess = 1    
    else if not exists (select A.ID from PR_REPORTS_O A with (nolock) where A.VNESHID = @aReportID)
        set @hasOptionsAccess = 1    
    else  
    begin
        if @visibilityForOptions=1
        begin
            if exists (select C.ID
                            from PR_REPORTS_O C 
                                join PR_DEVICE_OPT S on C.OPTIONID=S.OPTID
                                where S.DEVICEID=@aDeviceID and C.VNESHID = @aReportID)  
                set @hasOptionsAccess = 1
        end

        if @visibilityForOptions=2
        begin
            if not exists (select C.ID
                            from PR_REPORTS_O C 
                                join PR_DEVICE_OPT S on C.OPTIONID=S.OPTID
                                where S.DEVICEID=@aDeviceID and C.VNESHID = @aReportID)  
                set @hasOptionsAccess = 1
        end
    end
        
    if @hasModelAccess=1 and @hasCustomerAccess=1 and @hasOptionsAccess=1
        set @ret = 1
    else 
        set @ret = 0

    return @ret
end