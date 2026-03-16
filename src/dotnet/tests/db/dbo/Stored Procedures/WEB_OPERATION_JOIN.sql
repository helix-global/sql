CREATE PROCEDURE [dbo].[WEB_OPERATION_JOIN] @aUserID int, @aOperID int
AS
BEGIN

if exists (select GG.ID from dbo.WEB_IS_MY_CO_AJOIN(@aUserID,getdate()) GG where GG.ID = @aOperID)
begin

declare @dd datetime = getdate()
declare @empID int

select @empID = A.EMPLOYEEID from DEF_USERS A with (nolock) where A.ID = @aUserID

insert into PR_OPERATION_TIME (GID,S_CR,S_CDT,OPERID,DBEG,USERID,EMPID)
select newid(),@aUserID,@dd,A.ID,@dd,@aUserID,@empID
from PR_OPERATION A with (nolock)
where A.ID = @aOperID
and not exists (select F.ID from PR_OPERATION_TIME F where F.OPERID = A.ID and F.USERID = @aUserID and F.DEND is null)

end

END