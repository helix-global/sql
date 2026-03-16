CREATE function [dbo].[COM_ONLY_SHORTABS_BETWEEN](@aEmplID int, @aDBeg datetime, @aDEnd datetime, @aMode int)
returns int
as
begin
/*если между @aDBeg и @aDEnd только утвержденные короткие отсутствия - вернуть 1*/  
/*используется в COM_THIS_WEEK_ONLY_VACATION */

if @aDBeg > @aDEnd
  return 0

/*1 простой вариант: одно короткое отсутствие начато до @aDBeg и закончено после @aDEnd */

if exists (select A.ID 
             from COM_VACATION A with (nolock)
             where A.EMPLID = @aEmplID
               and A.S_S in (1000141,2130051) /*approved*/
               and A.VACATIONTYPE = 30 /* sh.abs. */
               and A.DBEG > dateadd(day,-2,@aDBeg)
               and A.DBEG < dateadd(day, 2,@aDEnd)
               and dbo.COM_VACATION_DBEG3(A.ID) <= @aDBeg
               and dbo.COM_VACATION_DEND3(A.ID) >= @aDEnd
           )
           return 1    


/*2 TODO? несколько последовательных коротких отсутствий (насколько реально?) */


return 0

end;