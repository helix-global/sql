CREATE procedure [dbo].[PR_CHANGE_QTY_IFNEED_ON_START]  @OperationID int
as 
set nocount on
/*KB4145*/

declare @DeviceQty int
declare @OperQty int
declare @AccMode int
declare @doChange int

select 
 @DeviceQty = isnull(D.RESQUANTITY,1)
,@OperQty = isnull(A.Q_IN,1) 
,@AccMode = T.ACCMODE
,@doChange = isnull(T.UPDOPERQTYFROMITEM,0)
from PR_OPERATION A with (nolock)
left join PR_DEVICE D with (nolock) on D.ID = A.DEVICEID
left join PR_MODELS M with (nolock) on M.ID = D.MODELID
left join PR_MODELTYPE T with (nolock) on T.ID = M.TYPEID
where A.ID = @OperationID

if @AccMode in (5,2/*KB4216*/) and @doChange = 1 and @DeviceQty <> @OperQty
begin
  
   update PR_OPERATION set Q_IN = @DeviceQty, PREP_RESULT = null  /*KB4203*/ where ID = @OperationID and isnull(Q_IN,1) <> @DeviceQty
   
end

set nocount off