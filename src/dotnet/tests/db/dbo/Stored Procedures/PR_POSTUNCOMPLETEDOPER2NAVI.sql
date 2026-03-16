CREATE procedure [dbo].[PR_POSTUNCOMPLETEDOPER2NAVI] @DepID int, @aUserID int, @aMode int
as 
SET nocount on

declare @operid int
declare @now datetime

set @now = getdate()

declare cur cursor local read_only for 
select A.ID
from PR_OPERATION A with (nolock)
left join PR_PRORDER B with (nolock) on B.ID = A.ORDERID
where B.DEPARTMENTID = @DepID
  and exists (select N.ID from PR_OPERATION_INSTALL N with (nolock) where N.OPERID = A.ID)
  and A.COMPLETED_DT is null
   
open cur;
WHILE 1=1
BEGIN
   FETCH NEXT FROM cur INTO @operid;
   IF @@FETCH_STATUS<>0 BREAK;
   
   exec PR_OPER2NAVI @operid, @aUserID, @now
   
END
close cur;
deallocate cur;

SET nocount off