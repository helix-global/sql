create function [dbo].[PR_REVISION_WHERE_USED] (@ModelID int, @UserID int)
returns @res table (ID int)
as 
begin

insert into @res (ID) 
select HH.REVID 
from PR_REV_BOM2 HH with (nolock) 
where HH.PARTMODELID = @ModelID

insert into @res (ID) 
select HH.REVID 
from PR_REV_COMPM HH with (nolock) 
where HH.COMPMODELID = @ModelID

return

end