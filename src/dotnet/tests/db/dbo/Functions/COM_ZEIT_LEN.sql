CREATE function [dbo].[COM_ZEIT_LEN](@aTimeBeg datetime, @aTimeEnd datetime, @aPause datetime)
returns time with schemabinding
as
begin

declare @res time
declare @vBeg datetime = cast(cast(@aTimeBeg as time) as datetime)
declare @vEnd datetime = cast(cast(@aTimeEnd as time) as datetime)

/*if datepart(hour,@vEnd) < 3*/  /*KB3228*/
if @vEnd <= @vBeg
  set @vEnd = dateadd(day,1,@vEnd)

declare @seconds int = datediff(second,@vBeg,@vEnd)
declare @secondsPause int = isnull(datepart(hour,@aPause)*60*60,0) + isnull(datepart(minute,@aPause)*60,0) + isnull(datepart(second,@aPause),0) 


set @seconds = @seconds - @secondsPause
if @seconds < 0
  set @seconds = 0

declare @resDate datetime = '19000101'
set @resDate = dateadd(second,@seconds,@resDate)
set @res = cast(@resDate as time)     

return @res

end;