CREATE function [dbo].[COM_ZEIT_REF2](@aTimeBeg datetime, @aTimeEnd datetime, @aPause datetime, @vacation int)
returns nvarchar(100) with schemabinding
as
begin

/*
v.2 выводит 'Absence' если весь день отпуск
*/

if @vacation = 1
  return 'Absence'

if @aTimeBeg is null or @aTimeEnd is null
  return null

declare @res nvarchar(100)

set @res = 'From: '+dbo.COM_HHMM(@aTimeBeg)+' To: '+dbo.COM_HHMM(@aTimeEnd)+' Pause: '+dbo.COM_HHMM(@aPause)

return @res

end;