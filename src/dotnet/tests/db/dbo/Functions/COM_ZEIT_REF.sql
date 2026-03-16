CREATE function [dbo].[COM_ZEIT_REF](@aTimeBeg datetime, @aTimeEnd datetime, @aPause datetime)
returns nvarchar(100) with schemabinding
as
begin

if @aTimeBeg is null or @aTimeEnd is null
  return null

declare @res nvarchar(100)

set @res = 'From: '+dbo.COM_HHMM(@aTimeBeg)+' To: '+dbo.COM_HHMM(@aTimeEnd)+' Pause: '+dbo.COM_HHMM(@aPause)

return @res

end;