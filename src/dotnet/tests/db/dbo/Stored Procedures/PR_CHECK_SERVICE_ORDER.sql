CREATE procedure [dbo].[PR_CHECK_SERVICE_ORDER] @OrderID int, @aMode int, @aUserID int 
as 
set nocount on

if exists (select A.ID 
             from PR_PRORDER_SERVICE A with (nolock)
        left join PR_PRORDER B with (nolock) on B.ID = A.ORDERID
        left join COM_DEPARTMENTS C with (nolock) on C.ID = B.DEPARTMENTID
            where A.ORDERID = @OrderID
              and isnull(C.SERVICEORDERFARREQUIRED,0) = 1
              and A.FRID is null
           )   
begin

   raiserror('Failure report required for the items in this service order.',16,0);
   set nocount off
   return

end
  

set nocount off