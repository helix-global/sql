create function dbo.COM_MIN_DATE (@date1 datetime, @date2 datetime)
returns datetime
as 
begin

  if (@date1 > @date2)
    return @date2
  
  return @date1

end