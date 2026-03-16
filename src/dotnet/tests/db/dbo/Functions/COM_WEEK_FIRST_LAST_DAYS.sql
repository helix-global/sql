CREATE function [dbo].[COM_WEEK_FIRST_LAST_DAYS](
 @y int, @w int
 )
 returns @res table (DBEG datetime, DEND datetime)
as
begin

	if @w<1 or @w>53
	begin
		return
	end

	--declare @d datetime = dbo.COM_ENCODE_DATE(@y,1,1) --KB2951
	declare @d datetime = dbo.COM_ENCODE_DATE(@y,1,4)
	declare @dMonday datetime 
	declare @dSunday datetime

	if @w=1
	begin
		declare @dayOfWeek int = (@@datefirst+datepart(weekday,@d)-2)%7+1;
		set @dMonday = dateadd(day,1-@dayOfWeek,@d)
		set @dSunday = dateadd(day,7-@dayOfWeek,@d)
	end
	else
	begin
		while @dMonday is null
		begin
			if DATEPART(iso_week,@d)=@w
				set @dMonday = @d
	
			set @d = dateadd(day,1,@d) 
		end

		set @dSunday = dateadd(day,6,@dMonday) 	
	end

	insert into @res
		select @dMonday,@dSunday

	return

end