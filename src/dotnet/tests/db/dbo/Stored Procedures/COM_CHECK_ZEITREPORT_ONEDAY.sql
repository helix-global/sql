CREATE PROCEDURE [dbo].[COM_CHECK_ZEITREPORT_ONEDAY] (@dayN int, @weekDD datetime, @dS datetime, @dE datetime, @dP datetime, @empid int, @aUserID int, @MethodOID int)
AS
BEGIN
set nocount on

declare @dSt datetime
declare @dEn datetime
declare @dPa datetime

declare @err nvarchar(max)
if @dayN = 1
  set @err = 'Invalid values for Monday. '
else if @dayN = 2
  set @err = 'Invalid values for Tuesday. '
else if @dayN = 3
  set @err = 'Invalid values for Wednesday. '
else if @dayN = 4
  set @err = 'Invalid values for Thursday. '
else if @dayN = 5
  set @err = 'Invalid values for Friday. '
else if @dayN = 6
  set @err = 'Invalid values for Saturday. '
else if @dayN = 7
  set @err = 'Invalid values for Sunday. '


set @dSt = cast(cast (@dS as time) as datetime)
set @dEn = cast(cast (@dE as time) as datetime)
set @dPa = cast(cast (@dP as time) as datetime)

/*if datepart(hour,@dE) < 3*/ /*KB3228*/
if @dEn <= @dSt
  set @dEn = dateadd(day,1,@dEn)


if @dEn is null and @dSt is not null
begin
   set @err = @err + 'Please enter valid end time or leave day fields empty.'
   raiserror(@err,16,0)
   set nocount off
   return   
end

if @dEn is not null and @dSt is null
begin
   set @err = @err + 'Please enter valid start time or leave day fields empty.'
   raiserror(@err,16,0)
   set nocount off
   return   
end


if @dSt >= @dEn
begin
  set @err = @err + 'Day start time cannot be later or equial to day end time.'
  raiserror(@err,16,0)
  set nocount off
  return   
end

declare @seconds int = datediff(second,@dSt,@dEn)
declare @secondsPause int = isnull(datepart(hour,@dPa)*60*60,0) + isnull(datepart(minute,@dPa)*60,0) + isnull(datepart(second,@dPa),0) 

if @secondsPause > 0 and @secondsPause >= isnull(@seconds,0)
begin
  set @err = @err + 'Pause time cannot be more than work time.'
  raiserror(@err,16,0)
  set nocount off
  return   
end

if ((@seconds - @secondsPause) > 6 * 60 * 60) and (@secondsPause < 30 * 60)
begin
  set @err = @err + 'Pause time cannot be less than 30 minutes.'
  raiserror(@err,16,0)
  set nocount off
  return   
end

if ((@seconds - @secondsPause) > 9 * 60 * 60) and (@secondsPause < 45 * 60)
begin
  set @err = @err + 'Pause time cannot be less than 45 minutes.'
  raiserror(@err,16,0)
  set nocount off
  return   
end

  
set nocount off
END