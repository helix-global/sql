CREATE function [dbo].[FC_FAILURERATE_2_MODEL] (@aID int,@aMode int)
returns @res table (ID int)
as 
begin
/*выдает список ID записей FC_FAILURERATES_FARS по строке из FC_FAILURERATES_FARS_FACODE*/


declare @yy int
declare @mm int
declare @faCodeID int

select @yy = A.FYEAR 
      ,@mm = A.FMONTH
      ,@faCodeID = A.FACODE
from FC_FAILURERATES_FARS_FACODE A with (nolock)
where A.ID = @aID



insert into @res (ID) 
  select distinct A.ID
  from FC_FAILURERATES_FARS A with (nolock)
  where A.FYEAR = @yy
    and A.FMONTH = @mm
    and A.FACODE = @faCodeID


return

end