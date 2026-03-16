create function [dbo].[LN_CARDS_IN] (@aWeekID int, @aDay int)
returns @res table (ID int)
as 
begin


insert into @res (ID) 
select C.ID 
from LN_ORDER A
left join LN_ORDER_POSITIONS B on B.VNESHID = A.ID
left join LN_CARDS C on C.EMPLID = A.EMPLID and C.S_S = 2000011
where A.WEEKID = @aWeekID
  and B.DAY = @aDay


return

end