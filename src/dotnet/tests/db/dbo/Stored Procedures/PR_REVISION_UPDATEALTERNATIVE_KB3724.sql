CREATE procedure [dbo].[PR_REVISION_UPDATEALTERNATIVE_KB3724]  @RevisionID int, @UserID int, @Mode int
as 
SET nocount on

/*KB3724
при утверждении ревизии нужно взять операции в карте, которые помечены признаком "Alternative Operation if Condition not met"
посчитать по ним Condition и если вернуло 0, то записать в PR_REV_OVERRIDE_ALTERNATIVE 
признак альтернативности этой операции по этой ревизии
*/

declare @opers table (MAPOPERID int, CONDITIONRESULT int)

insert into @opers (MAPOPERID, CONDITIONRESULT)
select B.ID
 ,dbo.PR_OPER_ISACTIVE_4REVISION(A.ID,B.ID,0)
from PR_REVISION A with(nolock)
left join PR_MAP_OPER B with(nolock) on B.MAPID = A.MAPID
where A.ID = @RevisionID
  and isnull(B.ALTIFCONDKB3724,0) = 1
  and isnull(B.CONDITION,0) > 0

declare @moID int
declare nxx cursor local read_only for 
select MAPOPERID from @opers  where CONDITIONRESULT = 0
open nxx 
WHILE 1=1
BEGIN
    FETCH NEXT FROM nxx INTO @moID;
    IF @@FETCH_STATUS<>0 BREAK;

	update PR_REV_OVERRIDE_ALTERNATIVE set TYPICAL2NAV = 1, ADDEDBYKB3724 = 1
	where REVID = @RevisionID and MAPOPERID = @moID

	if @@rowcount = 0
	begin
	   insert into PR_REV_OVERRIDE_ALTERNATIVE (GID,S_CR,S_CDT,REVID,MAPOPERID,TYPICAL2NAV,ADDEDBYKB3724)
	   values (newid(),@UserID,getdate(),@RevisionID,@moID,1,1)
	end
    
END
close nxx;
deallocate nxx;


SET nocount off