CREATE function [dbo].[COM_IS_VACATION_TIME](@aDT datetime, @aEmplID int)
returns int as 
begin
   
   if exists  (select ID from
                 (
                   select A.ID 
                         ,dbo.COM_VACATION_DBEG3(A.ID) as VDBEG
                         ,dbo.COM_VACATION_DEND3(A.ID) as VDEND
                     from COM_VACATION A with (nolock) 
                    where A.EMPLID = @aEmplID 
                      and A.DBEG <= @aDT
                      and dateadd(day,1,isnull(A.DEND,A.DBEG)) > @aDT
                      and A.S_S in (1000141,2130051) /*approved*/
                      and A.VACATIONTYPE not in (30,80) /* короткое отсутствие не запрещает поскольку не закреплено официально ? */
                 ) M
               where M.VDBEG <= @aDT
                 and M.VDEND > @aDT
              )
      return 1
     
   
   return 0

end