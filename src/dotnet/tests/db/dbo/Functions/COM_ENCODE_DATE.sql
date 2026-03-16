create function [dbo].[COM_ENCODE_DATE](@aYYYY int,@aMM int,@aDD int)
returns datetime as 
begin
  declare @res datetime
  
  set @res = CAST(STR(10000*@aYYYY+100*@aMM+@aDD) AS DATETIME) 
  
  return @res;
end