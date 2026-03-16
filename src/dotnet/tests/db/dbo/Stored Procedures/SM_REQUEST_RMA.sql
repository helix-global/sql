CREATE PROCEDURE [dbo].[SM_REQUEST_RMA] @ServCaseID int, @ServCallID int, @UserID int
AS
BEGIN
  set nocount on

  declare @scID int = @ServCaseID
  
  if (@scID is null)
     select @scID = A.CASEID from SM_SERVICECALL A where A.ID = @ServCallID

  if @scID is null
  begin
    raiserror('#EService case record not found.',16,0)
    set nocount off
    return
  end

  declare @now datetime
  set @now = GETDATE()
  set @now = CAST (@now as date)
 
  declare @ServOrdType int
  declare @custCode nvarchar(50)
  declare @custCRMGUID uniqueidentifier
  declare @alreadyrequested datetime
  
  select @ServOrdType = isnull(A.RMA_SC_TYPE,0)
        ,@custCode = B.CODE
        ,@custCRMGUID = B.CRMGUID
        ,@alreadyrequested = A.RMA_SC_REQUESTED
  from SM_SERVICECASE A
  left join COM_CUSTOMER B on B.ID = isnull(A.CUSTID_4SERVORD,A.CUSTID)
  where A.ID = @scID

  if @alreadyrequested is not null
  begin
    raiserror('#ERMA/SC/SCAFF has been already requested.',16,0)
    set nocount off
    return
  end
   
  if @ServOrdType = 0
  begin
    raiserror('#EPlease specify service order type.',16,0)
    set nocount off
    return
  end 
  
  if @custCRMGUID is null
  --if len(isnull(@custCode,'')) = 0
  begin
    raiserror('#ECustomer CRM code should have a value.',16,0)
    --raiserror('#ECustomer code should have a value.',16,0)
    set nocount off
    return
  end
  
  declare @itemsCount int = 0
  select @itemsCount = count(*) from SM_SERVICECASE_ITEMS A where A.VNESHID = @scID
  if @itemsCount = 0
  begin
    raiserror('#EItems table is empty.',16,0)
    set nocount off
    return
  end
  
  
  exec SM_REQUEST_RMA_2NAVI @scID, @UserID

  update SM_SERVICECASE set S_S = 1000193, RMA_SC_REQUESTED = getdate() where ID = @scID

  exec SM_REQUEST_ORDER_NOTIFICATION @UserID, @ServCaseID, 0

  set nocount off

END