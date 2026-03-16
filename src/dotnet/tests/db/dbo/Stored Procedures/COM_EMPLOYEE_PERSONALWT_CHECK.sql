create PROCEDURE [dbo].[COM_EMPLOYEE_PERSONALWT_CHECK] 
AS
BEGIN
set nocount on

/*проверяет текущую ссылку на график в COM_EMPLOYEE по настройкам из COM_PERSONALWORKTIME_HISTORY*/

declare @now datetime = getdate()
  
declare @needChanges table (EMPLID int not null, PERSONALWT int null, PERSONALWT_OLD int null)
insert into @needChanges (EMPLID, PERSONALWT, PERSONALWT_OLD)
select A.ID
    , (select top 1 B.PERSONALWT 
        from COM_PERSONALWORKTIME_HISTORY B 
        where B.EMPLOYEEID=A.ID 
            and B.DBEG < @now
        order by B.DBEG desc) as PERSONALWT_NEW
    , A.PERSONALWT
from COM_EMPLOYEE A

delete from @needChanges 
    where isnull(PERSONALWT,0)=isnull(PERSONALWT_OLD,0)

declare @chCount int
select @chCount = count(*) from @needChanges

print @chCount
  
update COM_EMPLOYEE set OLDPERSONALWT_AUTOCHANGED = PERSONALWT, PERSONALWT = (select top 1 F.PERSONALWT from @needChanges F where F.EMPLID = COM_EMPLOYEE.ID)
where ID in (select B.EMPLID from @needChanges B)  
  
set nocount off
END