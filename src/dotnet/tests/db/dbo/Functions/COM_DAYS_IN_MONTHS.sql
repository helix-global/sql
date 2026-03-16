CREATE function [dbo].[COM_DAYS_IN_MONTHS] (@dateInMonthBegin date,@dateInMonthEnd date)
returns @res table (YY int, MM int ,DD int, DDATE date, DDATE_PLUS1 date)
as 
begin
 
   declare @dbeg date
   declare @dend date
   
   set @dbeg = dbo.COM_ENCODE_DATE(year(@dateInMonthBegin),MONTH(@dateInMonthBegin),1)
   set @dend = dbo.COM_ENCODE_DATE(year(isnull(@dateInMonthEnd,@dateInMonthBegin)),MONTH(isnull(@dateInMonthEnd,@dateInMonthBegin)),1)
   set @dend = DATEADD(DAY,-1,DATEADD(month,1,@dend))
      
 
   insert into @res (YY,MM,DD,DDATE,DDATE_PLUS1)
   select YY,MM,DD,DDATE,DDATE_PLUS1 from dbo.COM_DAY_PERIOD(@dbeg,@dend)
       
       
   return

end