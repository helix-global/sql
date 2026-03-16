CREATE function [dbo].[COM_SAMEWEEK](@aDate1 datetime, @aDate2 datetime )
returns int with schemabinding as 
begin
  /* возвращает 1 если даты в одной iso неделе */
  
  if year(@aDate1) = year(@aDate2) 
    if datepart(isowk,@aDate1) = datepart(isowk,@aDate2)
      return 1

  /* при переходе через год */
  if datediff(ww,@aDate1,@aDate2) < 2 
     if datepart(isowk,@aDate1) = datepart(isowk,@aDate2) 
        return 1
   
  return 0

end