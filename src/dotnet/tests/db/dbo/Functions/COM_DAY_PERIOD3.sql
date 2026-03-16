create function [dbo].[COM_DAY_PERIOD3] (@dBeg datetime, @dEnd datetime, @Calendar int)
returns @res table (YY int, MM int ,DD int, DDATE date, DDATE_PLUS1 date, SHORTDAY int)
as 
begin

    if (@dEnd < @dBeg) return
 
    declare @dd date = cast(@dBeg as date)
    while (@dd <= cast(@dEnd as date))
    begin
 
       declare @shortDay int = 0
       
       if exists (select F.ID from COM_SHORT_WORKDAY F with (nolock) 
                  where F.CALENDAR = @Calendar 
                    and F.MM = month(@dd) 
                    and F.DD = day(@dd) )
         set @shortDay = 1
 
       insert into @res (YY,MM,DD,DDATE,DDATE_PLUS1,SHORTDAY)    
       values (year(@dd),month(@dd),day(@dd),@dd,DATEADD(day, 1, @dd),@shortDay)
       
       set @dd = DATEADD(day, 1, @dd)
       
    end

   
   return

end