CREATE function [dbo].[MNT_NEXT_SNOOZE_DATE](@aDate datetime, @periodType int)
returns datetime with schemabinding as 
begin
  
  if @periodType = 10 /*Day*/
    return dateadd(day,1,@aDate) 
  else if @periodType = 20 /*Week*/
    return dateadd(day,7,@aDate)
  else if @periodType = 30 /*Month*/
    return dateadd(month,1,@aDate) 
  else if @periodType = 35 /* 2 month*/
    return dateadd(month,2,@aDate) 
  else if @periodType = 40 /*Quarter*/
    return dateadd(month,3,@aDate)   
  else if @periodType = 42 /* 4 months*/
    return dateadd(month,4,@aDate)   
  else if @periodType = 45 /*Half a Year*/
    return dateadd(month,6,@aDate)   
  else if @periodType = 50 /*Year*/
    return dateadd(year,1,@aDate) 
  else if @periodType = 60 /*2 Years*/
    return dateadd(year,2,@aDate) 
  else if @periodType = 70 /*3 Years*/
    return dateadd(year,3,@aDate)   
  else if @periodType = 80 /*4 Years*/
    return dateadd(year,3,@aDate)     
  else if @periodType = 90 /*5 Years*/
    return dateadd(year,5,@aDate)     
  else if @periodType = 100 /*6 Years*/
    return dateadd(year,6,@aDate)     
  else if @periodType = 110 /*7 Years*/
    return dateadd(year,7,@aDate)     
  else if @periodType = 120 /*8 Years*/
    return dateadd(year,8,@aDate)     
/* новые
12	3 Days
13	4 Days
14	5 Days
15	6 Days
21	2 Weeks
22	3 Weeks
  */  
  else if @periodType = 12 /*3 Days*/
    return dateadd(day,3,@aDate)     
  else if @periodType = 13 /*4 Days*/
    return dateadd(day,4,@aDate)     
  else if @periodType = 14 /*5 Days*/
    return dateadd(day,5,@aDate)     
  else if @periodType = 15 /*6 Days*/
    return dateadd(day,6,@aDate)     
  else if @periodType = 21 /*2 Weeks*/
    return dateadd(day,14,@aDate)     
  else if @periodType = 22 /*3 Weeks*/
    return dateadd(day,21,@aDate)     
  else if @periodType = 24 /*5 Weeks*/
    return dateadd(day,35,@aDate)     

-- KB3310 29.06.2022    
  else if @periodType = 47 /*8 month*/
    return dateadd(month,8,@aDate)
  
  return null
  
end