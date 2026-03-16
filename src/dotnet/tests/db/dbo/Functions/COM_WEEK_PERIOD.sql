create function dbo.COM_WEEK_PERIOD (@dBeg datetime, @dEnd datetime)
returns @res table (YY int, WW int, DDATE date, DDATE_PLUS1 date)
as 
begin

    if (@dEnd < @dBeg) return
 
    declare @dd date = cast(@dBeg as date)
    while (@dd <= cast(@dEnd as date))
    begin
 
       insert into @res (YY,WW,DDATE,DDATE_PLUS1)    
       values (year(@dd),datepart(iso_week,@dd),@dd,DATEADD(week, 1, @dd))
       
       set @dd = DATEADD(week, 1, @dd)
       
    end

   
   return

end