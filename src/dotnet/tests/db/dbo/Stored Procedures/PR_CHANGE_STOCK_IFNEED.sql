CREATE procedure [dbo].[PR_CHANGE_STOCK_IFNEED] 
   @OperationID int,
   @UserID int
as 
set nocount on

declare @DeviceID int
declare @stock nvarchar(50)
declare @stockParamName nvarchar(300)

select 
     @stockParamName = T.STOCKPARAM
    ,@DeviceID = D.ID
from PR_OPERATION A with (nolock)
left join PR_DEVICE D with (nolock) on D.ID = A.DEVICEID
left join PR_MODELS M with (nolock) on M.ID = D.MODELID
left join PR_MODELTYPE T with (nolock) on T.ID = M.TYPEID
where A.ID = @OperationID

if @stockParamName is null
begin
    set nocount off
    return
end

select 
    @stock = LTRIM(RTRIM(convert(nvarchar,A.PVALUE)))
from PR_OPERATION_PARAMS A with (nolock)
left join PR_MODELTYPE_PARAMS B with (nolock) on B.ID = A.PARAMID 
where A.OPERID = @OperationID
  and B.NAME = @stockParamName
    
if @stock is not null
begin
    if @stock not in (select P.NAME
                      from  SH_STOCKS S with (nolock)
                      left join SH_STOCKS_PLACES P with (nolock) on P.VNESHID=S.ID
                      /*where S.DEPID in (SELECT ID FROM dbo.COM_ACCESS_DEPARTMENTS(@UserID, 8, GETDATE()))*/)
    begin
        raiserror('Unable to save operation while Shipping Stock value is not valid. Please check Shipping Stock configuration.',15,0)
        set nocount off
        return
    end

    update PR_DEVICE set SHIPPINGSTOCK = @stock where ID = @DeviceID 
end 

set nocount off