CREATE function [dbo].[COM_IS_VACATIONDAY2](@dd datetime,@aEmplID int)
returns int as 
begin
   
   /*
   возвращает 1 - полный день отпуск
              2 - отпуск утро
              3 - отпуск вечер 
              0 - нет отпусков 
              короткие отсутствия не считаются отпуском
   */
   declare @ddd date = cast(@dd as date)

   if exists (select A.ID
                from COM_VACATION A with (nolock)
               where A.EMPLID = @aEmplID
                 and A.S_S in (1000141,2130051) /*approved*/
                 and A.VACATIONTYPE not in (30,80,200)
                 and A.DBEG <= @ddd 
                 and isnull(A.DEND,A.DBEG) >= @ddd
                 and isnull(A.PERIODTYPE,1) = 1
                 )
         return 1
         
   declare @forenoon int = 0
   declare @afternoon int = 0      
         
   if exists (select A.ID
                from COM_VACATION A with (nolock)
               where A.EMPLID = @aEmplID
                 and A.S_S in (1000141,2130051) /*approved*/
                 and A.VACATIONTYPE not in (30,80,200)
                 and A.DBEG <= @ddd
                 and isnull(A.DEND,A.DBEG) >= @ddd
                 and isnull(A.PERIODTYPE,1) = 2 /*forenoon*/
                 )
         set @forenoon = 1

   if exists (select A.ID
                from COM_VACATION A with (nolock)
               where A.EMPLID = @aEmplID
                 and A.S_S in (1000141,2130051) /*approved*/
                 and A.VACATIONTYPE not in (30,80,200)
                 and A.DBEG <= @ddd
                 and isnull(A.DEND,A.DBEG) >= @ddd
                 and isnull(A.PERIODTYPE,1) = 3 /*afternoon*/
                 )
         set @afternoon = 1


   if @forenoon = 1 and @afternoon = 1
     return 1
     
   if @forenoon = 1
     return 2  
     
   if @afternoon = 1
     return 3     
     
     
   return 0  

end