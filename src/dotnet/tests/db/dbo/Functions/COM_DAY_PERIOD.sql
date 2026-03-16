CREATE function [dbo].[COM_DAY_PERIOD] (@dBeg datetime, @dEnd datetime)
returns @res table (YY int, MM int ,DD int, DDATE date, DDATE_PLUS1 date)
as 
begin

    if (@dEnd < @dBeg) return
 
    declare @dd date = cast(@dBeg as date)
    while (@dd <= cast(@dEnd as date))
    begin
 
       insert into @res (YY,MM,DD,DDATE,DDATE_PLUS1)    
       values (year(@dd),month(@dd),day(@dd),@dd,DATEADD(day, 1, @dd))
       
       set @dd = DATEADD(day, 1, @dd)
       
    end

   
   return

end