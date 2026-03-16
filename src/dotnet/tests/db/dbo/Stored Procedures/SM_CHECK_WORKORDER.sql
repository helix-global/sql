CREATE procedure [dbo].[SM_CHECK_WORKORDER]
 @DocID int, @MethodOID int, @UserID int
as 
SET nocount on

declare @errMsg nvarchar(max)

declare @woState int
declare @ShDbeg datetime
declare @ShDend datetime

declare @scaseID int
declare @scaseCustomerID int
declare @scaseCustomer2ID int
declare @customerID int
declare @emplID int
declare @servOrdFromCase int
declare @servOrdFromWO int
declare @contactID int
declare @contactCustID int
declare @deviceID int
declare @deviceSN nvarchar(50)
declare @servOrdNN nvarchar(20)
declare @sumTime int
declare @sumTimeTasks int
declare @needWOnumber nvarchar(30)
declare @WOnumber nvarchar(30)

select @scaseID = A.SCASEID
      ,@woState = A.S_S
      ,@scaseCustomerID = B.CUSTID
      ,@scaseCustomer2ID = B.CUSTID_4SERVORD
      ,@ShDbeg = A.SH_DBEG
      ,@ShDend = A.SH_DEND
      ,@emplID = A.EMPLID
      ,@servOrdFromWO = A.SORDERID
      ,@servOrdFromCase = B.SERVORDID
      ,@contactID = A.CONTACTID
      ,@contactCustID = FF.CUSTOMERID
      ,@customerID = A.CUSTID
      ,@deviceID = A.DEVICEID
      ,@deviceSN = K.SN
      ,@servOrdNN = L.NN
      ,@sumTime = isnull(BB.SCHED_TIME_CONST,0) 
      ,@needWOnumber = dbo.SM_NEW_WO_NUMBER(null,A.SORDERID,A.ID)
      ,@WOnumber = A.NN
from SM_WORKORDER A
left join SM_SERVICECASE B with (nolock) on B.ID = A.SCASEID
left join COM_CUST_CONTACTS FF with (nolock) on FF.ID = A.CONTACTID
left join SM_EMAIL_BOXES BB with (nolock) on BB.DEPID = A.SDEPID
left join PR_DEVICE K with (nolock) on K.ID = A.DEVICEID
left join PR_PRORDER L with (nolock) on L.ID = A.SORDERID
where A.ID = @DocID


select @sumTimeTasks =  sum(isnull(B.ESTIMATED_TIME,0))
from SM_WORKORDER_TASKS A with (nolock)
left join SM_SERVICETASKS B with (nolock) on B.ID = A.TASKID
where A.VNESHID = @DocID
 
set @sumTime = @sumTime + @sumTimeTasks

if @servOrdFromCase is not null and @servOrdFromWO is not null and @servOrdFromCase <> @servOrdFromWO
begin
  raiserror('Wrong service order reference specified.',16,0)
  SET nocount off
  return
end

if @woState > 1 and @contactID is null 
begin
  raiserror('Attribute "Contact" must have a value.',16,0)
  SET nocount off
  return
end

if @contactID is not null and @contactCustID <> @customerID
begin
  raiserror('Wrong contact reference specified.',16,0)
  SET nocount off
  return
end

if @WOnumber <> @needWOnumber
begin
  update SM_WORKORDER set NN = @needWOnumber where ID = @DocID and NN <> @needWOnumber
end

if @customerID is not null and @customerID <> @scaseCustomerID and @customerID <> @scaseCustomer2ID
begin
  raiserror('Wrong account (Business Partner reference) specified.',16,0)
  SET nocount off
  return
end

if @deviceID is not null and @servOrdFromWO is not null
begin
   if not exists (select FF.ID from PR_PRORDER_SERVICE FF with (nolock) where FF.ORDERID = @servOrdFromWO and FF.DEVICEID = @deviceID)
   begin
      set @errMsg = 'Product '+@deviceSN+' not found in the service order '+@servOrdNN+' lines.'
	  raiserror(@errMsg,16,0)
	  SET nocount off
	  return
   end
end   

update SM_WORKORDER set SUM_TIME_PLANNED_TASKS = @sumTime where ID = @DocID and isnull(SUM_TIME_PLANNED_TASKS,-454) <> @sumTime

if @ShDbeg is not null and @ShDend is not null and @ShDbeg >= @ShDend
begin
   raiserror('Please correct scheduled period of time.',16,0)
   SET nocount off
   return   
end

/*  KB2730: removed
if (@woState = 2130060 /*assigned*/)
begin

   if @emplID is null
   begin
     raiserror('The field "Assigned to" is empty.',16,0)
     SET nocount off
     return
   end

end
*/

if (@woState = 2130010) /*Scheduled*/       
begin
  
   if @ShDbeg is null or @ShDend is null
   begin
     raiserror('Please specify scheduled time.',16,0)
     SET nocount off
     return
   end
   
   if @ShDbeg >= @ShDend
   begin
     raiserror('Please correct scheduled period of time.',16,0)
     SET nocount off
     return   
   end
  
   if @emplID is null
   begin
     raiserror('Please specify employee to assign work order.',16,0)
     SET nocount off
     return
   end
   
   if not exists (select B.ID from SM_WORKORDER_TASKS B where B.VNESHID = @DocID)
   begin
     raiserror('Please specify work order service tasks.',16,0)
     SET nocount off
     return
   end
   
   if exists (select B.ID from SM_WORKORDER B with (nolock) where B.EMPLID = @emplID and B.SH_DBEG <= @ShDend and B.SH_DEND >= @ShDbeg and B.ID <> @DocID)
   begin
     raiserror('Please check scheduled time. Assigned employee already has work order scheduled in the same period of time.',16,0)
     SET nocount off
     return
   end

end

if @MethodOID = 2130021 /* Start */
begin

  exec SM_START_WORKORDER @DocID, @UserID
  
  update PR_PRORDER set S_S = 1000035 /*in progress*/ where ID = @servOrdFromWO and S_S = 1
  

end

if @MethodOID > 0 and @woState = 2130012/*completed*/
begin

  if exists (select B.ID from PR_OPERATION B with (nolock) where B.ORDERID = @servOrdFromWO and B.WORKORDERID = @DocID and B.COMPLETED_DT is null)
  begin
     raiserror('Please complete all operations by this work order first.',16,0)
     SET nocount off
     return  
  end

end


SET nocount off