CREATE function [dbo].[COM_IS_VACATIONDAY](@dd datetime,@aEmplID int)
returns int as 
begin
   
   /*
   возвращает 1 - полный день отпуск
              2 - частичный отпуск
              0 - нет отпусков 
   */
   declare @ddd date = cast(@dd as date)

   if exists (select A.ID
                from COM_VACATION A with (nolock)
               where A.EMPLID = @aEmplID
                 and A.DBEG <= @ddd 
                 and isnull(A.DEND,A.DBEG) >= @ddd
                 and A.VACATIONTYPE not in (30,80,200)
                 and isnull(A.PERIODTYPE,1) = 1
                 and A.S_S in (1000141,2130051) /*approved*/)
         return 1
         
   if exists (select A.ID
                from COM_VACATION A with (nolock)
               where A.EMPLID = @aEmplID
                 and A.DBEG <= @ddd
                 and isnull(A.DEND,A.DBEG) >= @ddd
                 and A.S_S in (1000141,2130051) /*approved*/)
         return 2


     
     
   return 0  

end