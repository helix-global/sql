create function [dbo].[WEB_IS_MY_CO_AJOIN](@UserID int,@OnDate datetime)
returns @res table(ID INT)
as
begin
declare @emplID int
select @emplID = U.EMPLOYEEID from DEF_USERS U with (nolock) where U.ID = @UserID


insert into @res (ID)
select A.ID
from PR_OPERATION A with (nolock)
left join PR_DEVICE D with (nolock) on D.ID = A.DEVICEID
left join PR_OPERATIONS B with (nolock) on B.ID = A.OPERTYPEID
left join PR_PRORDER O with (nolock) on O.ID = A.ORDERID
left join PR_MODELS M with (nolock) on M.ID = D.MODELID
where A.COMPLETED_DT is null
and A.S_S in (1000031) /*in progress*/
and (D.S_S in (1000008,1000011,1000029) /*in production, in service, pending production*/ or A.DEVICEID is null /*preparatory*/ )
and A.USERINPROGRESS is not null
and A.USERINPROGRESS <> @UserID
and B.OPERGRID in (select F.GROUPID from PR_EMPL_TO_OPERGR F with (nolock)
where F.EMPLOYEEID = @emplID and (F.DEPID = O.DEPARTMENTID or F.DEPID=M.DEPID)
and isnull(F.DBEG,'19900101') <= @OnDate
and isnull(F.DEND,'40000101') >= @OnDate)
and isnull(B.AJOIN,0) = 1


return

end