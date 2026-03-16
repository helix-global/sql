create function [dbo].[PM_TASK_ASSIGNEE_STR](@aTaskID int, @aMode int)
returns nvarchar(max)
as
begin

declare @res nvarchar(max)
set @res = ''

select @res = @res + case when len(@res) > 0 then ', ' else '' end + B.NAME
from PM_TASK_ASSIGNEE A with (nolock)
left join COM_EMPLOYEE B with (nolock) on B.ID = A.EMPLID
where A.VNESHID = @aTaskID
	                
if LEN(@res) = 0
   return null
     
return @res  

end;