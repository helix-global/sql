create function [dbo].[PR_ACCESS_OPERTYPES_ONLY_MY] (@aUserID int,@aDate datetime)
returns @res table (ID int)
as 
begin

insert into @res (ID)
select AA.OPERTYPEID as ID 
from PR_OPERATIONS_RAW_BYUSER AA with (nolock,noexpand)
left join PR_EMPL_TO_OPERGR A with (nolock) on A.ID = AA.LINKID
where AA.USERID = @aUserID
  and isnull(A.DBEG,'19900101') <= cast(@aDate as date)
  and isnull(A.DEND,'40000101') >= cast(@aDate as date)

return 

end