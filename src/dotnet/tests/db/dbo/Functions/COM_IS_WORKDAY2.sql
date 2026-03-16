CREATE function [dbo].[COM_IS_WORKDAY2](@dd datetime,@aCalendarID int,@whID int)
returns int as 
begin
   
   declare @dayOfWeek int
   set @dayOfWeek = (@@datefirst+datepart(weekday,@dd)-2)%7+1; 
   
   declare @result int
   set @result = 0
   if @dayOfWeek < 6
      set @result = 1
     
   if @whID is not null
   begin
   
     if exists (select A.ID from COM_WORKTIME_NW_WEEKS A with(nolock) where A.VNESHID = @whID and A.WEEKN = datepart(iso_week,@dd))  /*KB3469*/
        return 0 

     if exists (select A.ID from COM_WORKTIME_NW_DAYS A with(nolock) where A.VNESHID = @whID and A.DDAY = cast(@dd as date))  /*KB3685*/
        return 0 
   
     declare @dayInWT int  
     select @dayInWT = case @dayOfWeek when 1 then WD1 when 2 then WD2 when 3 then WD3 when 4 then WD4 when 5 then WD5 when 6 then WD6 when 7 then WD7 end
       from COM_WORKTIME A with (nolock)
      where A.ID = @whID
     
     if @result = 0 and isnull(@dayInWT,0) = 1
       set @result = 1
     
     if @dayInWT <> 1
       set @result = 0
   
   end
     
   declare @day date
   set @day = cast(@dd as date) 
   
   declare @cStatus int
   
   select @cStatus = A.DAYSTATUS from COM_CALENDAR A with (nolock) where A.CALENDAR = @aCalendarID and A.DDAY = @day 
   
   if (@result = 1 and @cStatus = 2)
     return 0
   
   if (@result = 0 and @cStatus = 1)
     return 1
     
     
   return @result  

end