CREATE function [dbo].[COM_ADD_TIME_READONLY](@aDEnd datetime)
returns int with schemabinding as 
begin
  
  if (datediff(day,@aDEnd,getdate()) > 0)
    return 1
 
  return 0;
end