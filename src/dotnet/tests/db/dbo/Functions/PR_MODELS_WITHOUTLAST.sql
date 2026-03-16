CREATE function [dbo].[PR_MODELS_WITHOUTLAST] (@aModelID int)
returns @res table (ID int)
as 
begin
  /* модели с одинаковыми кодами без последнего символа */

declare @code nvarchar(50)
declare @mtid int

select @code = A.CODE
      ,@mtid = A.TYPEID
from PR_MODELS A with (nolock) 
where A.ID = @aModelID

set @code = substring(@code,1,len(@code) - 1) + '_'

insert into @res(ID) values (@aModelID)

insert into @res (ID) 
select A.ID
from PR_MODELS A with (nolock)
where A.TYPEID = @mtid
  and A.CODE like @code
  and A.ID <> @aModelID

return

end