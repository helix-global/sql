create function dbo.FC_ACCESS_FAILURE_CODES (@aUserID int,@aMode int,@aDate datetime)
returns @res table (ID int)
as 
begin
/* выдает ID типов моделей на которые можно видеть коды _отказа_ */

declare @emplID int
select top 1 @emplID = A.EMPLOYEEID 
from DEF_USERS A with (nolock) 
where A.ID = @aUserID
  
declare @emplDepID int=dbo.COM_EMPLOYEE_DEP(@emplID, getdate())

declare @deps table (ID int)

insert into @deps (ID)
select ID from dbo.COM_ACCESS_DEPARTMENTS(@aUserID,@aMode,@aDate) 

insert into @deps (ID)
select A.DEPID
from FC_FARA_SETTINGS A with (nolock) 
where A.EMPLID = @emplID
  and A.MTID is null
  and A.FCVIEW = 1

insert into @res (ID)
select A.ID
from PR_MODELTYPE A with (nolock)
where A.DEPARTMENTID in (select ID from @deps)

insert into @res (ID)
select A.MTID
from FC_FARA_SETTINGS A with (nolock) 
where A.EMPLID = @emplID
  and A.MTID is not null
  and A.FCVIEW = 1

insert into @res (ID)
select A.MTID
from FC_FARA_SETTINGS A with (nolock) 
where A.DEPID = @emplDepID
  and A.MTID is not null
  and A.EMPLID is null
  and A.FCVIEW = 1


return

end