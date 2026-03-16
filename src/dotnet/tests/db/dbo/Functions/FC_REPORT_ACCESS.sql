CREATE function [dbo].[FC_REPORT_ACCESS](@FRid int, @UserID int , @aDate datetime)
returns int
as
begin

/* функция для использования в отчетах статистики отдела по своим FR*/

declare @accToDep int

select @accToDep = dbo.COM_DEP_ACCESS2(B.DEPID,6,@UserID,@aDate) 
from FC_REPORT A with (nolock) 
left join PR_MODELS B with (nolock) on B.ID = A.MODELID
where A.ID = @FRid

if @accToDep = 1
  return 1
  
if dbo.DEF_USERINGROUP4(@UserID,'ChildFR',@aDate) = 1
begin
  /* члены группы ChildFR видят дочерние FR */
  
  if exists (select A.PARENTID
               from dbo.FC_PARENT_TREE(@FRid) A
          left join FC_REPORT B with (nolock) on B.ID = A.PARENTID
          left join PR_MODELS C with (nolock) on C.ID = B.MODELID          
              where dbo.COM_DEP_ACCESS2(C.DEPID,6,@UserID,@aDate) = 1
              )
     return 1              

end
  
return 0  

end;