CREATE PROCEDURE [dbo].[COM_EMPLOYEE_DEPID_CHECK] 
AS
BEGIN
set nocount on

/*проверяет текущую ссылку на подразделении в COM_EMPLOYEE по настройкам из COM_EMPL_PERIODS*/

declare @now datetime = getdate()
  
declare @needChanges table (EMPLID int not null, DEPID int not null)
insert into @needChanges (EMPLID, DEPID)
select A.EMPLID, A.DEPID
from COM_EMPL_PERIODS A with (nolock)
left join COM_EMPLOYEE B with (nolock) on B.ID = A.EMPLID
where A.DBEG < @now
  and isnull(A.DEND,'40001212') > @now
  and A.DEPID <> isnull(B.DEPID,-1)

declare @chCount int
select @chCount = count(*) from @needChanges

print @chCount
  
update COM_EMPLOYEE set OLDDEPID_AUTOCHANGED = DEPID, DEPID = (select top 1 F.DEPID from @needChanges F where F.EMPLID = COM_EMPLOYEE.ID)
where ID in (select B.EMPLID from @needChanges B)  
  
set nocount off
END