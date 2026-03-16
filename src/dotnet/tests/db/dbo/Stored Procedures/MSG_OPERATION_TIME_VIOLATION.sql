CREATE PROCEDURE [dbo].[MSG_OPERATION_TIME_VIOLATION] 
AS
BEGIN
set nocount on
declare @now datetime
set @now = GETDATE()   
  
declare @opers table (OPERID int, EMPLID int, DEPID int, MANHOUR decimal(12,4),NORM decimal(12,4), FACT decimal(12,4), MESS nvarchar(max))

declare @depIDs table (ID int)
insert into @depIDs (ID)
select distinct B.DEPID
from DEF_USERS A 
left join COM_EMPLOYEE B on B.ID = A.EMPLOYEEID
where A.ID in (select ID from dbo.DEF_USERSINGROUP2('SPV_NOTY') )


insert into @opers (OPERID,DEPID,NORM,MANHOUR)
select A.ID,B.DEPARTMENTID,A.MANHOUR,A.MANHOUR
from PR_OPERATION A with (nolock)
left join PR_PRORDER B with (nolock) on B.ID = A.ORDERID
where A.ID > 1043391
  and A.COMPLETED_DT is null
  and A.ORDERID is not null
  and exists (select TT.ID from PR_OPERATION_TIME TT with (nolock) where TT.OPERID = A.ID)
  and B.DEPARTMENTID in (select ID from @depIDs) 
  and A.S_S = 1000031 /*in progress*/
  
update @opers set NORM = MANHOUR * 5 where MANHOUR is not null and MANHOUR <= 3  
update @opers set NORM = MANHOUR * 3 where MANHOUR is not null and MANHOUR < 30 and MANHOUR > 3
update @opers set NORM = MANHOUR * 2 where MANHOUR is not null and MANHOUR >= 30 
/*TODO равномерно распределить коэфф. от 10 до 2 для значений от минуты до часа*/

  
update @opers set NORM = 12*60 where NORM is null
  
update @opers set FACT = (select SUM(dbo.PR_WORKTIME2(B.ID,@now)) from PR_OPERATION_TIME B with (nolock) where B.OPERID = "@opers".OPERID)

delete from @opers where FACT is null

delete from @opers where FACT < NORM

if not exists (select OPERID from @opers)
begin
  set nocount off
  return 
end

delete from @opers where exists (select OPERID from MSG_OPER_WASNOTIFIED with (nolock) where OPERID = "@opers".OPERID)
if not exists (select OPERID from @opers)
begin
  set nocount off
  return 
end
  
update @opers set EMPLID = (select top 1 B.EMPID from PR_OPERATION_TIME B with (nolock) where B.OPERID = "@opers".OPERID and B.DEND is null order by B.ID desc) 

update @opers set MESS = dbo.MSG_OPERATION_TIME_VIOLATION_TEXT(OPERID,EMPLID,MANHOUR,NORM,FACT)

insert into MSG_OPER_WASNOTIFIED (OPERID)
select distinct OPERID from @opers

declare @depid int
declare nxx cursor local read_only for 
select distinct DEPID from @opers
open nxx 
WHILE 1=1
BEGIN
    FETCH NEXT FROM nxx INTO @depid;
    IF @@FETCH_STATUS<>0 BREAK;

    declare @mess nvarchar(max)
    set @mess = 'Dear All,<br><br>The following operations take too much time:<br><br><font size="-2"><table width="1000" cellspacing = "1" bgcolor="#eeeeee" border="1" bordercolor="#ffffff">'
    set @mess = @mess + '<tr><th>Model</th><th>SN</th><th>Order</th><th>Operation</th><th>Norm</th><th>Elapsed</th><th>Employee</th><th> </th></tr>'
    
    select @mess = @mess + A.MESS
    from @opers A where A.DEPID = @depid

    set @mess = @mess + '</table></font><br><br>Please, do not answer this e-mail.<br>Production Database'

    exec MSG_SEND_TOGROUP2 0,1080/*SPV_NOTY*/,@depid,'Violation of the operation execution time',@mess 
    --exec MSG_SEND_TOGROUP2 0,8/*ADM*/,@depid,'Violation of the operation execution time',@mess 
    
END
close nxx;
deallocate nxx;

  
set nocount off
END