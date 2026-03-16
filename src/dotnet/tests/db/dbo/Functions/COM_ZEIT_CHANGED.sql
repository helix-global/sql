CREATE function [dbo].[COM_ZEIT_CHANGED](@aTimeBeg1 datetime, @aTimeBeg2 datetime, @aTimeEnd1 datetime, @aTimeEnd2 datetime, @aPause1 datetime, @aPause2 datetime)
returns int with schemabinding
as
begin

declare @res int = 0

if (cast(isnull(@aTimeBeg1,'20000101') as time) <> cast(isnull(@aTimeBeg2,'20000101') as time))
    or (@aTimeBeg1 is not null and @aTimeBeg2 is null)
    or (@aTimeBeg1 is null and @aTimeBeg2 is not null)
    set @res = 100

if (cast(isnull(@aTimeEnd1,'20000101') as time) <> cast(isnull(@aTimeEnd2,'20000101') as time))
    or (@aTimeEnd1 is not null and @aTimeEnd2 is null)
    or (@aTimeEnd1 is null and @aTimeEnd2 is not null)
  set @res = @res + 20

if (cast(isnull(@aPause1,'20000101') as time) <> cast(isnull(@aPause2,'20000101') as time))
    or (@aPause1 is not null and @aPause2 is null)
    or (@aPause1 is null and @aPause2 is not null)
  set @res = @res + 3


return nullif(@res,0)


end;