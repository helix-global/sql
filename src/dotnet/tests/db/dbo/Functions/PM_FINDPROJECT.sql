create function [dbo].[PM_FINDPROJECT](@aTaskID int)
returns int
as
begin

declare @res int

select @res = A.PROJID from PM_TASK A with (nolock) where A.ID = @aTaskID
     
return @res  

end;