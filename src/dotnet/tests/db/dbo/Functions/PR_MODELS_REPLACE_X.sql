CREATE function [dbo].[PR_MODELS_REPLACE_X] (@aModelID int)
returns @res table (ID int)
as 
begin
  /* модели подмена которых дает XX в конце */

declare @code nvarchar(50)
select @code = A.CODE
from PR_MODELS A with (nolock) 
where A.ID = @aModelID

set @code = substring(@code,1,len(@code) - 1) + '_'

insert into @res(ID) values (@aModelID)

insert into @res (ID) 
select A.ID
from PR_MODELS A with (nolock)
where A.CODE like @code
  and isnull(A.REPLACEX,0) = 1
  and A.ID <> @aModelID

return

end