create function [dbo].[COM_LISTPERIOD](@aDate datetime)
returns int with schemabinding as 
begin
/* для работы с перечислением com_list_periods в списках */
    if cast(@aDate as date) = cast(getdate() as date) 
       return 1 
    if dbo.COM_SAMEWEEK(@aDate,getdate()) = 1
       return 10
    if year(@aDate) = year(getdate()) and month(@aDate) = month(getdate()) 
       return 20
              
    return 100 
              
end