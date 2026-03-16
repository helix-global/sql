create function [dbo].[PR_ACCESS_MT_TO_CHANGE] (@aUserID int,@aDate datetime)
returns @res table (ID int)
as 
begin
  /* типы модели изделий, по которым можно менять модель  */

insert into @res (ID) 
select distinct A.TYPEID 
from PR_MODELS A with (nolock) 
where A.ID in (select ID from dbo.PR_ACCESS_MODELS_TO_CHANGE(@aUserID,@aDate) )

return

end