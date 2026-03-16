create function [dbo].[DEF_2LOCALTIME](@aDateTime datetime, @aDelta int)
returns datetime with schemabinding as 
begin
  return dateadd(minute,@aDelta,@aDateTime)
end