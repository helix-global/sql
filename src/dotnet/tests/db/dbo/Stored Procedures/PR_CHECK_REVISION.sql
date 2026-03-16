
CREATE procedure [dbo].[PR_CHECK_REVISION] @RevID int, @aMode int, @aUserID int 
as 
set nocount on

declare @errLineID int 
declare @errMess nvarchar(max)

select top 1 @errLineID = A.ID
from PR_REV_SW A with (nolock)
where A.REVID = @RevID
  and exists( select B.ID 
                from PR_REV_SW B with (nolock) 
               where B.REVID = A.REVID
                 and B.SWID = A.SWID
                 and isnull(B.ONLYOPTION,-123) = isnull(A.ONLYOPTION,-123)
                 and isnull(B.ONLYOPTION2,-123) = isnull(A.ONLYOPTION2,-123)
                 and isnull(B.ONLYOPTION3,-123) = isnull(A.ONLYOPTION3,-123)
                 and B.ID <> A.ID)
                 
if @errLineID is not null
begin

   select @errMess = B.NAME
   from PR_REV_SW A with (nolock)
   left join PR_MODELTYPE_PARAMS B with (nolock) on B.ID = A.SWID
   where A.ID = @errLineID

   set @errMess = '#ESettings for software and tools parameter "'+isnull(@errMess,'NA')+'" are duplicated.'

   raiserror(@errMess,16,1)
   set nocount off
   return

end


set @errLineID = null
select top 1 @errLineID = A.ID
from PR_REV_BOM2 A with (nolock)
left join PR_REVISION B with (nolock) on B.ID = A.REVID
where A.REVID = @RevID
  and isnull(A.TYPICAL2NAV,0) = 0 
  and isnull(B.SYNC2NAV,0) > 0
  and exists( select B.ID 
                from PR_REV_BOM2 B with (nolock) 
               where B.REVID = A.REVID
                 and B.BOMID = A.BOMID
                 and isnull(B.TYPICAL2NAV,0) = 0 
                 and B.ID <> A.ID)
                 
if @errLineID is not null
begin

   select @errMess = B.NAME
   from PR_REV_BOM2 A with (nolock)
   left join PR_MODELTYPE_BOM B with (nolock) on B.ID = A.BOMID
   where A.ID = @errLineID

   set @errMess = '#EPlease specify "Alternative Position" for BOM item "'+isnull(@errMess,'NA')+'" if several models are possible.'

   raiserror(@errMess,16,1)
   set nocount off
   return

end


set nocount off