CREATE function [dbo].[COM_WEEK_PERIOD4] (@dBeg datetime, @dEnd datetime)
returns @res table (WEEKID int, YY int, WW int, DDATE date, DDATE_PLUS1 date, WEEK_MONDAY date, WEEK_SUNDAY date, WEEK_COMPLETED int, WEEK_NOW int)
as 
begin

	/*в отличие от [COM_WEEK_PERIOD3] выдает 6-ю неделю, если месяц включает 6 недель*/

    /*WEEKID число: YYYYWW */

    if (@dEnd < @dBeg) return
 
    declare @now date = cast(getdate() as date)
    declare @dd date = cast(@dBeg as date)
    declare @dayOfWeek int = (@@datefirst+datepart(weekday,@dd)-2)%7+1;
	declare @ddMon datetime
	declare @ddSun datetime

	
	set @ddMon = dateadd(day,1-@dayOfWeek,@dd)
	set @ddSun = dateadd(day,7-@dayOfWeek,@dd)
	    
    while @dEnd>@ddSun or (@dEnd>=@ddMon and @dEnd<=@ddSun)
    begin
 
       insert into @res (WEEKID
						,YY
						,WW
						,DDATE
						,DDATE_PLUS1
                        ,WEEK_MONDAY
						,WEEK_SUNDAY
                        ,WEEK_COMPLETED
                        ,WEEK_NOW)    
       values (year(@dd)*100+datepart(iso_week,@dd)
				,year(@dd)
				,datepart(iso_week,@dd)
				,@dd
				,DATEADD(week, 1, @dd)
                ,dateadd(day,1-@dayOfWeek,@dd)
				,dateadd(day,7-@dayOfWeek,@dd)
                ,case when dateadd(day,7-@dayOfWeek,@dd) > @now then 0 else 1 end
                ,case when year(@dd) = year(@now) and datepart(iso_week,@dd) = datepart(iso_week,@now) then 1 else 0 end )
       
	  
       set @dd = DATEADD(week, 1, @dd)	   
	
		set @ddMon = dateadd(day,1-@dayOfWeek,@dd)
		set @ddSun = dateadd(day,7-@dayOfWeek,@dd)

       
    end

   
   return

end